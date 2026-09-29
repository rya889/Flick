#!/usr/bin/env bash
# One command: pull the latest Flick branch and install a release build on your iPhone.
#
#   cd ~/dev/Flick && bash scripts/to-phone.sh
#
# First run asks for your Apple Team ID once and saves it in .flick/phone.env
# (gitignored). Later runs do not open Xcode and do not wipe the build cache.
#
# Optional:
#   FLICK_CLEAN=1 bash scripts/to-phone.sh    # full pod + flutter clean (slow; use if install is stuck)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="$ROOT/.flick/phone.env"
SIGNING="$ROOT/app/ios/Flutter/Signing.local.xcconfig"
DEFAULT_DEVICE="00008150-000C10D62687801C"
DEFAULT_BRANCH="cursor/fix-ios-deploy-target-983e"

TEAM_FROM_ENV="${FLICK_IOS_TEAM:-}"
DEVICE_FROM_ENV="${FLICK_IOS_DEVICE:-}"
BRANCH_FROM_ENV="${FLICK_BRANCH:-}"
TEAM=""
DEVICE=""
BRANCH=""

if [[ -f "$CONFIG" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "$CONFIG"
  set +a
  TEAM="${FLICK_IOS_TEAM:-}"
  DEVICE="${FLICK_IOS_DEVICE:-}"
  BRANCH="${FLICK_BRANCH:-}"
fi

# A value passed on the command line replaces the saved one.
# Example: FLICK_IOS_TEAM=AB12CD34EF bash scripts/to-phone.sh
if [[ -n "$TEAM_FROM_ENV" ]]; then
  TEAM="$TEAM_FROM_ENV"
fi
if [[ -n "$DEVICE_FROM_ENV" ]]; then
  DEVICE="$DEVICE_FROM_ENV"
fi
if [[ -n "$BRANCH_FROM_ENV" ]]; then
  BRANCH="$BRANCH_FROM_ENV"
fi

if [[ -z "$TEAM" && -f "$SIGNING" ]]; then
  TEAM="$(grep -E '^DEVELOPMENT_TEAM=' "$SIGNING" | head -1 | cut -d= -f2 | tr -d '[:space:]' || true)"
fi

DEVICE="${DEVICE:-$DEFAULT_DEVICE}"
BRANCH="${BRANCH:-$DEFAULT_BRANCH}"

echo "==> Flick → iPhone"
echo "    branch: $BRANCH"
echo "    device: $DEVICE"

echo "==> Sync to origin/$BRANCH (local code edits are discarded; phone.env is kept)"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git reset --hard "origin/$BRANCH"
# Ignored files (.flick/, Signing.local.xcconfig) are kept. Do not pass -x.
git clean -fd

if [[ -x "$ROOT/scripts/strip-swiftuicore-linker.sh" ]]; then
  bash "$ROOT/scripts/strip-swiftuicore-linker.sh" || true
fi

# Do not guess the team from Keychain certificates. That id can belong to a
# different Apple ID than the one signed into Xcode ("Unknown Name" in the Team menu).
if [[ -z "$TEAM" && -t 0 ]]; then
  echo ""
  echo "One-time: copy the Team ID for the account Xcode can actually use."
  echo "Xcode → Settings → Accounts → select your Apple ID → Phuc Le (Personal Team)."
  echo "Copy the 10-character Team ID shown for that row (not the words Personal Team)."
  read -rp "DEVELOPMENT_TEAM: " TEAM
  TEAM="$(echo "$TEAM" | tr -d '[:space:]')"
fi

if [[ ! "$TEAM" =~ ^[A-Za-z0-9]{10}$ ]]; then
  echo "" >&2
  echo "Need your Apple Team ID once. Then this same command is all you run:" >&2
  echo "  mkdir -p .flick" >&2
  echo "  printf '%s\n' 'FLICK_IOS_TEAM=YOUR10CHARID' 'FLICK_IOS_DEVICE=$DEFAULT_DEVICE' 'FLICK_BRANCH=$DEFAULT_BRANCH' > .flick/phone.env" >&2
  echo "  bash scripts/to-phone.sh" >&2
  exit 1
fi

mkdir -p "$ROOT/.flick"
cat >"$CONFIG" <<EOF
# Local only — not committed. Survives git reset.
FLICK_IOS_TEAM=$TEAM
FLICK_IOS_DEVICE=$DEVICE
FLICK_BRANCH=$BRANCH
EOF

mkdir -p "$(dirname "$SIGNING")"
cat >"$SIGNING" <<EOF
// Written by scripts/to-phone.sh — gitignored.
DEVELOPMENT_TEAM=$TEAM
CODE_SIGN_STYLE=Automatic
EOF

cd "$ROOT/app"
echo "==> flutter pub get"
flutter pub get

NEED_PODS=0
if [[ "${FLICK_CLEAN:-}" == "1" ]]; then
  echo "==> Clean rebuild (FLICK_CLEAN=1)"
  rm -rf ios/Pods ios/Podfile.lock ios/.symlinks build/ios
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/Runner-* 2>/dev/null || true
  flutter clean
  NEED_PODS=1
elif [[ ! -d ios/Pods || ! -f ios/Podfile.lock ]]; then
  NEED_PODS=1
fi

if [[ "$NEED_PODS" == "1" ]]; then
  echo "==> pod install"
  (cd ios && pod install --repo-update)
else
  echo "==> pod install (incremental)"
  (cd ios && pod install)
fi

echo ""
echo "Installing $(git -C "$ROOT" log -1 --oneline)"
echo "Unlock the iPhone and leave it awake until Flick opens."
echo ""

set +e
flutter run -d "$DEVICE" --release
code=$?
set -e

if [[ "$code" != "0" ]]; then
  echo ""
  echo "Install/launch failed (build may still have succeeded)."
  echo "Unlock the phone, confirm Developer Mode is on, then run this same command again."
  echo "If it fails twice:"
  echo "  open ios/Runner.xcworkspace"
  echo "  Product → Run on this iPhone once, then: bash scripts/to-phone.sh"
  echo "Stuck install: FLICK_CLEAN=1 bash scripts/to-phone.sh"
  exit "$code"
fi
