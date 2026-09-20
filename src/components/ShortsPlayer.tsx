"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { listChapters, shortDisplayText } from "@/lib/shorts";
import {
  primeVoices,
  speakText,
  speechSupported,
  stopSpeaking,
  unlockSpeech,
} from "@/lib/speak";
import { needsAiTldr, requestAiTldrs } from "@/lib/tldr-client";
import type { CatalogBook, ShortSegment, VoiceMode } from "@/lib/types";
import { VoiceToggle } from "./VoiceToggle";
import { WordReveal } from "./WordReveal";

const SPEEDS = [0.75, 1, 1.25, 1.5, 2];
const PREFETCH = 4;

interface ShortsPlayerProps {
  book: CatalogBook;
  shorts: ShortSegment[];
  initialIndex: number;
  voice: VoiceMode;
  playbackSpeed: number;
  liked: Set<string>;
  saved: Set<string>;
  onVoiceChange: (v: VoiceMode) => void;
  onSpeedChange: (s: number) => void;
  onLike: (id: string) => void;
  onSave: (id: string) => void;
  onProgress: (index: number, wordOffset: number) => void;
  onTickMinutes: (fraction: number) => void;
  onShortsUpdate: (shorts: ShortSegment[]) => void;
  onClose: () => void;
}

export function ShortsPlayer({
  book,
  shorts,
  initialIndex,
  voice,
  playbackSpeed,
  liked,
  saved,
  onVoiceChange,
  onSpeedChange,
  onLike,
  onSave,
  onProgress,
  onTickMinutes,
  onShortsUpdate,
  onClose,
}: ShortsPlayerProps) {
  const [index, setIndex] = useState(initialIndex);
  const [wordIndex, setWordIndex] = useState(0);
  const [paused, setPaused] = useState(false);
  const [heartBurst, setHeartBurst] = useState(false);
  const [listening, setListening] = useState(false);
  const [copied, setCopied] = useState(false);
  const [tldrBusy, setTldrBusy] = useState(false);
  const [tldrError, setTldrError] = useState<string | null>(null);
  const [listenError, setListenError] = useState<string | null>(null);
  const touchStart = useRef<{ x: number; y: number; t: number } | null>(null);
  const lastTap = useRef(0);
  const usedTouch = useRef(false);
  const minutesAccumulator = useRef(0);
  const speakRef = useRef<SpeechSynthesisUtterance | null>(null);
  const inflight = useRef<Set<string>>(new Set());
  const listenAdvance = useRef(false);

  const short = shorts[index];
  const display = short ? shortDisplayText(short, voice) : "";
  const words = display.split(/\s+/).filter(Boolean);
  const chapters = useMemo(() => listChapters(shorts), [shorts]);
  const chapterPos = useMemo(() => {
    if (!short || chapters.length === 0) return 0;
    const ci = short.chapterIndex ?? 0;
    const found = chapters.findIndex((c) => c.index === ci);
    return found >= 0 ? found : 0;
  }, [short, chapters]);
  const currentChapter = chapters[chapterPos];

  const ensureAiTldrs = useCallback(
    async (from: number) => {
      if (voice !== "tldr") return;
      const slice = shorts.slice(from, from + PREFETCH).filter(needsAiTldr);
      if (slice.length === 0) return;

      const ids = slice.map((s) => s.id).filter((id) => !inflight.current.has(id));
      if (ids.length === 0) return;
      ids.forEach((id) => inflight.current.add(id));

      const waitingOnCurrent = Boolean(short && ids.includes(short.id));
      if (waitingOnCurrent) {
        setTldrBusy(true);
        setTldrError(null);
      }

      try {
        const { tldrs, error, code } = await requestAiTldrs(
          slice
            .filter((s) => ids.includes(s.id))
            .map((s) => ({
              id: s.id,
              text: s.original,
              chapterTitle: s.chapterTitle,
            })),
          { title: book.title, author: book.author },
        );

        if (error) {
          if (waitingOnCurrent) {
            setTldrError(
              code === "NO_AI_KEY"
                ? "Add an AI key (header · AI key) for real TLDRs"
                : error,
            );
          }
          return;
        }

        if (tldrs.length === 0) return;

        const map = new Map(tldrs.map((t) => [t.id, t.tldr]));
        const next = shorts.map((s) => {
          const condensed = map.get(s.id);
          if (!condensed) return s;
          return { ...s, tldr: condensed, tldrSource: "ai" as const };
        });
        onShortsUpdate(next);
        setTldrError(null);
      } finally {
        ids.forEach((id) => inflight.current.delete(id));
        if (waitingOnCurrent) setTldrBusy(false);
      }
    },
    [book.author, book.title, onShortsUpdate, short, shorts, voice],
  );

  useEffect(() => {
    void ensureAiTldrs(index);
  }, [ensureAiTldrs, index, voice]);

  const stopListen = useCallback(() => {
    stopSpeaking();
    speakRef.current = null;
    setListening(false);
  }, []);

  useEffect(() => {
    primeVoices();
  }, []);

  useEffect(() => {
    setIndex(initialIndex);
  }, [initialIndex, book.id]);

  useEffect(() => {
    setWordIndex(0);
    // Keep audio alive when Listen advances to the next short
    if (!listenAdvance.current) stopListen();
    listenAdvance.current = false;
  }, [index, voice, stopListen]);

  useEffect(() => () => stopListen(), [stopListen]);

  useEffect(() => {
    if (!short || paused || listening || tldrBusy) return;
    if (voice === "tldr" && needsAiTldr(short)) return;
    const wpm = 180 * playbackSpeed;
    const msPerWord = 60000 / wpm;
    const timer = window.setInterval(() => {
      setWordIndex((w) => {
        if (w >= words.length - 1) return w;
        return w + 1;
      });
      minutesAccumulator.current += msPerWord / 60000;
      if (minutesAccumulator.current >= 0.25) {
        onTickMinutes(minutesAccumulator.current);
        minutesAccumulator.current = 0;
      }
    }, msPerWord);
    return () => clearInterval(timer);
  }, [short, paused, listening, playbackSpeed, words.length, onTickMinutes, tldrBusy, voice]);

  useEffect(() => {
    onProgress(index, wordIndex);
  }, [index, wordIndex, onProgress]);

  // Auto-advance when words finish (unless listening / condensing)
  useEffect(() => {
    if (listening || paused || tldrBusy) return;
    if (voice === "tldr" && short && needsAiTldr(short)) return;
    if (words.length > 0 && wordIndex >= words.length - 1) {
      const t = window.setTimeout(() => {
        if (index < shorts.length - 1) setIndex((i) => i + 1);
      }, 700);
      return () => window.clearTimeout(t);
    }
  }, [wordIndex, words.length, index, shorts.length, listening, paused, tldrBusy, voice, short]);

  const goNext = useCallback(() => {
    stopListen();
    if (index < shorts.length - 1) setIndex((i) => i + 1);
  }, [index, shorts.length, stopListen]);

  const goPrev = useCallback(() => {
    stopListen();
    if (index > 0) setIndex((i) => i - 1);
  }, [index, stopListen]);

  const goChapter = useCallback(
    (dir: -1 | 1) => {
      stopListen();
      const nextPos = chapterPos + dir;
      if (nextPos < 0 || nextPos >= chapters.length) return;
      setIndex(chapters[nextPos].startShortIndex);
    },
    [chapterPos, chapters, stopListen],
  );

  const burstLike = useCallback(() => {
    if (!short) return;
    setHeartBurst(true);
    window.setTimeout(() => setHeartBurst(false), 650);
    if (!liked.has(short.id)) onLike(short.id);
    try {
      navigator.vibrate?.(10);
    } catch {
      // ignore
    }
  }, [liked, onLike, short]);

  const toggleListen = useCallback(() => {
    // Unlock must stay in the tap stack (iOS Chrome / WebKit)
    unlockSpeech();
    setListenError(null);

    if (!short) return;
    if (listening) {
      stopListen();
      return;
    }
    if (!speechSupported()) {
      setListenError("Speech isn’t available in this browser");
      return;
    }

    setPaused(true);
    setListening(true);
    speakText(display, {
      rate: playbackSpeed,
      onEnd: () => {
        setListening(false);
        if (index < shorts.length - 1) {
          listenAdvance.current = true;
          setIndex((i) => i + 1);
        }
      },
      onError: (reason) => {
        setListening(false);
        if (reason === "interrupted" || reason === "canceled") return;
        setListenError(
          reason.includes("Silent")
            ? reason
            : "Couldn’t play audio — check Silent Mode, then tap Listen again",
        );
      },
    });
  }, [display, index, listening, playbackSpeed, short, shorts.length, stopListen]);

  const shareQuote = useCallback(async () => {
    if (!short) return;
    const payload = {
      title: book.title,
      text: `"${display.slice(0, 280)}${display.length > 280 ? "…" : ""}"\n— ${book.author ?? book.title} · via Flick`,
    };
    try {
      if (navigator.share) {
        await navigator.share(payload);
      } else {
        await navigator.clipboard.writeText(payload.text);
        setCopied(true);
        window.setTimeout(() => setCopied(false), 1600);
      }
    } catch {
      try {
        await navigator.clipboard.writeText(payload.text);
        setCopied(true);
        window.setTimeout(() => setCopied(false), 1600);
      } catch {
        // ignore
      }
    }
  }, [book.author, book.title, display, short]);

  /** Stage-only gestures — never attached to chrome/controls. */
  const onStageTouchStart = (e: React.TouchEvent) => {
    usedTouch.current = true;
    unlockSpeech(); // warm WebKit speech early on iOS
    const t = e.touches[0];
    touchStart.current = { x: t.clientX, y: t.clientY, t: Date.now() };
  };

  const onStageTouchEnd = (e: React.TouchEvent) => {
    const start = touchStart.current;
    touchStart.current = null;
    if (!start) return;

    const t = e.changedTouches[0];
    const dy = start.y - t.clientY;
    const dx = t.clientX - start.x;
    const dt = Date.now() - start.t;

    if (Math.abs(dy) > 50 && Math.abs(dy) > Math.abs(dx) * 1.2) {
      if (dy > 0) goNext();
      else goPrev();
      return;
    }

    if (Math.abs(dx) > 60 && Math.abs(dx) > Math.abs(dy) * 1.2) {
      if (dx > 0) goPrev();
      else goNext();
      return;
    }

    if (dt < 350 && Math.abs(dy) < 28 && Math.abs(dx) < 28) {
      const now = Date.now();
      if (now - lastTap.current < 280) {
        burstLike();
        lastTap.current = 0;
        return;
      }
      lastTap.current = now;
      // Defer single-tap so double-tap can cancel pause toggle
      window.setTimeout(() => {
        if (lastTap.current === 0) return;
        const age = Date.now() - lastTap.current;
        if (age >= 270 && age < 400) {
          // zone from touch X relative to viewport
          const w = window.innerWidth;
          if (t.clientX < w * 0.28) goPrev();
          else if (t.clientX > w * 0.72) goNext();
          else setPaused((p) => !p);
        }
      }, 280);
    }
  };

  const onStageClick = (e: React.MouseEvent<HTMLDivElement>) => {
    // Ignore synthetic clicks after touch (avoids double page-turn)
    if (usedTouch.current) {
      usedTouch.current = false;
      return;
    }
    if (e.detail === 2) {
      burstLike();
      return;
    }
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const w = rect.width;
    if (x < w * 0.28) goPrev();
    else if (x > w * 0.72) goNext();
    else setPaused((p) => !p);
  };

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowDown" || e.key === "j" || e.key === "ArrowRight") goNext();
      if (e.key === "ArrowUp" || e.key === "k" || e.key === "ArrowLeft") goPrev();
      if (e.key === " ") {
        e.preventDefault();
        setPaused((p) => !p);
      }
      if (e.key === "l") burstLike();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [burstLike, goNext, goPrev]);

  if (!short) return null;

  const hue = book.coverHue ?? 24;
  const progressPct = words.length ? ((wordIndex + 1) / words.length) * 100 : 0;

  // Sliding story pips
  const pipWindow = 10;
  let pipStart = 0;
  if (shorts.length > pipWindow) {
    pipStart = Math.min(
      Math.max(0, index - Math.floor(pipWindow / 2)),
      shorts.length - pipWindow,
    );
  }
  const pips = shorts.slice(
    pipStart,
    shorts.length > pipWindow ? pipStart + pipWindow : shorts.length,
  );

  return (
    <div
      className="fixed inset-0 z-50 flex flex-col bg-black"
      style={{ paddingTop: "env(safe-area-inset-top)", paddingBottom: "env(safe-area-inset-bottom)" }}
    >
      <div
        className="absolute inset-0 opacity-90"
        style={{
          background: `radial-gradient(ellipse at 30% 20%, hsl(${hue} 45% 22%) 0%, #0a0908 55%, #050504 100%)`,
        }}
      />

      {/* Top chrome — outside gesture stage */}
      <div className="relative z-20 flex shrink-0 flex-col gap-2 px-3 pt-2">
        <div className="flex gap-1">
          {pips.map((s, local) => {
            const i = pipStart + local;
            return (
              <div key={s.id} className="h-[2.5px] flex-1 overflow-hidden rounded-full bg-white/25">
                <div
                  className="h-full rounded-full bg-white"
                  style={{
                    width:
                      i < index
                        ? "100%"
                        : i === index
                          ? `${Math.max(4, progressPct)}%`
                          : "0%",
                  }}
                />
              </div>
            );
          })}
        </div>
        <div className="flex items-center justify-between gap-3">
          <button
            type="button"
            onClick={onClose}
            className="min-h-10 rounded-full bg-black/40 px-3 py-1.5 text-sm text-white backdrop-blur"
          >
            ← Library
          </button>
          <VoiceToggle mode={voice} onChange={onVoiceChange} />
        </div>
        {chapters.length > 1 && (
          <div className="flex items-center gap-2">
            <button
              type="button"
              disabled={chapterPos <= 0}
              onClick={() => goChapter(-1)}
              className="min-h-9 shrink-0 rounded-full bg-black/40 px-3 py-1.5 text-xs text-white backdrop-blur disabled:opacity-30"
              aria-label="Previous chapter"
            >
              ‹ Ch
            </button>
            <p className="min-w-0 flex-1 truncate text-center text-[11px] text-white/70">
              {currentChapter?.title ?? "Chapter"}
              <span className="text-white/40">
                {" "}
                · {chapterPos + 1}/{chapters.length}
              </span>
            </p>
            <button
              type="button"
              disabled={chapterPos >= chapters.length - 1}
              onClick={() => goChapter(1)}
              className="min-h-9 shrink-0 rounded-full bg-black/40 px-3 py-1.5 text-xs text-white backdrop-blur disabled:opacity-30"
              aria-label="Next chapter"
            >
              Ch ›
            </button>
          </div>
        )}
      </div>

      {/* Gesture stage only — left / center / right */}
      <div
        className="relative z-10 flex min-h-0 min-w-0 flex-1 flex-col justify-center overflow-y-auto px-4 py-3 sm:px-6"
        onTouchStart={onStageTouchStart}
        onTouchEnd={onStageTouchEnd}
        onClick={onStageClick}
        role="presentation"
      >
        <p className="pointer-events-none mb-3 shrink-0 truncate text-center font-display text-xs uppercase tracking-[0.2em] text-[var(--signal)]">
          {book.title}
          {voice === "tldr" ? " · TLDR" : ""}
        </p>
        {tldrBusy && (
          <p className="pointer-events-none mb-2 shrink-0 text-center text-xs text-[var(--signal)]">
            Condensing with AI…
          </p>
        )}
        {tldrError && (
          <p className="pointer-events-none mb-2 shrink-0 text-center text-xs text-amber-200/90">
            {tldrError}
          </p>
        )}
        {paused && !listening && !tldrBusy && (
          <p className="pointer-events-none mb-2 shrink-0 text-center text-xs text-white/50">
            Paused — tap center · double-tap like
          </p>
        )}
        {listening && (
          <p className="pointer-events-none mb-2 shrink-0 text-center text-xs text-[var(--signal)]">
            Listening…
          </p>
        )}
        {listenError && (
          <p className="pointer-events-none mb-2 shrink-0 text-center text-xs text-amber-200/90">
            {listenError}
          </p>
        )}
        <div className="pointer-events-none min-w-0 w-full">
          <WordReveal
            text={display}
            activeIndex={listening || tldrBusy ? words.length : wordIndex}
            paused={(paused && !listening) || tldrBusy}
          />
        </div>

        <p className="pointer-events-none mt-4 shrink-0 text-center text-[11px] text-white/40">
          {index + 1}/{shorts.length}
          {short.tldrSource === "ai" && voice === "tldr" ? " · AI" : ""}
          {chapters.length <= 1 && short.chapterTitle
            ? ` · ${short.chapterTitle}`
            : ""}
          {" · left back · right next"}
        </p>
      </div>

      {/* Bottom rail — separate from stage, cannot turn pages */}
      <div className="relative z-20 flex shrink-0 items-center justify-between gap-3 px-4 pb-3 pt-1">
        <div className="flex flex-col gap-2">
          <button
            type="button"
            className={`min-h-11 rounded-full px-3 py-2 text-sm ${
              liked.has(short.id) ? "bg-[var(--signal)]/25 text-[var(--signal)]" : "bg-black/40 text-white"
            }`}
            onClick={() => onLike(short.id)}
          >
            {liked.has(short.id) ? "♥ Liked" : "♡ Like"}
          </button>
          <button
            type="button"
            className={`min-h-11 rounded-full px-3 py-2 text-sm ${
              saved.has(short.id) ? "bg-amber-400/20 text-amber-200" : "bg-black/40 text-white"
            }`}
            onClick={() => onSave(short.id)}
          >
            {saved.has(short.id) ? "Saved" : "Save"}
          </button>
        </div>

        <div className="flex flex-col items-end gap-2">
          <button
            type="button"
            className={`min-h-11 rounded-full px-3 py-2 text-sm ${
              listening ? "bg-[var(--signal)] text-white" : "bg-black/40 text-white"
            }`}
            onPointerDown={() => unlockSpeech()}
            onClick={toggleListen}
          >
            {listening ? "Stop" : "Listen"}
          </button>
          <button
            type="button"
            className="min-h-11 rounded-full bg-black/40 px-3 py-2 text-sm text-white"
            onClick={shareQuote}
          >
            {copied ? "Copied" : "Share"}
          </button>
          <div className="flex gap-1 rounded-full bg-black/40 p-1">
            {SPEEDS.map((s) => (
              <button
                key={s}
                type="button"
                className={`min-h-8 rounded-full px-2 py-1 text-[10px] ${
                  playbackSpeed === s ? "bg-[var(--signal)] text-white" : "text-white/70"
                }`}
                onClick={() => onSpeedChange(s)}
              >
                {s}x
              </button>
            ))}
          </div>
        </div>
      </div>

      {heartBurst && (
        <div className="pointer-events-none absolute inset-0 z-50 flex items-center justify-center">
          <div className="heart-burst text-7xl text-[var(--signal)]">♥</div>
        </div>
      )}
    </div>
  );
}
