import { abbreviate } from "./abbreviate";
import type { ParsedBook, ShortSegment } from "./types";

const TARGET_WORDS = 55;
const MIN_WORDS = 28;

const CHAPTER_HEADING =
  /^(?:CHAPTER|Chapter|PART|Part|BOOK|Book|SECTION|Section)\s+[\divxlcdmDIVXLCDM0-9IVXivx]+(?:[.:\s].*)?$/;

function countWords(s: string): number {
  return s.trim().split(/\s+/).filter(Boolean).length;
}

function splitParagraphs(text: string): string[] {
  return text
    .split(/\n\s*\n+/)
    .map((p) => p.replace(/\s+/g, " ").trim())
    .filter((p) => p.length > 0);
}

function isChapterHeading(line: string): boolean {
  const t = line.trim();
  if (CHAPTER_HEADING.test(t)) return true;
  // Single-line ALL CAPS short titles sometimes used as chapter markers
  if (/^[A-Z][A-Z0-9 ,.'-]{3,60}$/.test(t) && countWords(t) <= 8) return true;
  return false;
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

export interface ChapterMeta {
  index: number;
  title: string;
  startShortIndex: number;
}

export function buildShorts(book: ParsedBook): ShortSegment[] {
  const paragraphs = splitParagraphs(book.text);
  type Piece = { text: string; chapterIndex: number; chapterTitle: string };
  const pieces: Piece[] = [];

  let chapterIndex = 0;
  let chapterTitle = "Chapter 1";
  let started = false;

  for (const p of paragraphs) {
    if (isChapterHeading(p)) {
      chapterIndex = started ? chapterIndex + 1 : 0;
      chapterTitle = p.slice(0, 80);
      started = true;
      continue;
    }
    if (countWords(p) < 8) continue;
    started = true;

    const chunks =
      countWords(p) <= TARGET_WORDS ? [p] : chunkParagraph(p);
    for (const text of chunks) {
      pieces.push({ text, chapterIndex, chapterTitle });
    }
  }

  if (pieces.length === 0 && book.text.trim()) {
    pieces.push({
      text: book.text.trim().slice(0, 800),
      chapterIndex: 0,
      chapterTitle: "Chapter 1",
    });
  }

  return pieces.map((piece, index) => ({
    id: `${book.id}-short-${index}`,
    bookId: book.id,
    index,
    original: piece.text,
    tldr: abbreviate(piece.text),
    tldrSource: "extractive" as const,
    wordCount: countWords(piece.text),
    chapterIndex: piece.chapterIndex,
    chapterTitle: piece.chapterTitle,
  }));
}

export function listChapters(shorts: ShortSegment[]): ChapterMeta[] {
  const map = new Map<number, ChapterMeta>();
  for (const s of shorts) {
    const ci = s.chapterIndex ?? 0;
    if (!map.has(ci)) {
      map.set(ci, {
        index: ci,
        title: s.chapterTitle || `Chapter ${ci + 1}`,
        startShortIndex: s.index,
      });
    }
  }
  return [...map.values()].sort((a, b) => a.index - b.index);
}

/** Normalize legacy shorts (e.g. `viral` field) into the current shape. */
export function normalizeShort(short: ShortSegment & { viral?: string }): ShortSegment {
  const tldr =
    short.tldr ||
    short.viral ||
    abbreviate(short.original);
  return {
    ...short,
    tldr,
    tldrSource: short.tldrSource ?? (short.viral ? "extractive" : short.tldr ? short.tldrSource : "extractive"),
    chapterIndex: short.chapterIndex ?? 0,
    chapterTitle: short.chapterTitle || "Chapter 1",
  };
}

export function shortDisplayText(
  short: ShortSegment,
  voice: "original" | "tldr",
): string {
  if (voice === "tldr") {
    const n = normalizeShort(short);
    return n.tldr || abbreviate(n.original);
  }
  return short.original;
}
