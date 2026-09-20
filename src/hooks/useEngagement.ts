"use client";

import { useCallback, useEffect, useState } from "react";
import {
  bumpForYou,
  dailyGoalProgress,
  loadEngagement,
  saveEngagement,
  setReaction,
  toggleLike,
  toggleSave,
  touchReadingSession,
} from "@/lib/engagement";
import type { EngagementData, ReactionKind } from "@/lib/types";

export function useEngagement() {
  const [data, setData] = useState<EngagementData>(() => loadEngagement());

  useEffect(() => {
    saveEngagement(data);
  }, [data]);

  const recordMinutes = useCallback((minutes: number) => {
    setData((d) => touchReadingSession(d, minutes));
  }, []);

  const like = useCallback((shortId: string) => {
    setData((d) => bumpForYou(toggleLike(d, shortId), shortId, 2));
  }, []);

  const save = useCallback((shortId: string) => {
    setData((d) => toggleSave(d, shortId));
  }, []);

  const react = useCallback((shortId: string, reaction: ReactionKind | null) => {
    setData((d) => setReaction(d, shortId, reaction));
  }, []);

  const setSpeed = useCallback((speed: number) => {
    setData((d) => ({ ...d, playbackSpeed: speed }));
  }, []);

  const setDailyGoal = useCallback((minutes: number) => {
    setData((d) => ({ ...d, dailyGoalMinutes: minutes }));
  }, []);

  const goalProgress = dailyGoalProgress(data);

  return {
    data,
    goalProgress,
    recordMinutes,
    like,
    save,
    react,
    setSpeed,
    setDailyGoal,
  };
}
