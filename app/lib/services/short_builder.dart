import '../models/models.dart';
import 'abbreviate.dart';

const targetWords = 90;
const minWords = 40;

final _chapterHeading = RegExp(
  r'^(?:CHAPTER|Chapter|PART|Part|BOOK|Book|SECTION|Section)\s+.+$',
);

bool _isChapterHeading(String line) {
  final t = line.trim();
  if (_chapterHeading.hasMatch(t)) return true;
  if (RegExp(r"^[A-Z][A-Z0-9 ,.'-]{3,60}$").hasMatch(t) &&
      wordCount(t) <= 8) {
    return true;
  }
  return false;
}

List<String> _splitParagraphs(String text) {
  return text
      .split(RegExp(r'\n\s*\n+'))
      .map((p) => p.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((p) => p.isNotEmpty)
      .toList();
}

List<String> _chunkParagraph(String paragraph) {
  final sentences =
      paragraph.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.isNotEmpty);
  final chunks = <String>[];
  var current = '';

  for (final sentence in sentences) {
    final candidate = current.isEmpty ? sentence : '$current $sentence';
    final words = wordCount(candidate);
    if (words > targetWords && current.isNotEmpty) {
      chunks.add(current.trim());
      current = sentence;
    } else if (words >= minWords && current.isEmpty) {
      chunks.add(candidate.trim());
      current = '';
    } else {
      current = candidate;
    }
  }
  if (current.trim().isNotEmpty) chunks.add(current.trim());
  return chunks;
}

List<ShortSegment> buildShorts(LibraryBook book) {
  final paragraphs = _splitParagraphs(book.text);
  final pieces = <({String text, int chapterIndex, String chapterTitle})>[];

  var chapterIndex = 0;
  var chapterTitle = 'Chapter 1';
  var started = false;

  for (final p in paragraphs) {
    final lines = p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    var body = p;

    if (lines.isNotEmpty && _isChapterHeading(lines.first)) {
      chapterIndex = started ? chapterIndex + 1 : 0;
      chapterTitle =
          lines.first.length > 80 ? lines.first.substring(0, 80) : lines.first;
      started = true;
      if (lines.length == 1) continue;
      body = lines.skip(1).join(' ');
    } else if (_isChapterHeading(p)) {
      chapterIndex = started ? chapterIndex + 1 : 0;
      chapterTitle = p.length > 80 ? p.substring(0, 80) : p;
      started = true;
      continue;
    }

    if (wordCount(body) < 8) continue;
    started = true;

    final chunks = wordCount(body) <= targetWords ? [body] : _chunkParagraph(body);
    for (final text in chunks) {
      pieces.add((
        text: text,
        chapterIndex: chapterIndex,
        chapterTitle: chapterTitle,
      ));
    }
  }

  if (pieces.isEmpty && book.text.trim().isNotEmpty) {
    final slice = book.text.trim();
    pieces.add((
      text: slice.length > 800 ? slice.substring(0, 800) : slice,
      chapterIndex: 0,
      chapterTitle: 'Chapter 1',
    ));
  }

  return [
    for (var i = 0; i < pieces.length; i++)
      ShortSegment(
        id: '${book.id}-short-$i',
        bookId: book.id,
        index: i,
        original: pieces[i].text,
        condense: abbreviate(pieces[i].text),
        summary: summarizePassage(pieces[i].text),
        quotes: keyQuotes(pieces[i].text),
        wordCount: wordCount(pieces[i].text),
        chapterIndex: pieces[i].chapterIndex,
        chapterTitle: pieces[i].chapterTitle,
      ),
  ];
}
