# Book covers — rights manifest & T12 contract (2026-10-01)

**MVP decision (T11):** Every book displays a **deterministic generated typography cover** (title + author + palette from `coverHue` / book id). No runtime hotlinking. Optional bundled art only after a row exists in this manifest.

## Metadata contract (T12 / catalog)

| Field | Type | Notes |
| --- | --- | --- |
| `coverSource` | `generated` \| `bundled` \| `lookup_pending` | Default `generated` |
| `coverAsset` | `String?` | Repo path e.g. `assets/covers/bartleby.webp` when bundled |
| `coverLicense` | `String?` | SPDX or “US-PD” + URL |
| `coverAttribution` | `String?` | Artist + source line for About |
| `coverRetrievedAt` | `ISO date?` | When art was verified |
| `coverLookupId` | `String?` | OLID / CoverID for research only — not clearance |

Resolver: `coverAsset` + `bundled` → local image; else → `FlickBookCover` typography widget.

## Source matrix (summary)

| Source | MVP use |
| --- | --- |
| Generated typography | **Default + required fallback** |
| Standard Ebooks / museum CC0 | Optional bundled art after per-title verification |
| Gutenberg in-ebook image | Case-by-case; self-host; no hotlink |
| Open Library Covers API | Lookup / candidate preview only; no auto-ship |
| Google Books thumbnails | Research fallback only; not runtime |

## Seed shelf disposition (five titles)

| Book | ID | Cover disposition | Notes |
| --- | --- | --- | --- |
| Bartleby, the Scrivener | `sample-bartleby` | **generated** | PG #11231; no bundled art in T12 |
| The Machine Stops | `sample-machine-stops` | **generated** | Extract from PG #72890 collection |
| Notes from Underground | `sample-notes-underground` | **generated** | PG #600 |
| Dr. Jekyll and Mr. Hyde | `sample-jekyll-hyde` | **generated** | PG #43 |
| The Strange Case… | | | |
| The Time Machine | `sample-time-machine` | **generated** | PG #35 |

All five: `coverSource=generated`, no `coverAsset`. Future SE/CC0 art adds a manifest row before bundling.

## Unresolved title policy

Titles that cannot be matched to a US-PD edition (e.g. misspelled “Peize”) stay **generated** until edition + rights are confirmed. Do not attach lookalike modern cover art.

## Handoff

T12 implements `BookCoverResolver` + `FlickBookCover`; no network fetch in the initial grid pass.
