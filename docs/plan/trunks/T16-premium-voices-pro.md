---
date: 2026-10-01
source: plan
origin: chat
status: complete
derived_from: [projects/flick/ROADMAP.md, decisions/2026-10-01-flick-voices-in-pro-and-ads.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, listen, tts, pro]
---

# T16-premium-voices-pro — Pro on-device premium Listen voices

| | |
| --- | --- |
| **ID** | `T16-premium-voices-pro` |
| **Estimate** | M |
| **Deps** | `T04`, `T08` (Pro shipped) |
| **Status** | complete |

## Goal
Free tier keeps compact OS TTS; Pro unlocks enhanced/Siri-class on-device voices. No new SKU; PD text never gated.

## In scope
- Voice picker gating + auto-pick by Pro status.
- Refresh voice after purchase/demo toggle.
- House soft prompt when free user taps a premium voice.
- Tests for free vs Pro pick logic.

## Out of scope
- Cloud TTS API (future).
- T08/T09 paywall copy changes.
- Mid-Listen ads; Bounce; sync.

## Acceptance tests
- [x] Free Listen uses basic/compact voice when available.
- [x] Pro uses best installed enhanced/Siri voice.
- [x] Free user tapping premium voice → house Pro prompt (not hard block on Listen).
- [x] PD books playable without Pro.
- [x] `flutter test` green.

## Files likely touched
- `app/lib/services/tts_voice.dart`
- `app/lib/state/flick_controller.dart`
- `app/lib/screens/ebook_reader.dart`
- `app/lib/screens/now_player.dart`
- `app/lib/screens/house_pro_prompt.dart`

## Handoff
- Hard stop after T16 unless Ryan opens a new trunk.
