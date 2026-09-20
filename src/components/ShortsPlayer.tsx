"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { shortDisplayText } from "@/lib/shorts";
import type { CatalogBook, ReactionKind, ShortSegment, VoiceMode } from "@/lib/types";
import { VoiceToggle } from "./VoiceToggle";
import { WordReveal } from "./WordReveal";

const SPEEDS = [0.75, 1, 1.25, 1.5, 2];
const REACTIONS: { id: ReactionKind; emoji: string }[] = [
  { id: "fire", emoji: "🔥" },
  { id: "mind", emoji: "🤯" },
  { id: "heart", emoji: "❤️" },
  { id: "skull", emoji: "💀" },
];

interface ShortsPlayerProps {
  book: CatalogBook;
  shorts: ShortSegment[];
  initialIndex: number;
  voice: VoiceMode;
  playbackSpeed: number;
  liked: Set<string>;
  saved: Set<string>;
  reactions: Record<string, ReactionKind>;
  onVoiceChange: (v: VoiceMode) => void;
  onSpeedChange: (s: number) => void;
  onLike: (id: string) => void;
  onSave: (id: string) => void;
  onReact: (id: string, r: ReactionKind | null) => void;
  onProgress: (index: number, wordOffset: number) => void;
  onTickMinutes: (fraction: number) => void;
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
  reactions,
  onVoiceChange,
  onSpeedChange,
  onLike,
  onSave,
  onReact,
  onProgress,
  onTickMinutes,
  onClose,
}: ShortsPlayerProps) {
  const [index, setIndex] = useState(initialIndex);
  const [wordIndex, setWordIndex] = useState(0);
  const [paused, setPaused] = useState(false);
  const touchStart = useRef<{ x: number; y: number; t: number } | null>(null);
  const minutesAccumulator = useRef(0);

  const short = shorts[index];
  const display = short ? shortDisplayText(short, voice) : "";
  const words = display.split(/\s+/).filter(Boolean);

  useEffect(() => {
    setIndex(initialIndex);
  }, [initialIndex, book.id]);

  useEffect(() => {
    setWordIndex(0);
  }, [index, voice]);

  useEffect(() => {
    if (!short || paused) return;
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
  }, [short, paused, playbackSpeed, words.length, onTickMinutes]);

  useEffect(() => {
    onProgress(index, wordIndex);
  }, [index, wordIndex, onProgress]);

  const goNext = useCallback(() => {
    if (index < shorts.length - 1) setIndex((i) => i + 1);
  }, [index, shorts.length]);

  const goPrev = useCallback(() => {
    if (index > 0) setIndex((i) => i - 1);
  }, [index]);

  const handleTapNav = useCallback(
    (clientX: number, width: number) => {
      // Left third = previous, right third = next, center = pause/play
      if (clientX < width * 0.28) goPrev();
      else if (clientX > width * 0.72) goNext();
      else setPaused((p) => !p);
    },
    [goNext, goPrev],
  );

  const onTouchStart = (e: React.TouchEvent) => {
    const t = e.touches[0];
    touchStart.current = { x: t.clientX, y: t.clientY, t: Date.now() };
  };

  const onTouchEnd = (e: React.TouchEvent) => {
    const start = touchStart.current;
    touchStart.current = null;
    if (!start) return;

    const t = e.changedTouches[0];
    const dy = start.y - t.clientY;
    const dx = t.clientX - start.x;
    const dt = Date.now() - start.t;

    // Vertical swipe still works
    if (Math.abs(dy) > 50 && Math.abs(dy) > Math.abs(dx) * 1.2) {
      if (dy > 0) goNext();
      else goPrev();
      return;
    }

    // Horizontal swipe as alternate prev/next
    if (Math.abs(dx) > 60 && Math.abs(dx) > Math.abs(dy) * 1.2) {
      if (dx > 0) goPrev();
      else goNext();
      return;
    }

    // Tap zones
    if (dt < 350 && Math.abs(dy) < 28 && Math.abs(dx) < 28) {
      handleTapNav(t.clientX, window.innerWidth);
    }
  };

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowDown" || e.key === "j" || e.key === "ArrowRight") goNext();
      if (e.key === "ArrowUp" || e.key === "k" || e.key === "ArrowLeft") goPrev();
      if (e.key === " ") {
        e.preventDefault();
        setPaused((p) => !p);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [goNext, goPrev]);

  if (!short) return null;

  const hue = book.coverHue ?? 24;

  return (
    <div
      className="fixed inset-0 z-50 flex flex-col bg-black"
      style={{ paddingTop: "env(safe-area-inset-top)", paddingBottom: "env(safe-area-inset-bottom)" }}
    >
      <div
        className="relative flex min-h-0 flex-1 flex-col justify-between overflow-hidden"
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
        onClick={(e) => {
          const target = e.target as HTMLElement;
          if (target.closest("[data-shorts-ui]")) return;
          const rect = e.currentTarget.getBoundingClientRect();
          handleTapNav(e.clientX - rect.left, rect.width);
        }}
      >
        <div
          className="absolute inset-0 opacity-90"
          style={{
            background: `radial-gradient(ellipse at 30% 20%, hsl(${hue} 45% 22%) 0%, #0a0908 55%, #050504 100%)`,
          }}
        />

        {/* Invisible tap zone hints (desktop/debug accessibility) */}
        <div className="pointer-events-none absolute inset-y-0 left-0 z-[5] w-[28%]" aria-hidden />
        <div className="pointer-events-none absolute inset-y-0 right-0 z-[5] w-[28%]" aria-hidden />

        <div
          className="relative z-10 flex items-start justify-between gap-3 px-4 pt-3"
          data-shorts-ui
        >
          <button
            type="button"
            onClick={onClose}
            className="rounded-full bg-black/40 px-3 py-1.5 text-sm text-white backdrop-blur"
          >
            ← Library
          </button>
          <VoiceToggle mode={voice} onChange={onVoiceChange} />
        </div>

        <div className="relative z-10 flex min-h-0 min-w-0 flex-1 flex-col justify-center overflow-y-auto px-4 py-4 sm:px-6">
          <p className="mb-3 shrink-0 truncate font-display text-xs uppercase tracking-[0.2em] text-[var(--signal)]">
            {book.title}
          </p>
          {paused && (
            <p className="mb-2 shrink-0 text-center text-xs text-white/50">Paused — tap center to play</p>
          )}
          <div className="min-w-0 w-full">
            <WordReveal text={display} activeIndex={wordIndex} paused={paused} />
          </div>
          <p className="mt-4 shrink-0 text-center text-[11px] text-white/40">
            Short {index + 1} / {shorts.length} · tap ← → · swipe ↑↓
          </p>
        </div>

        <div
          className="relative z-10 flex items-end justify-between gap-4 px-4 pb-4"
          data-shorts-ui
        >
          <div className="flex flex-col gap-2">
            {REACTIONS.map((r) => (
              <button
                key={r.id}
                type="button"
                className={`flex h-10 w-10 items-center justify-center rounded-full text-lg ${
                  reactions[short.id] === r.id
                    ? "bg-[var(--signal)]/30 ring-2 ring-[var(--signal)]"
                    : "bg-black/40"
                }`}
                onClick={() =>
                  onReact(short.id, reactions[short.id] === r.id ? null : r.id)
                }
              >
                {r.emoji}
              </button>
            ))}
          </div>
          <div className="flex flex-col items-end gap-2 text-white">
            <button
              type="button"
              className={`rounded-full px-3 py-2 text-sm ${liked.has(short.id) ? "text-[var(--signal)]" : "bg-black/40"}`}
              onClick={() => onLike(short.id)}
            >
              {liked.has(short.id) ? "♥ Liked" : "♡ Like"}
            </button>
            <button
              type="button"
              className={`rounded-full px-3 py-2 text-sm ${saved.has(short.id) ? "text-amber-300" : "bg-black/40"}`}
              onClick={() => onSave(short.id)}
            >
              {saved.has(short.id) ? "Saved" : "Save"}
            </button>
            <div className="flex gap-1 rounded-full bg-black/40 p-1">
              {SPEEDS.map((s) => (
                <button
                  key={s}
                  type="button"
                  className={`rounded-full px-2 py-1 text-[10px] ${
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
      </div>
    </div>
  );
}
