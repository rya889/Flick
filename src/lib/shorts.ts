import { sensationalize } from "./sensationalize";
import type { ParsedBook, ShortSegment } from "./types";

const TARGET_WORDS = 55;
const MIN_WORDS = 28;

function countWords(s: string): number {
  return s.trim().split(/\s+/).filter(Boolean).length;
}

function splitParagraphs(text: string): string[] {
  return text
    .split(/\n\s*\n+/)
    .map((p) => p.replace(/\s+/g, " ").trim())
    .filter((p) => p.length > 20);
}

function chunkParagraph(paragraph: string): string[] {
  const sentences = paragraph.split(/(?<=[.!?])\s+/).filter(Boolean);
  const chunks: string[] = [];
  let current = "";

  for (const sentence of sentences) {
    const candidate = current ? `${current} ${sentence}` : sentence;
    const words = countWords(candidate);
    if (words > TARGET_WORDS && current) {
      chunks.push(current.trim());
      current = sentence;
    } else if (words >= MIN_WORDS && !current) {
      chunks.push(candidate.trim());
      current = "";
    } else {
      current = candidate;
    }
  }
  if (current.trim()) chunks.push(current.trim());
  return chunks;
}

export function buildShorts(book: ParsedBook): ShortSegment[] {
  const paragraphs = splitParagraphs(book.text);
  const rawChunks: string[] = [];

  for (const p of paragraphs) {
    if (countWords(p) <= TARGET_WORDS) {
      rawChunks.push(p);
    } else {
      rawChunks.push(...chunkParagraph(p));
    }
  }

  if (rawChunks.length === 0 && book.text.trim()) {
    rawChunks.push(book.text.trim().slice(0, 800));
  }

  return rawChunks.map((original, index) => ({
    id: `${book.id}-short-${index}`,
    bookId: book.id,
    index,
    original,
    viral: sensationalize(original),
    wordCount: countWords(original),
  }));
}

export function shortDisplayText(short: ShortSegment, voice: "original" | "viral"): string {
  return voice === "viral" ? short.viral : short.original;
}
