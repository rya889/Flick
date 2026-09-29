#!/usr/bin/env bash
# Quick checks when: "Could not run build/ios/iphoneos/Runner.app" after Xcode build succeeded.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"
SIGNING="$APP/ios/Flutter/Signing.local.xcconfig"
DEVICE="${FLICK_IOS_DEVICE:-rPhone17}"
UDID="${FLICK_IOS_UDID:-00008150-000C10D62687801C}"

echo "==> Flick iOS device doctor"
echo "Repo: $(git -C "$ROOT" log -1 --oneline 2>/dev/null || echo '(not a git repo)')"
echo ""

fail=0
warn() { echo "⚠️  $*"; fail=1; }
ok() { echo "OK: $*"; }

if [[ ! -f "$SIGNING" ]]; then
  warn "Missing $SIGNING — run: FLICK_IOS_TEAM=YOUR10CHARID bash scripts/ios-configure-signing.sh"
else
  ok "Signing.local.xcconfig present ($(grep DEVELOPMENT_TEAM "$SIGNING" | head -1))"
fi

if [[ ! -d "$APP/ios/Pods" ]]; then
  warn "No ios/Pods — run: bash scripts/ios-reinstall-pods.sh"
else
  ok "Pods directory exists"
fi

cd "$APP"
if ! command -v flutter >/dev/null; then
  warn "flutter not in PATH"
else
  echo ""
  echo "==> flutter devices"
  flutter devices 2>&1 | sed 's/^/    /' || true
  echo ""
  if ! flutter devices 2>/dev/null | grep -qE "$DEVICE|$UDID"; then
    warn "Device '$DEVICE' / UDID not listed — unlock iPhone, trust this Mac, use USB if wireless fails"
  else
    ok "Device visible to Flutter"
  fi
fi

RUNNER_APP="$APP/build/ios/iphoneos/Runner.app"
if [[ -d "$RUNNER_APP" ]]; then
  echo ""
  echo "==> codesign (last build)"
  codesign -dv --verbose=2 "$RUNNER_APP" 2>&1 | sed -n '1,12p' | sed 's/^/    /' || warn "codesign check failed on Runner.app"
else
  echo ""
  echo "(No $RUNNER_APP yet — build with: cd app && flutter build ios --release)"
fi

echo ""
echo "==> Common fixes for install/launch failure"
cat <<'TXT'
  1. One-time signing (survives git reset):
       FLICK_IOS_TEAM=XXXXXXXXXX bash scripts/ios-configure-signing.sh
       bash scripts/ios-reinstall-pods.sh
  2. iPhone: Settings → Privacy & Security → Developer Mode → ON (reboot if asked)
  3. Unlock phone during "Installing and launching…"
  4. First install on this bundle id: open ios/Runner.xcworkspace → select rPhone17 → Product → Run once
  5. Verbose log:
       cd app && flutter run -d rPhone17 --release -v 2>&1 | tee /tmp/flick-ios-run.log
     Search the log for: error:, IXError, AMFI, verify, provisioning, killed
  6. If app icon appears but Flutter errors: launch Flick manually; crash = Xcode → Devices → Open Console
TXT

exit "$fail"
