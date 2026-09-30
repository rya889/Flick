import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../models/reader_sync.dart';
import '../services/book_pages.dart';
import '../services/catalog_store.dart';
import '../services/short_builder.dart';
import '../services/library_access.dart';
import '../services/progress_bridge.dart';
import '../services/plus_service.dart';
import '../services/tldr_api.dart';
import '../services/tts_voice.dart';

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
  String? bootstrapError;
  /// Library-first: do not dump users into an autoplaying Now feed.
  int tabIndex = 1;
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

  bool playing = false;
  bool muted = true;
  bool listening = false;
  bool showHeartBurst = false;
  bool plusActive = false;
  bool tldrLoading = false;
  String? tldrError;
  TldrHealth? tldrHealth;
  double playbackSpeed = 1.0;
  SyncTarget syncTarget = SyncTarget.device;
  DateTime? lastLibraryBackup;
  Map<String, ReaderLocation> readerLocations = {};
  double readerFontSize = 18;
  ReaderPaper readerPaper = ReaderPaper.paper;
  bool readerFollowAlong = false;
  bool readerOpen = false;
  int readerSpokenWord = -1;
  int readerPageFinishedGen = 0;
  int _readerSpeakGen = 0;
  bool _readerUtterance = false;
  int listenSecondsToday = 0;
  String listenDay = '';
  int karaokeWord = -1;

  Timer? _karaokeTimer;
  Timer? _listenTimer;
  final Set<String> _aiInflight = {};
  final Set<String> _aiDone = {};
  bool _ttsConfigured = false;
  bool _ttsHandlersInstalled = false;
  int _ttsSpeakBaseWordIndex = 0;
  Map<String, String>? _ttsVoice;
  String? listenVoiceLabel;
  bool listenVoiceIsBasic = true;
  List<SpokenVoice> listenVoices = const [];

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

  bool get listenCapped => false;

  void reportBootstrapError(Object error) {
    bootstrapError = error.toString();
    ready = false;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    await _store.init();
    try {
      await _plus.init();
    } catch (e, st) {
      debugPrint('Flick Plus init failed (non-fatal): $e\n$st');
    }
    // Migrate legacy Drift plusDemo flag into PlusService once.
    if (!_plus.plusActive && await _store.plusDemo) {
      try {
        await _plus.setDemo(true);
      } catch (e, st) {
        debugPrint('Flick Plus demo migrate failed: $e\n$st');
      }
    }
    plusActive = _plus.plusActive;
    themePreference = await _store.themePreference;
    playbackSpeed = await _store.playbackSpeed;
    syncTarget = await _store.syncTarget;
    lastLibraryBackup = await _store.lastLibraryBackup;
    readerLocations = await _store.loadReaderLocations();
    readerFontSize = await _store.readerFontSize;
    readerPaper = await _store.readerPaper;
    readerFollowAlong = await _store.readerFollowAlong;
    contentMode = ContentMode.full;
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

    unawaited(_refreshTldrHealth());

    if (books.isEmpty) {
      await seedSamples();
    }

    tabIndex = 1;
    playing = false;
    ready = true;
    notifyListeners();

    // Heavy migration after first frame — must not block or crash launch.
    unawaited(_refreshExtractiveTldrInBackground());
  }

  Future<void> _refreshExtractiveTldrInBackground() async {
    if (books.isEmpty) return;
    try {
      await _store.refreshExtractiveTldrIfNeeded(books, shortsByBook);
      for (final book in books) {
        shortsByBook[book.id] = await _store.loadShorts(book.id);
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('Flick extractive TLDR refresh failed (non-fatal): $e\n$st');
    }
  }

  Future<void> _refreshTldrHealth() async {
    tldrHealth = await _tldrApi.health();
    notifyListeners();
  }

  Future<void> _configureTts() async {
    if (_ttsConfigured) return;
    try {
      // iPhone silent switch mutes ambient; playback category is required for Listen.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }
      await _tts.setLanguage('en-US');
      await _preferNaturalVoice();
      // iOS speech rate is ~0.0–1.0 (0.5 ≈ normal). Scale mildly with playbackSpeed.
      final rate = (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
          ? (0.45 * playbackSpeed).clamp(0.3, 0.7)
          : 0.45 * playbackSpeed;
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _installTtsHandlers();
      _ttsConfigured = true;
    } catch (e, st) {
      debugPrint('Flick TTS configure failed: $e\n$st');
    }
  }

  Future<void> _preferNaturalVoice() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;
      final voices = <Map<String, String>>[];
      for (final item in raw) {
        if (item is! Map) continue;
        voices.add({
          for (final entry in item.entries)
            entry.key.toString(): entry.value.toString(),
        });
      }
      final picked = pickSpokenVoice(voices);
      listenVoices = [
        for (final voice in voices) spokenVoiceFromMap(voice),
      ].where((voice) => voice.locale.toLowerCase().startsWith('en')).toList()
        ..sort(
          (a, b) => spokenVoiceSortScore(b).compareTo(spokenVoiceSortScore(a)),
        );
      if (picked == null) return;
      await _applySpokenVoice(picked);
    } catch (e, st) {
      debugPrint('Flick TTS voice selection failed: $e\n$st');
    }
  }

  Future<void> _applySpokenVoice(SpokenVoice picked) async {
    _ttsVoice = picked.toTtsVoice();
    listenVoiceLabel = picked.natural ? picked.name : '${picked.name} · basic';
    listenVoiceIsBasic = !picked.natural;
    await _tts.setVoice(_ttsVoice!);
    debugPrint(
      'Flick TTS voice: ${picked.name} natural=${picked.natural} id=${picked.identifier}',
    );
  }

  Future<void> prepareListenVoices() => _configureTts();

  Future<void> useListenVoice(SpokenVoice voice) async {
    await _configureTts();
    await _applySpokenVoice(voice);
    notifyListeners();
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
    // Stay on Library — do not auto-open / autoplay a sample.
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
    final resume = shortIndex ??
        await _shortIndexForOpen(book, shorts);
    queue = shorts.map((s) => FeedItem(book: book, short: s)).toList();
    queueIndex = resume.clamp(0, max(0, queue.length - 1));
    await _store.setLastBookId(book.id);
    tabIndex = 0;
    playing = false;
    _readerUtterance = false;
    _karaokeTimer?.cancel();
    unawaited(_tts.stop());
    _resetKaraoke();
    notifyListeners();
    unawaited(ensureAiTldrForCurrent());
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
    if (_blocked(BookSource.paste)) return;
    final book = await _store.importText(title: title, text: text);
    books = [book, ...books.where((b) => b.id != book.id)];
    shortsByBook[book.id] = await _store.loadShorts(book.id);
    await openBook(book);
    tabIndex = 0;
    notifyListeners();
  }

  Future<void> importTxtFile(String fileName, String text) async {
    if (_blocked(BookSource.txt)) return;
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
    if (_blocked(BookSource.epub)) return;
    final book = await _store.importEpubBytes(fileName: fileName, bytes: bytes);
    books = [book, ...books.where((b) => b.id != book.id)];
    shortsByBook[book.id] = await _store.loadShorts(book.id);
    await openBook(book);
    tabIndex = 0;
    notifyListeners();
  }

  void setTab(int index) {
    if (index == 2) index = 0;
    tabIndex = index;
    if (index != 0) {
      playing = false;
      _readerUtterance = false;
      _karaokeTimer?.cancel();
      unawaited(_tts.stop());
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
    contentMode = ContentMode.full;
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
    unawaited(_mirrorReaderFromCurrentShort());
    _resetKaraoke();
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
    unawaited(_mirrorReaderFromCurrentShort());
    _resetKaraoke();
    notifyListeners();
    unawaited(ensureAiTldrForCurrent());
  }

  void prevShort() {
    if (queue.isEmpty || queueIndex <= 0) return;
    queueIndex -= 1;
    _persistProgress();
    unawaited(_mirrorReaderFromCurrentShort());
    _resetKaraoke();
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
      unawaited(_mirrorReaderFromCurrentShort());
      _resetKaraoke();
      notifyListeners();
    }
  }

  void togglePlay() {
    playing = !playing;
    if (playing) {
      _resumePlayback();
    } else {
      _pausePlayback();
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

  Future<List<StoredChapterSpan>> chapterSpans(String bookId) =>
      _store.loadChapterSpans(bookId);

  Future<void> saveReaderLocation(ReaderLocation location) async {
    readerLocations[location.bookId] = location;
    await _store.saveReaderLocations(readerLocations);
    await _mirrorShortFromReader(location);
    notifyListeners();
  }

  LibraryBlock? blockFor(BookSource source) {
    return blockImport(
      source,
      premium: plusActive,
      importedBooks: countedImports(books),
    );
  }

  int get importedBookCount => countedImports(books);

  int get libraryBookLimit => bookLimitFor(premium: plusActive);

  bool _blocked(BookSource source) => blockFor(source) != null;

  Future<void> setReaderFollowAlong(bool value) async {
    readerFollowAlong = value;
    await _store.setReaderFollowAlong(value);
    if (!value) await stopReaderSpeech();
    notifyListeners();
  }

  void beginReaderSession() {
    readerOpen = true;
    playing = false;
    _karaokeTimer?.cancel();
    unawaited(_tts.stop());
    notifyListeners();
  }

  void endReaderSession(String bookId) {
    readerOpen = false;
    _readerSpeakGen += 1;
    _readerUtterance = false;
    readerSpokenWord = -1;
    unawaited(_tts.stop());
    final prog = progress[bookId];
    if (prog != null && activeBook?.id == bookId && queue.isNotEmpty) {
      queueIndex = prog.shortIndex.clamp(0, queue.length - 1);
    }
    playing = false;
    _karaokeTimer?.cancel();
    notifyListeners();
  }

  int get readerSpeakGen => _readerSpeakGen;

  Future<void> speakReaderPage(String text) async {
    final spoken = text.trim();
    if (spoken.isEmpty || muted) return;
    final gen = ++_readerSpeakGen;
    _readerUtterance = false;
    readerSpokenWord = 0;
    try {
      await _configureTts();
      await _tts.stop();
      if (gen != _readerSpeakGen) return;
      _readerUtterance = true;
      readerSpokenWord = 0;
      notifyListeners();
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSpeechRate((0.5 * playbackSpeed).clamp(0.35, 0.65));
      } else {
        await _tts.setSpeechRate(0.5 * playbackSpeed);
      }
      if (_ttsVoice != null) await _tts.setVoice(_ttsVoice!);
      await _tts.speak(spoken);
    } catch (e, st) {
      debugPrint('Flick reader TTS failed: $e\n$st');
    }
  }

  Future<void> stopReaderSpeech() async {
    _readerSpeakGen += 1;
    _readerUtterance = false;
    readerSpokenWord = -1;
    await _tts.stop();
  }

  Future<void> setReaderFontSize(double value) async {
    readerFontSize = value.clamp(14, 32);
    await _store.setReaderFontSize(readerFontSize);
    notifyListeners();
  }

  Future<void> setReaderPaper(ReaderPaper value) async {
    readerPaper = value;
    await _store.setReaderPaper(value);
    notifyListeners();
  }

  Future<void> setSyncTarget(SyncTarget value) async {
    syncTarget = value;
    await _store.setSyncTarget(value);
    notifyListeners();
  }

  LibrarySnapshot librarySnapshot() {
    return LibrarySnapshot(
      exportedAt: DateTime.now(),
      books: books,
      shortsByBook: shortsByBook,
      progress: progress,
      reader: readerLocations,
      hearts: hearts,
      saves: saves,
    );
  }

  Future<String> exportLibraryJson() async {
    final json = librarySnapshot().encode();
    lastLibraryBackup = DateTime.now();
    await _store.setLastLibraryBackup(lastLibraryBackup!);
    notifyListeners();
    return json;
  }

  Future<String> restoreLibraryJson(String raw) async {
    final incoming = LibrarySnapshot.decode(raw);
    final plan = planLibraryMerge(
      localBooks: books,
      localProgress: progress,
      localReader: readerLocations,
      localHearts: hearts,
      localSaves: saves,
      incoming: incoming,
    );
    for (final book in plan.booksToAdd) {
      var shorts = plan.shortsForNewBooks[book.id] ?? const <ShortSegment>[];
      if (shorts.isEmpty && book.text.trim().isNotEmpty) {
        shorts = buildShorts(book);
      }
      await _store.importBookBundle(book, shorts);
      shortsByBook[book.id] = shorts;
    }
    if (plan.booksToAdd.isNotEmpty) {
      books = [...plan.booksToAdd, ...books];
    }
    progress = plan.progress;
    readerLocations = plan.reader;
    hearts = plan.hearts;
    saves = plan.saves;
    await _store.saveProgress(progress);
    await _store.saveReaderLocations(readerLocations);
    await _store.saveHearts(hearts);
    await _store.saveSaves(saves);
    notifyListeners();
    return 'Added ${plan.booksToAdd.length} books. '
        'Updated ${plan.readerUpdates} reader places and '
        '${plan.progressUpdates} Flick positions.';
  }

  Future<void> setPlaybackSpeed(double value) async {
    playbackSpeed = value.clamp(0.5, 3.0);
    await _store.setPlaybackSpeed(playbackSpeed);
    await _configureTts();
    // Restart playback so the new rate applies immediately (not next short).
    final from = karaokeWord >= 0 ? karaokeWord : 0;
    _karaokeTimer?.cancel();
    if (playing) {
      if (_playbackUsesTts) {
        unawaited(_speakFromWord(from));
      } else {
        _startKaraokeTimer(fromIndex: from > 0 ? from - 1 : -1);
      }
    } else {
      karaokeWord = -1;
    }
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
      _karaokeTimer?.cancel();
      if (playing) {
        await _speakFromWord(karaokeWord >= 0 ? karaokeWord : 0);
      }
      _startListenMeter();
    } else {
      muted = true;
      listening = false;
      await _tts.stop();
      _stopListenMeter();
      if (playing) {
        _startKaraokeTimer(fromIndex: karaokeWord >= 0 ? karaokeWord : -1);
      }
    }
    notifyListeners();
    return true;
  }

  bool get _playbackUsesTts => listening && !muted;

  int _wordIndexAtOffset(String text, int start) {
    if (text.isEmpty) return 0;
    final clamped = start.clamp(0, text.length);
    final before = text.substring(0, clamped);
    final count =
        before.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return max(0, count - 1);
  }

  String _textFromWordIndex(int fromIndex) {
    final words = displayWords;
    if (words.isEmpty) return '';
    if (fromIndex <= 0) return displayText;
    if (fromIndex >= words.length) return '';
    return words.sublist(fromIndex).join(' ');
  }

  void _pausePlayback() {
    _karaokeTimer?.cancel();
    if (_playbackUsesTts) {
      unawaited(_tts.stop());
    }
  }

  void _resumePlayback() {
    if (_playbackUsesTts) {
      _karaokeTimer?.cancel();
      final from = karaokeWord >= 0 ? karaokeWord : 0;
      unawaited(_speakFromWord(from));
    } else {
      _startKaraokeTimer(
        fromIndex: karaokeWord >= 0 ? karaokeWord - 1 : -1,
      );
    }
  }

  Future<void> _speakCurrent() async {
    await _speakFromWord(0);
  }

  Future<void> _speakFromWord(int fromWordIndex) async {
    if (muted || listenCapped) return;
    final text = _textFromWordIndex(fromWordIndex);
    if (text.isEmpty) return;
    try {
      await _configureTts();
      _ttsSpeakBaseWordIndex = fromWordIndex.clamp(0, max(0, displayWords.length - 1));
      await _tts.stop();
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
        await _tts.setSpeechRate((0.5 * playbackSpeed).clamp(0.35, 0.65));
      } else {
        await _tts.setSpeechRate(0.45 * playbackSpeed);
      }
      if (_ttsVoice != null) {
        await _tts.setVoice(_ttsVoice!);
      }
      if (fromWordIndex <= 0) {
        karaokeWord = -1;
      }
      final result = await _tts.speak(text);
      debugPrint('Flick TTS speak result: $result');
    } catch (e, st) {
      debugPrint('Flick TTS speak failed: $e\n$st');
    }
  }

  void _installTtsHandlers() {
    if (_ttsHandlersInstalled) return;
    _ttsHandlersInstalled = true;

    _tts.setStartHandler(() {
      if (_readerUtterance) {
        readerSpokenWord = 0;
        notifyListeners();
        return;
      }
      if (!_playbackUsesTts || !playing) return;
      if (karaokeWord < 0) {
        karaokeWord = _ttsSpeakBaseWordIndex;
        notifyListeners();
      }
    });

    _tts.setProgressHandler((text, start, end, word) {
      if (_readerUtterance) {
        final local = _wordIndexAtOffset(text, start);
        if (local != readerSpokenWord) {
          readerSpokenWord = local;
          notifyListeners();
        }
        return;
      }
      if (!_playbackUsesTts || !playing) return;
      final local = _wordIndexAtOffset(text, start);
      final next = _ttsSpeakBaseWordIndex + local;
      if (next != karaokeWord) {
        karaokeWord = next;
        notifyListeners();
      }
    });

    _tts.setCompletionHandler(() {
      if (_readerUtterance) {
        _readerUtterance = false;
        readerPageFinishedGen = _readerSpeakGen;
        notifyListeners();
        return;
      }
      if (!playing) return;
      if (!_playbackUsesTts) return;
      _karaokeTimer?.cancel();
      karaokeWord = max(0, displayWords.length - 1);
      notifyListeners();
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (playing && _playbackUsesTts) nextShort();
      });
    });
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

  Future<bool> purchasePremium() async {
    final ok = await _plus.purchasePremium();
    plusActive = _plus.plusActive;
    await _store.setPlusDemo(_plus.demoActive);
    notifyListeners();
    return ok;
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

  Future<int> _shortIndexForOpen(
    LibraryBook book,
    List<ShortSegment> shorts,
  ) async {
    final prog = progress[book.id];
    final reader = readerLocations[book.id];
    if (reader != null &&
        (prog == null || reader.updatedAt.isAfter(prog.updatedAt))) {
      final chapters = chaptersForBook(
        book,
        stored: await _store.loadChapterSpans(book.id),
      );
      final index = shortIndexAtPlace(
        shortPlaces(chapters, shorts),
        reader.chapterIndex,
        reader.charOffset,
      );
      if (index != null) return index;
    }
    return prog?.shortIndex ?? 0;
  }

  Future<void> _mirrorShortFromReader(ReaderLocation location) async {
    final book = books.cast<LibraryBook?>().firstWhere(
          (b) => b?.id == location.bookId,
          orElse: () => null,
        );
    if (book == null) return;
    final shorts = shortsByBook[book.id] ?? await _store.loadShorts(book.id);
    shortsByBook[book.id] = shorts;
    final chapters = chaptersForBook(
      book,
      stored: await _store.loadChapterSpans(book.id),
    );
    final index = shortIndexAtPlace(
      shortPlaces(chapters, shorts),
      location.chapterIndex,
      location.charOffset,
    );
    if (index == null || index < 0 || index >= shorts.length) return;
    progress[book.id] = ReadingProgress(
      bookId: book.id,
      shortId: shorts[index].id,
      shortIndex: index,
      updatedAt: location.updatedAt,
    );
    await _store.saveProgress(progress);
  }

  Future<void> _mirrorReaderFromCurrentShort() async {
    final item = current;
    if (item == null || playMode != PlayMode.story || readerOpen) return;
    final chapters = chaptersForBook(
      item.book,
      stored: await _store.loadChapterSpans(item.book.id),
    );
    final loc = readerLocationForShort(
      bookId: item.book.id,
      chapters: chapters,
      shorts: shortsByBook[item.book.id] ?? [item.short],
      shortIndex: item.short.index,
      updatedAt: DateTime.now(),
    );
    if (loc == null) return;
    readerLocations[item.book.id] = loc;
    await _store.saveReaderLocations(readerLocations);
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
    unawaited(_tts.stop());
    if (playing) _startKaraoke();
  }

  void _startKaraoke() {
    _karaokeTimer?.cancel();
    if (_playbackUsesTts) {
      unawaited(_speakCurrent());
      return;
    }
    _startKaraokeTimer(fromIndex: -1);
  }

  void _startKaraokeTimer({required int fromIndex}) {
    _karaokeTimer?.cancel();
    karaokeWord = fromIndex;
    final words = displayWords;
    if (words.isEmpty) return;
    // ~420ms/word at 1x; allow up to 3x (~140ms) without clamping away the gain.
    final msPerWord = (420 / playbackSpeed).round().clamp(100, 900);
    _karaokeTimer = Timer.periodic(Duration(milliseconds: msPerWord), (timer) {
      if (!playing || _playbackUsesTts) return;
      karaokeWord += 1;
      notifyListeners();
      if (karaokeWord >= words.length - 1) {
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (playing && !_playbackUsesTts) nextShort();
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
