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
tags: [flick, trunk, t04-listen-polish]
---

# T04-listen-polish — Listen polish (OS TTS)

| | |
| --- | --- |
| **ID** | `T04-listen-polish` |
| **Estimate** | M |
| **Deps** | `T03` preferred (dogfood path exists); can follow T02 if Finish deferred |
| **Status** | ready |

## Goal
Make on-device Listen reliable and pleasant for fiction dogfood — karaoke + mute/speed — without building cloud voices yet.

## In scope
- Fix obvious TTS/karaoke desync or stop/resume bugs on Story shorts.
- Mute + playback speed discoverable and sticky for the session.
- Free Listen cap (60 min/day per product lock) behaves clearly; unlimited when Pro/Plus demo — **do not** redesign pricing here.
- Lock-screen / background audio still **not** required.
- Tests around `tts_voice.dart` / controller Listen handlers.

## Out of scope
- Cloud / premium voices (later backlog; Pro-gated)
- Paywall copy/price change (T08)
- Short chunking overhaul (T05)
- Ads

## Acceptance tests
- [ ] Start/pause/resume Listen on Bartleby short without crash.
- [ ] Karaoke highlight roughly tracks speech (or documented limitation).
- [ ] Mute + speed work; cap messaging shows for free users.
- [ ] Relevant unit tests green.

## Files likely touched
- `app/lib/services/tts_voice.dart`
- `app/lib/state/flick_controller.dart` (TTS handlers)
- `app/lib/screens/now_player.dart`
- `app/test/tts_voice_test.dart`

## Handoff note (fill when done)
- Next: **T05-finish-shorts-polish**.
- List remaining karaoke/TTS debt.
