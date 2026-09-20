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
  const containerRef = useRef<HTMLDivElement>(null);
  const touchStartY = useRef<number | null>(null);
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

  const onTouchStart = (e: React.TouchEvent) => {
    touchStartY.current = e.touches[0].clientY;
  };

  const onTouchEnd = (e: React.TouchEvent) => {
    if (touchStartY.current === null) return;
    const dy = e.changedTouches[0].clientY - touchStartY.current;
    if (dy < -50) goNext();
    else if (dy > 50) goPrev();
    touchStartY.current = null;
  };

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowDown" || e.key === "j") goNext();
      if (e.key === "ArrowUp" || e.key === "k") goPrev();
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
        ref={containerRef}
        className="relative flex flex-1 flex-col justify-between overflow-hidden"
        onClick={() => setPaused((p) => !p)}
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        <div
          className="absolute inset-0 opacity-90"
          style={{
            background: `radial-gradient(ellipse at 30% 20%, hsl(${hue} 45% 22%) 0%, #0a0908 55%, #050504 100%)`,
          }}
        />
        <div className="relative z-10 flex items-start justify-between gap-3 px-4 pt-3">
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onClose();
            }}
            className="rounded-full bg-black/40 px-3 py-1.5 text-sm text-white backdrop-blur"
          >
            ← Library
          </button>
          <VoiceToggle mode={voice} onChange={onVoiceChange} />
        </div>

        <div className="relative z-10 flex flex-1 flex-col justify-center px-5 pb-8">
          <p className="mb-3 font-display text-xs uppercase tracking-[0.2em] text-[var(--signal)]">
            {book.title}
          </p>
          {paused && (
            <p className="mb-2 text-center text-xs text-white/50">Paused — tap to play</p>
          )}
          <WordReveal text={display} activeIndex={wordIndex} paused={paused} />
          <p className="mt-4 text-center text-[11px] text-white/40">
            Short {index + 1} / {shorts.length} · swipe ↑↓
          </p>
        </div>

        <div
          className="relative z-10 flex items-end justify-between gap-4 px-4 pb-4"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="flex flex-col gap-2">
            {REACTIONS.map((r) => (
              <button
                key={r.id}
                type="button"
                className={`flex h-10 w-10 items-center justify-center rounded-full text-lg ${
                  reactions[short.id] === r.id ? "bg-[var(--signal)]/30 ring-2 ring-[var(--signal)]" : "bg-black/40"
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
