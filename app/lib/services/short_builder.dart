import '../models/models.dart';
import 'abbreviate.dart';

/// ~55–125 words targets ~20–45s Listen at 1x (T05 snackable shorts).
const targetWords = 85;
const minWords = 55;
const maxWords = 125;

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

/// Split a long paragraph into sentence groups, each at most [maxWords].
List<String> _splitOversized(String paragraph) {
  final sentences = paragraph
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (sentences.isEmpty) return [paragraph];

  final chunks = <String>[];
  var current = '';

  for (final sentence in sentences) {
    final candidate = current.isEmpty ? sentence : '$current $sentence';
    if (wordCount(candidate) > maxWords && current.isNotEmpty) {
      chunks.add(current.trim());
      current = sentence;
    } else {
      current = candidate;
    }
  }
  if (current.trim().isNotEmpty) chunks.add(current.trim());

  // Hard-split any single sentence still over max.
  final out = <String>[];
  for (final chunk in chunks) {
    if (wordCount(chunk) <= maxWords) {
      out.add(chunk);
      continue;
    }
    final words = chunk.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    var buf = <String>[];
    for (final w in words) {
      buf.add(w);
      if (buf.length >= maxWords) {
        out.add(buf.join(' '));
        buf = [];
      }
    }
    if (buf.isNotEmpty) out.add(buf.join(' '));
  }
  return out;
}

/// Pack paragraph/sentence units into snackable shorts near [targetWords].
List<String> packShortUnits(List<String> units) {
  if (units.isEmpty) return const [];

  final packed = <String>[];
  var current = '';

  void flush() {
    final t = current.trim();
    if (t.isNotEmpty) packed.add(t);
    current = '';
  }

  for (final unit in units) {
    final piece = unit.trim();
    if (piece.isEmpty) continue;
    if (current.isEmpty) {
      current = piece;
      continue;
    }
    final candidate = '$current $piece';
    final words = wordCount(candidate);
    if (words <= targetWords) {
      current = candidate;
      continue;
    }
    // Crossing target: emit current if it's already snackable enough.
    if (wordCount(current) >= minWords) {
      flush();
      current = piece;
      continue;
    }
    // Current is still short — keep growing until max, then cut.
    if (words <= maxWords) {
      current = candidate;
    } else {
      flush();
      current = piece;
    }
  }
  flush();

  // Merge a tiny trailing short into the previous one when possible.
  if (packed.length >= 2 && wordCount(packed.last) < minWords) {
    final merged = '${packed[packed.length - 2]} ${packed.last}';
    if (wordCount(merged) <= maxWords + 20) {
      packed[packed.length - 2] = merged;
      packed.removeLast();
    }
  }

  // Merge a tiny leading short forward when the chapter opens short.
  if (packed.length >= 2 && wordCount(packed.first) < minWords) {
    final merged = '${packed.first} ${packed[1]}';
    if (wordCount(merged) <= maxWords + 20) {
      packed[1] = merged;
      packed.removeAt(0);
    }
  }

  return packed;
}

List<ShortSegment> buildShorts(LibraryBook book) {
  final paragraphs = _splitParagraphs(book.text);
  final pieces = <({String text, int chapterIndex, String chapterTitle})>[];

  var chapterIndex = 0;
  var chapterTitle = 'Chapter 1';
  var started = false;
  var pendingUnits = <String>[];

  void flushPending() {
    final packed = packShortUnits(pendingUnits);
    for (final text in packed) {
      pieces.add((
        text: text,
        chapterIndex: chapterIndex,
        chapterTitle: chapterTitle,
      ));
    }
    pendingUnits = [];
  }

  for (final p in paragraphs) {
    final lines =
        p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    var body = p;

    if (lines.isNotEmpty && _isChapterHeading(lines.first)) {
      flushPending();
      chapterIndex = started ? chapterIndex + 1 : 0;
      chapterTitle =
          lines.first.length > 80 ? lines.first.substring(0, 80) : lines.first;
      started = true;
      if (lines.length == 1) continue;
      body = lines.skip(1).join(' ');
    } else if (_isChapterHeading(p)) {
      flushPending();
      chapterIndex = started ? chapterIndex + 1 : 0;
      chapterTitle = p.length > 80 ? p.substring(0, 80) : p;
      started = true;
      continue;
    }

    if (wordCount(body) < 8) continue;
    started = true;

    if (wordCount(body) <= maxWords) {
      pendingUnits.add(body);
    } else {
      pendingUnits.addAll(_splitOversized(body));
    }
  }
  flushPending();

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
