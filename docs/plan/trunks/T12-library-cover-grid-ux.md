---
date: 2026-10-01
source: plan
origin: chat
status: ready
derived_from: [projects/flick/ROADMAP.md, projects/flick/trunks/T11-book-covers-source.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, library, covers, ux]
---

# T12-library-cover-grid-ux — cover-aware library shelf

| | |
| --- | --- |
| **ID** | `T12-library-cover-grid-ux` |
| **Estimate** | M |
| **Deps** | `T11` (`T07` is complete) |
| **Status** | ready |

## Goal
Make the Library shelf scannable and personal without turning Flick into a bookstore: show covers for the seed shelf and imported books, with a reliable typography fallback.

## In scope
- Add a compact cover/grid treatment to Library for seed and imported books.
- Prefer a cleared local cover asset; otherwise render the deterministic generated typography cover from T11.
- Preserve title, author, source, reading progress, and tap targets; covers must not become the only way to identify a book.
- Handle missing, corrupt, slow, and offline assets without layout jumps or broken-image icons.
- Keep the first shelf small and finish-oriented; no remote cover fetch is required for the initial UI pass.

## Out of scope
- New catalog/search or download behavior (T07).
- Cover rights research or arbitrary Open Library/Google Books image reuse (T11).
- A bookstore-style carousel, recommendations, or social sharing.
- Reader redesign.

## Acceptance tests
- [ ] All five seed titles display a cover or deterministic fallback in the same grid/list layout.
- [ ] An imported book with no cover metadata displays the fallback and remains playable.
- [ ] Offline mode has no network-dependent cover failure or layout shift.
- [ ] Small/large text and dark theme keep title/author/progress legible.
- [ ] Existing Bartleby → Story → Listen → Finish path is unchanged.

## Files likely touched
- `app/lib/screens/library_screen.dart`
- `app/lib/models/models.dart` or catalog metadata models
- cover asset/renderer helper and focused tests

## Handoff
- Next: **T13-onboarding-empty-states** (if unlocked) or **T14-reader-chrome-polish**.
