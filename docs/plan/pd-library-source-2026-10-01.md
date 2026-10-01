# PD library source — 2026-10-01

**Decision for T07:** Use **[Gutendex](https://gutendex.com/)** (Gutenberg metadata JSON API) + direct **Project Gutenberg plain-text** URLs from each book’s `formats` map.

## Comparison

| Option | US PD clarity | Quality | ToS / App risk | Offline | Maintainer cost | Flutter fit |
| --- | --- | --- | --- | --- | --- | --- |
| **Gutendex + PG text URLs** | High (PG ids) | Plain UTF-8; variable headers | Low — public APIs, no scraping Goodreads | Seeds offline; browse needs network | Low | `http` + existing TXT import |
| Gutenberg RDF/API mirrors | High | Good | Medium — fewer hosted mirrors | Same | Medium | More parsing |
| Standard Ebooks | High | Excellent EPUB | Medium — separate catalog + licenses | Bundles heavy | Medium | EPUB path exists |
| OPDS (e.g. Internet Archive) | Mixed | Variable | Medium | Harder search | Higher | Extra dependency |
| Open Library only | Metadata | Often not PD text | **High** — wrong text risk | — | — | Not for MVP |

## MVP scope (T07)

- Library → **Browse PD** → search Gutendex (`languages=en`) → tap title → download `text/plain` → `BookSource.catalog` via `CatalogStore.importCatalogBook`.
- Dedupe by `gutenberg-{id}`; failures show snackbar, no DB corruption.
- Bundled seed shelf unchanged and works offline.

## Risks / follow-ups

- Gutendex is a community API — rate limits unknown; cache results in-session only for MVP.
- Gutenberg headers/footers remain in text (same as bundled seeds); strip in a later trunk if needed.
- Non-US users: product still positions US PD; no geo enforcement in MVP.
- Do **not** scrape Goodreads or ship non-PD translations (e.g. Kafka Wyllie).

## Fallback

If Gutendex is down: user can still use seed shelf + paste/TXT import; optional future mirror of a static PG top-100 JSON in repo.
