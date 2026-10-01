# T01 — Foundation baseline

One trunk per session. This note records the baseline only. It does not change pricing, samples, or features.

Product locks that supersede stale docs and paywall copy:

- Wedge: public-domain fiction finishers (anti-doomscroll).
- Later seed shelf (not this trunk): Bartleby → The Machine Stops → Notes from Underground → Jekyll & Hyde → The Time Machine.
- Later monetization: Pro $4.99/mo · $29.99/yr; premium voices inside Pro; v1 ads = soft house “try Pro” only; never paywall public-domain books.
- Bundled Kafka *Metamorphosis* (common Gutenberg Wyllie text) is not safe to ship.

## How to run tests

From the repo root:

```bash
cd app && flutter test
```

Also noted in [`app/README.md`](../app/README.md).

## flutter test (2026-10-01)

Command: `cd app && flutter test`  
Result: **21 passed, 2 failed.**

Failures, both in `app/test/catalog_store_test.dart`, same cause: this environment has no `libsqlite3.so`.

- `CatalogStore persists books and shorts in Drift`
- `paste limits reject oversized text`

Error: `Invalid argument(s): Failed to load dynamic library 'libsqlite3.so'`.

Other suites passed (widget, tts voice, reader mvp, reader sync, epub parser, abbreviate, ux flows). These two failures are an environment gap, not a product change in this trunk.

## Vault vs code

| Lock | What the repo still says or ships |
|---|---|
| Pro $4.99/mo · $29.99/yr; voices in Pro | Docs and paywall still say Flick Plus $6.99/mo and $49.99/yr (`docs/01-product-design-spec.md`, `docs/02-backend-spec.md`, `app/lib/screens/paywall_sheet.dart`) |
| Seed shelf: Bartleby, The Machine Stops, Notes from Underground, Jekyll & Hyde, The Time Machine | Bundled samples in `app/lib/models/models.dart` are Alice in Wonderland, A Scandal in Bohemia, and The Metamorphosis |
| Do not ship Kafka/Wyllie *Metamorphosis* | `app/assets/samples/metamorphosis.txt` is still bundled as `sample-metamorphosis`. A one-line do-not-ship comment is on that entry. Replacing the file is T02 |

## Handoff

Ran `cd app && flutter test` on 2026-10-01. Result: 21 passed, 2 failed (`catalog_store_test.dart`, missing `libsqlite3.so`). Deltas are in the table above. Metamorphosis is flagged only; the text is still in the app.

Next trunk: **T02-seed-shelf-in-app** — replace samples with the public-domain seed shelf and remove the unsafe Kafka text. Do not start T02 in this session.
