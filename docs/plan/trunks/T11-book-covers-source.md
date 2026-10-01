---
date: 2026-10-01
source: research
origin: chat
status: ready
derived_from: [projects/flick/ROADMAP.md, projects/flick/trunks/T06-pd-library-source-research.md]
generated_by: AI agent
reviewed: false
sensitivity: normal
tags: [flick, trunk, book-covers, public-domain, rights]
---

# T11-book-covers-source — cover source and rights decision

| | |
| --- | --- |
| **ID** | `T11-book-covers-source` |
| **Estimate** | S |
| **Deps** | `T03` dogfood (met); `T06` source decision (met) |
| **Status** | ready |

## Goal
Choose a defensible, low-maintenance cover pipeline for the five seed titles and future imported public-domain books. This is a research/metadata decision, not a UI or app-code trunk.

## Decision to carry into implementation

1. **Default / safety net: local generated typography cover.** Render title, author, and a deterministic Flick palette/shape treatment locally (or pre-generate checked-in assets). It works offline, has no third-party image rights or hotlink risk, and is the required fallback for every book.
2. **Preferred art layer: individually vetted Standard Ebooks or museum CC0 artwork.** Use the underlying artwork only after recording the exact source, US-PD/CC0 proof, artist, and attribution. If reusing a complete Standard Ebooks cover, verify that edition’s colophon and separately respect any font license; do not assume that every Open Library or web image is cleared.
3. **Gutenberg: optional source for an image already inside the specific ebook.** Read that ebook’s license/transcriber note, self-host a permitted copy, and link/credit the source. Never hotlink Gutenberg images. Avoid making “Project Gutenberg” the product’s cover/source brand; its trademark terms apply when the name is associated with redistributed works.
4. **Open Library Covers API: metadata/edition lookup and candidate preview only.** Community-contributed cover rights are not automatically clear. A cover may become usable only after independent rights verification and a local rights record; use OLID/CoverID, identify the app with a contact `User-Agent`, cache sparingly, and respect rate limits.
5. **Google Books: not an MVP asset source.** Its thumbnails require Google attribution and prominent Google Books links, and the API terms include commercial-use and removal obligations. Keep it as a manually reviewed research fallback, not a runtime dependency.

### Source matrix

| Candidate | Rights/operational fit | Plan |
| --- | --- | --- |
| Local generated typography | Clear Flick-owned output; offline; no API or attribution dependency | **Default for every title and required fallback** |
| Standard Ebooks / museum CC0 art | Strongest art option when the exact artwork, edition, artist, and license are recorded; assembled covers/fonts still need verification | Preferred optional art layer |
| Gutenberg image in the specific ebook | Work-specific license/transcriber note controls; self-hosting is required and the PG trademark still needs care | Optional, case-by-case |
| Open Library Covers API | Useful metadata/edition lookup, but community cover copyright is not implied; rate limits and caching apply | Candidate lookup only, never automatic clearance |
| Google Books thumbnails | Attribution, prominent link, removal, and API/commercial-use obligations make it a poor runtime dependency | Research fallback only |

“Peize” did not resolve as a clear public-domain book title in the initial lookup. Treat it as an unresolved title/spelling or metadata test case: do not attach a cover from a similarly named modern work; use the generated fallback until title, edition, and rights are confirmed.

## Rights/attribution record

For every non-generated asset, keep: title/author/edition ID; image URL and local filename; source/provider; artist; exact license or US-PD proof URL; attribution text; retrieval date; and whether the asset may be bundled, cached, or modified. Show a compact source/credit link in book details or About rather than cluttering the shelf.

## In scope
- Compare Open Library, Standard Ebooks, Gutenberg, Google Books, and generated covers against rights, attribution, offline behavior, API/ToS risk, and solo-maintainer cost.
- Produce a small rights manifest for the five seed titles, even when each resolves to generated art.
- Define the metadata fields T12/T07 need (`coverAsset`, `coverSource`, `coverLicense`, `coverAttribution`, `coverRetrievedAt`).
- Decide which covers can be bundled locally and which must remain generated.

## Out of scope
- Library grid implementation (T12).
- Runtime cover downloading or remote catalog work (T07/T12).
- App feature code or broad visual redesign.
- Treating a source’s “public domain book” status as proof that a third-party scan or cover image is also cleared.

## Acceptance tests
- [ ] A source matrix and one MVP recommendation are recorded in this trunk.
- [ ] Each seed title has a cover disposition and rights/attribution record; unresolved titles use generated fallback.
- [ ] No recommendation requires hotlinking or an unverified community/commercial cover.
- [ ] T12 has a clear local asset/metadata contract.

## Research links
- [Open Library Covers API](https://openlibrary.org/dev/docs/api/covers) and [API limits](https://openlibrary.org/developers/api).
- [Standard Ebooks cover-art guidance](https://standardebooks.org/contribute/how-tos/how-to-choose-and-create-a-cover-image) and [art manual](https://standardebooks.org/manual/1.9.0/10-art-and-images).
- [Project Gutenberg linking/image guidance](https://www.gutenberg.org/policy/linking.html) and [license](https://www.gutenberg.org/policy/license).
- [Google Books branding](https://developers.google.com/books/branding) and [API terms](https://developers.google.com/books/terms).

## Files likely touched
- `docs/plan/trunks/T11-book-covers-source.md`
- A dated cover-rights brief or manifest under `docs/plan/` if needed.

## Handoff
- Next: **T12-library-cover-grid-ux**, using generated covers first and only cleared local art assets.
