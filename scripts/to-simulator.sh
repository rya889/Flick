#!/usr/bin/env bash
# One command: match origin/main and run Flick on the iOS Simulator.
#
#   cd ~/dev/Flick && bash scripts/to-simulator.sh
#
# Logs: .flick/last-to-simulator.log
# On failure, prints a "COPY FOR CURSOR AGENT" block (errors highlighted in red).
#
# Optional:
#   FLICK_SIMULATOR="iPhone 17 Pro" bash scripts/to-simulator.sh
#   FLICK_VERBOSE=1 bash scripts/to-simulator.sh      # show noisy lines too
#   FLICK_FULL_LOG=1 bash scripts/to-simulator.sh    # no error filtering on flutter output
#   FLICK_KEEP_LOCAL=1 | FLICK_TEST=1 | FLICK_FALLBACK_MACOS=1
#
# Device pick order:
#   1) FLICK_SIMULATOR name (exact match) — boots it even if another sim is already open
#   2) else newest booted iPhone
#   3) else newest available iPhone
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/agent-report.sh
source "$ROOT/scripts/lib/agent-report.sh"

cd "$ROOT"
flick_report_init "to-simulator"

BRANCH="${FLICK_BRANCH:-main}"
# Default to Ryan's usual device; override with FLICK_SIMULATOR=...
SIM_NAME="${FLICK_SIMULATOR:-iPhone 17 Pro}"
LAST_STEP="init"

fail() {
  local code="${1:-1}"
  local step="${2:-$LAST_STEP}"
  flick_emit_agent_block "$code" "$step"
  exit "$code"
}

if [[ "${FLICK_VERBOSE:-}" == "1" ]]; then
  set -x
fi

LAST_STEP="git sync"
flick_log "Flick → iOS Simulator (branch $BRANCH)"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
if [[ "${FLICK_KEEP_LOCAL:-}" == "1" ]]; then
  flick_log "pull --rebase origin/$BRANCH"
  git pull --rebase origin "$BRANCH"
else
  flick_log "reset --hard origin/$BRANCH"
  git reset --hard "origin/$BRANCH"
  git clean -fd
fi

if [[ -x "$ROOT/scripts/strip-swiftuicore-linker.sh" ]]; then
  bash "$ROOT/scripts/strip-swiftuicore-linker.sh" || true
fi

cd "$ROOT/app"
LAST_STEP="flutter pub get"
flick_log "flutter pub get"
flutter pub get || fail $? "flutter pub get"

if [[ "${FLICK_TEST:-}" == "1" ]]; then
  LAST_STEP="flutter test"
  flick_log "flutter test"
  flutter test || fail $? "flutter test"
fi

if [[ ! -d ios/Pods || ! -f ios/Podfile.lock ]]; then
  LAST_STEP="pod install"
  flick_log "pod install"
  (cd ios && pod install) || fail $? "pod install"
fi

open_ios_simulator() {
  if flutter emulators 2>/dev/null | grep -q apple_ios_simulator; then
    flick_log "flutter emulators --launch apple_ios_simulator"
    flutter emulators --launch apple_ios_simulator || true
    return 0
  fi

  local sim_app="/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
  if [[ -d "$sim_app" ]]; then
    flick_log "open Simulator.app"
    open "$sim_app"
    return 0
  fi

  open -a Simulator 2>/dev/null && return 0
  return 1
}

pick_flutter_ios_device() {
  local want_name="${1:-}"
  python3 - "$want_name" <<'PY' 2>/dev/null
import json, re, subprocess, sys
want = (sys.argv[1] if len(sys.argv) > 1 else "").strip()
raw = subprocess.check_output(["flutter", "devices", "--machine"], text=True)
devices = [d for d in json.loads(raw) if d.get("emulator") and d.get("targetPlatform") == "ios"]
if not devices:
    raise SystemExit(1)

def iphone_num(name: str) -> int:
    m = re.search(r"iPhone (\d+)", name or "")
    return int(m.group(1)) if m else 0

if want:
    exact = [d for d in devices if d.get("name") == want]
    if exact:
        print(exact[0]["id"])
        raise SystemExit(0)
    # Flutter sometimes suffixes the name; allow contains match.
    soft = [d for d in devices if want in (d.get("name") or "")]
    if soft:
        print(soft[0]["id"])
        raise SystemExit(0)

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

# Prefer an explicit name (e.g. iPhone 17 Pro) over whatever is already booted.
if want:
    matches = [d for d in candidates if d["name"] == want]
    if not matches:
        # Soft match: "iPhone 17 Pro" vs "iPhone 17 Pro (16.x)"
        matches = [d for d in candidates if want in d["name"]]
    if not matches:
        print(f"No simulator named: {want}", file=sys.stderr)
        names = ", ".join(sorted({d["name"] for d in candidates})[:12])
        print(f"Available iPhones include: {names}", file=sys.stderr)
        raise SystemExit(1)
    pick = matches[0]
    udid = pick["udid"]
    name = pick["name"]
    if pick.get("state") == "Booted":
        print(f"Using requested simulator: {name} ({udid})", flush=True)
        raise SystemExit(0)
    print(f"Boot simulator: {name} ({udid})", flush=True)
    subprocess.run(["xcrun", "simctl", "boot", udid], check=False)
    # Bring Simulator.app to the chosen device.
    subprocess.run(["open", "-a", "Simulator", "--args", "-CurrentDeviceUDID", udid], check=False)
    raise SystemExit(0)

booted = [d for d in candidates if d.get("state") == "Booted"]
if booted:
    booted.sort(key=lambda d: iphone_num(d["name"]), reverse=True)
    d = booted[0]
    print(f'Using booted simulator: {d["name"]} ({d["udid"]})', flush=True)
    raise SystemExit(0)

candidates.sort(key=lambda d: iphone_num(d["name"]), reverse=True)
pick = candidates[0]
udid = pick["udid"]
name = pick["name"]
print(f"Boot simulator: {name} ({udid})", flush=True)
subprocess.run(["xcrun", "simctl", "boot", udid], check=False)
PY
}

require_xcode_for_ios() {
  local xp
  xp="$(xcode-select -p 2>/dev/null || true)"
  [[ -n "$xp" ]] || return 1
  if [[ "$xp" == *CommandLineTools* ]] && [[ ! -d /Applications/Xcode.app ]]; then
    return 1
  fi
  return 0
}

FLUTTER_DEVICE=""
LAST_STEP="simulator"
if require_xcode_for_ios; then
  open_ios_simulator || true
  flick_log "Preferred simulator: ${SIM_NAME:-"(newest / already booted)"}"
  simctl_boot_if_needed "$SIM_NAME" | while read -r line; do flick_log "$line"; done || true
  sleep 3
  FLUTTER_DEVICE="$(pick_flutter_ios_device "$SIM_NAME" || true)"
fi

if [[ -z "$FLUTTER_DEVICE" ]]; then
  if [[ "${FLICK_FALLBACK_MACOS:-}" == "1" ]]; then
    flick_log "FLICK_FALLBACK_MACOS=1 → macos"
    FLUTTER_DEVICE="macos"
  else
    flick_log "ERROR: no iOS simulator for Flutter"
    fail 1 "no ios simulator"
  fi
fi

LAST_STEP="flutter run"
flick_log "flutter run -d $FLUTTER_DEVICE ($(git -C "$ROOT" log -1 --oneline))"
echo ""
echo "Tip: full log → $FLICK_REPORT_LOG"
echo "     paste block on failure, or run: bash scripts/agent-report.sh"
echo ""

RUN_EXIT=0
if [[ "${FLICK_FULL_LOG:-}" == "1" ]]; then
  flutter run -d "$FLUTTER_DEVICE" 2>&1 | tee -a "$FLICK_REPORT_LOG" || RUN_EXIT=$?
else
  flutter run -d "$FLUTTER_DEVICE" 2>&1 | tee -a "$FLICK_REPORT_LOG" | flick_run_filtered || RUN_EXIT=$?
fi

if [[ "$RUN_EXIT" != "0" ]]; then
  fail "$RUN_EXIT" "flutter run"
fi

flick_log "done"
