export type BookFormat = "epub" | "mobi" | "txt" | "paste" | "url" | "sample";

export type VoiceMode = "original" | "tldr";

export interface ParsedBook {
  id: string;
  title: string;
  author?: string;
  text: string;
  format: BookFormat;
  sourceLabel: string;
  addedAt: number;
  coverHue?: number;
}

export interface ShortSegment {
  id: string;
  bookId: string;
  index: number;
  original: string;
  /** Abbreviated extractive summary of the same passage. */
  tldr: string;
  wordCount: number;
  chapterIndex: number;
  chapterTitle: string;
}

export interface ReadingProgress {
  bookId: string;
  shortIndex: number;
  wordOffset: number;
  updatedAt: number;
}

export interface CatalogBook extends ParsedBook {
  shortCount: number;
  progress?: ReadingProgress;
}

export interface EngagementData {
  streak: number;
  lastReadDate: string;
  dailyGoalMinutes: number;
  minutesReadToday: number;
  likedShortIds: string[];
  savedShortIds: string[];
  playbackSpeed: number;
  forYouWeights: Record<string, number>;
}

export interface UploadJob {
  id: string;
  fileName: string;
  status: "pending" | "parsing" | "done" | "error";
  progress: number;
  error?: string;
  bookId?: string;
}

export const DEFAULT_ENGAGEMENT: EngagementData = {
  streak: 0,
  lastReadDate: "",
  dailyGoalMinutes: 15,
  minutesReadToday: 0,
  likedShortIds: [],
  savedShortIds: [],
  playbackSpeed: 1,
  forYouWeights: {},
};

export const SAMPLE_LIBRARY = [
  {
    id: "sample-alice",
    title: "Alice in Wonderland",
    author: "Lewis Carroll",
    path: "/samples/alice.txt",
    hue: 32,
  },
  {
    id: "sample-holmes",
    title: "A Scandal in Bohemia",
    author: "Arthur Conan Doyle",
    path: "/samples/holmes.txt",
    hue: 210,
  },
  {
    id: "sample-metamorphosis",
    title: "The Metamorphosis",
    author: "Franz Kafka",
    path: "/samples/metamorphosis.txt",
    hue: 145,
  },
] as const;
