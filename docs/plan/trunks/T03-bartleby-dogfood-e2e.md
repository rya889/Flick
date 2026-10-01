---
date: 2026-10-01
source: chat
origin: ai
type: plan
status: ready
derived_from: [projects/flick/ROADMAP.md]
generated_by: AI agent (Forge trunks)
reviewed: false
sensitivity: normal
tags: [flick, trunk, t03-bartleby-dogfood-e2e]
---

# T03-bartleby-dogfood-e2e — Ryan dogfood Bartleby end-to-end

| | |
| --- | --- |
| **ID** | `T03-bartleby-dogfood-e2e` |
| **Estimate** | M |
| **Deps** | `T02` (Bartleby must exist as sample) |
| **Status** | complete |

## Goal
One sitting path: Library → Bartleby → Story shorts → Listen → **Finish** celebration/state. This is the wedge proof.

## In scope
- Cold path: land or navigate so Bartleby is obvious (Library tile / empty-state CTA).
- Story mode works through Bartleby shorts with karaoke-capable text.
- Listen (OS TTS) plays along on at least one short; progress advances.
- Define/implement a minimal **Finish** moment when last short / book complete (celebration UI or clear completed state — keep small).
- Manual script for Ryan + automated smoke if feasible (`ux_flows_test` / widget test).
- Regression: seed samples still load; no paywall on PD chapter text.

## Out of scope
- Short-length retune for all books (T05)
- Cloud voices / Listen cap redesign (T04/T08)
- Bounce algorithm changes
- Remote PD catalog
- Ads / Pro soft prompts

## Acceptance tests
- [x] Ryan (or agent on device/sim) completes Bartleby Story path without importing files.
- [x] Listen works on ≥1 short during that path.
- [x] Finish state visible when book completes.
- [x] PD text never blocked by paywall.
- [x] Notes: Finish rate / friction bullets in handoff for Ryan.

## Files likely touched
- `app/lib/screens/library_screen.dart`
- `app/lib/screens/now_player.dart` / `shell.dart`
- `app/lib/state/flick_controller.dart` (progress / complete)
- `app/lib/screens/ebook_reader.dart` (only if needed)
- `app/test/ux_flows_test.dart` or new dogfood test

## Handoff note (fill when done)
- Done 2026-10-01 — [`docs/T03-handoff.md`](../../T03-handoff.md).
- Next: **T04-listen-polish**.
