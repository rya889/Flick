---
date: 2026-10-01
source: chat
origin: ai
type: plan
status: parked
derived_from: [projects/flick/ROADMAP.md]
generated_by: AI agent (Forge trunks)
reviewed: false
sensitivity: normal
tags: [flick, trunk, t10-ads-phase2-parked]
---

# T10-ads-phase2-parked — Ads Phase 2 (parked)

| | |
| --- | --- |
| **ID** | `T10-ads-phase2-parked` |
| **Estimate** | M |
| **Deps** | `T09` + explicit Ryan unlock + retention evidence |
| **Status** | parked |

## Goal
Parked: third-party native shorts ads + after-Finish interstitial **after** retention/momentum. Do not implement until Ryan explicitly unlocks.

## In scope
- When unlocked: follow caps/placements in `ads-and-audience-pricing-2026-10-01.md` Phase 2.
- Holdout-friendly; cut interstitial first if D7 retention tax > ~3–5 pp.
- Still never gate PD chapters; never interrupt Listen.

## Out of scope
- Anything before Ryan unlock
- Coin gates on chapters
- Mid-Listen ads

## Acceptance tests
- [ ] Ryan written unlock in chat or decision note.
- [ ] Then define fresh acceptance tests before coding.

## Files likely touched
- TBD ad SDK + player interstitial hooks

## Handoff note (fill when done)
- Status: **PARKED**. Next agent: skip unless unlock exists.
