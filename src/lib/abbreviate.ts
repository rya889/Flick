/** Extractive abbreviation — keep the plot, cut the padding. No slang. */

function countWords(s: string): string[] {
  return s.trim().split(/\s+/).filter(Boolean);
}

function wordCount(s: string): number {
  return countWords(s).length;
}

function sentenceSplit(text: string): string[] {
  return (
    text
      .replace(/\s+/g, " ")
      .trim()
      .match(/[^.!?]+[.!?]+|[^.!?]+$/g)
      ?.map((s) => s.trim())
      .filter(Boolean) ?? []
  );
}

function contentScore(sentence: string): number {
  const words = countWords(sentence);
  let score = Math.min(words.length, 28);
  if (/\b(he|she|they|I|we)\b/i.test(sentence)) score += 2;
  if (/"|“|”/.test(sentence)) score += 3;
  if (/\b(said|asked|cried|thought|found|saw|went|came|knew)\b/i.test(sentence))
    score += 2;
  if (/^(and|but|so|then|now|for|or)\b/i.test(sentence.trim())) score -= 2;
  return score;
}

/** Clip a long run of words at a soft boundary near `keep`. */
function clipWords(text: string, keep: number): string {
  const words = countWords(text);
  if (words.length <= keep) return text.trim();
  // Prefer cutting after comma / dash near the target
  let cut = keep;
  for (let i = keep; i >= Math.floor(keep * 0.65); i--) {
    if (/[,;:—–-]$/.test(words[i - 1])) {
      cut = i;
      break;
    }
  }
  return `${words.slice(0, cut).join(" ").replace(/[,;:—–-]+$/, "")}…`;
}

/**
 * Compress a passage to ~35–40% length by keeping the highest-signal sentences
 * (always keep opening beat when possible). No slang — just less book.
 */
export function abbreviate(text: string): string {
  const trimmed = text.trim();
  if (!trimmed) return trimmed;

  const total = wordCount(trimmed);
  if (total <= 18) return trimmed;

  const targetWords = Math.max(14, Math.round(total * 0.38));
  const sentences = sentenceSplit(trimmed);

  if (sentences.length <= 1) {
    return clipWords(trimmed, targetWords);
  }

  if (sentences.length === 2) {
    const first = sentences[0];
    if (wordCount(first) >= Math.min(targetWords, 16)) {
      return wordCount(first) > targetWords * 1.35
        ? clipWords(first, targetWords)
        : first;
    }
    return sentences.join(" ");
  }

  const ranked = sentences
    .map((s, i) => ({
      s,
      i,
      score:
        contentScore(s) +
        (i === 0 ? 5 : 0) +
        (i === sentences.length - 1 ? 1 : 0),
    }))
    .sort((a, b) => b.score - a.score);

  const chosen = new Set<number>();
  chosen.add(0);

  let words = wordCount(sentences[0]);
  for (const item of ranked) {
    if (chosen.has(item.i)) continue;
    const w = wordCount(item.s);
    if (words + w > targetWords && chosen.size >= 2) break;
    chosen.add(item.i);
    words += w;
    if (words >= targetWords && chosen.size >= 2) break;
  }

  const ordered = [...chosen]
    .sort((a, b) => a - b)
    .map((i) => sentences[i]);
  let result = ordered.join(" ").replace(/\s+/g, " ").trim();
  if (wordCount(result) > targetWords * 1.25) {
    result = clipWords(result, targetWords);
  }
  return result;
}
