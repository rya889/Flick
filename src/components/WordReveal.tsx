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
      className={`font-serif text-[1.35rem] leading-relaxed tracking-tight text-[var(--paper)] transition-opacity ${
        paused ? "opacity-80" : "opacity-100"
      }`}
    >
      {words.map((word, i) => {
        const lit = i <= activeIndex;
        return (
          <span
            key={`${i}-${word}`}
            className={`mr-1.5 inline transition-colors duration-150 ${
              lit ? "text-[var(--paper)]" : "text-[var(--paper)]/35"
            }`}
          >
            {word}
          </span>
        );
      })}
    </p>
  );
}
