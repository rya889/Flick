# T09 — House Pro soft prompts (v1 ads)

**Widget:** `house_pro_prompt.dart` — dismissible bottom sheet, no third-party SDK.

| Placement | When |
| --- | --- |
| After Finish | Only after user dismisses **Finished!** overlay (not during animation) |
| Settings | Flick Pro row |
| Voice tease | Settings when basic OS voice detected |

**Never:** mid-Listen, karaoke, or Finish celebration overlay.

### Manual checklist
- [ ] Finish Bartleby → dismiss celebration → soft Pro sheet appears → **Not now** returns to reading.
- [ ] Settings → Flick Pro → sheet → dismiss.
- [ ] Settings → Natural Listen voices (if basic voice) → sheet.
- [ ] Unmute Listen on a short — **no** interstitial while playing.

Stop before **T10** (parked).
