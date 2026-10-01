---
date: 2026-10-01
source: plan
origin: chat
status: complete
derived_from: [projects/flick/trunks/T11-book-covers-source.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, covers, bundled]
---

# T15-bundled-seed-covers — rights-cleared seed shelf art

| | |
| --- | --- |
| **ID** | `T15-bundled-seed-covers` |
| **Estimate** | M |
| **Deps** | `T11`, `T12` |
| **Status** | complete |

## Goal
Bundle cleared cover art for the five seed titles where documented; keep typography fallback for imports and missing assets.

## In scope
- Update rights manifest with per-title source, license, attribution.
- `BookCoverMeta` overrides + `assets/covers/` JPEGs (Standard Ebooks).
- Pubspec asset registration; tests for bundled meta.

## Out of scope
- Runtime Open Library / Google Books fetch.
- Non-seed catalog covers.

## Acceptance tests
- [x] Library grid shows bundled art for all five seeds when in shelf.
- [x] Manifest rows list source + license per bundled file.
- [x] Import/custom books still use generated typography.
- [x] `flutter test` green.

## Files likely touched
- `app/lib/models/book_cover.dart`
- `app/assets/covers/*`
- `docs/plan/book-covers-rights-manifest-2026-10-01.md`
- `app/test/book_cover_test.dart`

## Handoff
- Next: **T16-premium-voices-pro**.
