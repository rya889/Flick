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
tags: [flick, trunk, t02-seed-shelf-in-app]
---

# T02-seed-shelf-in-app — Seed shelf in-app

| | |
| --- | --- |
| **ID** | `T02-seed-shelf-in-app` |
| **Estimate** | M |
| **Deps** | `T01` recommended (rights awareness); can start if Kafka risk is understood |
| **Status** | complete |

## Goal
Replace prototype samples with Ryan’s seed shelf so the Library dogfoods real PD fiction — **Bartleby must be present**.

## In scope
- Remove or stop shipping Alice / Holmes / Metamorphosis as default samples.
- Bundle (or first-run import) seed-shelf titles from `seed-shelf-2026-10-01.md`:
  1. Bartleby (PG #11231) — **required**
  2. Machine Stops (from PG #72890 collection — extract story only)
  3. Notes from Underground (PG #600)
  4. Jekyll & Hyde (PG #43)
  5. Time Machine (PG #35)
- Update `sampleLibrary` / `seedSamples()` / library UI copy (“public-domain samples”).
- Prefer US-PD Gutenberg plain text; keep assets lean (full novellas OK; don’t vendor huge epics).
- Ensure ≥3 samples so Bounce unlock rules still work.
- Unit/widget coverage for sample IDs if existing tests assert Alice/Holmes/Kafka.

## Out of scope
- Remote browse catalog (T06–T07)
- Finish celebration UX (T03/T05)
- Listen polish (T04)
- Monetization (T08+)
- Non-seed titles / alternates (Flatland, Heart of Darkness) unless needed for Bounce count

## Acceptance tests
- [x] Fresh install / clear DB → Library offers seed-shelf titles including **Bartleby**.
- [x] Opening Bartleby yields Story shorts (non-empty).
- [x] No Metamorphosis / Kafka sample shipped.
- [x] Existing catalog/sample tests updated and green.
- [x] Ryan dogfood: can add Bartleby in one tap.

## Files likely touched
- `app/assets/samples/` (replace/add txt)
- `app/lib/models/models.dart` (`sampleLibrary`)
- `app/lib/state/flick_controller.dart` (`seedSamples`)
- `app/lib/screens/library_screen.dart`
- `app/pubspec.yaml` (asset entries)
- `app/test/*` that mention old sample ids

## Handoff note (fill when done)
- Done 2026-10-01. See [`docs/T02-handoff.md`](../../T02-handoff.md).
- Next: **T03-bartleby-dogfood-e2e**.
- Machine Stops: story-only extract from PG #72890 (not the full collection).
