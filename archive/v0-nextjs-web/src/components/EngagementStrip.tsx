"use client";

import type { EngagementData } from "@/lib/types";

interface EngagementStripProps {
  data: EngagementData;
  goalProgress: number;
  onGoalClick?: () => void;
}

export function EngagementStrip({ data, goalProgress, onGoalClick }: EngagementStripProps) {
  const pct = Math.round(goalProgress * 100);
  return (
    <div className="flex flex-wrap items-center gap-2 text-[11px] font-medium text-[var(--ink-muted)]">
      <span className="rounded-full bg-[var(--paper-elevated)] px-2.5 py-1 border border-[var(--ink-muted)]/20">
        🔥 {data.streak} day streak
      </span>
      <button
        type="button"
        onClick={onGoalClick}
        className="flex items-center gap-1.5 rounded-full bg-[var(--paper-elevated)] px-2.5 py-1 border border-[var(--ink-muted)]/20"
      >
        <span>Daily goal</span>
        <span className="h-1.5 w-12 overflow-hidden rounded-full bg-[var(--ink)]/10">
          <span
            className="block h-full rounded-full bg-[var(--signal)] transition-all"
            style={{ width: `${pct}%` }}
          />
        </span>
        <span>{data.minutesReadToday}/{data.dailyGoalMinutes}m</span>
      </button>
      <span className="rounded-full bg-[var(--paper-elevated)] px-2.5 py-1 border border-[var(--ink-muted)]/20">
        ❤️ {data.likedShortIds.length}
      </span>
      <span className="rounded-full bg-[var(--paper-elevated)] px-2.5 py-1 border border-[var(--ink-muted)]/20">
        📌 {data.savedShortIds.length}
      </span>
    </div>
  );
}
