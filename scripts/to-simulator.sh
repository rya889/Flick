#!/usr/bin/env bash
# One command: match origin/main and run Flick on the iOS Simulator.
#
#   cd ~/dev/Flick && bash scripts/to-simulator.sh
#
# Sync discards uncommitted/unpushed local edits (same idea as to-phone.sh).
# Gitignored files (.flick/, Signing.local.xcconfig) are kept.
#
# Optional:
#   FLICK_SIMULATOR="iPhone 16" bash scripts/to-simulator.sh
#   FLICK_KEEP_LOCAL=1 bash scripts/to-simulator.sh   # pull --rebase instead of reset --hard
#   FLICK_TEST=1 bash scripts/to-simulator.sh         # flutter test before run
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BRANCH="${FLICK_BRANCH:-main}"
DEVICE="${FLICK_SIMULATOR:-ios}"

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

echo "==> Simulator"
open -a Simulator || true
sleep 2

echo ""
echo "Running $(git -C "$ROOT" log -1 --oneline) on $DEVICE"
echo ""

flutter run -d "$DEVICE"
