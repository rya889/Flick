---
date: 2026-10-01
source: plan
origin: chat
status: complete
derived_from: [projects/flick/ROADMAP.md, projects/flick/trunks/T03-bartleby-dogfood-e2e.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, onboarding, empty-states, ux]
---

# T13-onboarding-empty-states — small first-run and failure states

| | |
| --- | --- |
| **ID** | `T13-onboarding-empty-states` |
| **Estimate** | S |
| **Deps** | `T03` dogfood (met) |
| **Status** | complete |

## Goal
Replace blank or ambiguous screens with brief next actions that get a new user to a free book quickly, without adding an onboarding funnel.

## In scope
- First-run/empty Library: one primary action to open the seed shelf.
- No search/import results: explain the state and offer a retry or seed-shelf path.
- Offline/failed import: preserve existing books and give a clear retry path.
- Keep copy bite-size, skippable, and consistent with Finish/anti-doomscroll positioning.

## Out of scope
- Accounts, permissions tour, paywall, or a multi-screen tutorial.
- Reworking the Bartleby dogfood flow.
- New catalog behavior or analytics overhaul.

## Acceptance tests
- [x] A fresh install has a clear path to Bartleby in one tap or obvious next step.
- [x] Empty/error states never look like a broken or paid-only library.
- [x] Existing users with books see no onboarding interruption.
- [x] Offline state offers a useful local action.

## Files likely touched
- `app/lib/screens/library_screen.dart`
- shared empty/error-state widgets and focused tests
