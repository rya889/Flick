# T02 — Seed shelf in-app

Replaced prototype samples (Alice, Holmes, Kafka *Metamorphosis*) with the five-title public-domain seed shelf. **Bartleby** is first in `sampleLibrary` for day-0 dogfood.

## Gutenberg sources

| Title | PG ebook | Asset | Size (bytes) |
| --- | --- | --- | ---: |
| Bartleby, the Scrivener | [#11231](https://www.gutenberg.org/ebooks/11231) | `app/assets/samples/bartleby.txt` | 82,985 |
| The Machine Stops | [#72890](https://www.gutenberg.org/ebooks/72890) (extracted from collection) | `app/assets/samples/machine-stops.txt` | 68,391 |
| Notes from Underground | [#600](https://www.gutenberg.org/ebooks/600) | `app/assets/samples/notes-underground.txt` | 242,639 |
| Dr. Jekyll and Mr. Hyde | [#43](https://www.gutenberg.org/ebooks/43) | `app/assets/samples/jekyll-hyde.txt` | 141,046 |
| The Time Machine | [#35](https://www.gutenberg.org/ebooks/35) | `app/assets/samples/time-machine.txt` | 181,406 |

Plain-text bodies were trimmed to content between Gutenberg `START`/`END` markers. **Machine Stops** is the lead story only (from “Imagine, if you can…” through the air-ship collapse); other stories in PG #72890 were not bundled.

## Acceptance (2026-10-01)

- [x] Library seed list includes **Bartleby** (`sample-bartleby`).
- [x] Bartleby asset → non-empty Story shorts (`bartleby_shorts_test.dart`).
- [x] No Metamorphosis / Kafka sample in app assets or `sampleLibrary`.
- [x] Sample ID tests updated (`sample_library_test.dart`).
- [x] UI copy: “Add public-domain samples” on Library empty state and Bounce gate.

## Tests

```bash
cd app && flutter test
```

**Result:** 26 passed, 0 failed (after `libsqlite3-dev` on Linux; same Drift suite as T01).

## Code touchpoints

- `app/lib/models/models.dart` — `sampleLibrary`
- `app/assets/samples/*.txt` — five seed texts; removed `alice.txt`, `holmes.txt`, `metamorphosis.txt`
- `app/lib/screens/library_screen.dart`, `now_player.dart` — button copy
- `app/test/sample_library_test.dart`, `app/test/bartleby_shorts_test.dart`

## Handoff

Next trunk: **T03-bartleby-dogfood-e2e** — Ryan path: open Bartleby → Story → Listen → Finish moment in one sitting. Do not regress seed shelf in T03.
