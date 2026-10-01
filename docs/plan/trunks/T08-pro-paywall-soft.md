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
tags: [flick, trunk, t08-pro-paywall-soft]
---

# T08-pro-paywall-soft — Pro paywall soft align

| | |
| --- | --- |
| **ID** | `T08-pro-paywall-soft` |
| **Estimate** | M |
| **Deps** | `T03` (dogfood path); ideally after T07 so catalog isn’t confused with IAP |
| **Status** | complete |

## Goal
Align monetization UX to locked Pro **$4.99 / $29.99**, voices-in-Pro messaging, and **never gate PD chapters** — soft paywall only.

## In scope
- Update paywall copy/prices toward Pro $4.99/mo + $29.99/yr (annual emphasized); map RevenueCat products / demo strings carefully.
- Ensure PD sample + imported PD chapter text are **not** paywalled; fix any EPUB/library-cap rules that contradict vault locks for PD.
- Soft triggers only: Listen cap, premium voices tease, Settings — no interrupt mid-Listen / mid-short.
- Rename user-visible “Plus/Premium” → **Pro** where low-risk; avoid mega rename of every symbol unless trivial.
- Sync thought-repo README if copy examples change; leave Phase 2 ads alone.

## Out of scope
- House Pro prompt placements implementation beyond paywall sheet (T09)
- Native/third-party ads (T10)
- Cloud TTS voice catalog build-out (backlog)
- Changing AI TLDR gating semantics unless required for consistency

## Acceptance tests
- [ ] Paywall shows $4.99 / $29.99 (or demo equivalent) and Pro naming.
- [ ] Bartleby / PD path readable without purchase.
- [ ] Listen cap still upsells Pro softly.
- [ ] No mid-short / mid-Listen blocking ad or hard gate on PD text.
- [ ] Tests for paywall reasons updated.

## Files likely touched
- `app/lib/screens/paywall_sheet.dart`
- `app/lib/services/plus_service.dart`
- `app/lib/services/library_access.dart`
- `app/lib/screens/settings_sheet.dart`
- `docs/01-product-design-spec.md` monetization section (align to vault locks)
- related tests

## Handoff note (fill when done)
- Next: **T09-house-pro-prompts-v1**.
- Note RC product IDs / what still says Plus in code.
