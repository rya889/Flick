import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/reader_sync.dart';
import '../services/book_pages.dart';
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
  int _pageIndex = 0;
  bool _chrome = true;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final c = context.read<FlickController>();
    try {
      final spans = await c.chapterSpans(widget.book.id);
      final chapters = chaptersForBook(widget.book, stored: spans);
      final pages = paginateBook(chapters, c.readerFontSize);
      final saved = c.readerLocations[widget.book.id];
      final index = saved == null
          ? 0
          : pageIndexForLocation(pages, saved.chapterIndex, saved.charOffset);
      if (!mounted) return;
      setState(() {
        _pages = pages;
        _pageIndex = index;
        _loading = false;
        _pageController = PageController(initialPage: index);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _relayout(double fontSize) {
    final c = context.read<FlickController>();
    final current = _pages.isEmpty ? null : _pages[_pageIndex.clamp(0, _pages.length - 1)];
    final spansFuture = c.chapterSpans(widget.book.id);
    spansFuture.then((spans) {
      if (!mounted) return;
      final chapters = chaptersForBook(widget.book, stored: spans);
      final pages = paginateBook(chapters, fontSize);
      final index = current == null
          ? 0
          : pageIndexForLocation(
              pages,
              current.chapterIndex,
              current.startInChapter,
            );
      _pageController?.dispose();
      setState(() {
        _pages = pages;
        _pageIndex = index;
        _pageController = PageController(initialPage: index);
      });
      _persist();
    });
  }

  void _persist() {
    if (_pages.isEmpty) return;
    final page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    context.read<FlickController>().saveReaderLocation(
          ReaderLocation(
            bookId: widget.book.id,
            chapterIndex: page.chapterIndex,
            charOffset: page.startInChapter,
            updatedAt: DateTime.now(),
          ),
        );
  }

  void _onTap(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    final x = details.localPosition.dx;
    final controller = _pageController;
    if (controller == null) return;
    if (x < width * 0.28) {
      controller.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else if (x > width * 0.72) {
      controller.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      setState(() => _chrome = !_chrome);
    }
  }

  Future<void> _showChapters() async {
    final titles = <int, String>{};
    for (final page in _pages) {
      titles.putIfAbsent(page.chapterIndex, () => page.chapterTitle);
    }
    if (!mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              for (final entry in titles.entries)
                ListTile(
                  title: Text(entry.value),
                  onTap: () => Navigator.pop(context, entry.key),
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
    final fraction = _pages.length <= 1
        ? 1.0
        : _pageIndex / (_pages.length - 1);

    return Scaffold(
      backgroundColor: paper.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: TextStyle(color: paper.ink)),
                  )
                : Stack(
                    children: [
                      Column(
                        children: [
                          if (_chrome) _topBar(context, c, paper, page),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: _onTap,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _pages.length,
                                onPageChanged: (index) {
                                  setState(() => _pageIndex = index);
                                  _persist();
                                },
                                itemBuilder: (context, index) {
                                  final slice = _pages[index];
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      12,
                                      22,
                                      28,
                                    ),
                                    child: Text(
                                      slice.text.isEmpty
                                          ? 'This chapter is empty.'
                                          : slice.text,
                                      style: GoogleFonts.literata(
                                        fontSize: c.readerFontSize,
                                        height: 1.45,
                                        color: paper.ink,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (_chrome)
                            _bottomBar(context, paper, page, fraction),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _topBar(
    BuildContext context,
    FlickController c,
    _PaperColors paper,
    PageSlice? page,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: paper.ink),
          ),
          Expanded(
            child: Text(
              widget.book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: paper.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Smaller text',
            onPressed: () {
              final next = (c.readerFontSize - 1).clamp(14, 32).toDouble();
              c.setReaderFontSize(next);
              _relayout(next);
            },
            icon: Icon(Icons.text_decrease, color: paper.ink),
          ),
          IconButton(
            tooltip: 'Larger text',
            onPressed: () {
              final next = (c.readerFontSize + 1).clamp(14, 32).toDouble();
              c.setReaderFontSize(next);
              _relayout(next);
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
    );
  }

  Widget _bottomBar(
    BuildContext context,
    _PaperColors paper,
    PageSlice? page,
    double fraction,
  ) {
    final percent = (fraction * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            color: paper.ink.withValues(alpha: 0.8),
            backgroundColor: paper.ink.withValues(alpha: 0.12),
            minHeight: 3,
          ),
          const SizedBox(height: 8),
          Text(
            '${page?.chapterTitle ?? ''} · $percent%',
            style: TextStyle(color: paper.ink.withValues(alpha: 0.7), fontSize: 13),
          ),
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
