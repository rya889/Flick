#!/usr/bin/env bash
# One command: match origin/main and run Flick on the iOS Simulator.
#
#   cd ~/dev/Flick && bash scripts/to-simulator.sh
#
# Requires: full Xcode (not only Command Line Tools) + iOS Simulator runtime.
#   xcode-select -p   # should be .../Xcode.app/Contents/Developer
#   flutter doctor
#
# Sync discards uncommitted local edits on tracked files (like to-phone.sh).
#
# Optional:
#   FLICK_SIMULATOR="iPhone 16 Pro" bash scripts/to-simulator.sh
#   FLICK_KEEP_LOCAL=1 bash scripts/to-simulator.sh
#   FLICK_TEST=1 bash scripts/to-simulator.sh
#   FLICK_FALLBACK_MACOS=1 bash scripts/to-simulator.sh   # if no iOS sim (not ideal)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BRANCH="${FLICK_BRANCH:-main}"
SIM_NAME="${FLICK_SIMULATOR:-}"

echo "==> Flick → iOS Simulator"
echo "    branch: $BRANCH"

echo "==> Sync to origin/$BRANCH"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
if [[ "${FLICK_KEEP_LOCAL:-}" == "1" ]]; then
  echo "    (keeping local commits — pull --rebase)"
  git pull --rebase origin "$BRANCH"
else
  echo "    (local code edits on tracked files are discarded)"
  git reset --hard "origin/$BRANCH"
  git clean -fd
fi

if [[ -x "$ROOT/scripts/strip-swiftuicore-linker.sh" ]]; then
  bash "$ROOT/scripts/strip-swiftuicore-linker.sh" || true
fi

cd "$ROOT/app"
echo "==> flutter pub get"
flutter pub get

if [[ "${FLICK_TEST:-}" == "1" ]]; then
  echo "==> flutter test"
  flutter test
fi

if [[ ! -d ios/Pods || ! -f ios/Podfile.lock ]]; then
  echo "==> pod install"
  (cd ios && pod install)
fi

open_ios_simulator() {
  if flutter emulators 2>/dev/null | grep -q apple_ios_simulator; then
    echo "==> Boot iOS Simulator (flutter emulators)"
    flutter emulators --launch apple_ios_simulator || true
    return 0
  fi

  local sim_app="/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
  if [[ -d "$sim_app" ]]; then
    echo "==> Open Simulator.app (Xcode)"
    open "$sim_app"
    return 0
  fi

  if open -a Simulator 2>/dev/null; then
    echo "==> Open Simulator"
    return 0
  fi

  return 1
}

boot_named_simulator() {
  local name="$1"
  [[ -n "$name" ]] || return 1
  if ! command -v xcrun >/dev/null 2>&1; then
    return 1
  fi
  local udid
  udid="$(xcrun simctl list devices available | grep -F "$name (" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
  if [[ -z "$udid" ]]; then
    echo "No simulator named: $name" >&2
    return 1
  fi
  echo "==> Boot simulator: $name ($udid)"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b 2>/dev/null || sleep 3
}

boot_first_iphone_simulator() {
  command -v xcrun >/dev/null 2>&1 || return 1
  local line udid name
  line="$(xcrun simctl list devices available | grep -E 'iPhone.*\([A-F0-9-]+\)' | grep -v unavailable | head -1 || true)"
  [[ -n "$line" ]] || return 1
  udid="$(echo "$line" | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
  name="$(echo "$line" | sed -E 's/^[[:space:]]*(.+)[[:space:]]+\([A-F0-9-]+\).*/\1/')"
  echo "==> Boot simulator: $name ($udid)"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b 2>/dev/null || sleep 3
}

pick_flutter_ios_device() {
  # Prefer a booted iOS simulator (not physical device).
  flutter devices 2>/dev/null | grep -E 'simulator' | grep -i ios | head -1 | sed -E 's/^[[:space:]]*([^•]+)[[:space:]]+•[[:space:]]*([^[:space:]]+).*/\2/' | tr -d '[:space:]'
}

require_xcode_for_ios() {
  local xp
  xp="$(xcode-select -p 2>/dev/null || true)"
  if [[ -z "$xp" ]]; then
    return 1
  fi
  if [[ "$xp" == *CommandLineTools* ]] && [[ ! -d /Applications/Xcode.app ]]; then
    return 1
  fi
  return 0
}

FLUTTER_DEVICE=""

if require_xcode_for_ios; then
  open_ios_simulator || true
  if [[ -n "$SIM_NAME" ]]; then
    boot_named_simulator "$SIM_NAME" || true
  else
    boot_first_iphone_simulator || true
  fi
  sleep 2
  FLUTTER_DEVICE="$(pick_flutter_ios_device || true)"
fi

if [[ -z "$FLUTTER_DEVICE" ]]; then
  if [[ "${FLICK_FALLBACK_MACOS:-}" == "1" ]]; then
    echo "==> No iOS simulator — falling back to macOS (FLICK_FALLBACK_MACOS=1)"
    FLUTTER_DEVICE="macos"
  else
    echo "" >&2
    echo "No iOS Simulator available for Flutter." >&2
    echo "" >&2
    echo "Flutter only sees:" >&2
    flutter devices 2>/dev/null | sed 's/^/  /' >&2 || true
    echo "" >&2
    echo "Fix (one-time):" >&2
    echo "  1. Install Xcode from the App Store (not only Command Line Tools)." >&2
    echo "  2. sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
    echo "  3. sudo xcodebuild -runFirstLaunch" >&2
    echo "  4. Xcode → Settings → Platforms → install an iOS simulator runtime." >&2
    echo "  5. flutter doctor" >&2
    echo "" >&2
    echo "Then run again:  cd ~/dev/Flick && bash scripts/to-simulator.sh" >&2
    echo "Or quick desktop smoke:  FLICK_FALLBACK_MACOS=1 bash scripts/to-simulator.sh" >&2
    exit 1
  fi
fi

echo ""
echo "Running $(git -C "$ROOT" log -1 --oneline) on $FLUTTER_DEVICE"
echo ""

flutter run -d "$FLUTTER_DEVICE"
