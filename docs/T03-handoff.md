# T03 — Bartleby dogfood end-to-end

## Shipped
- **Bartleby path:** Library empty state **Start with Bartleby**; in-shelf **Start with Bartleby** card; sample tile labeled “recommended start”; `openBartlebyStory()` opens Story (Now tab).
- **Finish moment:** On last Story short, swipe/advance or Listen auto-advance shows **Finished!** overlay; persists `completedBookIds`; Library shows **Finished** on shelf row.
- **PD safety:** Samples never count toward import cap (`library_access` unchanged); no paywall on sample text.
- **Tests:** `bartleby_dogfood_test.dart`, `book_finish.dart` unit checks.

## Tests
`cd app && flutter test` → **29 passed** (2026-10-01).

## Ryan device check
1. Open Flick → **Library** tab.
2. Tap **Start with Bartleby** (card or empty-state button) — lands on **Now** with Bartleby Story shorts.
3. Tap center of short to **play**; tap **speaker** (unmute) for **Listen** + karaoke highlight on one short.
4. Swipe up through shorts until the last; swipe again (or let Listen finish the last short) → **Finished!** sheet.
5. Tap **Back to Library** — Bartleby row shows **Finished**.

## Friction / Finish notes
- First launch may auto-seed all five samples (`bootstrap` when DB empty); Bartleby card still highlights the dogfood path.
- Listen uses OS TTS; premium voice download is a Settings/Accessibility path (snackbar on first unmute).
- Finish celebration is in-app only (no share sheet yet).

## Handoff
Next: **T04-listen-polish**.
