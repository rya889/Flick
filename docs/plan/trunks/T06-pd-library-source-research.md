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
tags: [flick, trunk, t06-pd-library-source-research]
---

# T06-pd-library-source-research — PD library source research

| | |
| --- | --- |
| **ID** | `T06-pd-library-source-research` |
| **Estimate** | S |
| **Deps** | `T05` preferred so dogfood isn’t blocked; can run earlier if Ryan prioritizes catalog |
| **Status** | complete |

## Goal
Choose how Flick gets a **broader** PD corpus beyond bundled seeds — research + decision only; no production ingest yet.

## In scope
- Compare options with a short matrix: Project Gutenberg (API / feeds / mirrors), Standard Ebooks, local OPDS, Open Library metadata + PG text, others as needed.
- Criteria: US PD clarity, EPUB/TXT quality, ToS/App Store risk, offline, rate limits, Flutter fit, solo-maintainer cost.
- Recommend **one** MVP path + fallback; write `projects/flick/pd-library-source-2026-10-01.md` (or dated) + optional `decisions/` stub.
- Sketch T07 implementation shape (browse → metadata → download → existing import pipeline).

## Out of scope
- Implementing browse/download UI (T07)
- Replacing seed assets
- Licensing non-US territories
- Scraping Goodreads (explicitly forbidden in product spec)

## Acceptance tests
- [ ] Research brief committed with comparison table + recommendation.
- [ ] Explicit MVP scope for T07 (what “browse + import” means).
- [ ] Risks/ToS called out.
- [ ] No production code required (spikes OK if deleted or clearly experimental).

## Files likely touched
- `thought-repo/projects/flick/pd-library-source-*.md` (new)
- Optional `thought-repo/decisions/2026-10-01-flick-pd-library-source.md`
- CATALOG/INDEX rows

## Handoff note (fill when done)
- Next: **T07-pd-catalog-browse-import** using the chosen source.
- Link the brief path here.
