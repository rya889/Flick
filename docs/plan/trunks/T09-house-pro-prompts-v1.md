---
date: 2026-10-01
source: chat
origin: ai
type: plan
status: complete
derived_from: [projects/flick/ROADMAP.md]
generated_by: AI agent (Forge trunks)
reviewed: false
sensitivity: normal
tags: [flick, trunk, t09-house-pro-prompts-v1]
---

# T09-house-pro-prompts-v1 — House Pro soft prompts (v1 ads)

| | |
| --- | --- |
| **ID** | `T09-house-pro-prompts-v1` |
| **Estimate** | S |
| **Deps** | `T08` |
| **Status** | complete |

## Goal
Ship v1 “ads”: **house Pro soft prompts only** — Finish end, Settings, voice tease — never interrupt Listen/karaoke/Finish celebration animation.

## In scope
- Add non-blocking house upsell surfaces per `ads-and-audience-pricing-2026-10-01.md` + voices/ads decision.
- Placements: after Finish (not during celebration), Settings, voice tease entry points.
- Copy emphasizes Pro perks (voices, ad-free later, Listen unlimited) without third-party ad SDKs.
- Respect “never interrupt” list from the decision note.

## Out of scope
- Native between-shorts ads / Finish interstitial (T10)
- Rewarded premium-voice trial (Phase 1.5 — only if Ryan unlocks)
- Analytics mega-instrumentation
- Changing prices (T08)

## Acceptance tests
- [ ] Soft prompts appear only at allowed surfaces.
- [ ] No prompt during Listen, karaoke, mid-chapter, or Finish animation.
- [ ] Dismissible; PD reading continues.
- [ ] Manual checklist recorded in handoff.

## Files likely touched
- `app/lib/screens/now_player.dart` / Finish UI
- `app/lib/screens/settings_sheet.dart`
- `app/lib/screens/paywall_sheet.dart` (entry reuse)
- possibly small new widget under `screens/` or `theme/`

## Handoff note (fill when done)
- Next: stop or backlog premium voices; **do not** start T10 unless Ryan unlocks.
- Link any copy strings changed.
