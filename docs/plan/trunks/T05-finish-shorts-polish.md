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
tags: [flick, trunk, t05-finish-shorts-polish]
---

# T05-finish-shorts-polish — Finish + shorts tuning

| | |
| --- | --- |
| **ID** | `T05-finish-shorts-polish` |
| **Estimate** | M |
| **Deps** | `T03` |
| **Status** | complete |

## Goal
Tune short segmentation and Finish UX for PD fiction snackability (~15–60s attention) without rewriting the whole player.

## In scope
- Adjust `short_builder` / page split targets toward ~60–120 words / ~20–45s where safe.
- Finish celebration / completed-book chrome polish (building on T03 minimum).
- Chapter/progress affordances that help finishers (resume last short already exists — tighten copy/UI).
- Verify Bartleby + one other seed title still feel finishable.
- Update tests for short boundaries if assertions exist.

## Out of scope
- Bounce ranking / For You
- AI TLDR quality
- Remote catalog
- Monetization / ads
- Mega player redesign

## Acceptance tests
- [ ] Bartleby shorts land in snackable range for most segments (spot-check).
- [ ] Finish UX clear; no regression on T03 path.
- [ ] Second seed title (e.g. Machine Stops) completable without broken shorts.
- [ ] Tests green.

## Files likely touched
- `app/lib/services/short_builder.dart`
- `app/lib/services/book_pages.dart` / `page_text.dart`
- `app/lib/screens/now_player.dart`
- `app/lib/state/flick_controller.dart`
- related tests

## Handoff note (fill when done)
- Next: **T06-pd-library-source-research**.
- Note any titles that chunk poorly.
