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

## Seed shelf disposition (five titles) — T15 bundled

| Book | ID | Asset | License | SE source |
| --- | --- | --- | --- | --- |
| Bartleby, the Scrivener | `sample-bartleby` | `assets/covers/bartleby.jpg` | CC0-1.0 | `herman-melville/short-fiction` (collection cover) |
| The Machine Stops | `sample-machine-stops` | `assets/covers/machine-stops.jpg` | CC0-1.0 | `e-m-forster/short-fiction` (collection cover) |
| Notes from Underground | `sample-notes-underground` | `assets/covers/notes-underground.jpg` | CC0-1.0 | `fyodor-dostoevsky/notes-from-underground/constance-garnett` |
| Dr. Jekyll and Mr. Hyde | `sample-jekyll-hyde` | `assets/covers/jekyll-hyde.jpg` | CC0-1.0 | `robert-louis-stevenson/the-strange-case-of-dr-jekyll-and-mr-hyde` |
| The Time Machine | `sample-time-machine` | `assets/covers/time-machine.jpg` | CC0-1.0 | `h-g-wells/the-time-machine` |

Imported / non-seed titles remain **generated** unless a new manifest row is added.

## Unresolved title policy

Titles that cannot be matched to a US-PD edition (e.g. misspelled “Peize”) stay **generated** until edition + rights are confirmed. Do not attach lookalike modern cover art.

## Handoff

T12 implements `BookCoverResolver` + `FlickBookCover`; no network fetch in the initial grid pass.
