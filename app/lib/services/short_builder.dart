import 'package:flutter/painting.dart';

import '../models/models.dart';
import 'abbreviate.dart';

/// Fixed Shorts type — TikTok/Insta style; Pages may still change size.
const shortsFontSize = 19.0;
const shortsLineHeight = 1.45;

/// Used at import / tests before the Now pane has a real layout size.
const shortsFallbackWidth = 350.0;
const shortsFallbackHeight = 520.0;

/// Soft fill targets as a fraction of the Shorts text viewport.
const shortsFillTarget = 0.92;
const shortsMinFill = 0.45;

/// Kept for older tests / Listen estimates; packing is height-based.
const targetWords = 80;
const minWords = 60;
const maxWords = 110;

TextStyle defaultShortsTextStyle() => const TextStyle(
      fontSize: shortsFontSize,
      height: shortsLineHeight,
    );

final _chapterHeading = RegExp(
  r'^(?:CHAPTER|Chapter|PART|Part|BOOK|Book|SECTION|Section)\s+.+$',
);

bool _isChapterHeading(String line) {
  final t = line.trim();
  if (_chapterHeading.hasMatch(t)) return true;
  // ALL-CAPS titles only — not sentence fragments like "A STORY OF WALL-STREET."
  if (RegExp(r"^[A-Z][A-Z0-9 ,'-]{3,60}$").hasMatch(t) &&
      wordCount(t) <= 8 &&
      !t.endsWith('.')) {
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

double measureShortHeight(
  String text, {
  required double maxWidth,
  TextStyle? style,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style ?? defaultShortsTextStyle()),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  )..layout(maxWidth: maxWidth);
  return painter.height;
}

bool shortFitsViewport(
  String text, {
  required double maxWidth,
  required double maxHeight,
  TextStyle? style,
}) {
  return measureShortHeight(text, maxWidth: maxWidth, style: style) <=
      maxHeight;
}

/// Split [text] into chunks that each fit [budget] height.
List<String> _fitToHeight(
  String text, {
  required double maxWidth,
  required double budget,
  required TextStyle style,
}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const [];
  if (measureShortHeight(trimmed, maxWidth: maxWidth, style: style) <= budget) {
    return [trimmed];
  }

  final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return const [];

  final out = <String>[];
  var start = 0;
  while (start < words.length) {
    if (start == words.length - 1) {
      out.add(words[start]);
      break;
    }
    var lo = start + 1;
    var hi = words.length;
    var best = start + 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final candidate = words.sublist(start, mid).join(' ');
      if (measureShortHeight(candidate, maxWidth: maxWidth, style: style) <=
          budget) {
        best = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    if (best <= start) best = start + 1;
    out.add(words.sublist(start, best).join(' '));
    start = best;
  }
  return out;
}

/// Pack paragraph/sentence units so each short fills ~one Shorts viewport.
List<String> packShortUnitsToViewport(
  List<String> units, {
  required double maxWidth,
  required double maxHeight,
  TextStyle? style,
}) {
  if (units.isEmpty) return const [];
  final textStyle = style ?? defaultShortsTextStyle();
  final budget = (maxHeight * shortsFillTarget).clamp(40.0, maxHeight);
  final minFill = maxHeight * shortsMinFill;

  final sentences = <String>[];
  for (final unit in units) {
    final trimmed = unit.trim();
    if (trimmed.isEmpty) continue;
    final parts = _sentencesOf(trimmed);
    if (parts.isEmpty) {
      sentences.addAll(
        _fitToHeight(
          trimmed,
          maxWidth: maxWidth,
          budget: budget,
          style: textStyle,
        ),
      );
    } else {
      for (final part in parts) {
        sentences.addAll(
          _fitToHeight(
            part,
            maxWidth: maxWidth,
            budget: budget,
            style: textStyle,
          ),
        );
      }
    }
  }
  if (sentences.isEmpty) return const [];

  final packed = <String>[];
  var current = '';
  final softBudget = budget * 1.08;

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
    final candidateH =
        measureShortHeight(candidate, maxWidth: maxWidth, style: textStyle);
    if (candidateH <= budget) {
      current = candidate;
      continue;
    }
    final currentH =
        measureShortHeight(current, maxWidth: maxWidth, style: textStyle);
    // Prefer a slight overshoot over leaving an underfilled short.
    if (currentH < minFill && candidateH <= softBudget) {
      current = candidate;
      continue;
    }
    flush();
    current = sentence;
  }
  flush();

  return _coalesceByHeight(
    packed,
    maxWidth: maxWidth,
    budget: budget,
    minFill: minFill,
    style: textStyle,
  );
}

List<String> _coalesceByHeight(
  List<String> input, {
  required double maxWidth,
  required double budget,
  required double minFill,
  required TextStyle style,
}) {
  if (input.length <= 1) return input;
  final softBudget = budget * 1.08;

  List<String> mergePass(List<String> source) {
    final out = List<String>.from(source);
    final skipped = <int>{};
    var guard = 0;
    while (guard++ < 128) {
      var idx = -1;
      for (var i = 0; i < out.length; i++) {
        if (skipped.contains(i)) continue;
        final h =
            measureShortHeight(out[i], maxWidth: maxWidth, style: style);
        if (h < minFill) {
          idx = i;
          break;
        }
      }
      if (idx < 0) break;

      var merged = false;
      if (idx > 0) {
        final candidate = '${out[idx - 1]} ${out[idx]}';
        if (measureShortHeight(candidate, maxWidth: maxWidth, style: style) <=
            softBudget) {
          out[idx - 1] = candidate;
          out.removeAt(idx);
          skipped.clear();
          merged = true;
        }
      }
      if (!merged && idx < out.length - 1) {
        final candidate = '${out[idx]} ${out[idx + 1]}';
        if (measureShortHeight(candidate, maxWidth: maxWidth, style: style) <=
            softBudget) {
          out[idx] = candidate;
          out.removeAt(idx + 1);
          skipped.clear();
          merged = true;
        }
      }
      if (!merged) skipped.add(idx);
    }
    return out;
  }

  var out = mergePass(input);

  // Force-fold remaining tinies into the previous short (accept soft overshoot).
  for (var i = out.length - 1; i >= 1; i--) {
    final h = measureShortHeight(out[i], maxWidth: maxWidth, style: style);
    if (h >= minFill) continue;
    out[i - 1] = '${out[i - 1]} ${out[i]}';
    out.removeAt(i);
  }
  if (out.length >= 2) {
    final h = measureShortHeight(out.first, maxWidth: maxWidth, style: style);
    if (h < minFill) {
      out[1] = '${out.first} ${out[1]}';
      out.removeAt(0);
    }
  }

  // Re-split only chunks that blew well past the soft ceiling.
  final hardCeil = softBudget * 1.12;
  final normalized = <String>[];
  for (final chunk in out) {
    final h = measureShortHeight(chunk, maxWidth: maxWidth, style: style);
    if (h <= hardCeil) {
      normalized.add(chunk);
    } else {
      normalized.addAll(
        _fitToHeight(
          chunk,
          maxWidth: maxWidth,
          budget: softBudget,
          style: style,
        ),
      );
    }
  }
  return mergePass(normalized);
}

/// Back-compat helper: pack with the canonical phone viewport.
List<String> packShortUnits(List<String> units) {
  return packShortUnitsToViewport(
    units,
    maxWidth: shortsFallbackWidth,
    maxHeight: shortsFallbackHeight,
  );
}

List<ShortSegment> buildShorts(
  LibraryBook book, {
  double? maxWidth,
  double? maxHeight,
  TextStyle? style,
}) {
  final width = (maxWidth != null && maxWidth >= 40)
      ? maxWidth
      : shortsFallbackWidth;
  final height = (maxHeight != null && maxHeight >= 40)
      ? maxHeight
      : shortsFallbackHeight;
  final textStyle = style ?? defaultShortsTextStyle();

  final paragraphs = _splitParagraphs(book.text);
  final pieces = <({String text, int chapterIndex, String chapterTitle})>[];

  var chapterIndex = 0;
  var chapterTitle = 'Chapter 1';
  var started = false;
  var pendingUnits = <String>[];

  void flushPending() {
    final packed = packShortUnitsToViewport(
      pendingUnits,
      maxWidth: width,
      maxHeight: height,
      style: textStyle,
    );
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

    if (wordCount(body) < 3) continue;
    started = true;
    pendingUnits.add(body);
  }
  flushPending();

  // Chapter-edge crumbs: fold into neighbors by measured height.
  final softBudget = height * shortsFillTarget * 1.08;
  for (var i = pieces.length - 1; i >= 1; i--) {
    final h = measureShortHeight(
      pieces[i].text,
      maxWidth: width,
      style: textStyle,
    );
    if (h >= height * shortsMinFill) continue;
    final merged = '${pieces[i - 1].text} ${pieces[i].text}';
    if (measureShortHeight(merged, maxWidth: width, style: textStyle) >
        softBudget) {
      continue;
    }
    pieces[i - 1] = (
      text: merged,
      chapterIndex: pieces[i - 1].chapterIndex,
      chapterTitle: pieces[i - 1].chapterTitle,
    );
    pieces.removeAt(i);
  }
  if (pieces.length >= 2) {
    final h = measureShortHeight(
      pieces.first.text,
      maxWidth: width,
      style: textStyle,
    );
    if (h < height * shortsMinFill) {
      final merged = '${pieces.first.text} ${pieces[1].text}';
      if (measureShortHeight(merged, maxWidth: width, style: textStyle) <=
          softBudget) {
        pieces[1] = (
          text: merged,
          chapterIndex: pieces[1].chapterIndex,
          chapterTitle: pieces[1].chapterTitle,
        );
        pieces.removeAt(0);
      }
    }
  }

  if (pieces.isEmpty && book.text.trim().isNotEmpty) {
    final fitted = _fitToHeight(
      book.text.trim(),
      maxWidth: width,
      budget: height * shortsFillTarget,
      style: textStyle,
    );
    for (final text in fitted) {
      pieces.add((
        text: text,
        chapterIndex: 0,
        chapterTitle: 'Chapter 1',
      ));
    }
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

/// Remap a short index after a rebuild using cumulative word offset.
int remapShortIndex({
  required List<ShortSegment> oldShorts,
  required List<ShortSegment> newShorts,
  required int oldIndex,
}) {
  if (newShorts.isEmpty) return 0;
  if (oldShorts.isEmpty) return 0;
  final clamped = oldIndex.clamp(0, oldShorts.length - 1);
  var wordsBefore = 0;
  for (var i = 0; i < clamped; i++) {
    wordsBefore += oldShorts[i].wordCount;
  }
  var acc = 0;
  var mapped = 0;
  for (var i = 0; i < newShorts.length; i++) {
    mapped = i;
    acc += newShorts[i].wordCount;
    if (acc > wordsBefore) break;
  }
  return mapped;
}
