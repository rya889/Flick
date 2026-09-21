"use client";

interface WordRevealProps {
  text: string;
  activeIndex: number;
  paused: boolean;
}

export function WordReveal({ text, activeIndex, paused }: WordRevealProps) {
  const words = text.split(/\s+/).filter(Boolean);

  return (
    <p
      className={`mx-auto max-w-full min-w-0 text-center font-serif text-[clamp(1.15rem,4.8vw,1.45rem)] leading-[1.55] tracking-tight text-[var(--paper)] transition-opacity [overflow-wrap:anywhere] [word-break:break-word] ${
        paused ? "opacity-80" : "opacity-100"
      }`}
    >
      {words.map((word, i) => {
        const lit = i <= activeIndex;
        return (
          <span
            key={`${i}-${word}`}
            className={`inline transition-colors duration-150 ${
              lit ? "text-[var(--paper)]" : "text-[var(--paper)]/35"
            }`}
          >
            {word}
            {i < words.length - 1 ? " " : ""}
          </span>
        );
      })}
    </p>
  );
}
