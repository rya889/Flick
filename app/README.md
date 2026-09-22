# Flick (Flutter prototype)

**The anti-doomscroll reader.**

Implements Design Specs in [`../docs/`](../docs/) as a runnable Flutter prototype (Android / iOS / web).

## Run

```bash
cd app
flutter pub get
flutter run -d chrome          # fastest demo in this environment
# flutter run -d android
# flutter run -d ios
```

## Phone test (web)

```bash
cd app
flutter build web --release --base-href /
cp web/vercel.json build/web/
cd build/web && npx vercel deploy --temporary --yes
```

Open the printed URL on your phone. If it’s an anonymous deploy, **claim it** from the printed claim link so it doesn’t expire in ~60 minutes.

For a lasting project under your Vercel team: `npx vercel login`, then deploy from `build/web` into project `flick`.


| In | Out / stub |
|----|------------|
| Story + Bounce player | Real IAP (demo Plus toggle) |
| Karaoke autoplay, pips, chapter nav | EPUB parser (TXT + paste) |
| Extractive TLDR submodes | AI TLDR API |
| OS TTS Listen + 60 min cap UI | Background audio |
| Hearts, saves, share | Social / accounts |
| Samples + library | Drift (uses SharedPreferences) |
| Signal Coral theme System/Light/Dark | — |

See `/docs` for the definitive product direction.
