# Flick — Context

## Product

Local-first **book → shorts** reader:

- Import EPUB / MOBI / TXT / paste / URL / samples
- TikTok-style autoplay shorts + Reddit-style For You feed
- Modes: **Full** (original) vs **TLDR** (AI condensation when key present)
- Catalog + resume in IndexedDB; engagement (streaks, likes, saves) in localStorage
- Chapter nav, top progress bars, Listen / Share / double-tap like
- iPhone-friendly; Listen has WebKit / iOS Chrome speech workarounds

## Stack

- Next.js 16 App Router, React 19, Tailwind 4
- Client parsers (JSZip epub, mobi heuristic, txt)
- `/api/tldr` — OpenAI or Vercel AI Gateway (env or browser `AI key`)
- `/api/fetch-book` — URL import

## Key paths

```
src/components/FlickApp.tsx      # shell, tabs, player
src/components/ShortsPlayer.tsx  # gestures, chapters, Listen, TLDR prefetch
src/components/AiKeyPanel.tsx    # browser AI key for TLDR
src/lib/shorts.ts                # chapter detect + buildShorts
src/lib/abbreviate.ts            # extractive fallback TLDR
src/lib/speak.ts                 # iOS-safe speechSynthesis
src/lib/tldr-client.ts           # /api/tldr client + cache flags
src/app/api/tldr/route.ts        # AI condensation API
src/hooks/useCatalog.ts          # IndexedDB catalog
public/samples/*.txt             # chapter-marked samples
```

## Recent decisions

- Viral/slang mode → **TLDR** (AI abbreviate, not slang)
- Removed “Up next”
- Kept top progress pips
- Chapter ‹ Ch / Ch › controls
- Listen: unlock on tap, chunk text, resume keepalive (iOS Chrome)

## Deploy notes

- Temporary anonymous Vercel deploys were used earlier (expire ~60m)
- Target durable project: `le-team2/flick-shorts`
- TLDR needs `AI_GATEWAY_API_KEY` / `OPENAI_API_KEY` on server, or user pastes key in UI
