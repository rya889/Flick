# T04 — Listen polish

- Enabled real **60 min/day** free Listen cap (`listenCapped` was hardcoded off).
- **Sticky mute** preference via `listen.muted` in Drift meta.
- **Cap UX:** remaining time label on Now chrome; auto-pause + mute when cap hit.
- Unit tests: `listen_cap_test.dart`.

`cd app && flutter test` → 32 passed.

Next: **T05-finish-shorts-polish**.
