# T16 — Premium voices inside Pro

## Done
- `pickSpokenVoice(..., allowPremiumVoices: plusActive)` — free tier picks compact/basic EN only; Pro uses enhanced/Siri scoring (unchanged Pro SKU).
- Voice sheet locks premium-tier rows for free users → `showHouseProPrompt(voiceTease)`.
- Listen voice refreshes after Pro demo toggle / purchase / restore.
- Now chrome: basic-voice snackbar with Pro action (free only).
- House prompt copy updated for on-device premium voices (no “cloud later”).

## Fair use
- v1 uses **on-device** Apple voices only; no cloud TTS meter yet. Future cloud path should add daily caps without mid-Listen interrupts.

## Tests
- `tts_voice_test.dart` — free tier avoids enhanced/premium picks.
- Full `flutter test` green.

## Ryan check
- **Free:** Settings → turn off Pro demo → Listen on Now → basic voice label; unmute shows Pro snackbar optional.
- **Pro:** Enable Pro demo → re-open app or toggle Pro → Listen should prefer enhanced/Siri if installed (Settings → Spoken Content).
- Reader → Voice menu: premium rows show lock until Pro.
- PD books open without Pro.
