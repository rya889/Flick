---
date: 2026-10-02
source: plan
origin: chat
status: ready
based_on: Forge release path
reviewed: false
sensitivity: normal
tags: [flick, release, app-store, testflight, ios]
---

# Flick release milestones

This is the iOS-first release path for Flick. The gates are ordered; a later gate may be prepared in parallel, but do not treat it as passed until its exit criteria are met.

## Locked release facts

- iOS bundle ID: `com.rya889.flick`
- Pro pricing: **$4.99/month** and **$29.99/year**
- T17 is complete and T18 is the ready, no-new-features TestFlight-prep trunk.
- Android is deliberately later; it is not part of the iOS 1.0 critical path.

## Gates

### 1. Friend alpha

**Goal:** Put the current dogfood-clean build in the hands of a small group of trusted friends.

**Exit criteria:**

- Physical-device smoke test passes: open shelf → Story swipe → Listen/karaoke → Finish, especially Bartleby.
- Free public-domain books and chapters remain usable without Pro; Pro voice behavior and the $4.99/$29.99 ladder are sane.
- Known limitations and a feedback channel are written down; no launch-blocking crash or data-loss issue is open.

### 2. Apple signing

**Goal:** Make a reproducible signed iOS archive for the real app identity.

**Exit criteria:**

- App ID/bundle ID is `com.rya889.flick` in the intended Apple Developer team.
- Distribution signing certificate, provisioning profile, capabilities, and release configuration are valid on the build machine.
- Archive/export produces an IPA installable on an allowed test device. Credentials, certificates, profiles, and secrets stay out of git.

### 3. App Store Connect shell

**Goal:** Create the App Store Connect record before uploading the release candidate.

**Exit criteria:**

- App record and bundle ID match `com.rya889.flick`; SKU and ownership are recorded.
- Store metadata shell exists: name, subtitle/description, category, age rating, support URL, privacy URL, and review contact/notes placeholders.
- Internal TestFlight group and build-processing path are ready; agreements, tax, and banking blockers are identified.

### 4. RevenueCat / IAP live

**Goal:** Configure the production subscription path, while validating it in sandbox first.

**Exit criteria:**

- App Store Connect products map to RevenueCat offerings and the `Pro` entitlement: **$4.99 monthly** and **$29.99 annual**.
- Sandbox purchase, entitlement unlock, renewal/expiration handling, and restore purchases pass on a real device.
- Production keys/configuration are separated from development values; no secret is committed.

### 5. TestFlight internal

**Goal:** Distribute the signed release candidate to internal testers.

**Exit criteria:**

- IPA uploads, processes, and installs through the internal TestFlight group.
- Internal testers can complete the alpha smoke path and exercise purchase/restore in sandbox.
- Release notes, known limitations, crash feedback, and a go/no-go decision are recorded.

### 6. TestFlight external (optional)

**Goal:** Gather a broader beta signal only if it is worth the review/feedback cost.

**Exit criteria:**

- Optional external group, tester instructions, feedback route, and beta notes are ready.
- Any required beta review is passed and the build is usable by people outside the internal team.
- This gate may be skipped; it must not block 1.0 when internal validation and App Review readiness are sufficient.

### 7. App Review

**Goal:** Submit a production candidate with a truthful, reviewable store record.

**Exit criteria:**

- Metadata, screenshots, age rating, privacy answers, support/privacy URLs, and review notes match the shipped behavior.
- Subscription products, restore flow, Pro gating, public-domain content, and any network-dependent behavior are testable for the reviewer.
- The production candidate is frozen except for review-blocking fixes; rejection responses and resubmission steps are prepared.

### 8. 1.0

**Goal:** Release Flick publicly on iOS after approval.

**Exit criteria:**

- Approved build is released with production RevenueCat/IAP configuration and the final store metadata.
- Launch smoke test, subscription/restore monitoring, crash monitoring, and a support/rollback plan are in place.
- Post-launch backlog is explicit. Do not pull parked work into the 1.0 cut: T10 ads, Bounce, cloud TTS, or accounts/sync.

### 9. Android later

**Goal:** Revisit Android after iOS 1.0 has real usage and feedback.

**Exit criteria:**

- A separate Android scope is approved from iOS learnings, including Play Store identity, billing/RevenueCat mapping, signing, and device coverage.
- Android is scheduled as follow-on work; it is not a prerequisite for the iOS release path above.

## Parked for after 1.0

- **T10 ads** (including native/rewarded ad experiments)
- Bounce algorithm work
- Cloud TTS
- Accounts and sync

These remain intentionally outside T18 and the iOS 1.0 release candidate.
