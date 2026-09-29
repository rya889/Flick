# Flick — Deploy & secrets

## iOS device run (physical iPhone)

Requires Mac + Xcode. This repo targets **iOS 15+** and bundle id **`com.rya889.flick`**.

### Pull latest build onto your phone (includes fixing local git blockers)

**Every test run — discard all local changes and match the branch:**

```bash
cd ~/dev/Flick && bash scripts/hard-sync-test.sh && cd app && flutter run -d rPhone17 --release
```

One-liner without the script (same effect):

```bash
cd ~/dev/Flick && git fetch origin cursor/fix-ios-deploy-target-983e && git checkout cursor/fix-ios-deploy-target-983e && git reset --hard origin/cursor/fix-ios-deploy-target-983e && git clean -fd && cd app && flutter pub get && rm -rf ios/Pods ios/Podfile.lock ios/.symlinks build/ios && (cd ios && pod install --repo-update) && flutter clean && flutter run -d rPhone17 --release
```

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

**If Flick crashes on launch:** capture logs while reproducing:

```bash
cd ~/dev/Flick/app
flutter run -d rPhone17 --release -v 2>&1 | tee /tmp/flick-ios.log
```

Or in Xcode: **Window → Devices and Simulators → your iPhone → Open Console**, filter `Runner` / `Flick`, launch the app, copy the crash lines.

### “Xcode build done” but Flutter cannot install / launch

Build succeeded; **install or launch** failed. Run the checklist:

```bash
cd ~/dev/Flick
bash scripts/ios-device-doctor.sh
```

Most common fixes:

1. **Signing file + pods** (if you skipped this after hard sync):
   ```bash
   FLICK_IOS_TEAM=YOUR10CHARID bash scripts/ios-configure-signing.sh
   bash scripts/ios-reinstall-pods.sh
   cd app && flutter run -d rPhone17 --release
   ```
2. **Developer Mode** on the iPhone (iOS 16+): Settings → Privacy & Security → Developer Mode → On (reboot if prompted).
3. **Unlock the phone** while Flutter shows “Installing and launching…”.
4. **Register the device profile once** in Xcode: `open app/ios/Runner.xcworkspace` → select **rPhone17** at the top → **Product → Run**. After that, `flutter run --release` usually works without opening Xcode again.
5. **Verbose log** to see the real error (provisioning vs crash):
   ```bash
   cd app && flutter run -d 00008150-000C10D62687801C --release -v 2>&1 | tee /tmp/flick-ios-run.log
   ```
6. Prefer **USB** if wireless deploy fails; retry with the UDID: `-d 00008150-000C10D62687801C`.

If the **Flick icon appears** on the home screen but Flutter still errors, open the app manually — if it crashes immediately, use **Devices → Open Console** (not a signing issue).

After pulling crash fixes, **re-run pods** (Podfile pins RevenueCat + static frameworks):

```bash
bash scripts/ios-reinstall-pods.sh
```

If Xcode reports **SwiftUICore** linker errors, an old pod install added a flag Xcode rejects. From repo root:

```bash
bash scripts/strip-swiftuicore-linker.sh
# or restore a clean project file:
git restore app/ios/Runner.xcodeproj/project.pbxproj
```

Then in Xcode: **Runner → Build Settings → Other Linker Flags** — ensure **`-weak_framework SwiftUICore` is not listed**.

### First-time signing (once per Mac)

Xcode stores your **Team** in `project.pbxproj` if you pick it in the UI. Our test scripts run **`git reset --hard`**, which **removes that Team** every pull — so Xcode asks you to sign again.

**Fix:** keep Team ID in a **gitignored local file** (survives hard sync):

```bash
cd ~/dev/Flick
# Team ID = 10-character id from Xcode → Runner → Signing, or Apple Developer membership
FLICK_IOS_TEAM=YOURTEAMID bash scripts/ios-configure-signing.sh
```

Then use **`flutter run`** (or `hard-sync-test.sh`) — you should **not** need to open Xcode to re-select Team after each agent update.

Optional manual setup: copy `app/ios/Flutter/Signing.local.xcconfig.example` → `Signing.local.xcconfig` and replace `XXXXXXXXXX` with your Team ID.

If Xcode still nags, open the workspace once to refresh profiles (not every pull):

```bash
cd app
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

**iPhone “Untrusted Developer”** (Settings → General → VPN & Device Management) is separate: you only re-trust when the **certificate or bundle id changes**, not on every Dart code update. Keep **`com.rya889.flick`** and the same Apple ID to avoid repeating that step.

### UIScene lifecycle (Xcode 27 / iOS 27 SDK)

Apple requires the **UIScene** app lifecycle on upcoming iOS versions. This repo adopts it via `UIApplicationSceneManifest` in `Info.plist` and `FlutterImplicitEngineDelegate` in `AppDelegate.swift` (see [Flutter UIScene migration](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)).

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
