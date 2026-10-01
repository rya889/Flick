# Flick (Flutter prototype)

**The anti-doomscroll reader.**

Implements Design Specs in [`../docs/`](../docs/) as a runnable Flutter prototype (Android / iOS / web).

## Tests

```bash
cd app && flutter test
```

Latest baseline and vault-vs-code deltas: [`../docs/T01-handoff.md`](../docs/T01-handoff.md). **One trunk per session.**

## Run

```bash
cd app
flutter pub get
flutter run -d chrome          # fastest demo in this environment
# flutter run -d android
# flutter run -d ios
```

## iOS Simulator (one command)

From repo root (pulls `main`, opens Simulator, debug run):

```bash
cd ~/dev/Flick && bash scripts/to-simulator.sh
```

Sync matches `origin/main` with `reset --hard` (discards local edits on tracked files). Optional: `FLICK_TEST=1`; `FLICK_SIMULATOR="iPhone 16"`; `FLICK_KEEP_LOCAL=1` to `pull --rebase` instead.

## iPhone (physical device)

See **[`../docs/04-deploy-and-secrets.md`](../docs/04-deploy-and-secrets.md)** — section *Pull latest build onto your phone* (includes `git restore` for local changes + `scripts/iphone-pull-and-run.sh`).

Quick:

```bash
cd ~/dev/Flick
FLICK_IOS_DEVICE=rPhone17 bash scripts/iphone-pull-and-run.sh
```

## Phone / durable web

Prefer the **repo-root** Vercel project (Flutter web + `/v1` AI proxy). See [`../docs/04-deploy-and-secrets.md`](../docs/04-deploy-and-secrets.md).

Local one-shot (expires unless claimed):

```bash
cd app
flutter build web --release --base-href /
cp web/vercel.json build/web/
cd build/web && npx vercel deploy --temporary --yes
```

## Feature status

| In | Notes |
|----|-------|
| Story + Bounce player | — |
| Karaoke autoplay, pips, chapter nav | — |
| Extractive TLDR (free) | — |
| **AI TLDR via `/v1/tldr`** | Plus-gated; needs server AI keys |
| OS TTS Listen + 60 min cap | Unlimited with Plus |
| Hearts, saves, share | — |
| EPUB / TXT / paste + Drift | — |
| **RevenueCat Plus** | Wired; needs RC + store accounts |
| Signal Coral theme | — |

Out of scope for now: accounts, social, cloud TTS, PDF/MOBI.
