# T15 — Bundled seed cover art

## Done
- Five JPEG covers under `app/assets/covers/` from [Standard Ebooks](https://standardebooks.org) (CC0-1.0).
- `BookCoverMeta` overrides in `app/lib/models/book_cover.dart` with license + attribution per title.
- Rights table updated in `docs/plan/book-covers-rights-manifest-2026-10-01.md`.
- Typography fallback unchanged for imports and asset load errors.

## SE sources
| ID | SE edition |
|----|------------|
| `sample-bartleby` | `herman-melville/short-fiction` |
| `sample-machine-stops` | `e-m-forster/short-fiction` |
| `sample-notes-underground` | `fyodor-dostoevsky/notes-from-underground/constance-garnett` |
| `sample-jekyll-hyde` | `robert-louis-stevenson/the-strange-case-of-dr-jekyll-and-mr-hyde` |
| `sample-time-machine` | `h-g-wells/the-time-machine` |

## Tests
- `flutter test` — 38 passed (includes bundled meta tests).

## Ryan check
- Library → On your shelf: five **photo covers** (not typography blocks).
- Hero chips still use monogram layout.
