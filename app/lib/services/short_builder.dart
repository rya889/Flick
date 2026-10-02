import '../models/models.dart';
import 'abbreviate.dart';

/// ~60–110 words targets ~20–40s Listen at 1x (snackable shorts).
const targetWords = 80;
const minWords = 60;
const maxWords = 110;

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

List<String> _sentencesOf(String text) {
  return text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Hard-split any blob still over [maxWords].
List<String> _hardSplitWords(String text) {
  if (wordCount(text) <= maxWords) return [text];
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final out = <String>[];
  for (var i = 0; i < words.length; i += maxWords) {
    final end = (i + maxWords).clamp(0, words.length);
    out.add(words.sublist(i, end).join(' '));
  }
  return out;
}

/// Pack paragraph units into snackable shorts near [targetWords].
List<String> packShortUnits(List<String> units) {
  if (units.isEmpty) return const [];

  final sentences = <String>[];
  for (final unit in units) {
    final trimmed = unit.trim();
    if (trimmed.isEmpty) continue;
    final parts = _sentencesOf(trimmed);
    if (parts.isEmpty) {
      sentences.add(trimmed);
    } else {
      for (final part in parts) {
        sentences.addAll(_hardSplitWords(part));
      }
    }
  }
  if (sentences.isEmpty) return const [];

  final packed = <String>[];
  var current = '';

  void flush() {
    final t = current.trim();
    if (t.isNotEmpty) packed.add(t);
    current = '';
  }

  for (final sentence in sentences) {
    if (current.isEmpty) {
      current = sentence;
      continue;
    }
    final candidate = '$current $sentence';
    final words = wordCount(candidate);
    if (words <= targetWords) {
      current = candidate;
      continue;
    }
    if (wordCount(current) >= minWords) {
      flush();
      current = sentence;
      continue;
    }
    if (words <= maxWords) {
      current = candidate;
    } else {
      flush();
      current = sentence;
    }
  }
  flush();

  return _coalesceShorts(packed);
}

/// Merge undersized shorts into neighbors until everything is near target.
List<String> _coalesceShorts(List<String> input) {
  if (input.length <= 1) return input;
  var out = _mergeTinies(List<String>.from(input));

  // Re-split merges that blew past a soft ceiling (no recursive coalesce).
  final softMax = maxWords + 35;
  final normalized = <String>[];
  for (final chunk in out) {
    if (wordCount(chunk) <= softMax) {
      normalized.add(chunk);
      continue;
    }
    final sentences = _sentencesOf(chunk);
    var current = '';
    for (final sentence in sentences) {
      final candidate = current.isEmpty ? sentence : '$current $sentence';
      if (wordCount(candidate) > maxWords && current.isNotEmpty) {
        normalized.add(current.trim());
        current = sentence;
      } else {
        current = candidate;
      }
    }
    if (current.trim().isNotEmpty) {
      normalized.addAll(_hardSplitWords(current.trim()));
    }
  }
  // Re-split can leave crumbs — merge them again, allowing soft overshoot.
  return _mergeTinies(normalized);
}

List<String> _mergeTinies(List<String> input) {
  if (input.length <= 1) return input;
  final out = List<String>.from(input);
  var guard = 0;
  while (guard++ < 64) {
    final tinyAt = out.indexWhere((s) => wordCount(s) < minWords);
    if (tinyAt < 0) break;
    if (tinyAt > 0) {
      out[tinyAt - 1] = '${out[tinyAt - 1]} ${out[tinyAt]}';
      out.removeAt(tinyAt);
      continue;
    }
    if (tinyAt < out.length - 1) {
      out[tinyAt] = '${out[tinyAt]} ${out[tinyAt + 1]}';
      out.removeAt(tinyAt + 1);
      continue;
    }
    break;
  }
  return out;
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

    // Keep even short dialogue lines so packing can merge them.
    if (wordCount(body) < 3) continue;
    started = true;
    pendingUnits.add(body);
  }
  flushPending();

  // Chapter boundaries can leave a crumb short — fold into a neighbor.
  for (var i = pieces.length - 1; i >= 1; i--) {
    if (wordCount(pieces[i].text) >= minWords) continue;
    pieces[i - 1] = (
      text: '${pieces[i - 1].text} ${pieces[i].text}',
      chapterIndex: pieces[i - 1].chapterIndex,
      chapterTitle: pieces[i - 1].chapterTitle,
    );
    pieces.removeAt(i);
  }
  if (pieces.length >= 2 && wordCount(pieces.first.text) < minWords) {
    pieces[1] = (
      text: '${pieces.first.text} ${pieces[1].text}',
      chapterIndex: pieces[1].chapterIndex,
      chapterTitle: pieces[1].chapterTitle,
    );
    pieces.removeAt(0);
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
