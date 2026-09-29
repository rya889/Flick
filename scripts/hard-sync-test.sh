#!/usr/bin/env bash
# Throw away ALL local changes and match the remote branch exactly, then refresh iOS build inputs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH="${FLICK_BRANCH:-cursor/fix-ios-deploy-target-983e}"

cd "$ROOT"
echo "==> Hard sync to origin/$BRANCH (local edits will be discarded)"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git reset --hard "origin/$BRANCH"
git clean -fd

if [[ -x "$ROOT/scripts/strip-swiftuicore-linker.sh" ]]; then
  bash "$ROOT/scripts/strip-swiftuicore-linker.sh" || true
fi

cd "$ROOT/app"
flutter pub get
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks build/ios
rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/Runner-* 2>/dev/null || true
(cd ios && pod install --repo-update)
flutter clean

echo ""
echo "Ready at: $(git -C "$ROOT" log -1 --oneline)"
if [[ ! -f "$ROOT/app/ios/Flutter/Signing.local.xcconfig" ]]; then
  echo ""
  echo "Tip: To avoid re-signing in Xcode after every sync, run once:"
  echo "  FLICK_IOS_TEAM=YOUR10CHARID bash scripts/ios-configure-signing.sh"
fi
echo "Run:  cd app && flutter run -d rPhone17 --release"
echo "      (or set FLICK_DEVICE=your_device_name)"
