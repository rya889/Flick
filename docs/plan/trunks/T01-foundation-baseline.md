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
tags: [flick, trunk, t01-foundation-baseline]
---

# T01-foundation-baseline — Foundation baseline

| | |
| --- | --- |
| **ID** | `T01-foundation-baseline` |
| **Estimate** | S |
| **Deps** | `none` |
| **Status** | complete |

## Goal
Make the next dogfood trunks safe: app/tests baseline understood, rights landmine flagged, vault↔code deltas documented — **no product feature work**.

## In scope
- Confirm `cd /Users/ryan/dev/Flick/app && flutter test` (or note failures) and how to run on device/web per `app/README.md`.
- Document locked-vs-code deltas in a short note under `projects/flick/` (or update this trunk’s handoff): Pro $4.99/$29.99 vs Plus $6.99; seed shelf vs Alice/Holmes/Metamorphosis; **Metamorphosis (Kafka Wyllie) not PD-safe to ship**.
- Point agents at `SESSION.md` + this roadmap; ensure `projects/flick/README.md` links ROADMAP/SESSION/trunks.
- Optional: disable or clearly mark Metamorphosis sample as do-not-ship in UI/comments **only if** a one-line change; prefer full removal in T02.

## Out of scope
- Replacing seed shelf texts (T02)
- Paywall/pricing rewrite (T08)
- PD remote catalog (T06–T07)
- Refactors of Drift / RevenueCat / Bounce

## Acceptance tests
- [ ] `flutter test` status recorded (pass or known failures listed).
- [ ] Written delta note: pricing name, sample IDs, Kafka rights risk.
- [ ] README links to ROADMAP + SESSION + trunks.
- [ ] No unrelated feature commits.

## Files likely touched
- `thought-repo/projects/flick/README.md`
- Optional one-liner in `Flick/app/lib/models/models.dart` (comment only)
- This trunk handoff section

## Handoff note (fill when done)
- Next agent: **T02-seed-shelf-in-app**.
- Note test command results and any flaky targets here.
