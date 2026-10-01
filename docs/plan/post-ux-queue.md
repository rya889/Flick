---
date: 2026-10-01
type: plan
status: decision
tags: [flick, roadmap, post-t14]
---

# After T11–T14 (UX queue complete)

## Shipped in UX queue

| Trunk | Summary |
|-------|---------|
| T11 | Cover rights manifest + generated typography default |
| T12 | Library 2-col cover grid, `FlickBookCover` |
| T13 | Library / catalog empty states |
| T14 | Continue reading hero, reader resume chip, chrome polish |

**Regression bar:** Bartleby → Story → Listen → Finish still works; PD never paywalled.

## Ryan visual checklist (T14)

See [`docs/T14-handoff.md`](../T14-handoff.md). Run on simulator after `git pull` + `scripts/to-simulator.sh`.

## Next build options (pick one trunk / theme per session)

Nothing is auto-scheduled after T14. **T10 stays parked** until Ryan unlocks in writing.

| Priority | Theme | Notes |
|----------|--------|--------|
| A | **Bundled seed cover art** | Per T11: rights-recorded Standard Ebooks / CC0 only; wire `BookCoverMeta` overrides |
| B | **Sync / backup polish** | Existing sync sheet; harden restore, errors, empty sync |
| C | **Bounce / queue** | Algorithm and UX for multi-book bounce (large; split) |
| D | **Premium voices in Pro** | Cloud TTS behind Pro; no new paywall surfaces |
| E | **Phase 1.5 rewarded voice trial** | Optional listen trial; see pricing research |
| F | **T10 ads Phase 2** | **Blocked** — native shorts + Finish interstitial |

## Agent start

1. Ryan names a row (A–F) or a new trunk file.
2. If no trunk file exists, add one under `docs/plan/trunks/` before coding.
3. Do not reopen T08/T09 paywall copy unless Ryan asks.
