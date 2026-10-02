---
date: 2026-10-02
source: plan
origin: chat
status: complete
derived_from: [projects/flick/ROADMAP.md, docs/plan/post-ux-queue.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, ship, stabilize, alpha]
---

# T17-ship-stabilize — dogfood-clean for TestFlight / friend alpha

| | |
| --- | --- |
| **ID** | `T17-ship-stabilize` |
| **Estimate** | S |
| **Deps** | `T01`–`T16` (met); T10 remains parked |
| **Status** | complete |

## Goal
Make current `main` dogfood-clean for TestFlight / friend alpha. No new product bets.

## In scope
1. Regression: Bartleby → Story → Listen → Finish; seed covers; PD catalog; free basic Listen; Pro enhanced voices; PD never paywalled.
2. Fix clear bugs from recent Now/reader chrome that fail regression or `flutter test`.
3. `docs/T17-handoff.md` with Ryan alpha checklist + known limitations.
4. Optional tiny UX fix if it unblocks dogfood.

## Out of scope
Bounce algorithm, accounts/sync rewrite, cloud voices, ads phase 2 (T10), new books beyond seed+Gutendex, paywall redesign, inventing T18.

## Acceptance tests
- [x] `flutter test` green (43 passed)
- [x] Handoff lists manual alpha steps (`docs/T17-handoff.md`)
- [x] Commit + push to `main`
- [x] Hard stop (no T18)

## Files likely touched
- `docs/plan/trunks/T17-ship-stabilize.md`
- `docs/T17-handoff.md`
- `docs/plan/ROADMAP.md` / `SESSION.md` / `CLOUD-AGENT.md` / `post-ux-queue.md`
- `app/lib/screens/now_player.dart` — Shorts chapter-list fallback

## Handoff
- See `docs/T17-handoff.md`. Next work only when Ryan names a new trunk.
