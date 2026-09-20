"use client";

import { shortDisplayText } from "@/lib/shorts";
import type { CatalogBook, ReactionKind, ShortSegment, VoiceMode } from "@/lib/types";

interface FeedItem {
  short: ShortSegment;
  book: CatalogBook;
  score: number;
}

interface FeedViewProps {
  items: FeedItem[];
  voice: VoiceMode;
  liked: Set<string>;
  saved: Set<string>;
  reactions: Record<string, ReactionKind>;
  onOpenShort: (bookId: string, index: number) => void;
  onLike: (id: string) => void;
  onSave: (id: string) => void;
}

export function FeedView({
  items,
  voice,
  liked,
  saved,
  reactions,
  onOpenShort,
  onLike,
  onSave,
}: FeedViewProps) {
  if (items.length === 0) {
    return (
      <div className="rounded-2xl border border-dashed border-[var(--ink-muted)]/30 p-8 text-center text-sm text-[var(--ink-muted)]">
        Add books or read shorts to populate your For You feed.
      </div>
    );
  }

  return (
    <div className="mx-auto flex max-w-lg flex-col gap-3 pb-8">
      {items.map(({ short, book, score }) => {
        const text = shortDisplayText(short, voice);
        const preview = text.split(/\s+/).slice(0, 42).join(" ");
        const reaction = reactions[short.id];
        return (
          <article
            key={short.id}
            className="overflow-hidden rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] shadow-sm"
          >
            <div className="flex items-center gap-2 border-b border-[var(--ink-muted)]/10 px-3 py-2 text-[11px] text-[var(--ink-muted)]">
              <span
                className="h-2 w-2 rounded-full"
                style={{ background: `hsl(${book.coverHue ?? 20} 60% 45%)` }}
              />
              <span className="font-medium text-[var(--ink)]">r/{book.title.replace(/\s+/g, "")}</span>
              <span>·</span>
              <span>For You score {Math.round(score)}</span>
            </div>
            <button
              type="button"
              className="block w-full px-4 py-3 text-left"
              onClick={() => onOpenShort(book.id, short.index)}
            >
              <h3 className="font-display text-sm font-semibold text-[var(--ink)]">
                {voice === "viral" ? "Viral cut" : "Passage"} #{short.index + 1}
              </h3>
              <p className="mt-2 font-serif text-[15px] leading-relaxed text-[var(--ink)]/90">
                {preview}
                {text.split(/\s+/).length > 42 ? "…" : ""}
              </p>
            </button>
            <div className="flex items-center gap-2 px-3 pb-3 text-xs">
              <button
                type="button"
                className={`rounded-full px-3 py-1.5 ${liked.has(short.id) ? "bg-[var(--signal)]/15 text-[var(--signal)]" : "bg-[var(--ink)]/5"}`}
                onClick={() => onLike(short.id)}
              >
                ▲ {liked.has(short.id) ? "Liked" : "Like"}
              </button>
              <button
                type="button"
                className="rounded-full bg-[var(--ink)]/5 px-3 py-1.5"
                onClick={() => onSave(short.id)}
              >
                {saved.has(short.id) ? "Saved" : "Save"}
              </button>
              {reaction && (
                <span className="ml-auto text-[var(--ink-muted)]">Reacted</span>
              )}
            </div>
          </article>
        );
      })}
    </div>
  );
}
