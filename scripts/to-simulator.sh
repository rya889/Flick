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
#   FLICK_SIMULATOR="iPhone 17 Pro" bash scripts/to-simulator.sh
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

pick_flutter_ios_device() {
  python3 - <<'PY' 2>/dev/null
import json, re, subprocess
raw = subprocess.check_output(["flutter", "devices", "--machine"], text=True)
devices = [d for d in json.loads(raw) if d.get("emulator") and d.get("targetPlatform") == "ios"]
if not devices:
    raise SystemExit(1)

def iphone_num(name: str) -> int:
    m = re.search(r"iPhone (\d+)", name or "")
    return int(m.group(1)) if m else 0

# Prefer the newest iPhone model Flutter already sees (usually the booted sim).
devices.sort(key=lambda d: iphone_num(d.get("name", "")), reverse=True)
print(devices[0]["id"])
PY
}

simctl_boot_if_needed() {
  local want_name="${1:-}"
  python3 - "$want_name" <<'PY'
import json, re, subprocess, sys

want = sys.argv[1].strip()

def iphone_num(name: str) -> int:
    m = re.search(r"iPhone (\d+)", name or "")
    return int(m.group(1)) if m else 0

data = json.loads(
    subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"], text=True)
)
candidates = []
for runtime, devs in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for d in devs:
        if not d.get("isAvailable", True):
            continue
        name = d.get("name", "")
        if "iPhone" not in name:
            continue
        candidates.append(d)

if not candidates:
    raise SystemExit(1)

booted = [d for d in candidates if d.get("state") == "Booted"]
if booted:
    booted.sort(key=lambda d: iphone_num(d["name"]), reverse=True)
    d = booted[0]
    print(f'==> Using booted simulator: {d["name"]} ({d["udid"]})', flush=True)
    raise SystemExit(0)

if want:
    matches = [d for d in candidates if d["name"] == want]
    if not matches:
        print(f"No simulator named: {want}", file=sys.stderr)
        raise SystemExit(1)
    pick = matches[0]
else:
    candidates.sort(key=lambda d: iphone_num(d["name"]), reverse=True)
    pick = candidates[0]

udid = pick["udid"]
name = pick["name"]
print(f"==> Boot simulator: {name} ({udid})", flush=True)
subprocess.run(["xcrun", "simctl", "boot", udid], check=False)
PY
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
  # If a sim is already booted (e.g. iPhone 17 Pro), do not boot a random older one.
  FLUTTER_DEVICE="$(pick_flutter_ios_device || true)"
  if [[ -z "$FLUTTER_DEVICE" ]]; then
    simctl_boot_if_needed "$SIM_NAME" || true
    sleep 4
    FLUTTER_DEVICE="$(pick_flutter_ios_device || true)"
  else
    echo "==> Flutter already sees an iOS simulator — skipping simctl boot"
  fi
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
