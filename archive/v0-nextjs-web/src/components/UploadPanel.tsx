"use client";

import { useRef, useState } from "react";
import { SAMPLE_LIBRARY } from "@/lib/types";
import type { UploadJob } from "@/lib/types";

interface UploadPanelProps {
  uploads: UploadJob[];
  onFiles: (files: FileList) => void;
  onPaste: (text: string, title: string) => Promise<void>;
  onUrl: (url: string) => Promise<void>;
  onSample: (id: string) => Promise<void>;
  busy?: boolean;
}

export function UploadPanel({
  uploads,
  onFiles,
  onPaste,
  onUrl,
  onSample,
  busy,
}: UploadPanelProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [paste, setPaste] = useState("");
  const [pasteTitle, setPasteTitle] = useState("My paste");
  const [url, setUrl] = useState("");
  const [error, setError] = useState<string | null>(null);

  const submitPaste = async () => {
    setError(null);
    try {
      await onPaste(paste, pasteTitle);
      setPaste("");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Paste failed");
    }
  };

  const submitUrl = async () => {
    setError(null);
    try {
      await onUrl(url);
      setUrl("");
    } catch (e) {
      setError(e instanceof Error ? e.message : "URL import failed");
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div
        className="rounded-2xl border-2 border-dashed border-[var(--signal)]/40 bg-[var(--paper-elevated)] p-6 text-center"
        onDragOver={(e) => e.preventDefault()}
        onDrop={(e) => {
          e.preventDefault();
          if (e.dataTransfer.files?.length) onFiles(e.dataTransfer.files);
        }}
      >
        <p className="font-display text-lg font-semibold text-[var(--ink)]">
          Drop EPUB, MOBI, or TXT
        </p>
        <p className="mt-1 text-sm text-[var(--ink-muted)]">Multi-file upload with resume in catalog</p>
        <button
          type="button"
          disabled={busy}
          className="mt-4 rounded-full bg-[var(--signal)] px-5 py-2.5 text-sm font-semibold text-white shadow-[0_8px_24px_rgba(255,90,54,0.25)]"
          onClick={() => inputRef.current?.click()}
        >
          Choose files
        </button>
        <input
          ref={inputRef}
          type="file"
          accept=".epub,.mobi,.azw,.txt"
          multiple
          className="hidden"
          onChange={(e) => e.target.files && onFiles(e.target.files)}
        />
      </div>

      {uploads.length > 0 && (
        <div className="rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-[var(--ink-muted)]">
            Upload queue
          </p>
          <ul className="mt-2 space-y-2">
            {uploads.map((job) => (
              <li key={job.id} className="text-sm">
                <div className="flex justify-between gap-2">
                  <span className="truncate">{job.fileName}</span>
                  <span className="text-[var(--ink-muted)]">{job.status}</span>
                </div>
                <div className="mt-1 h-1 overflow-hidden rounded-full bg-[var(--ink)]/10">
                  <div
                    className="h-full bg-[var(--signal)] transition-all"
                    style={{ width: `${job.progress}%` }}
                  />
                </div>
                {job.error && <p className="text-xs text-red-600">{job.error}</p>}
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="grid gap-4 sm:grid-cols-2">
        <div className="rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] p-4">
          <label className="text-xs font-semibold uppercase text-[var(--ink-muted)]">Paste text</label>
          <input
            className="mt-2 w-full rounded-lg border border-[var(--ink-muted)]/20 bg-[var(--paper)] px-3 py-2 text-sm"
            value={pasteTitle}
            onChange={(e) => setPasteTitle(e.target.value)}
            placeholder="Title"
          />
          <textarea
            className="mt-2 min-h-[100px] w-full rounded-lg border border-[var(--ink-muted)]/20 bg-[var(--paper)] px-3 py-2 text-sm"
            value={paste}
            onChange={(e) => setPaste(e.target.value)}
            placeholder="Paste chapter or article…"
          />
          <button
            type="button"
            disabled={!paste.trim() || busy}
            onClick={submitPaste}
            className="mt-2 rounded-full border border-[var(--ink)]/20 px-4 py-2 text-sm font-medium"
          >
            Add paste
          </button>
        </div>
        <div className="rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] p-4">
          <label className="text-xs font-semibold uppercase text-[var(--ink-muted)]">From URL</label>
          <input
            className="mt-2 w-full rounded-lg border border-[var(--ink-muted)]/20 bg-[var(--paper)] px-3 py-2 text-sm"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            placeholder="https://…"
          />
          <button
            type="button"
            disabled={!url.trim() || busy}
            onClick={submitUrl}
            className="mt-2 rounded-full border border-[var(--ink)]/20 px-4 py-2 text-sm font-medium"
          >
            Import URL
          </button>
        </div>
      </div>

      <div>
        <p className="text-xs font-semibold uppercase tracking-wide text-[var(--ink-muted)]">
          Public-domain samples
        </p>
        <div className="mt-3 grid gap-3 sm:grid-cols-3">
          {SAMPLE_LIBRARY.map((s) => (
            <button
              key={s.id}
              type="button"
              disabled={busy}
              onClick={() => onSample(s.id)}
              className="rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] p-4 text-left transition hover:border-[var(--signal)]/50"
            >
              <div
                className="mb-2 h-1 w-10 rounded-full"
                style={{ background: `hsl(${s.hue} 55% 48%)` }}
              />
              <p className="font-display text-sm font-semibold">{s.title}</p>
              <p className="text-xs text-[var(--ink-muted)]">{s.author}</p>
            </button>
          ))}
        </div>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
