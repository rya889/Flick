# Archive — Flick v0 (Next.js web)

Frozen snapshot of the original **browser** implementation of Flick.

**Do not treat this as the product direction.** The definitive redesign lives in [`/docs`](../../docs/).

## Why archived

The web prototype proved the concept (books → shorts, karaoke autoplay, chapter chrome) but hit structural limits:

- Mobile web gestures felt clunky vs native short-form apps
- Browser `speechSynthesis` Listen was unreliable (especially iOS)
- AI TLDR depended on fragile browser/server key setup

## What this folder contains

| Path | Notes |
|------|--------|
| `src/` | Next.js 16 App Router UI, parsers, IndexedDB, `/api/tldr`, `/api/fetch-book` |
| `public/samples/` | Public-domain sample TXT books |
| `CONTEXT.md` | Product/tech notes for **this** web build |
| `HANDOFF.md` | Prior Cloud Agent restore notes |
| `package.json` | Next 16 / React 19 / Tailwind 4 |

## How to run (reference only)

```bash
cd archive/v0-nextjs-web
npm install
npm run dev
```

## Salvage for the redesign

Worth carrying forward as ideas/reference (not as code defaults):

- Karaoke autoplay + top chapter progress pips
- Chapter ‹ › navigation
- Short segmentation / chapter detection approaches
- Sample library content in `public/samples/`

New implementation target: **Flutter iOS + Android** per `/docs`.
