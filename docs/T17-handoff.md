# T17 — Ship stabilize (TestFlight / friend alpha)

**Status:** complete on `main`  
**Tests:** `flutter test` — **43 passed** (2026-10-02)

## Goal
Dogfood-clean build for friend alpha. No Bounce, no T10 ads, no cloud TTS, no paywall redesign.

## Regression covered (automated + intended manual)

| Path | Automated | Manual |
|------|-----------|--------|
| Bartleby dogfood id + finish on last short | `bartleby_dogfood_test`, `bartleby_shorts_test` | Yes |
| PD samples never library-blocked | `bartleby_dogfood_test` | Yes |
| Seed covers bundled (SE CC0) | `book_cover_test` | Library shelf photos |
| Free / Pro Listen voice gating | `tts_voice_test` | Settings Pro demo |
| Reader place ↔ Story short | `reader_sync_test`, `ux_flows_test` | Shorts ↔ Pages toggle |
| Reader paper follows app theme | `reader_paper_theme_test` | Dark/Light settings |
| Free library caps / EPUB gate | `reader_mvp_test`, `ux_flows_test` | Optional |
| Cover layout no overflow | `flick_book_cover_layout_test` | Visual |

## Ryan alpha checklist

```bash
cd ~/dev/Flick && bash scripts/to-simulator.sh
# Prefer: iPhone 17 Pro (default). Override: FLICK_SIMULATOR="iPhone 17 Pro"
```

1. **Fresh shelf** — Library → Add samples (or empty state → Start with Bartleby). Five seed covers should show **photos**, not blank typography blocks.
2. **Bartleby dogfood** — Open Bartleby → **Now → Shorts** → swipe a few → unmute **Listen** → karaoke moves → reach last short → **Finished** overlay.
3. **Shorts ↔ Pages** — Toggle layout; place should stay on the same passage; Listen should keep going if playing.
4. **Chapters** — List button next to Shorts/Pages opens chapters (works in both modes).
5. **Theme** — Settings → Dark: reader background dark. Light: light. Sepia only if you set it in Pages text menu.
6. **Margin taps** — Rapid double-tap right margin: one page/short at a time (no runaway).
7. **Browse PD** — Library → Browse PD → search a title → import (respect free import cap) → opens on Now.
8. **Pro voices** — Settings → Pro demo on → Listen prefers enhanced/Siri if installed. Off → basic. PD text still readable without Pro.
9. **No PD paywall** — Never asked to pay to open Bartleby / seed / catalog PD text.

## Known limitations (alpha OK)

- **On-device voices only** — no cloud TTS; Pro unlocks enhanced/Siri-class Apple voices when downloaded.
- **Imported / catalog books** — typography covers unless a rights-recorded asset is added later.
- **T10 ads** — parked; house Pro soft prompts only.
- **Bounce** — soft-prompt only; not the alpha path.
- **Sync** — device-local; Drive/Files not required for alpha.
- **Simulator** — script defaults to **iPhone 17 Pro**; shut down other sims if Flutter still attaches oddly.

## Tiny UX in this trunk

- Chapters button on **Shorts** falls back to a short-index chapter list if the Pages host isn’t wired yet.

## Stop

Hard stop after T17. Do **not** invent T18 until Ryan names the next trunk.
