---
date: 2026-10-01
source: chat
origin: ai
type: plan
status: decision
derived_from:
  - projects/flick/README.md
  - projects/flick/seed-shelf-2026-10-01.md
  - projects/flick/pricing-research-2026-10-01.md
  - projects/flick/ads-and-audience-pricing-2026-10-01.md
  - decisions/2026-10-01-flick-segment-public-domain-fiction.md
  - decisions/2026-10-01-flick-voices-in-pro-and-ads.md
  - /Users/ryan/dev/Flick/docs/README.md
  - /Users/ryan/dev/Flick/app/README.md
generated_by: AI agent (Forge trunks)
reviewed: false
sensitivity: normal
tags: [flick, roadmap, trunks, public-domain]
---

# Flick roadmap — one trunk per session

## North star
Ship an anti-doomscroll **public-domain fiction finisher**: Ryan (and users) open a free PD book, swipe Story shorts, Listen with karaoke, and **Finish** — starting with the seed shelf, especially **Bartleby**.

**Locked (2026-10-01 ET):**
- Wedge: PD fiction finishers (nonfiction TLDR parked)
- Seed shelf: Bartleby → Machine Stops → Underground → Jekyll → Time Machine (`seed-shelf-2026-10-01.md`)
- Monetization: Pro **$4.99/mo** / **$29.99/yr**; premium voices **in Pro**; v1 ads = **house Pro soft prompts only**
- Never paywall PD books/chapters
- Broader PD library/source is required later (dedicated trunks) — do not forget

**Code reality (Flutter `~/dev/Flick/app`):** Story/Bounce, karaoke, extractive TLDR, OS TTS Listen, Drift library, the seed shelf, Bartleby dogfood, and RevenueCat Pro are wired. T08/T09 monetization is shipped; do not undo it. The next priority is UX/covers (T11–T14), with no further paywall work until that queue is finished.

## Shared branch workflow (all agents)

All cloud and local agents work on the shared trunk branch **`main`** (the repository default):
- Work on `main` only; do not create or use feature branches unless Ryan explicitly says to.
- Before starting, pull and rebase onto the latest `main` (for example, `git pull --rebase origin main`).
- Push handoff commits to `main` so the next agent can continue from the same branch.
- Do not create parallel long-lived branches for trunks.

## Principles (every agent)
1. **One trunk per ~200k-token session.** Read `SESSION.md` + **one** trunk file. Do not start the next trunk.
2. **Self-contained trunks.** Goal, scope fences, acceptance tests, likely files, deps, handoff — no need to re-derive strategy from chat.
3. **ONE feature at a time** → test → refine. Prefer S over M; split if a trunk feels mega.
4. **Dogfood early.** Bartleby end-to-end is acceptance on T02–T03 (and regression on later polish trunks).
5. **Do not forget the PD library.** After dogfood works, T06 research → T07 implement a real broader catalog path.
6. **No big-refactors** unless the trunk says so. Touch listed files; leave Bounce/AI TLDR/social alone unless in-scope.
7. **Persistent memory** lives in this thought-repo. Update the trunk’s handoff + CATALOG when done; don’t rely on chat history.

## Ordered trunks

| # | ID | Est | Status |
|---|-----|-----|--------|
| 1 | [T01-foundation-baseline](./trunks/T01-foundation-baseline.md) | S | complete |
| 2 | [T02-seed-shelf-in-app](./trunks/T02-seed-shelf-in-app.md) | M | complete |
| 3 | [T03-bartleby-dogfood-e2e](./trunks/T03-bartleby-dogfood-e2e.md) | M | complete |
| 4 | [T04-listen-polish](./trunks/T04-listen-polish.md) | M | complete |
| 5 | [T05-finish-shorts-polish](./trunks/T05-finish-shorts-polish.md) | M | complete |
| 6 | [T06-pd-library-source-research](./trunks/T06-pd-library-source-research.md) | S | complete |
| 7 | [T07-pd-catalog-browse-import](./trunks/T07-pd-catalog-browse-import.md) | M | complete |
| 8 | [T08-pro-paywall-soft](./trunks/T08-pro-paywall-soft.md) | M | complete |
| 9 | [T09-house-pro-prompts-v1](./trunks/T09-house-pro-prompts-v1.md) | S | complete |
| 10 | [T10-ads-phase2-parked](./trunks/T10-ads-phase2-parked.md) | M | **parked** — do not run until Ryan unlocks |
| 11 | [T11-book-covers-source](./trunks/T11-book-covers-source.md) | S | complete |
| 12 | [T12-library-cover-grid-ux](./trunks/T12-library-cover-grid-ux.md) | M | complete |
| 13 | [T13-onboarding-empty-states](./trunks/T13-onboarding-empty-states.md) | S | complete |
| 14 | [T14-reader-chrome-polish](./trunks/T14-reader-chrome-polish.md) | S | complete |
| 15 | [T15-bundled-seed-covers](./trunks/T15-bundled-seed-covers.md) | M | complete |
| 16 | [T16-premium-voices-pro](./trunks/T16-premium-voices-pro.md) | M | complete |

**Backlog (not scheduled):** further monetization work, including cloud premium voices inside Pro, waits until the T11 → T12 → T13 → T14 UX queue finishes; Standard Ebooks polish beyond cleared cover art; accounts/sync; Bounce algorithm; Phase 1.5 rewarded voice trial. T10 remains parked until Ryan explicitly unlocks it.

**Next queue:** UX trunks **T11–T14 are complete.** See [post-ux-queue](./post-ux-queue.md) for backlog options (bundled cover art, sync polish, Bounce, premium voices, etc.). **T10 remains parked** until Ryan unlocks.

**Cover policy (T11 → T12):** local generated typography is the guaranteed fallback and initial default; only individually rights-checked Standard Ebooks/museum CC0 art or permitted work-specific Gutenberg art may be bundled. Open Library and Google Books are lookup/research fallbacks, not assumed-cleared runtime assets.

## How to pick work
1. Open `SESSION.md`.
2. Take the **first ready trunk in the current T11–T14 queue** whose deps are met (or the ID Ryan named).
3. Stop when acceptance tests pass or the session budget is spent — write handoff, don’t stretch into the next ID.
