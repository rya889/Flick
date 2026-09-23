import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../services/catalog_store.dart';
import '../services/plus_service.dart';
import '../services/tldr_api.dart';

class FeedItem {
  FeedItem({required this.book, required this.short});
  final LibraryBook book;
  final ShortSegment short;
}

class FlickController extends ChangeNotifier {
  FlickController(
    this._store, {
    PlusService? plus,
    TldrApi? tldrApi,
  })  : _plus = plus ?? PlusService(),
        _tldrApi = tldrApi ?? TldrApi();

  final CatalogStore _store;
  final PlusService _plus;
  final TldrApi _tldrApi;
  final FlutterTts _tts = FlutterTts();
  final _rng = Random();

  bool ready = false;
  int tabIndex = 0;
  PlayMode playMode = PlayMode.story;
  ContentMode contentMode = ContentMode.full;
  TldrSubmode tldrSubmode = TldrSubmode.condense;
  ThemePreference themePreference = ThemePreference.system;

  List<LibraryBook> books = [];
  Map<String, List<ShortSegment>> shortsByBook = {};
  Map<String, ReadingProgress> progress = {};
  Set<String> hearts = {};
  Set<String> saves = {};

  LibraryBook? activeBook;
  List<FeedItem> queue = [];
  int queueIndex = 0;

  bool playing = true;
  bool muted = true;
  bool listening = false;
  bool showHeartBurst = false;
  bool plusActive = false;
  bool tldrLoading = false;
  String? tldrError;
  TldrHealth? tldrHealth;
  double playbackSpeed = 1.0;
  int listenSecondsToday = 0;
  String listenDay = '';
  int karaokeWord = -1;

  Timer? _karaokeTimer;
  Timer? _listenTimer;
  final Set<String> _aiInflight = {};
  final Set<String> _aiDone = {};

  PlusService get plusService => _plus;

  static const freeListenCapSeconds = 60 * 60;

  FeedItem? get current =>
      queue.isEmpty || queueIndex < 0 || queueIndex >= queue.length
          ? null
          : queue[queueIndex];

  String get displayText {
    final item = current;
    if (item == null) return '';
    if (contentMode == ContentMode.full) return item.short.original;
    switch (tldrSubmode) {
      case TldrSubmode.condense:
        return item.short.condense;
      case TldrSubmode.summary:
        return item.short.summary;
      case TldrSubmode.quotes:
        return item.short.quotes;
    }
  }

  List<String> get displayWords =>
      displayText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  int get chapterCount {
    final item = current;
    if (item == null) return 1;
    final shorts = shortsByBook[item.book.id] ?? [];
    if (shorts.isEmpty) return 1;
    return shorts.map((s) => s.chapterIndex).reduce(max) + 1;
  }

  int get currentChapterIndex => current?.short.chapterIndex ?? 0;

  int get listenRemainingSeconds {
    if (plusActive) return freeListenCapSeconds;
    return max(0, freeListenCapSeconds - listenSecondsToday);
  }

  bool get listenCapped => !plusActive && listenSecondsToday >= freeListenCapSeconds;

  Future<void> bootstrap() async {
    await _store.init();
    await _plus.init();
    // Migrate legacy Drift plusDemo flag into PlusService once.
    if (!_plus.plusActive && await _store.plusDemo) {
      await _plus.setDemo(true);
    }
    plusActive = _plus.plusActive;
    themePreference = await _store.themePreference;
    playbackSpeed = await _store.playbackSpeed;
    books = await _store.loadBooks();
    progress = await _store.loadProgress();
    hearts = await _store.loadHearts();
    saves = await _store.loadSaves();
    final listen = await _store.loadListen();
    listenDay = listen.day;
    listenSecondsToday = listen.day == _todayKey() ? listen.seconds : 0;
    if (listen.day != _todayKey()) {
      listenDay = _todayKey();
      listenSecondsToday = 0;
      await _store.saveListen(listenDay, 0);
    }

    for (final book in books) {
      shortsByBook[book.id] = await _store.loadShorts(book.id);
    }

    await _configureTts();
    unawaited(_refreshTldrHealth());

    if (books.isEmpty) {
      await seedSamples();
    } else {
      await resumeLast();
    }

    ready = true;
    notifyListeners();
    _startKaraoke();
    unawaited(ensureAiTldrForCurrent());
  }

  Future<void> _refreshTldrHealth() async {
    tldrHealth = await _tldrApi.health();
    notifyListeners();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setSpeechRate(0.45 * playbackSpeed);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      // Web / unsupported platforms may fail; Listen stays optional.
    }
  }

  Future<void> seedSamples() async {
    final imported = <LibraryBook>[];
    for (final sample in sampleLibrary) {
      if (books.any((b) => b.id == sample.id)) continue;
      imported.add(await _store.importSample(sample));
    }
    books = [...imported, ...books];
    for (final book in imported) {
      shortsByBook[book.id] = await _store.loadShorts(book.id);
    }
    if (imported.isNotEmpty) {
      await openBook(imported.first);
    }
  }

  Future<void> resumeLast() async {
    final lastId = await _store.lastBookId;
    final book = books.cast<LibraryBook?>().firstWhere(
          (b) => b?.id == lastId,
          orElse: () => books.isEmpty ? null : books.first,
        );
    if (book != null) await openBook(book);
  }

  Future<void> openBook(LibraryBook book, {int? shortIndex}) async {
    activeBook = book;
    playMode = PlayMode.story;
    final shorts = shortsByBook[book.id] ?? await _store.loadShorts(book.id);
    shortsByBook[book.id] = shorts;
    final resume = shortIndex ?? progress[book.id]?.shortIndex ?? 0;
    queue = shorts.map((s) => FeedItem(book: book, short: s)).toList();
    queueIndex = resume.clamp(0, max(0, queue.length - 1));
    await _store.setLastBookId(book.id);
    _resetKaraoke();
    notifyListeners();
  }

  Future<void> addSample(SampleMeta sample) async {
    if (books.any((b) => b.id == sample.id)) {
      final existing = books.firstWhere((b) => b.id == sample.id);
      await openBook(existing);
      tabIndex = 0;
      notifyListeners();
      return;
    }
    final book = await _store.importSample(sample);
    books = [book, ...books];
    shortsByBook[book.id] = await _store.loadShorts(book.id);
    await openBook(book);
    tabIndex = 0;
    notifyListeners();
  }

  Future<void> importPaste(String title, String text) async {
    final book = await _store.importText(title: title, text: text);
    books = [book, ...books.where((b) => b.id != book.id)];
    shortsByBook[book.id] = await _store.loadShorts(book.id);
    await openBook(book);
    tabIndex = 0;
    notifyListeners();
  }

  Future<void> importTxtFile(String fileName, String text) async {
    final title = fileName.replaceAll(RegExp(r'\.txt$', caseSensitive: false), '');
    final book = await _store.importText(
      title: title,
      text: text,
      source: BookSource.txt,
      hue: 180 + _rng.nextInt(80).toDouble(),
    );
    books = [book, ...books.where((b) => b.id != book.id)];
    shortsByBook[book.id] = await _store.loadShorts(book.id);
    await openBook(book);
    tabIndex = 0;
    notifyListeners();
  }

  Future<void> importEpubFile(String fileName, Uint8List bytes) async {
    final book = await _store.importEpubBytes(fileName: fileName, bytes: bytes);
    books = [book, ...books.where((b) => b.id != book.id)];
    shortsByBook[book.id] = await _store.loadShorts(book.id);
    await openBook(book);
    tabIndex = 0;
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    if (index == 2) {
      enterBounce();
    }
    notifyListeners();
  }

  void setPlayMode(PlayMode mode) {
    if (mode == PlayMode.bounce) {
      enterBounce();
    } else if (activeBook != null) {
      openBook(activeBook!);
    } else {
      playMode = PlayMode.story;
      notifyListeners();
    }
  }

  void enterBounce() {
    if (books.length < 3) {
      playMode = PlayMode.bounce;
      queue = [];
      queueIndex = 0;
      tabIndex = 0;
      notifyListeners();
      return;
    }
    playMode = PlayMode.bounce;
    contentMode = ContentMode.tldr;
    queue = _buildBounceQueue();
    queueIndex = 0;
    tabIndex = 0;
    _resetKaraoke();
    notifyListeners();
  }

  List<FeedItem> _buildBounceQueue() {
    final items = <FeedItem>[];
    for (final book in books) {
      final shorts = shortsByBook[book.id] ?? [];
      for (final short in shorts.take(6)) {
        items.add(FeedItem(book: book, short: short));
      }
    }
    items.shuffle(_rng);
    // Prefer hearted / saved near the front
    items.sort((a, b) {
      final as = (hearts.contains(a.short.id) ? 2 : 0) +
          (saves.contains(a.short.id) ? 1 : 0);
      final bs = (hearts.contains(b.short.id) ? 2 : 0) +
          (saves.contains(b.short.id) ? 1 : 0);
      return bs.compareTo(as);
    });
    // Light reshuffle of non-hearted to keep variety
    if (items.length > 4) {
      final head = items.take(3).toList();
      final tail = items.skip(3).toList()..shuffle(_rng);
      return [...head, ...tail];
    }
    return items;
  }

  void goToIndex(int index) {
    if (queue.isEmpty) return;
    queueIndex = index.clamp(0, queue.length - 1);
    _persistProgress();
    _resetKaraoke();
    if (listening && !muted) {
      unawaited(_speakCurrent());
    }
    notifyListeners();
    unawaited(ensureAiTldrForCurrent());
  }

  void nextShort() {
    if (queue.isEmpty) return;
    if (queueIndex >= queue.length - 1) {
      if (playMode == PlayMode.bounce) {
        queue = _buildBounceQueue();
        queueIndex = 0;
      } else {
        return;
      }
    } else {
      queueIndex += 1;
    }
    _persistProgress();
    _resetKaraoke();
    if (listening && !muted) {
      unawaited(_speakCurrent());
    }
    notifyListeners();
    unawaited(ensureAiTldrForCurrent());
  }

  void prevShort() {
    if (queue.isEmpty || queueIndex <= 0) return;
    queueIndex -= 1;
    _persistProgress();
    _resetKaraoke();
    if (listening && !muted) {
      unawaited(_speakCurrent());
    }
    notifyListeners();
    unawaited(ensureAiTldrForCurrent());
  }

  void jumpChapter(int delta) {
    final item = current;
    if (item == null || playMode != PlayMode.story) return;
    final shorts = shortsByBook[item.book.id] ?? [];
    final targetChapter = (item.short.chapterIndex + delta)
        .clamp(0, chapterCount - 1);
    final idx = shorts.indexWhere((s) => s.chapterIndex == targetChapter);
    if (idx >= 0) {
      queueIndex = idx;
      _persistProgress();
      _resetKaraoke();
      notifyListeners();
    }
  }

  void togglePlay() {
    playing = !playing;
    if (playing) {
      _startKaraoke();
    } else {
      _karaokeTimer?.cancel();
    }
    notifyListeners();
  }

  void setContentMode(ContentMode mode) {
    contentMode = mode;
    _resetKaraoke();
    notifyListeners();
    if (mode == ContentMode.tldr) {
      unawaited(ensureAiTldrForCurrent());
    }
  }

  void setTldrSubmode(TldrSubmode mode) {
    tldrSubmode = mode;
    _resetKaraoke();
    notifyListeners();
    unawaited(ensureAiTldrForCurrent());
  }

  /// Plus-only: fetch AI TLDR for the current short (one passage) and cache locally.
  Future<void> ensureAiTldrForCurrent({bool force = false}) async {
    if (!plusActive || contentMode != ContentMode.tldr) return;
    final item = current;
    if (item == null) return;
    final short = item.short;
    final key = '${short.id}:${tldrSubmode.name}';
    if (_aiInflight.contains(key)) return;
    if (!force && _aiDone.contains(key)) return;

    final header = _plus.entitlementHeader;
    if (header.isEmpty) return;

    _aiInflight.add(key);
    tldrLoading = true;
    tldrError = null;
    notifyListeners();

    try {
      final result = await _tldrApi.request(
        mode: tldrSubmode,
        text: short.original,
        contentHash: short.contentHash,
        entitlementHeader: header,
        appUserId: _plus.appUserId,
      );
      if (!result.ok || result.text.isEmpty) {
        tldrError = result.error ?? result.code ?? 'AI TLDR failed';
        return;
      }

      final updated = switch (tldrSubmode) {
        TldrSubmode.condense => short.copyWith(
            condense: result.text,
            tldrSource: 'ai',
          ),
        TldrSubmode.summary => short.copyWith(
            summary: result.text,
            tldrSource: 'ai',
          ),
        TldrSubmode.quotes => short.copyWith(
            quotes: result.text,
            tldrSource: 'ai',
          ),
      };
      await _replaceShort(updated);
      _aiDone.add(key);
      _resetKaraoke();
    } catch (e) {
      tldrError = e.toString();
    } finally {
      _aiInflight.remove(key);
      tldrLoading = false;
      notifyListeners();
    }
  }

  Future<void> _replaceShort(ShortSegment updated) async {
    final list = List<ShortSegment>.from(shortsByBook[updated.bookId] ?? []);
    final idx = list.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      list[idx] = updated;
    }
    shortsByBook[updated.bookId] = list;
    for (var i = 0; i < queue.length; i++) {
      if (queue[i].short.id == updated.id) {
        queue[i] = FeedItem(book: queue[i].book, short: updated);
      }
    }
    await _store.updateShort(updated);
  }

  Future<void> setThemePreference(ThemePreference value) async {
    themePreference = value;
    await _store.setThemePreference(value);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double value) async {
    playbackSpeed = value.clamp(0.5, 3.0);
    await _store.setPlaybackSpeed(playbackSpeed);
    await _configureTts();
    // Restart karaoke so the new rate applies immediately (not next short).
    _resetKaraoke();
    notifyListeners();
  }

  void toggleHeart([String? shortId]) {
    final id = shortId ?? current?.short.id;
    if (id == null) return;
    if (hearts.contains(id)) {
      hearts.remove(id);
    } else {
      hearts.add(id);
      showHeartBurst = true;
      notifyListeners();
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        showHeartBurst = false;
        notifyListeners();
      });
    }
    unawaited(_store.saveHearts(hearts));
    notifyListeners();
  }

  void toggleSave([String? shortId]) {
    final id = shortId ?? current?.short.id;
    if (id == null) return;
    if (saves.contains(id)) {
      saves.remove(id);
    } else {
      saves.add(id);
    }
    unawaited(_store.saveSaves(saves));
    notifyListeners();
  }

  Future<void> shareCurrent() async {
    final item = current;
    if (item == null) return;
    final text =
        '"${displayText.trim()}"\n— ${item.book.title}${item.book.author != null ? ', ${item.book.author}' : ''}\n\nShared from Flick — The anti-doomscroll reader.';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<bool> toggleMute() async {
    if (muted) {
      if (listenCapped) {
        notifyListeners();
        return false;
      }
      muted = false;
      listening = true;
      await _speakCurrent();
      _startListenMeter();
    } else {
      muted = true;
      listening = false;
      await _tts.stop();
      _stopListenMeter();
    }
    notifyListeners();
    return true;
  }

  Future<void> _speakCurrent() async {
    if (muted || listenCapped) return;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.45 * playbackSpeed);
      await _tts.speak(displayText);
    } catch (_) {}
  }

  void _startListenMeter() {
    _listenTimer?.cancel();
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (muted || plusActive) return;
      listenSecondsToday += 1;
      if (listenSecondsToday >= freeListenCapSeconds) {
        muted = true;
        listening = false;
        await _tts.stop();
        _stopListenMeter();
      }
      await _store.saveListen(_todayKey(), listenSecondsToday);
      notifyListeners();
    });
  }

  void _stopListenMeter() {
    _listenTimer?.cancel();
    _listenTimer = null;
  }

  Future<void> setPlusDemo(bool value) async {
    await _plus.setDemo(value);
    plusActive = _plus.plusActive;
    await _store.setPlusDemo(value);
    notifyListeners();
    if (plusActive) {
      unawaited(ensureAiTldrForCurrent());
    }
  }

  Future<bool> purchasePlusMonthly() async {
    final ok = await _plus.purchaseMonthly();
    plusActive = _plus.plusActive;
    await _store.setPlusDemo(_plus.demoActive);
    notifyListeners();
    if (plusActive) unawaited(ensureAiTldrForCurrent());
    return ok;
  }

  Future<bool> purchasePlusYearly() async {
    final ok = await _plus.purchaseYearly();
    plusActive = _plus.plusActive;
    await _store.setPlusDemo(_plus.demoActive);
    notifyListeners();
    if (plusActive) unawaited(ensureAiTldrForCurrent());
    return ok;
  }

  Future<bool> restorePurchases() async {
    final ok = await _plus.restore();
    plusActive = _plus.plusActive;
    notifyListeners();
    if (plusActive) unawaited(ensureAiTldrForCurrent());
    return ok;
  }

  void _persistProgress() {
    final item = current;
    if (item == null || playMode != PlayMode.story) return;
    progress[item.book.id] = ReadingProgress(
      bookId: item.book.id,
      shortId: item.short.id,
      shortIndex: item.short.index,
      updatedAt: DateTime.now(),
    );
    unawaited(_store.saveProgress(progress));
    unawaited(_store.setLastBookId(item.book.id));
  }

  void _resetKaraoke() {
    karaokeWord = -1;
    _karaokeTimer?.cancel();
    if (playing) _startKaraoke();
  }

  void _startKaraoke() {
    _karaokeTimer?.cancel();
    karaokeWord = -1;
    final words = displayWords;
    if (words.isEmpty) return;
    // ~420ms/word at 1x; allow up to 3x (~140ms) without clamping away the gain.
    final msPerWord = (420 / playbackSpeed).round().clamp(100, 900);
    _karaokeTimer = Timer.periodic(Duration(milliseconds: msPerWord), (timer) {
      if (!playing) return;
      karaokeWord += 1;
      notifyListeners();
      if (karaokeWord >= words.length - 1) {
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (playing) nextShort();
        });
      }
    });
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  List<FeedItem> get savedItems {
    final out = <FeedItem>[];
    for (final book in books) {
      for (final short in shortsByBook[book.id] ?? []) {
        if (saves.contains(short.id)) {
          out.add(FeedItem(book: book, short: short));
        }
      }
    }
    return out;
  }

  @override
  void dispose() {
    _karaokeTimer?.cancel();
    _listenTimer?.cancel();
    _tts.stop();
    super.dispose();
  }
}
