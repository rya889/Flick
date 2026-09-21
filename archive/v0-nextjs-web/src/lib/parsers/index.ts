import { createId } from "../id";
import type { BookFormat, ParsedBook } from "../types";
import { parseEpubFile } from "./epub";
import { parseMobiFile } from "./mobi";
import { parseTxtFile, parseTxtString } from "./txt";

export function detectFormat(fileName: string): BookFormat | null {
  const lower = fileName.toLowerCase();
  if (lower.endsWith(".epub")) return "epub";
  if (lower.endsWith(".mobi") || lower.endsWith(".azw")) return "mobi";
  if (lower.endsWith(".txt")) return "txt";
  return null;
}

export async function parseUploadedFile(file: File): Promise<ParsedBook> {
  const format = detectFormat(file.name);
  if (!format) throw new Error("Unsupported file type. Use EPUB, MOBI, or TXT.");

  const id = createId("book");
  const addedAt = Date.now();

  if (format === "txt") {
    const text = parseTxtString(await parseTxtFile(file));
    return {
      id,
      title: file.name.replace(/\.txt$/i, ""),
      text,
      format,
      sourceLabel: file.name,
      addedAt,
      coverHue: Math.floor(Math.random() * 360),
    };
  }

  if (format === "epub") {
    const { title, author, text } = await parseEpubFile(file);
    return {
      id,
      title,
      author,
      text,
      format,
      sourceLabel: file.name,
      addedAt,
      coverHue: Math.floor(Math.random() * 360),
    };
  }

  const { title, text } = await parseMobiFile(file);
  return {
    id,
    title,
    text,
    format: "mobi",
    sourceLabel: file.name,
    addedAt,
    coverHue: Math.floor(Math.random() * 360),
  };
}

export function parsePastedText(text: string, title = "Pasted text"): ParsedBook {
  return {
    id: createId("book"),
    title,
    text: parseTxtString(text),
    format: "paste",
    sourceLabel: "Paste",
    addedAt: Date.now(),
    coverHue: Math.floor(Math.random() * 360),
  };
}

export async function parseFromUrlPayload(
  payload: { text: string; title?: string; author?: string },
): Promise<ParsedBook> {
  return {
    id: createId("book"),
    title: payload.title?.trim() || "From URL",
    author: payload.author,
    text: parseTxtString(payload.text),
    format: "url",
    sourceLabel: "URL",
    addedAt: Date.now(),
    coverHue: Math.floor(Math.random() * 360),
  };
}

export async function parseSample(
  sampleId: string,
  title: string,
  author: string,
  path: string,
  hue: number,
): Promise<ParsedBook> {
  const res = await fetch(path);
  if (!res.ok) throw new Error("Failed to load sample");
  const text = parseTxtString(await res.text());
  return {
    id: sampleId,
    title,
    author,
    text,
    format: "sample",
    sourceLabel: title,
    addedAt: Date.now(),
    coverHue: hue,
  };
}
