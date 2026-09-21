import type { ShortSegment } from "./types";

const KEY_STORAGE = "flick-ai-key";

export function getStoredAiKey(): string {
  if (typeof window === "undefined") return "";
  try {
    return localStorage.getItem(KEY_STORAGE)?.trim() ?? "";
  } catch {
    return "";
  }
}

export function setStoredAiKey(key: string): void {
  if (typeof window === "undefined") return;
  try {
    const v = key.trim();
    if (v) localStorage.setItem(KEY_STORAGE, v);
    else localStorage.removeItem(KEY_STORAGE);
  } catch {
    // ignore
  }
}

export type TldrStatus = {
  configured: boolean;
  hint?: string;
};

export async function fetchTldrStatus(): Promise<TldrStatus> {
  try {
    const res = await fetch("/api/tldr");
    if (!res.ok) return { configured: false };
    return (await res.json()) as TldrStatus;
  } catch {
    return { configured: false };
  }
}

export async function requestAiTldrs(
  passages: { id: string; text: string; chapterTitle?: string }[],
  meta?: { title?: string; author?: string },
): Promise<{ tldrs: { id: string; tldr: string }[]; error?: string; code?: string }> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };
  const key = getStoredAiKey();
  if (key) headers["x-ai-key"] = key;

  const res = await fetch("/api/tldr", {
    method: "POST",
    headers,
    body: JSON.stringify({
      passages,
      title: meta?.title,
      author: meta?.author,
    }),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    return {
      tldrs: [],
      error: (data as { error?: string }).error ?? `HTTP ${res.status}`,
      code: (data as { code?: string }).code,
    };
  }
  return { tldrs: (data as { tldrs: { id: string; tldr: string }[] }).tldrs ?? [] };
}

/** True when this short still needs a real AI condensation. */
export function needsAiTldr(short: ShortSegment): boolean {
  return short.tldrSource !== "ai";
}
