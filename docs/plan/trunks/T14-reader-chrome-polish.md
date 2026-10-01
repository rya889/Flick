---
date: 2026-10-01
source: plan
origin: chat
status: ready
derived_from: [projects/flick/ROADMAP.md, projects/flick/trunks/T05-finish-shorts-polish.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, reader, ux, polish]
---

# T14-reader-chrome-polish — bite-size return and reading chrome

| | |
| --- | --- |
| **ID** | `T14-reader-chrome-polish` |
| **Estimate** | S |
| **Deps** | `T05` and a working seed-shelf dogfood path |
| **Status** | ready — optional after core dogfood |

## Goal
Make it easier to resume a book and understand progress while keeping the reader quiet, fast, and focused.

## In scope
- A compact “Continue reading” hero/card for the most recently active book.
- A progress/resume chip with current position and a clear tap target.
- Small reader-chrome contrast/spacing fixes that make dark theme behavior intentional.
- Finish-celebration polish only where T05 left a concrete rough edge; do not reopen the whole flow.

## Out of scope
- A new navigation shell, reader rewrite, or theme-system refactor.
- Recommendations, social proof, or infinite feeds.
- New content, ads, paywall, or sync.

## Acceptance tests
- [ ] Cold open returns to the active book/position in one obvious action.
- [ ] Progress is understandable without competing with text or karaoke controls.
- [ ] Dark theme has readable contrast across reader chrome and fallback covers.
- [ ] Bartleby finish path and Listen controls do not regress.

## Files likely touched
- `app/lib/screens/library_screen.dart`
- `app/lib/screens/ebook_reader.dart` / `now_player.dart`
- theme tokens and focused widget tests
