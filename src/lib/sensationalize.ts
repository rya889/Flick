import type { VoiceMode } from "./types";

const HOOKS = [
  "Wait—",
  "Nobody talks about this:",
  "This part hits different:",
  "POV:",
  "The way this unfolds…",
];

const EMPHASIS = [
  "literally",
  "actually",
  "unhinged",
  "devastating",
  "iconic",
];

function pick<T>(arr: T[], seed: number): T {
  return arr[Math.abs(seed) % arr.length];
}

function hashSeed(text: string): number {
  let h = 0;
  for (let i = 0; i < text.length; i++) {
    h = (h * 31 + text.charCodeAt(i)) | 0;
  }
  return h;
}

/** Local “viral voice” transform — no network, deterministic per segment. */
export function sensationalize(text: string): string {
  const trimmed = text.trim();
  if (!trimmed) return trimmed;

  const seed = hashSeed(trimmed);
  const hook = pick(HOOKS, seed);
  const emphasis = pick(EMPHASIS, seed >> 3);

  let body = trimmed
    .replace(/\b(very|really|quite)\b/gi, "")
    .replace(/\s{2,}/g, " ")
    .trim();

  const sentences = body.split(/(?<=[.!?])\s+/).filter(Boolean);
  if (sentences.length === 0) return `${hook} ${body}`;

  const punch = sentences[0];
  const rest = sentences.slice(1).join(" ");

  const capped =
    punch.length > 120 ? `${punch.slice(0, 117).trim()}…` : punch;

  const tail = rest ? ` And then— ${rest}` : "";
  return `${hook} ${capped} (${emphasis}).${tail}`;
}

export function applyVoice(text: string, mode: VoiceMode): string {
  if (mode === "viral") return sensationalize(text);
  return text;
}
