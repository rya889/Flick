"use client";

import type { VoiceMode } from "@/lib/types";

interface VoiceToggleProps {
  mode: VoiceMode;
  onChange: (mode: VoiceMode) => void;
}

export function VoiceToggle({ mode, onChange }: VoiceToggleProps) {
  return (
    <div
      className="flex rounded-full border border-white/20 bg-black/35 p-0.5 text-xs font-medium backdrop-blur"
      role="group"
      aria-label="Reading mode"
    >
      <button
        type="button"
        className={`rounded-full px-3 py-1.5 transition-colors ${
          mode === "original"
            ? "bg-white text-black"
            : "text-white/65"
        }`}
        onClick={() => onChange("original")}
      >
        Full
      </button>
      <button
        type="button"
        className={`rounded-full px-3 py-1.5 transition-colors ${
          mode === "tldr"
            ? "bg-[var(--signal)] text-white"
            : "text-white/65"
        }`}
        onClick={() => onChange("tldr")}
      >
        TLDR
      </button>
    </div>
  );
}
