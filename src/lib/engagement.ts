import type { EngagementData } from "./types";
import { DEFAULT_ENGAGEMENT } from "./types";

const STORAGE_KEY = "flick-engagement-v1";

function todayKey(): string {
  return new Date().toISOString().slice(0, 10);
}

export function loadEngagement(): EngagementData {
  if (typeof window === "undefined") return DEFAULT_ENGAGEMENT;
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { ...DEFAULT_ENGAGEMENT };
    const parsed = JSON.parse(raw) as Partial<EngagementData>;
    // Drop legacy reactions field if present
    const { ...rest } = parsed as EngagementData & { reactions?: unknown };
    delete (rest as { reactions?: unknown }).reactions;
    return { ...DEFAULT_ENGAGEMENT, ...rest };
  } catch {
    return { ...DEFAULT_ENGAGEMENT };
  }
}

export function saveEngagement(data: EngagementData): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

export function touchReadingSession(
  data: EngagementData,
  minutesDelta: number,
): EngagementData {
  const today = todayKey();
  let { streak, lastReadDate, minutesReadToday } = data;

  if (lastReadDate !== today) {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yKey = yesterday.toISOString().slice(0, 10);
    if (lastReadDate === yKey) streak += 1;
    else if (lastReadDate !== today) streak = 1;
    lastReadDate = today;
    minutesReadToday = 0;
  }

  minutesReadToday = Math.min(999, minutesReadToday + minutesDelta);

  return { ...data, streak, lastReadDate, minutesReadToday };
}

export function toggleLike(data: EngagementData, shortId: string): EngagementData {
  const set = new Set(data.likedShortIds);
  if (set.has(shortId)) set.delete(shortId);
  else set.add(shortId);
  return { ...data, likedShortIds: [...set] };
}

export function toggleSave(data: EngagementData, shortId: string): EngagementData {
  const set = new Set(data.savedShortIds);
  if (set.has(shortId)) set.delete(shortId);
  else set.add(shortId);
  return { ...data, savedShortIds: [...set] };
}

export function bumpForYou(data: EngagementData, shortId: string, delta = 1): EngagementData {
  const weights = { ...data.forYouWeights };
  weights[shortId] = (weights[shortId] ?? 0) + delta;
  return { ...data, forYouWeights: weights };
}

export function dailyGoalProgress(data: EngagementData): number {
  if (data.dailyGoalMinutes <= 0) return 1;
  return Math.min(1, data.minutesReadToday / data.dailyGoalMinutes);
}
