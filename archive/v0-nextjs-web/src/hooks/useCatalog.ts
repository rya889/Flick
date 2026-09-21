"use client";

import { useCallback, useEffect, useState } from "react";
import {
  clearFinishedUploads,
  deleteBook,
  getAllBooks,
  getAllProgress,
  getBook,
  getProgress,
  getShortsForBook,
  saveBookWithShorts,
  saveProgress,
  saveShorts,
  saveUploadJob,
  getUploadJobs,
} from "@/lib/db";
import { createId } from "@/lib/id";
import {
  parseFromUrlPayload,
  parsePastedText,
  parseSample,
  parseUploadedFile,
} from "@/lib/parsers";
import { buildShorts, normalizeShort } from "@/lib/shorts";
import type {
  CatalogBook,
  ParsedBook,
  ReadingProgress,
  ShortSegment,
  UploadJob,
} from "@/lib/types";
import { SAMPLE_LIBRARY } from "@/lib/types";

export function useCatalog() {
  const [books, setBooks] = useState<CatalogBook[]>([]);
  const [uploads, setUploads] = useState<UploadJob[]>([]);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    const [list, progressList, jobList] = await Promise.all([
      getAllBooks(),
      getAllProgress(),
      getUploadJobs(),
    ]);
    const progressMap = new Map(progressList.map((p) => [p.bookId, p]));
    setBooks(
      list.map((b) => ({
        ...b,
        progress: progressMap.get(b.id),
      })),
    );
    setUploads(jobList.filter((j) => j.status !== "done"));
  }, []);

  useEffect(() => {
    refresh().finally(() => setLoading(false));
  }, [refresh]);

  const ingestBook = useCallback(
    async (book: ParsedBook, jobId?: string) => {
      const shorts = buildShorts(book);
      const saved = await saveBookWithShorts(book, shorts, shorts.length);
      if (jobId) {
        await saveUploadJob({
          id: jobId,
          fileName: book.sourceLabel,
          status: "done",
          progress: 100,
          bookId: book.id,
        });
      }
      await refresh();
      return saved;
    },
    [refresh],
  );

  const addFiles = useCallback(
    async (files: FileList | File[]) => {
      const list = Array.from(files);
      for (const file of list) {
        const jobId = createId("upload");
        const job: UploadJob = {
          id: jobId,
          fileName: file.name,
          status: "parsing",
          progress: 10,
        };
        await saveUploadJob(job);
        setUploads((u) => [...u, job]);
        try {
          await saveUploadJob({ ...job, progress: 40 });
          const book = await parseUploadedFile(file);
          await saveUploadJob({ ...job, progress: 70 });
          await ingestBook(book, jobId);
        } catch (e) {
          const message = e instanceof Error ? e.message : "Upload failed";
          await saveUploadJob({ ...job, status: "error", progress: 0, error: message });
          await refresh();
        }
      }
      await clearFinishedUploads();
      await refresh();
    },
    [ingestBook, refresh],
  );

  const addPaste = useCallback(
    async (text: string, title?: string) => {
      const book = parsePastedText(text, title);
      return ingestBook(book);
    },
    [ingestBook],
  );

  const addFromUrl = useCallback(
    async (url: string) => {
      const res = await fetch(`/api/fetch-book?url=${encodeURIComponent(url)}`);
      const payload = await res.json();
      if (!res.ok) throw new Error(payload.error ?? "URL import failed");
      const book = await parseFromUrlPayload(payload);
      return ingestBook(book);
    },
    [ingestBook],
  );

  const addSample = useCallback(
    async (sampleId: string) => {
      const sample = SAMPLE_LIBRARY.find((s) => s.id === sampleId);
      if (!sample) throw new Error("Unknown sample");
      // Always re-parse samples so chapter markers / TLDR stay current
      const book = await parseSample(
        sample.id,
        sample.title,
        sample.author,
        sample.path,
        sample.hue,
      );
      return ingestBook(book);
    },
    [ingestBook],
  );

  const removeBook = useCallback(
    async (id: string) => {
      await deleteBook(id);
      await refresh();
    },
    [refresh],
  );

  const updateProgress = useCallback(async (progress: ReadingProgress) => {
    await saveProgress(progress);
    setBooks((prev) =>
      prev.map((b) => (b.id === progress.bookId ? { ...b, progress } : b)),
    );
  }, []);

  const loadShorts = useCallback(async (bookId: string) => {
    const shorts = await getShortsForBook(bookId);
    const needsRebuild = shorts.some(
      (s) =>
        !s.tldr ||
        s.chapterIndex === undefined ||
        s.chapterTitle === undefined,
    );
    if (!needsRebuild) {
      return shorts.map((s) => normalizeShort(s));
    }
    const book = await getBook(bookId);
    if (!book) return shorts.map((s) => normalizeShort(s));
    const rebuilt = buildShorts(book);
    await saveBookWithShorts(book, rebuilt, rebuilt.length);
    await refresh();
    return rebuilt;
  }, [refresh]);

  const patchShorts = useCallback(async (updated: ShortSegment[]) => {
    if (updated.length === 0) return;
    await saveShorts(updated);
  }, []);

  const resumeProgress = useCallback(async (bookId: string) => {
    return (await getProgress(bookId)) ?? null;
  }, []);

  return {
    books,
    uploads,
    loading,
    refresh,
    addFiles,
    addPaste,
    addFromUrl,
    addSample,
    removeBook,
    updateProgress,
    loadShorts,
    patchShorts,
    resumeProgress,
  };
}
