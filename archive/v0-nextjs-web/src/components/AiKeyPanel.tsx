"use client";

import { useEffect, useState } from "react";
import {
  fetchTldrStatus,
  getStoredAiKey,
  setStoredAiKey,
} from "@/lib/tldr-client";

export function AiKeyPanel() {
  const [open, setOpen] = useState(false);
  const [key, setKey] = useState("");
  const [serverReady, setServerReady] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    setKey(getStoredAiKey());
    void fetchTldrStatus().then((s) => setServerReady(s.configured));
  }, []);

  if (!open) {
    return (
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="rounded-full border border-[var(--ink-muted)]/20 bg-[var(--paper-elevated)] px-3 py-1.5 text-[11px] text-[var(--ink-muted)]"
      >
        {serverReady || key ? "AI · ready" : "AI key"}
      </button>
    );
  }

  return (
    <div className="rounded-2xl border border-[var(--ink-muted)]/15 bg-[var(--paper-elevated)] p-3 text-sm">
      <div className="mb-2 flex items-center justify-between gap-2">
        <p className="font-medium text-[var(--ink)]">TLDR AI key</p>
        <button
          type="button"
          className="text-xs text-[var(--ink-muted)]"
          onClick={() => setOpen(false)}
        >
          Close
        </button>
      </div>
      <p className="mb-2 text-[11px] leading-relaxed text-[var(--ink-muted)]">
        Paste an OpenAI key (sk-…) or Vercel AI Gateway key. Stored only in this
        browser. Server env keys also work if configured.
        {serverReady ? " Server key detected." : ""}
      </p>
      <input
        type="password"
        value={key}
        onChange={(e) => setKey(e.target.value)}
        placeholder="sk-… or AI Gateway key"
        className="mb-2 w-full rounded-xl border border-[var(--ink-muted)]/20 bg-[var(--paper)] px-3 py-2 text-sm text-[var(--ink)] outline-none"
        autoComplete="off"
      />
      <div className="flex gap-2">
        <button
          type="button"
          className="rounded-full bg-[var(--ink)] px-3 py-1.5 text-xs text-[var(--paper)]"
          onClick={() => {
            setStoredAiKey(key);
            setSaved(true);
            window.setTimeout(() => setSaved(false), 1200);
          }}
        >
          {saved ? "Saved" : "Save"}
        </button>
        <button
          type="button"
          className="rounded-full bg-[var(--ink)]/5 px-3 py-1.5 text-xs text-[var(--ink-muted)]"
          onClick={() => {
            setKey("");
            setStoredAiKey("");
          }}
        >
          Clear
        </button>
      </div>
    </div>
  );
}
