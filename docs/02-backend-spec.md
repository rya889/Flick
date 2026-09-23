# Flick — Backend Spec v0

**Status:** Closed (definitive for redesign)  
**Depends on:** [01-product-design-spec.md](./01-product-design-spec.md)

---

## 1. Principles

1. **Offline-first core** — library, Story Full text, karaoke, OS TTS, progress, hearts/saves work without network.  
2. **Thin server** — exists for AI TLDR proxy (+ later sync/social).  
3. **No login in v1** — identity = device install + RevenueCat entitlement.  
4. **Minimal cost** — free-tier AI to start; provider-swappable.  
5. **Privacy** — never upload whole books; AI sends one short’s text only when Plus requests it.

## 2. Stack (locked)

| Layer | Choice |
|-------|--------|
| Client | **Flutter** (iOS + Android) |
| Local DB | **Drift (SQLite)** (Isar acceptable alternative) |
| Files | App documents directory (EPUB/TXT blobs) |
| TTS | **flutter_tts** → AVSpeech / Android TTS |
| IAP | **RevenueCat** + StoreKit 2 / Play Billing |
| AI proxy | Thin HTTP API (Vercel / Supabase Edge / Cloudflare Workers / Cloud Run — implementer’s pick) |
| AI providers | Adapter pattern; start free |
| Analytics | **None** for now |

## 3. AI providers (start free)

| Priority | Provider | Role |
|----------|----------|------|
| 1 | **Groq** free tier | Primary — fast, ~1k req/day class limits on free text models |
| 2 | **Gemini Flash-Lite** free | Fallback |
| 3 | **Cloudflare Workers AI** | Optional fallback (neuron budget) |

- Client never holds the master provider key.  
- Server caches by `contentHash` when feasible.  
- Free tiers may train on inputs — only send the single short being condensed.  
- When revenue allows: keep cheap bulk models; optionally add paid model for quality tier.

## 4. Domain model

### LibraryBook
`id`, `title`, `author?`, `source` (`epub` \| `txt` \| `paste` \| `sample`), `fileUri?`, `rawTextRef`, `addedAt`, `coverHue?`

### Chapter
`bookId`, `index`, `title`, `startOffset`, `endOffset`

### Short
`id`, `bookId`, `chapterIndex`, `indexInBook`, `textFull`, `wordCount`,  
`textCondense?`, `textSummary?`, `keyQuotes[]?`,  
`tldrSource` (`none` \| `extractive` \| `ai`), `contentHash`

### Progress
`bookId`, `shortId`, `shortIndex`, `updatedAt`

### Engagement
`heartedShortIds[]`, `savedShortIds[]`,  
`listenSecondsToday`, `listenDayKey`,  
`bounceWeights{}`, `playbackSpeed`

### Entitlement (local cache)
`plusActive`, `productId`, `expiresAt`, `lastVerifiedAt`

## 5. Import pipeline

1. User picks EPUB / TXT / paste (or sample).  
2. Parse on device → chapters → shorts.  
3. Short rules: prefer paragraph; else sentence-split to ~60–120 words / ~20–45s.  
4. Persist SQLite + file; extractive lite-TLDR optional sync/async.  
5. **Paste limits:** enforce **both** — max **500KB** and max **~100k words** (whichever hits first).  

**Samples:** ship 3 public-domain titles; they count toward Bounce’s ≥3 books.

## 6. Offline vs online

| Offline (core) | Online (enhanced) |
|----------------|-------------------|
| Library, parsing cache, Story Full, karaoke | AI TLDR |
| OS TTS (within free cap or Plus) | Entitlement refresh |
| Progress, hearts, saves | Later: sync, social, cloud TTS |

## 7. Listen metering

- Track `listenSecondsToday` keyed by local calendar day.  
- Free: hard-stop **TTS** at **60:00**; do not block reading/karaoke.  
- Soft paywall: unlimited Listen with Plus.  
- Plus: no daily TTS cap.

## 8. Bounce algorithm (v1)

**Gate:** `libraryBookCount >= 3` (samples count).

**Preferences:**

- Prefer TLDR unit if present; else Full / extractive  
- Avoid last N played shorts  
- Prefer unread / under-read  
- Boost hearted / saved signals lightly  
- Prefer cross-book after within-book variety exhausted  
- Never auto-jump books in Story mode  

## 9. API surface (minimal)

### `GET /v1/health`
Public uptime check.

### `POST /v1/tldr`
**Auth:** Plus entitlement (RevenueCat verification or short-lived token — exact scheme at implement time).  

**Body (conceptual):**
```json
{
  "mode": "condense" | "summary" | "quotes",
  "contentHash": "…",
  "text": "passage only"
}
```

**Server duties:**

- Reject oversized payloads  
- Rate-limit per install / entitlement  
- Do not log full passage bodies in plain long-term storage  
- Provider failover: Groq → Gemini → …  
- Return structured text for the requested mode  

### Non-goals for v1 API
Book upload, user accounts, social, analytics ingest.

## 10. IAP / Plus

| Product | Price | Trial |
|---------|-------|-------|
| Monthly | $6.99 | — |
| Yearly | $49.99 | 7-day free trial |

**Entitles (day one):** AI TLDR + unlimited Listen  

**Paywall triggers (product):** Listen cap, first AI TLDR tap, Settings  

Restore purchases / Family Sharing: **not required** for v1.

## 11. Security notes

- Provider API keys only on server.  
- Prefer attesting Plus server-side before spending AI budget.  
- Assume free-tier prompts may be retained by providers — minimize text sent.  

## 12. Cost sketch (solo)

| Item | v1 expectation |
|------|----------------|
| Apple / Google developer accounts | Required (paid yearly) |
| RevenueCat free tier | Likely enough early |
| AI | $0 on Groq/Gemini free; watch RPD |
| Hosting AI proxy | Free tiers initially |
| Analytics | $0 (none) |

## 13. Open implementation choices (non-blocking)

- Exact host for AI proxy (Vercel vs Supabase vs Cloudflare)  
- Drift vs Isar  
- Entitlement proof format on `/v1/tldr`  
- Whether server-side response cache is Redis, KV, or DB  

Resolve at implementation time without changing product behavior.
