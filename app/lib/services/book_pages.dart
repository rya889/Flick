import '../models/models.dart';

class ReaderChapter {
  const ReaderChapter({
    required this.index,
    required this.title,
    required this.text,
  });

  final int index;
  final String title;
  final String text;
}

class PageSlice {
  const PageSlice({
    required this.chapterIndex,
    required this.chapterTitle,
    required this.text,
    required this.startInChapter,
  });

  final int chapterIndex;
  final String chapterTitle;
  final String text;
  final int startInChapter;
}

class StoredChapterSpan {
  const StoredChapterSpan({
    required this.index,
    required this.title,
    required this.startOffset,
    required this.endOffset,
  });

  final int index;
  final String title;
  final int startOffset;
  final int endOffset;
}

final _chapterHeading = RegExp(
  r'^(?:CHAPTER|Chapter|PART|Part|BOOK|Book|SECTION|Section)\s+.+$',
);

bool isReaderChapterHeading(String line) {
  final t = line.trim();
  if (t.isEmpty) return false;
  if (_chapterHeading.hasMatch(t)) return true;
  if (RegExp(r"^[A-Z][A-Z0-9 ,.'-]{3,60}$").hasMatch(t) &&
      t.split(RegExp(r'\s+')).length <= 8) {
    return true;
  }
  return false;
}

/// Chapters for the page reader. Prefer EPUB offsets when they fit the text.
List<ReaderChapter> chaptersForBook(
  LibraryBook book, {
  List<StoredChapterSpan> stored = const [],
}) {
  if (stored.isNotEmpty &&
      stored.every(
        (c) =>
            c.startOffset >= 0 &&
            c.endOffset <= book.text.length &&
            c.endOffset > c.startOffset,
      )) {
    return [
      for (final c in stored)
        ReaderChapter(
          index: c.index,
          title: c.title,
          text: book.text.substring(c.startOffset, c.endOffset).trim(),
        ),
    ].where((c) => c.text.isNotEmpty).toList();
  }
  return chaptersFromPlainText(book.text);
}

List<ReaderChapter> chaptersFromPlainText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return const [
      ReaderChapter(index: 0, title: 'Start', text: ''),
    ];
  }

  final blocks = trimmed.split(RegExp(r'\n\s*\n+'));
  final chapters = <ReaderChapter>[];
  var index = 0;
  var title = 'Chapter 1';
  final buffer = StringBuffer();

  void flush() {
    final body = buffer.toString().trim();
    buffer.clear();
    if (body.isEmpty && chapters.isNotEmpty) return;
    chapters.add(ReaderChapter(index: index, title: title, text: body));
  }

  for (final block in blocks) {
    final lines = block
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) continue;
    if (isReaderChapterHeading(lines.first)) {
      if (buffer.isNotEmpty) {
        flush();
        index += 1;
      }
      title = lines.first.length > 80 ? lines.first.substring(0, 80) : lines.first;
      if (lines.length > 1) {
        buffer.writeln(lines.skip(1).join('\n'));
        buffer.writeln();
      }
      continue;
    }
    buffer.writeln(block.trim());
    buffer.writeln();
  }
  flush();

  if (chapters.isEmpty) {
    return [ReaderChapter(index: 0, title: 'Chapter 1', text: trimmed)];
  }
  return chapters;
}

/// Rough phone page. Larger type means fewer characters per page.
int charsPerPage(double fontSize) {
  final size = fontSize.clamp(14.0, 32.0);
  final lines = (560 / size).round().clamp(8, 36);
  final charsPerLine = (820 / size).round().clamp(16, 48);
  return lines * charsPerLine;
}

List<PageSlice> paginateBook(List<ReaderChapter> chapters, double fontSize) {
  final budget = charsPerPage(fontSize);
  final pages = <PageSlice>[];
  for (final chapter in chapters) {
    final slices = _paginate(chapter.text, budget);
    if (slices.isEmpty) {
      pages.add(
        PageSlice(
          chapterIndex: chapter.index,
          chapterTitle: chapter.title,
          text: '',
          startInChapter: 0,
        ),
      );
      continue;
    }
    for (final slice in slices) {
      pages.add(
        PageSlice(
          chapterIndex: chapter.index,
          chapterTitle: chapter.title,
          text: slice.text,
          startInChapter: slice.start,
        ),
      );
    }
  }
  return pages;
}

class _Slice {
  const _Slice(this.text, this.start);
  final String text;
  final int start;
}

List<_Slice> _paginate(String text, int budget) {
  final source = text.trim();
  if (source.isEmpty) return const [];
  if (source.length <= budget) return [_Slice(source, 0)];

  final pages = <_Slice>[];
  var i = 0;
  while (i < source.length) {
    var end = i + budget;
    if (end >= source.length) {
      pages.add(_Slice(source.substring(i).trim(), i));
      break;
    }
    final window = source.substring(i, end);
    final breakAt = window.lastIndexOf(' ');
    if (breakAt > budget ~/ 3) {
      end = i + breakAt;
    }
    final page = source.substring(i, end).trim();
    if (page.isNotEmpty) pages.add(_Slice(page, i));
    i = end;
    while (i < source.length && source[i] == ' ') {
      i += 1;
    }
  }
  return pages;
}

int pageIndexForLocation(List<PageSlice> pages, int chapterIndex, int charOffset) {
  if (pages.isEmpty) return 0;
  var fallback = 0;
  for (var i = 0; i < pages.length; i++) {
    final page = pages[i];
    if (page.chapterIndex < chapterIndex) continue;
    if (page.chapterIndex > chapterIndex) return fallback;
    fallback = i;
    final nextStart = i + 1 < pages.length && pages[i + 1].chapterIndex == chapterIndex
        ? pages[i + 1].startInChapter
        : 1 << 30;
    if (charOffset < nextStart) return i;
  }
  return fallback;
}
