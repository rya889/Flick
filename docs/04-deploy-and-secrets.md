# Flick — Deploy & secrets

## iOS device run (physical iPhone)

Requires Mac + Xcode. This repo targets **iOS 15+** and bundle id **`com.rya889.flick`**.

### Pull latest build onto your phone (includes fixing local git blockers)

Feature work lives on branch **`cursor/fix-ios-deploy-target-983e`** until merged to `main`.  
A **release** install is required to see UI changes on the home-screen icon; debug builds need `flutter run` attached.

**One script (recommended):**

```bash
cd ~/dev/Flick
FLICK_IOS_DEVICE=rPhone17 bash scripts/iphone-pull-and-run.sh
```

**Same steps manually** — run from repo root. These lines **discard local edits** that usually block `git pull` (Xcode, `pub get`, etc.):

```bash
cd ~/dev/Flick
git fetch origin cursor/fix-ios-deploy-target-983e

# Drop local changes on files that conflict with the branch
git restore --source=HEAD --staged --worktree \
  app/pubspec.lock \
  app/pubspec.yaml \
  app/ios/Flutter/AppFrameworkInfo.plist \
  app/ios/Runner.xcodeproj/project.pbxproj \
  app/ios/Runner/Info.plist

# If checkout complained about untracked Podfile:
rm -f app/ios/Podfile

git checkout cursor/fix-ios-deploy-target-983e
git pull origin cursor/fix-ios-deploy-target-983e

# Confirm you have the new build (Library-first + Brief label):
grep -n "tabIndex = 1" app/lib/state/flick_controller.dart
grep -n "Brief" app/lib/screens/now_player.dart
git log -1 --oneline

bash scripts/ios-reinstall-pods.sh
cd app
flutter clean
rm -rf build/ios
flutter run -d rPhone17 --release
```

**If you need to keep local edits** instead of discarding:

```bash
git stash push -u -m "wip before flick pull"
git checkout cursor/fix-ios-deploy-target-983e
git pull origin cursor/fix-ios-deploy-target-983e
# … build as above …
git stash pop   # optional; may conflict
```

**If the phone still shows old UI:** force-quit Flick, then run `flutter run … --release` again (do not rely on an old debug install).

### First-time signing

```bash
cd app
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

In Xcode: **Runner → Signing & Capabilities → Team** (your Apple ID). Then use the pull-and-run steps above.

If Pods still complain about an old deployment target, wipe and reinstall:

```bash
cd app/ios
rm -rf Pods Podfile.lock
pod install
```

## Durable web (Vercel)

Repo root deploys Flutter web + `/v1/*` AI proxy:

| Path | Role |
|------|------|
| `scripts/vercel-install.sh` | Clone Flutter stable, `pub get` |
| `scripts/vercel-build.sh` | `flutter build web --release` |
| `api/health.js` | `GET /v1/health` |
| `api/tldr.js` | `POST /v1/tldr` (Plus-gated) |
| `vercel.json` | SPA + API rewrites |

Project (LeTeam): connect GitHub `rya889/Flick`, production branch as desired (this PR uses `cursor/design-docs-and-archive-983e` until merge).

### Server env (Vercel → Project → Settings → Environment Variables)

| Key | Required | Purpose |
|-----|----------|---------|
| `GROQ_API_KEY` | Recommended | Primary free TLDR provider |
| `GEMINI_API_KEY` | Optional | Failover |
| `AI_GATEWAY_API_KEY` | Optional | Vercel AI Gateway failover |
| `FLICK_ALLOW_DEMO_PLUS` | Set `1` for web demos | Accepts `X-Flick-Entitlement: demo` |
| `REVENUECAT_SECRET_API_KEY` | For real Plus checks | Verifies subscriber via RC REST |
| `FLICK_PLUS_SHARED_SECRET` | Optional | Alternate entitlement header value |

Without any AI provider key, `/v1/tldr` returns `503 NO_PROVIDER`.

### Client dart-defines (native builds)

```bash
flutter run \
  --dart-define=REVENUECAT_API_KEY=appl_xxx \
  --dart-define=FLICK_API_BASE=https://YOUR_PROJECT.vercel.app
```

Web on the same Vercel host can leave `FLICK_API_BASE` empty (same-origin `/v1`).

## RevenueCat checklist (user)

1. Create RevenueCat project + apps (iOS / Android).  
2. Entitlement id: `flick_plus`.  
3. Products: `flick_plus_monthly` ($6.99), `flick_plus_yearly` ($49.99, 7-day trial).  
4. Offering `default` with monthly + annual packages.  
5. Paste **public** SDK keys into CI/`--dart-define=REVENUECAT_API_KEY`.  
6. Paste **secret** API key into Vercel `REVENUECAT_SECRET_API_KEY`.  
7. App Store Connect + Play Console paid-apps enrollment (paid yearly accounts).  

Until those exist, paywall uses **demo Plus** on web / when no SDK key is compiled in.
