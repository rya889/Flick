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
  if (sentence.contains('"') || sentence.contains('“') || sentence.contains('”')) {
    score += 4;
  }
  if (RegExp(
    r'\b(said|asked|cried|thought|found|saw|went|came|knew|felt|seemed)\b',
    caseSensitive: false,
  ).hasMatch(sentence)) {
    score += 2;
  }
  if (RegExp(r'^(and|but|so|then|now|for|or)\b', caseSensitive: false)
      .hasMatch(sentence.trim())) {
    score -= 2;
  }
  // Prefer mid-length informative lines over tiny fragments.
  if (words.length < 5) score -= 4;
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

/// Compress to ~45% length by keeping high-signal sentences in order.
/// Avoids the "first sentence only" trap on short two-sentence passages.
String abbreviate(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return trimmed;

  final total = wordCount(trimmed);
  if (total <= 22) return trimmed;

  final targetWords = (total * 0.45).round().clamp(18, total);
  final sentences = sentenceSplit(trimmed);

  if (sentences.length <= 1) return _clipWords(trimmed, targetWords);

  final ranked = sentences
      .asMap()
      .entries
      .map((e) {
        var score = _contentScore(e.value);
        // Mild position bias — do not dominate scoring.
        if (e.key == 0) score += 1.5;
        if (e.key == sentences.length - 1) score += 0.5;
        return (i: e.key, s: e.value, score: score);
      })
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  final picked = <int>{};
  var words = 0;
  for (final item in ranked) {
    if (words >= targetWords && picked.length >= 2) break;
    if (words >= targetWords && picked.isNotEmpty) break;
    picked.add(item.i);
    words += wordCount(item.s);
  }

  // Always try to keep at least two sentences when the passage has them
  // and we're still under ~55% of original length.
  if (sentences.length >= 2 && picked.length == 1) {
    final only = picked.first;
    final second = only + 1 < sentences.length ? only + 1 : only - 1;
    if (second >= 0) {
      final candidate = wordCount(sentences[only]) + wordCount(sentences[second]);
      if (candidate <= (total * 0.65).round().clamp(targetWords, total)) {
        picked.add(second);
      }
    }
  }

  final ordered = picked.toList()..sort();
  var out = ordered.map((i) => sentences[i]).join(' ');
  if (wordCount(out) > targetWords * 1.45) {
    out = _clipWords(out, targetWords);
  }
  return out;
}

/// Gist of the passage: top content sentences in reading order (not just #1).
String summarizePassage(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return trimmed;

  final sentences = sentenceSplit(trimmed);
  if (sentences.isEmpty) return trimmed;
  if (sentences.length == 1) return sentences.first;

  final ranked = sentences
      .asMap()
      .entries
      .map((e) => (i: e.key, s: e.value, score: _contentScore(e.value)))
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  final take = sentences.length >= 4 ? 3 : 2;
  final picked = ranked.take(take).map((e) => e.i).toList()..sort();
  var out = picked.map((i) => sentences[i]).join(' ');
  final maxWords = (wordCount(trimmed) * 0.4).round().clamp(20, 80);
  if (wordCount(out) > maxWords) {
    out = _clipWords(out, maxWords);
  }
  return out;
}

String keyQuotes(String text) {
  final sentences = sentenceSplit(text);
  if (sentences.isEmpty) return text.trim();

  final dialogue = sentences
      .where((s) => s.contains('"') || s.contains('“') || s.contains('”'))
      .toList();

  final pool = dialogue.isNotEmpty ? dialogue : sentences;
  final ranked = pool
      .map((s) => (s: s, score: _contentScore(s)))
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  final picks = ranked.take(2).map((e) {
    final cleaned = e.s.replaceAll(RegExp(r'[“”"]'), '').trim();
    return '“$cleaned”';
  });
  return picks.join('\n\n');
}
