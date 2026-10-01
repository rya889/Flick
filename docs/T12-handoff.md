# T12 — Library cover grid UX

- **`FlickBookCover`** — deterministic typography (title/author/hue); bundled asset path only when manifest says `bundled`.
- **Library shelf** — 2-column grid with cover, title, progress, reader icon; tap opens Story (Now).
- **Samples** — typography thumbnails on add list.
- Tests: `book_cover_test.dart` (34 total suite).

Offline: no network covers. Imported books without art use same fallback.

Next: **T13-onboarding-empty-states**.
