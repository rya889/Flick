"use client";

import type { CatalogBook } from "@/lib/types";

interface CatalogListProps {
  books: CatalogBook[];
  onOpen: (book: CatalogBook) => void;
  onRemove: (id: string) => void;
}

export function CatalogList({ books, onOpen, onRemove }: CatalogListProps) {
  if (books.length === 0) {
    return (
      <p className="text-sm text-[var(--ink-muted)]">Your local catalog is empty — add a book above.</p>
    );
  }

  return (
    <ul className="grid gap-3 sm:grid-cols-2">
      {books.map((book) => {
        const pct =
          book.shortCount > 0 && book.progress
            ? Math.round(((book.progress.shortIndex + 1) / book.shortCount) * 100)
            : 0;
        return (
          <li
            key={book.id}
            className="flex flex-col rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] p-4"
          >
            <div className="flex items-start gap-3">
              <div
                className="h-12 w-10 shrink-0 rounded-md shadow-inner"
                style={{
                  background: `linear-gradient(145deg, hsl(${book.coverHue ?? 30} 40% 28%), hsl(${book.coverHue ?? 30} 30% 12%))`,
                }}
              />
              <div className="min-w-0 flex-1">
                <h3 className="truncate font-display font-semibold text-[var(--ink)]">{book.title}</h3>
                <p className="text-xs text-[var(--ink-muted)]">
                  {book.author ?? book.format.toUpperCase()} · {book.shortCount} shorts
                </p>
                {book.progress && (
                  <p className="mt-1 text-[11px] text-[var(--signal)]">
                    Resume short {book.progress.shortIndex + 1}
                  </p>
                )}
                <div className="mt-2 h-1 overflow-hidden rounded-full bg-[var(--ink)]/10">
                  <div className="h-full bg-[var(--signal)]" style={{ width: `${pct}%` }} />
                </div>
              </div>
            </div>
            <div className="mt-3 flex gap-2">
              <button
                type="button"
                className="flex-1 rounded-full bg-[var(--ink)] px-3 py-2 text-xs font-semibold text-[var(--paper)]"
                onClick={() => onOpen(book)}
              >
                {book.progress ? "Resume" : "Read"}
              </button>
              <button
                type="button"
                className="rounded-full border border-[var(--ink-muted)]/25 px-3 py-2 text-xs text-[var(--ink-muted)]"
                onClick={() => onRemove(book.id)}
              >
                Remove
              </button>
            </div>
          </li>
        );
      })}
    </ul>
  );
}
