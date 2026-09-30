import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/reader_sync.dart';
import '../services/book_pages.dart';
import '../services/progress_bridge.dart';
import '../state/flick_controller.dart';

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

  void _onController() {
    final c = _controller;
    if (c == null || !mounted || !_followPlaying) return;
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

  void _onTap(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    final x = details.localPosition.dx;
    if (x < width * 0.28) {
      _goRelative(-1);
    } else if (x > width * 0.72) {
      _goRelative(1);
    } else {
      setState(() => _chrome = !_chrome);
    }
  }

  Future<void> _goRelative(int delta) async {
    final controller = _pageController;
    if (controller == null || _pages.isEmpty) return;
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
    await controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _startFollow() {
    _followTimer?.cancel();
    final c = _controller;
    if (c == null || _pages.isEmpty) return;
    final page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    _followWord = 0;
    if (!c.muted && c.listening) {
      c.speakReaderPage(page.text);
      _armedGen = c.readerSpeakGen;
      return;
    }
    final words = page.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final count = words.length;
    final ms = (420 / c.playbackSpeed).round().clamp(100, 900);
    _followTimer = Timer.periodic(Duration(milliseconds: ms), (timer) {
      if (!mounted || !_followPlaying) {
        timer.cancel();
        return;
      }
      if (_followWord >= count - 1) {
        timer.cancel();
        _goRelative(1);
        return;
      }
      setState(() => _followWord += 1);
      _persist();
    });
  }

  void _toggleFollowPlay() {
    setState(() => _followPlaying = !_followPlaying);
    if (_followPlaying) {
      _startFollow();
    } else {
      _followTimer?.cancel();
      _controller?.stopReaderSpeech();
      setState(() => _followWord = -1);
    }
  }

  Future<void> _showChapters() async {
    if (_chapters.isEmpty) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
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
    final activeWord = _followPlaying && c.readerFollowAlong
        ? (!c.muted && c.listening ? c.readerSpokenWord : _followWord)
        : -1;

    return Scaffold(
      backgroundColor: paper.background,
      body: SafeArea(
        child: Column(
          children: [
            if (_chrome) _topBar(context, c, paper),
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
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: _onTap,
                    child: PageView.builder(
                      controller: _pageController,
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
                              activeWord: index == _pageIndex ? activeWord : -1,
                              highlight: paper.ink.withValues(alpha: 0.16),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            _bottomBar(paper, page, fraction),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, FlickController c, _PaperColors paper) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: paper.ink, fontWeight: FontWeight.w600),
          ),
          Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: paper.ink),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    tooltip: c.readerFollowAlong
                        ? 'Follow along on'
                        : 'Follow along off',
                    onPressed: () async {
                      final next = !c.readerFollowAlong;
                      await c.setReaderFollowAlong(next);
                      if (!next) {
                        _followTimer?.cancel();
                        _followPlaying = false;
                        setState(() => _followWord = -1);
                      }
                    },
                    icon: Icon(
                      c.readerFollowAlong
                          ? Icons.spatial_audio
                          : Icons.spatial_audio_off,
                      color: paper.ink,
                    ),
                  ),
                  if (c.readerFollowAlong)
                    IconButton(
                      tooltip: _followPlaying ? 'Pause follow' : 'Play follow',
                      onPressed: _toggleFollowPlay,
                      icon: Icon(
                        _followPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: paper.ink,
                      ),
                    ),
                  IconButton(
                    tooltip: c.muted ? 'Listen' : 'Mute',
                    onPressed: () async {
                      await c.toggleMute();
                      if (_followPlaying) _startFollow();
                    },
                    icon: Icon(
                      c.muted ? Icons.volume_off : Icons.volume_up,
                      color: paper.ink,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Smaller text',
                    onPressed: () {
                      final next = (c.readerFontSize - 1).clamp(14, 32).toDouble();
                      c.setReaderFontSize(next);
                      _fit = null;
                    },
                    icon: Icon(Icons.text_decrease, color: paper.ink),
                  ),
                  IconButton(
                    tooltip: 'Larger text',
                    onPressed: () {
                      final next = (c.readerFontSize + 1).clamp(14, 32).toDouble();
                      c.setReaderFontSize(next);
                      _fit = null;
                    },
                    icon: Icon(Icons.text_increase, color: paper.ink),
                  ),
                  IconButton(
                    tooltip: 'Paper',
                    onPressed: () {
                      final next = switch (c.readerPaper) {
                        ReaderPaper.paper => ReaderPaper.sepia,
                        ReaderPaper.sepia => ReaderPaper.ink,
                        ReaderPaper.ink => ReaderPaper.paper,
                      };
                      c.setReaderPaper(next);
                      _fit = null;
                    },
                    icon: Icon(Icons.contrast, color: paper.ink),
                  ),
                  IconButton(
                    tooltip: 'Chapters',
                    onPressed: _showChapters,
                    icon: Icon(Icons.list, color: paper.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _bottomBar(_PaperColors paper, PageSlice? page, double fraction) {
    final percent = (fraction * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            color: paper.ink.withValues(alpha: 0.8),
            backgroundColor: paper.ink.withValues(alpha: 0.12),
            minHeight: 3,
          ),
          const SizedBox(height: 6),
          Text(
            '${page?.chapterTitle ?? ''} · $percent%',
            style: TextStyle(color: paper.ink.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
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
    if (activeWord < 0) {
      return Text(text, style: style);
    }
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < words.length; i++) ...[
            TextSpan(
              text: words[i],
              style: i == activeWord
                  ? style.copyWith(
                      backgroundColor: highlight,
                      fontWeight: FontWeight.w700,
                    )
                  : style,
            ),
            if (i != words.length - 1) const TextSpan(text: ' '),
          ],
        ],
      ),
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
