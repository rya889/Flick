---
date: 2026-10-02
source: plan
origin: chat
status: ready
derived_from: [docs/plan/release-milestones.md, docs/plan/trunks/T17-ship-stabilize.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, testflight, ios, release]
---

# T18-testflight-prep — signed TestFlight-ready release candidate

| | |
| --- | --- |
| **ID** | `T18-testflight-prep` |
| **Estimate** | S |
| **Deps** | `T17` complete |
| **Status** | ready |

## Goal

Prepare the current Flick build for internal TestFlight without adding product features. Follow the release gates in [`../release-milestones.md`](../release-milestones.md); this trunk covers the signing/IPA/metadata preparation needed to enter that path.

## In scope

- Confirm the iOS App ID and bundle ID are `com.rya889.flick` in the intended Apple Developer/App Store Connect accounts.
- Validate release signing, provisioning, capabilities, archive, and IPA export on the supported build machine.
- Prepare an App Store Connect metadata checklist: app name, subtitle/description, category, age rating, screenshots, support URL, privacy URL, review contact, and review notes.
- Prepare the internal TestFlight group, release notes, known limitations, tester instructions, and feedback route.
- Run the T17 regression on the release candidate: Bartleby → Story → Listen/karaoke → Finish, seed shelf/covers, free Listen, Pro voice behavior, and public-domain access.
- Verify RevenueCat/IAP configuration is ready for sandbox purchase and restore testing; do not commit production secrets.

## Out of scope

- New reader, Story, Bounce, catalog, TTS, account, or sync features.
- T10 ads, Bounce algorithm work, cloud TTS, and accounts/sync for 1.0.
- External TestFlight, App Review submission, public release, or Android launch work except for checklists and handoff notes.
- Rewriting the product or changing the $4.99/month and $29.99/year Pro ladder.

## Acceptance tests

- [ ] Release archive and IPA export succeed for `com.rya889.flick` without secrets entering git.
- [ ] IPA installs on a physical test device and completes the T17 dogfood path.
- [ ] App Store Connect shell/metadata checklist is complete or has named blockers.
- [ ] Internal TestFlight upload/group/release-notes checklist is complete or has named blockers.
- [ ] Sandbox purchase and restore test plan is written for the $4.99/$29.99 Pro products.
- [ ] No new product feature is added; `flutter test` remains green if code is touched.
- [ ] Handoff records the exact build number, blockers, and next release gate.

## Files likely touched

- `app/ios/Runner.xcodeproj/project.pbxproj`
- `app/ios/Flutter/Debug.xcconfig`
- `app/ios/Flutter/Release.xcconfig`
- `docs/plan/release-milestones.md`
- `docs/T17-handoff.md` or a dated release handoff under `docs/`

## Handoff

Start with T17's completed alpha checklist. Stop after the internal TestFlight-prep handoff; do not turn this trunk into feature work or an App Review submission.
