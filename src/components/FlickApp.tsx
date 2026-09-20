"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useCatalog } from "@/hooks/useCatalog";
import { useEngagement } from "@/hooks/useEngagement";
import type { CatalogBook, ShortSegment, VoiceMode } from "@/lib/types";
import { CatalogList } from "./CatalogList";
import { EngagementStrip } from "./EngagementStrip";
import { FeedView } from "./FeedView";
import { ShortsPlayer } from "./ShortsPlayer";
import { UploadPanel } from "./UploadPanel";
import { VoiceToggle } from "./VoiceToggle";

type Tab = "library" | "feed";

export function FlickApp() {
  const catalog = useCatalog();
  const engagement = useEngagement();
  const [tab, setTab] = useState<Tab>("library");
  const [voice, setVoice] = useState<VoiceMode>("original");
  const [player, setPlayer] = useState<{
    book: CatalogBook;
    shorts: ShortSegment[];
    index: number;
  } | null>(null);
  const [feedShorts, setFeedShorts] = useState<
    { short: ShortSegment; book: CatalogBook }[]
  >([]);
  const [busy, setBusy] = useState(false);

  const liked = useMemo(
    () => new Set(engagement.data.likedShortIds),
    [engagement.data.likedShortIds],
  );
  const saved = useMemo(
    () => new Set(engagement.data.savedShortIds),
    [engagement.data.savedShortIds],
  );

  const openBook = useCallback(
    async (book: CatalogBook) => {
      setBusy(true);
      try {
        const shorts = await catalog.loadShorts(book.id);
        const progress = book.progress ?? (await catalog.resumeProgress(book.id));
        const index = progress?.shortIndex ?? 0;
        setPlayer({ book, shorts, index });
        engagement.recordMinutes(0.1);
      } finally {
        setBusy(false);
      }
    },
    [catalog, engagement],
  );

  const buildFeed = useCallback(async () => {
    const pairs: { short: ShortSegment; book: CatalogBook }[] = [];
    for (const book of catalog.books) {
      const shorts = await catalog.loadShorts(book.id);
      for (const short of shorts.slice(0, 8)) {
        pairs.push({ short, book });
      }
    }
    setFeedShorts(pairs);
  }, [catalog]);

  useEffect(() => {
    if (tab === "feed") buildFeed();
  }, [tab, catalog.books, buildFeed]);

  const feedItems = useMemo(() => {
    const weights = engagement.data.forYouWeights;
    return feedShorts
      .map((item) => {
        const base = item.short.wordCount * 0.3;
        const w = weights[item.short.id] ?? 0;
        const likedBoost = liked.has(item.short.id) ? 12 : 0;
        const savedBoost = saved.has(item.short.id) ? 8 : 0;
        const recency = (Date.now() - item.book.addedAt) / 86400000;
        const score = base + w * 3 + likedBoost + savedBoost - recency * 0.5;
        return { ...item, score };
      })
      .sort((a, b) => b.score - a.score)
      .slice(0, 24);
  }, [feedShorts, engagement.data.forYouWeights, liked, saved]);

  const handleProgress = useCallback(
    (index: number, wordOffset: number) => {
      if (!player) return;
      catalog.updateProgress({
        bookId: player.book.id,
        shortIndex: index,
        wordOffset,
        updatedAt: Date.now(),
      });
    },
    [catalog, player],
  );

  return (
    <div className="mx-auto flex min-h-0 w-full max-w-3xl flex-1 flex-col px-4 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-[calc(0.75rem+env(safe-area-inset-top))]">
      <header className="mb-4 flex flex-col gap-3 border-b border-[var(--ink-muted)]/15 pb-4">
        <div className="flex items-center justify-between gap-3">
          <div>
            <h1 className="font-display text-2xl font-bold tracking-tight text-[var(--ink)]">
              Flick
            </h1>
            <p className="text-xs text-[var(--ink-muted)]">Books → shorts · on-device</p>
          </div>
          <VoiceToggle mode={voice} onChange={setVoice} />
        </div>
        <EngagementStrip
          data={engagement.data}
          goalProgress={engagement.goalProgress}
          onGoalClick={() => {
            const next = engagement.data.dailyGoalMinutes === 15 ? 30 : 15;
            engagement.setDailyGoal(next);
          }}
        />
        <nav className="flex gap-2">
          {(["library", "feed"] as Tab[]).map((t) => (
            <button
              key={t}
              type="button"
              className={`rounded-full px-4 py-2 text-sm font-medium capitalize ${
                tab === t
                  ? "bg-[var(--ink)] text-[var(--paper)]"
                  : "bg-[var(--paper-elevated)] text-[var(--ink-muted)]"
              }`}
              onClick={() => setTab(t)}
            >
              {t === "feed" ? "For You feed" : "Library"}
            </button>
          ))}
        </nav>
      </header>

      {tab === "library" ? (
        <div className="flex flex-col gap-8">
          <UploadPanel
            uploads={catalog.uploads}
            busy={busy || catalog.loading}
            onFiles={(files) => catalog.addFiles(files)}
            onPaste={async (text, title) => {
              setBusy(true);
              try {
                await catalog.addPaste(text, title);
              } finally {
                setBusy(false);
              }
            }}
            onUrl={async (url) => {
              setBusy(true);
              try {
                await catalog.addFromUrl(url);
              } finally {
                setBusy(false);
              }
            }}
            onSample={async (id) => {
              setBusy(true);
              try {
                const book = await catalog.addSample(id);
                await openBook(book);
              } finally {
                setBusy(false);
              }
            }}
          />
          <section>
            <h2 className="mb-3 font-display text-sm font-semibold uppercase tracking-wide text-[var(--ink-muted)]">
              Local catalog
            </h2>
            <CatalogList
              books={catalog.books}
              onOpen={openBook}
              onRemove={(id) => catalog.removeBook(id)}
            />
          </section>
        </div>
      ) : (
        <FeedView
          items={feedItems}
          voice={voice}
          liked={liked}
          saved={saved}
          onOpenShort={(bookId, index) => {
            const book = catalog.books.find((b) => b.id === bookId);
            if (!book) return;
            void catalog.loadShorts(bookId).then((shorts) => {
              setPlayer({ book, shorts, index });
            });
          }}
          onLike={engagement.like}
          onSave={engagement.save}
        />
      )}

      {player && (
        <ShortsPlayer
          book={player.book}
          shorts={player.shorts}
          initialIndex={player.index}
          voice={voice}
          playbackSpeed={engagement.data.playbackSpeed}
          liked={liked}
          saved={saved}
          onVoiceChange={setVoice}
          onSpeedChange={engagement.setSpeed}
          onLike={engagement.like}
          onSave={engagement.save}
          onProgress={handleProgress}
          onTickMinutes={engagement.recordMinutes}
          onClose={() => setPlayer(null)}
        />
      )}
    </div>
  );
}
