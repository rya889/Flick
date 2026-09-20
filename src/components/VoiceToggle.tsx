"use client";

import type { VoiceMode } from "@/lib/types";

interface VoiceToggleProps {
  mode: VoiceMode;
  onChange: (mode: VoiceMode) => void;
}

export function VoiceToggle({ mode, onChange }: VoiceToggleProps) {
  return (
    <div
      className="flex rounded-full border border-[var(--ink-muted)]/30 bg-[var(--paper-elevated)] p-0.5 text-xs font-medium"
      role="group"
      aria-label="Voice mode"
    >
      <button
        type="button"
        className={`rounded-full px-3 py-1.5 transition-colors ${
          mode === "original"
            ? "bg-[var(--ink)] text-[var(--paper)]"
            : "text-[var(--ink-muted)]"
        }`}
        onClick={() => onChange("original")}
      >
        Original
      </button>
      <button
        type="button"
        className={`rounded-full px-3 py-1.5 transition-colors ${
          mode === "viral"
            ? "bg-[var(--signal)] text-white shadow-[0_0_20px_rgba(255,90,54,0.35)]"
            : "text-[var(--ink-muted)]"
        }`}
        onClick={() => onChange("viral")}
      >
        Viral
      </button>
    </div>
  );
}
