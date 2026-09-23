/// Extractive TLDR helpers — no API required.
library;

List<String> _words(String s) =>
    s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

int wordCount(String s) => _words(s).length;

List<String> sentenceSplit(String text) {
  final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  final matches = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$').allMatches(cleaned);
  return matches
      .map((m) => m.group(0)!.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

double _contentScore(String sentence) {
  final words = _words(sentence);
  double score = words.length.clamp(0, 28).toDouble();
  if (RegExp(r'\b(he|she|they|I|we)\b', caseSensitive: false)
      .hasMatch(sentence)) {
    score += 2;
  }
  if (sentence.contains('"') || sentence.contains('“')) score += 3;
  if (RegExp(
    r'\b(said|asked|cried|thought|found|saw|went|came|knew)\b',
    caseSensitive: false,
  ).hasMatch(sentence)) {
    score += 2;
  }
  if (RegExp(r'^(and|but|so|then|now|for|or)\b', caseSensitive: false)
      .hasMatch(sentence.trim())) {
    score -= 2;
  }
  return score;
}

String _clipWords(String text, int keep) {
  final words = _words(text);
  if (words.length <= keep) return text.trim();
  var cut = keep;
  for (var i = keep; i >= (keep * 0.65).floor(); i--) {
    if (RegExp(r'[,;:—–-]$').hasMatch(words[i - 1])) {
      cut = i;
      break;
    }
  }
  return '${words.take(cut).join(' ').replaceAll(RegExp(r'[,;:—–-]+$'), '')}…';
}

/// Compress to ~38% length by keeping high-signal sentences.
String abbreviate(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return trimmed;

  final total = wordCount(trimmed);
  if (total <= 18) return trimmed;

  final targetWords = (total * 0.38).round().clamp(14, total);
  final sentences = sentenceSplit(trimmed);

  if (sentences.length <= 1) return _clipWords(trimmed, targetWords);

  if (sentences.length == 2) {
    final first = sentences.first;
    if (wordCount(first) >= targetWords.clamp(0, 16)) {
      return wordCount(first) > targetWords * 1.35
          ? _clipWords(first, targetWords)
          : first;
    }
    return sentences.join(' ');
  }

  final ranked = sentences
      .asMap()
      .entries
      .map((e) {
        var score = _contentScore(e.value);
        if (e.key == 0) score += 6;
        if (e.key == sentences.length - 1) score += 1;
        return (i: e.key, s: e.value, score: score);
      })
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  final picked = <int>{};
  var words = 0;
  for (final item in ranked) {
    if (words >= targetWords && picked.isNotEmpty) break;
    picked.add(item.i);
    words += wordCount(item.s);
  }
  if (!picked.contains(0)) {
    picked.add(0);
  }

  final ordered = picked.toList()..sort();
  var out = ordered.map((i) => sentences[i]).join(' ');
  if (wordCount(out) > targetWords * 1.4) {
    out = _clipWords(out, targetWords);
  }
  return out;
}

String summarizePassage(String text) {
  final condensed = abbreviate(text);
  final sentences = sentenceSplit(condensed);
  if (sentences.isEmpty) return condensed;
  if (sentences.length == 1) return 'Summary: ${sentences.first}';
  return 'Summary: ${sentences.take(2).join(' ')}';
}

String keyQuotes(String text) {
  final sentences = sentenceSplit(text);
  if (sentences.isEmpty) return text.trim();
  final ranked = sentences
      .map((s) => (s: s, score: _contentScore(s)))
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  final picks = ranked.take(2).map((e) => '“${e.s.replaceAll(RegExp(r'[“”"]'), '').trim()}”');
  return picks.join('\n\n');
}
