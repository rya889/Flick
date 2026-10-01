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
tags: [flick, trunk, t07-pd-catalog-browse-import]
---

# T07-pd-catalog-browse-import — PD catalog browse + import MVP

| | |
| --- | --- |
| **ID** | `T07-pd-catalog-browse-import` |
| **Estimate** | M |
| **Deps** | `T06` (decision must exist) |
| **Status** | complete |

## Goal
Implement the T06-chosen source enough that a user can browse PD fiction and import into the existing library pipeline.

## In scope
- Browse/search UI (minimal) for PD titles from chosen source.
- Import into existing `CatalogStore` / EPUB-or-TXT path; mark source distinctly from local samples.
- Cache or disk persistence for downloaded blobs via existing `book_blob_store` patterns.
- Empty/error/rate-limit handling; never present copyrighted texts knowingly.
- Keep seed shelf working offline without network.

## Out of scope
- Full bookstore / accounts / sync
- Perfect metadata coverage of all Gutenberg
- Bounce feed of remote books
- Ads / Pro paywall work
- Re-chunking strategy changes (T05)

## Acceptance tests
- [ ] From Library, browse → select → import ≥1 remote PD book end-to-end.
- [ ] Imported book plays in Story + Listen.
- [ ] Offline: seed shelf still works with network off.
- [ ] Basic failure path (404/timeout) doesn’t corrupt DB.
- [ ] Tests or documented manual script.

## Files likely touched
- `app/lib/screens/library_screen.dart` (+ possible new catalog screen)
- `app/lib/services/catalog_store.dart`
- `app/lib/services/book_blob_store*.dart`
- `app/lib/services/epub_parser.dart` / import helpers
- `app/lib/models/models.dart` (source enum if needed)
- new service file for remote client

## Handoff note (fill when done)
- Next: **T08-pro-paywall-soft**.
- Record API endpoints used + any ToS follow-ups.
