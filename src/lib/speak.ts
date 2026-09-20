/** iOS / Chrome-safe Web Speech helpers. */

type SpeakHandle = {
  stop: () => void;
};

let unlocked = false;
let resumeTimer: number | null = null;
let active = false;

function synth(): SpeechSynthesis | null {
  if (typeof window === "undefined") return null;
  return window.speechSynthesis ?? null;
}

export function speechSupported(): boolean {
  return Boolean(synth());
}

/** Must run inside a real tap/click. Unlocks WebKit speech for later calls. */
export function unlockSpeech(): void {
  const s = synth();
  if (!s || unlocked) return;
  try {
    s.cancel();
    const warm = new SpeechSynthesisUtterance(" ");
    warm.volume = 0.01;
    warm.rate = 2;
    warm.pitch = 1;
    s.speak(warm);
    s.cancel();
    unlocked = true;
  } catch {
    // ignore
  }
}

function pickVoice(): SpeechSynthesisVoice | null {
  const s = synth();
  if (!s) return null;
  const voices = s.getVoices();
  if (!voices.length) return null;
  return (
    voices.find((v) => v.lang === "en-US" && /samantha|karen|moira|daniel|enhanced/i.test(v.name)) ||
    voices.find((v) => v.lang.startsWith("en") && v.localService) ||
    voices.find((v) => v.lang.startsWith("en")) ||
    voices[0] ||
    null
  );
}

/** Warm the voice list (iOS often returns [] until this runs). */
export function primeVoices(): void {
  const s = synth();
  if (!s) return;
  s.getVoices();
  if (typeof s.addEventListener === "function") {
    s.addEventListener("voiceschanged", () => s.getVoices(), { once: true });
  }
}

function chunkText(text: string, maxLen = 180): string[] {
  const clean = text.replace(/\s+/g, " ").trim();
  if (!clean) return [];
  if (clean.length <= maxLen) return [clean];

  const parts: string[] = [];
  const sentences = clean.match(/[^.!?]+[.!?]+|[^.!?]+$/g) ?? [clean];
  let buf = "";
  for (const sentence of sentences) {
    const next = buf ? `${buf} ${sentence.trim()}` : sentence.trim();
    if (next.length > maxLen && buf) {
      parts.push(buf);
      if (sentence.trim().length > maxLen) {
        // Hard-split long sentence on commas / spaces
        let rest = sentence.trim();
        while (rest.length > maxLen) {
          let cut = rest.lastIndexOf(" ", maxLen);
          if (cut < maxLen * 0.5) cut = maxLen;
          parts.push(rest.slice(0, cut).trim());
          rest = rest.slice(cut).trim();
        }
        buf = rest;
      } else {
        buf = sentence.trim();
      }
    } else {
      buf = next;
    }
  }
  if (buf) parts.push(buf);
  return parts.filter(Boolean);
}

function startResumeKeepalive(): void {
  stopResumeKeepalive();
  // Safari/iOS Chrome pause speech after ~15s unless resumed
  resumeTimer = window.setInterval(() => {
    const s = synth();
    if (!s || !active) return;
    if (s.speaking && s.paused) s.resume();
    // Some iOS builds report speaking=false while paused mid-utterance
    if (s.paused) s.resume();
  }, 4000);
}

function stopResumeKeepalive(): void {
  if (resumeTimer != null) {
    window.clearInterval(resumeTimer);
    resumeTimer = null;
  }
}

export function stopSpeaking(): void {
  active = false;
  stopResumeKeepalive();
  const s = synth();
  if (s) {
    try {
      s.cancel();
    } catch {
      // ignore
    }
  }
}

/**
 * Speak text with iOS/Chrome workarounds. Call from a click/tap handler.
 * Returns a handle; onEnd fires when the full queue finishes (or on error/stop).
 */
export function speakText(
  text: string,
  opts: {
    rate?: number;
    onEnd?: () => void;
    onError?: (reason: string) => void;
  } = {},
): SpeakHandle {
  const s = synth();
  if (!s) {
    opts.onError?.("Speech not supported in this browser");
    return { stop: stopSpeaking };
  }

  unlockSpeech();
  stopSpeaking();
  active = true;

  const rate = Math.min(1.4, Math.max(0.75, opts.rate ?? 1));
  const chunks = chunkText(text);
  if (chunks.length === 0) {
    active = false;
    opts.onEnd?.();
    return { stop: stopSpeaking };
  }

  // Force voice list load
  s.getVoices();
  const voice = pickVoice();
  let i = 0;
  let finished = false;

  const finish = (ok: boolean, reason?: string) => {
    if (finished) return;
    finished = true;
    active = false;
    stopResumeKeepalive();
    if (ok) opts.onEnd?.();
    else opts.onError?.(reason ?? "Speech failed");
  };

  const speakNext = () => {
    if (!active || finished) return;
    if (i >= chunks.length) {
      finish(true);
      return;
    }
    const u = new SpeechSynthesisUtterance(chunks[i]);
    u.rate = rate;
    u.pitch = 1;
    u.volume = 1;
    if (voice) u.voice = voice;
    u.lang = voice?.lang || "en-US";
    u.onend = () => {
      i += 1;
      speakNext();
    };
    u.onerror = (ev) => {
      // "interrupted" / "canceled" from our own cancel — ignore
      const err = (ev as SpeechSynthesisErrorEvent).error;
      if (err === "interrupted" || err === "canceled") {
        finish(false, err);
        return;
      }
      finish(false, err || "error");
    };
    try {
      s.speak(u);
    } catch (e) {
      finish(false, e instanceof Error ? e.message : "speak failed");
    }
  };

  startResumeKeepalive();
  // Kick immediately in the same user-gesture stack
  speakNext();

  // If nothing started within a beat, surface failure (common silent iOS drop)
  window.setTimeout(() => {
    if (!active || finished) return;
    if (!s.speaking && !s.pending) {
      finish(false, "Speech did not start — try again or check Silent Mode");
    }
  }, 700);

  return { stop: stopSpeaking };
}
