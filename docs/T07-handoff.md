# T07 — PD catalog browse + import

- **Browse PD** on Library → `PdCatalogScreen` (Gutendex search, English).
- Import: download plain text → `importCatalogBook` → Story/Listen via `openBook`.
- Id: `gutenberg-{id}`; errors surface as snackbar without DB writes.
- Seeds remain offline-first.

**API:** `https://gutendex.com/books/` + PG text URLs from `formats`.

**Manual:** Library → Browse PD → search `wells` → import → Now tab plays.

Tests: `gutenberg_catalog_test.dart`, `ux_flows_test` catalog/sample blocks.

Next: **T08-pro-paywall-soft**.
