import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/reader_sync.dart';
import '../services/book_pages.dart';
import '../services/page_text.dart';
import '../services/progress_bridge.dart';
import '../services/tts_voice.dart';
import '../state/flick_controller.dart';
import 'house_pro_prompt.dart';

class EbookReaderScreen extends StatefulWidget {
  const EbookReaderScreen({super.key, required this.book});

  final LibraryBook book;

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends State<EbookReaderScreen> {
  PageController? _pageController;
  List<PageSlice> _pages = const [];
  List<ReaderChapter> _chapters = const [];
  int _pageIndex = 0;
  bool _chrome = true;
  bool _loading = true;
  String? _error;
  Size? _fit;
  bool _followPlaying = false;
  int _followWord = -1;
  Timer? _followTimer;
  int _heardFinish = 0;
  int _armedGen = 0;
  FlickController? _controller;
  bool _pageTurnInFlight = false;
  DateTime _lastPageTurnAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const _pageTurnCooldown = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    _controller = context.read<FlickController>();
    _controller!.addListener(_onController);
    _controller!.beginReaderSession();
  }

  @override
  void dispose() {
    _followTimer?.cancel();
    _controller?.removeListener(_onController);
    _controller?.endReaderSession(widget.book.id);
    _pageController?.dispose();
    super.dispose();
  }

  DateTime _lastSpokenAt = DateTime.fromMillisecondsSinceEpoch(0);

  void _onController() {
    final c = _controller;
    if (c == null || !mounted || !_followPlaying) return;
    if (!c.muted &&
        c.readerSpokenWord >= 0 &&
        c.readerSpokenWord != _followWord) {
      _lastSpokenAt = DateTime.now();
      setState(() => _followWord = c.readerSpokenWord);
    }
    if (!c.readerFollowAlong || c.muted || !c.listening) return;
    if (c.readerPageFinishedGen == _heardFinish) return;
    if (c.readerPageFinishedGen != _armedGen) return;
    _heardFinish = c.readerPageFinishedGen;
    _goRelative(1);
  }

  TextStyle _style(FlickController c, _PaperColors paper) {
    return GoogleFonts.literata(
      fontSize: c.readerFontSize,
      height: 1.45,
      color: paper.ink,
    );
  }

  void _scheduleFit(Size fit) {
    final current = _fit;
    if (current != null &&
        (current.width - fit.width).abs() < 8 &&
        (current.height - fit.height).abs() < 8) {
      return;
    }
    _fit = fit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _layoutFor(fit);
    });
  }

  Future<void> _layoutFor(Size fit) async {
    final c = _controller;
    if (c == null) return;
    final current = _pages.isEmpty
        ? null
        : _pages[_pageIndex.clamp(0, _pages.length - 1)];
    try {
      final spans = await c.chapterSpans(widget.book.id);
      final chapters = chaptersForBook(widget.book, stored: spans);
      final paper = _paperColors(c.readerPaper);
      final pages = paginateBookFitted(
        chapters,
        style: _style(c, paper),
        maxWidth: fit.width,
        maxHeight: fit.height,
      );
      final saved = _locationToOpen(c, chapters);
      final index = current != null
          ? pageIndexForLocation(
              pages,
              current.chapterIndex,
              current.startInChapter,
            )
          : saved == null
              ? 0
              : pageIndexForLocation(
                  pages,
                  saved.chapterIndex,
                  saved.charOffset,
                );
      if (!mounted) return;
      _pageController?.dispose();
      setState(() {
        _chapters = chapters;
        _pages = pages;
        _pageIndex = index.clamp(0, pages.isEmpty ? 0 : pages.length - 1);
        _loading = false;
        _error = null;
        _pageController = PageController(initialPage: _pageIndex);
      });
      _persist();
      if (_followPlaying) _startFollow();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  ReaderLocation? _locationToOpen(
    FlickController c,
    List<ReaderChapter> chapters,
  ) {
    final saved = c.readerLocations[widget.book.id];
    final prog = c.progress[widget.book.id];
    final shorts = c.shortsByBook[widget.book.id] ?? const <ShortSegment>[];
    if (prog != null &&
        (saved == null || prog.updatedAt.isAfter(saved.updatedAt))) {
      return readerLocationForShort(
        bookId: widget.book.id,
        chapters: chapters,
        shorts: shorts,
        shortIndex: prog.shortIndex,
        updatedAt: prog.updatedAt,
      );
    }
    return saved;
  }

  void _persist() {
    if (_pages.isEmpty || _controller == null) return;
    final page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    var offset = page.startInChapter;
    if (_followPlaying && _followWord > 0) {
      final words = page.text.split(RegExp(r'\s+'));
      final taken = words.take(_followWord).join(' ');
      offset += taken.isEmpty ? 0 : taken.length + 1;
    }
    _controller!.saveReaderLocation(
      ReaderLocation(
        bookId: widget.book.id,
        chapterIndex: page.chapterIndex,
        charOffset: offset,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _onTapZone(_ReaderTapZone zone) {
    switch (zone) {
      case _ReaderTapZone.previous:
        unawaited(_goRelative(-1));
      case _ReaderTapZone.next:
        unawaited(_goRelative(1));
      case _ReaderTapZone.center:
        setState(() => _chrome = !_chrome);
    }
  }

  Future<void> _goRelative(int delta) async {
    final controller = _pageController;
    if (controller == null || _pages.isEmpty) return;
    final now = DateTime.now();
    if (_pageTurnInFlight ||
        now.difference(_lastPageTurnAt) < _pageTurnCooldown) {
      return;
    }
    final next = _pageIndex + delta;
    if (next < 0 || next >= _pages.length) {
      if (delta > 0) {
        _followPlaying = false;
        _followTimer?.cancel();
        await _controller?.stopReaderSpeech();
        if (mounted) setState(() => _followWord = -1);
      }
      return;
    }
    _pageTurnInFlight = true;
    _lastPageTurnAt = now;
    try {
      await controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } finally {
      if (mounted) _pageTurnInFlight = false;
    }
  }

  void _startFollow() {
    _followTimer?.cancel();
    final c = _controller;
    if (c == null || _pages.isEmpty || !_followPlaying) return;
    final page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    final words = page.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final count = words.length;
    setState(() => _followWord = 0);
    c.readerSpokenWord = 0;
    if (!c.muted && count > 0) {
      c.listening = true;
      c.speakReaderPage(page.text);
      _armedGen = c.readerSpeakGen;
      _heardFinish = c.readerPageFinishedGen;
    }
    if (count == 0) return;
    final ms = (420 / c.playbackSpeed).round().clamp(100, 900);
    _followTimer = Timer.periodic(Duration(milliseconds: ms), (timer) {
      if (!mounted || !_followPlaying || !c.readerFollowAlong) {
        timer.cancel();
        return;
      }
      if (DateTime.now().difference(_lastSpokenAt).inMilliseconds < 700) {
        return;
      }
      if (_followWord >= count - 1) {
        timer.cancel();
        if (c.muted) _goRelative(1);
        return;
      }
      setState(() => _followWord += 1);
    });
  }

  Future<void> _toggleFollow() async {
    final c = _controller;
    if (c == null) return;
    final turnOn = !(c.readerFollowAlong && _followPlaying);
    if (!turnOn) {
      _followTimer?.cancel();
      _followPlaying = false;
      await c.setReaderFollowAlong(false);
      await c.stopReaderSpeech();
      if (mounted) setState(() => _followWord = -1);
      return;
    }
    await c.setReaderFollowAlong(true);
    if (c.muted) await c.toggleMute();
    if (!mounted) return;
    if (c.listenVoiceIsBasic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Basic voice. Settings → Accessibility → Spoken Content → Voices → English → download Premium (Ava or Zoe), then tap Listen again.',
          ),
        ),
      );
    }
    setState(() => _followPlaying = true);
    _startFollow();
  }

  Future<void> _toggleListen() async {
    final c = _controller;
    if (c == null) return;
    final wasMuted = c.muted;
    await c.toggleMute();
    if (!mounted) return;
    if (wasMuted) {
      await c.setReaderFollowAlong(true);
      setState(() => _followPlaying = true);
      _startFollow();
    } else {
      _followTimer?.cancel();
      await c.stopReaderSpeech();
      if (_followPlaying) _startFollow();
    }
  }

  Future<void> _changeFont(double delta) async {
    final c = _controller;
    final fit = _fit;
    if (c == null || fit == null) return;
    final next = (c.readerFontSize + delta).clamp(14.0, 32.0);
    if (next == c.readerFontSize) return;
    await c.setReaderFontSize(next);
    if (mounted) await _layoutFor(fit);
  }

  Future<void> _cyclePaper() async {
    final c = _controller;
    final fit = _fit;
    if (c == null) return;
    final next = switch (c.readerPaper) {
      ReaderPaper.paper => ReaderPaper.sepia,
      ReaderPaper.sepia => ReaderPaper.ink,
      ReaderPaper.ink => ReaderPaper.paper,
    };
    await c.setReaderPaper(next);
    if (mounted) setState(() {});
    if (fit != null && mounted) await _layoutFor(fit);
  }

  Future<void> _pickVoice(FlickController c) async {
    await c.prepareListenVoices();
    if (!mounted) return;
    final picked = await showModalBottomSheet<SpokenVoice>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Voice'),
                subtitle: Text(
                  c.plusActive
                      ? 'Pro: enhanced and Siri-class voices when installed on this device.'
                      : 'Free tier uses basic voices. Pro unlocks enhanced Listen voices.',
                ),
              ),
              for (final voice in c.listenVoices)
                ListTile(
                  title: Text(voice.name),
                  subtitle: Text(
                    voice.isPremiumTier && !c.plusActive
                        ? '${voice.locale} · Pro'
                        : voice.natural
                            ? voice.locale
                            : '${voice.locale} · basic',
                  ),
                  trailing: voice.name == c.listenVoiceLabel ||
                          '${voice.name} · basic' == c.listenVoiceLabel
                      ? const Icon(Icons.check)
                      : voice.isPremiumTier && !c.plusActive
                          ? const Icon(Icons.lock_outline)
                          : null,
                  onTap: () async {
                    if (!c.canSelectListenVoice(voice)) {
                      Navigator.pop(context);
                      if (context.mounted) {
                        await showHouseProPrompt(
                          context,
                          placement: HouseProPlacement.voiceTease,
                        );
                      }
                      return;
                    }
                    Navigator.pop(context, voice);
                  },
                ),
            ],
          ),
        );
      },
    );
    if (picked == null) return;
    await c.useListenVoice(picked);
    if (_followPlaying) _startFollow();
  }

  Future<void> _showChapters() async {
    if (_chapters.isEmpty) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Chapters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final chapter in _chapters)
                ListTile(
                  title: Text(chapter.title),
                  onTap: () => Navigator.pop(context, chapter.index),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null || _pageController == null) return;
    final index = _pages.indexWhere((p) => p.chapterIndex == picked);
    if (index < 0) return;
    await _pageController!.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final paper = _paperColors(c.readerPaper);
    final page = _pages.isEmpty
        ? null
        : _pages[_pageIndex.clamp(0, _pages.length - 1)];
    final fraction = _pages.length <= 1 ? 0.0 : _pageIndex / (_pages.length - 1);
    final activeWord = _followPlaying && c.readerFollowAlong ? _followWord : -1;

    final pageLabel = _pages.isEmpty
        ? ''
        : 'Page ${_pageIndex + 1} of ${_pages.length}';

    return Scaffold(
      backgroundColor: paper.background,
      body: SafeArea(
        child: Column(
          children: [
            if (_chrome) _topBar(context, c, paper, page, pageLabel),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _scheduleFit(
                    Size(constraints.maxWidth - 44, constraints.maxHeight),
                  );
                  if (_loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, style: TextStyle(color: paper.ink)),
                    );
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        key: ValueKey(
                          '${c.readerFontSize}-${c.readerPaper.name}-${_pages.length}',
                        ),
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _pageIndex = index;
                            _followWord = 0;
                          });
                          _persist();
                          if (_followPlaying) _startFollow();
                        },
                        itemBuilder: (context, index) {
                          final slice = _pages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: _PageText(
                                text: slice.text.isEmpty
                                    ? 'This chapter is empty.'
                                    : slice.text,
                                style: _style(c, paper),
                                activeWord:
                                    index == _pageIndex ? activeWord : -1,
                                highlight: paper.ink.withValues(alpha: 0.16),
                              ),
                            ),
                          );
                        },
                      ),
                      _ReaderTapLanes(onZoneTap: _onTapZone),
                    ],
                  );
                },
              ),
            ),
            if (_chrome) _bottomBar(context, c, paper, page, fraction, pageLabel),
          ],
        ),
      ),
    );
  }

  Future<void> _showReaderMenu(FlickController c) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _followPlaying ? Icons.record_voice_over : Icons.spatial_audio_off,
                ),
                title: Text(_followPlaying ? 'Stop read-along' : 'Read-along'),
                onTap: () => Navigator.pop(context, 'follow'),
              ),
              ListTile(
                leading: Icon(c.muted ? Icons.volume_off : Icons.volume_up),
                title: Text(c.muted ? 'Start Listen' : 'Mute Listen'),
                onTap: () => Navigator.pop(context, 'listen'),
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over_outlined),
                title: Text('Voice · ${c.listenVoiceLabel ?? 'System'}'),
                onTap: () => Navigator.pop(context, 'voice'),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: Text('Speed · ${c.playbackSpeed}x'),
                onTap: () => Navigator.pop(context, 'speed'),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text size & theme'),
                onTap: () => Navigator.pop(context, 'text'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'follow':
        await _toggleFollow();
      case 'listen':
        await _toggleListen();
      case 'voice':
        await _pickVoice(c);
      case 'speed':
        await _pickSpeed(c);
      case 'text':
        await _showTextSettings(c);
    }
  }

  Future<void> _pickSpeed(FlickController c) async {
    final speed = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in const [0.75, 1.0, 1.25, 1.5, 2.0])
                ListTile(
                  title: Text('${s}x'),
                  trailing: (c.playbackSpeed - s).abs() < 0.01
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, s),
                ),
            ],
          ),
        );
      },
    );
    if (speed == null) return;
    await c.setPlaybackSpeed(speed);
    if (_followPlaying) _startFollow();
  }

  Future<void> _showTextSettings(FlickController c) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Text', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Smaller',
                      onPressed: () => _changeFont(-2),
                      icon: const Icon(Icons.text_decrease),
                    ),
                    Text('${c.readerFontSize.round()} pt'),
                    IconButton(
                      tooltip: 'Larger',
                      onPressed: () => _changeFont(2),
                      icon: const Icon(Icons.text_increase),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _cyclePaper();
                  },
                  icon: const Icon(Icons.contrast),
                  label: const Text('Paper / night theme'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(
    BuildContext context,
    FlickController c,
    _PaperColors paper,
    PageSlice? page,
    String pageLabel,
  ) {
    final chapterTitle = page?.chapterTitle ?? 'Chapter';
    return Material(
      color: paper.background,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: paper.ink),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: paper.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (c.continueReadingLabel(widget.book.id) != null)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            final idx = c.progress[widget.book.id]?.shortIndex;
                            await c.openBook(widget.book, shortIndex: idx);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(
                            'Resume ${c.continueReadingLabel(widget.book.id)} in Story',
                            style: TextStyle(
                              color: paper.ink.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Listen',
                  onPressed: _toggleListen,
                  icon: Icon(
                    c.muted ? Icons.headphones_outlined : Icons.headphones,
                    color: paper.ink,
                  ),
                ),
                IconButton(
                  tooltip: 'Reader settings',
                  onPressed: () => _showReaderMenu(c),
                  icon: Icon(Icons.more_vert, color: paper.ink),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _showChapters,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 18, color: paper.ink.withValues(alpha: 0.8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chapterTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: paper.ink.withValues(alpha: 0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      pageLabel,
                      style: TextStyle(
                        color: paper.ink.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                    Icon(Icons.expand_more,
                        size: 20, color: paper.ink.withValues(alpha: 0.55)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(
    BuildContext context,
    FlickController c,
    _PaperColors paper,
    PageSlice? page,
    double fraction,
    String pageLabel,
  ) {
    final percent = (fraction * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            color: paper.ink.withValues(alpha: 0.88),
            backgroundColor: paper.ink.withValues(alpha: 0.18),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 6),
          Text(
            '$pageLabel · $percent% in book',
            textAlign: TextAlign.center,
            style: TextStyle(color: paper.ink.withValues(alpha: 0.65), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

enum _ReaderTapZone { previous, center, next }

/// Kindle-style margins: tap left/right to turn; center toggles chrome.
class _ReaderTapLanes extends StatelessWidget {
  const _ReaderTapLanes({required this.onZoneTap});

  final void Function(_ReaderTapZone zone) onZoneTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 26,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onZoneTap(_ReaderTapZone.previous),
          ),
        ),
        Expanded(
          flex: 48,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onZoneTap(_ReaderTapZone.center),
          ),
        ),
        Expanded(
          flex: 26,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onZoneTap(_ReaderTapZone.next),
          ),
        ),
      ],
    );
  }
}

class _PageText extends StatelessWidget {
  const _PageText({
    required this.text,
    required this.style,
    required this.activeWord,
    required this.highlight,
  });

  final String text;
  final TextStyle style;
  final int activeWord;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    final blocks = pageBlocks(text);
    if (blocks.isEmpty) {
      return Text(text, style: style);
    }
    final children = <Widget>[];
    var wordIndex = 0;
    for (var b = 0; b < blocks.length; b++) {
      final block = blocks[b];
      final spans = <InlineSpan>[];
      for (var i = 0; i < block.words.length; i++) {
        if (i > 0) spans.add(const TextSpan(text: ' '));
        spans.add(
          TextSpan(
            text: block.words[i],
            style: wordIndex + i == activeWord
                ? style.copyWith(backgroundColor: highlight)
                : style,
          ),
        );
      }
      children.add(Text.rich(TextSpan(children: spans)));
      wordIndex += block.words.length;
      if (b != blocks.length - 1) {
        children.add(const SizedBox(height: 18));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _PaperColors {
  const _PaperColors(this.background, this.ink);
  final Color background;
  final Color ink;
}

_PaperColors _paperColors(ReaderPaper paper) {
  return switch (paper) {
    ReaderPaper.paper => const _PaperColors(Color(0xFFFFFBF5), Color(0xFF1C1C1C)),
    ReaderPaper.sepia => const _PaperColors(Color(0xFFF4ECD8), Color(0xFF3E2F1C)),
    ReaderPaper.ink => const _PaperColors(Color(0xFF121212), Color(0xFFE8E4DC)),
  };
}
