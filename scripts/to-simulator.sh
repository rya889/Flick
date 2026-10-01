#!/usr/bin/env bash
# One command: pull latest main and run Flick on the iOS Simulator.
#
#   cd ~/dev/Flick && bash scripts/to-simulator.sh
#
# Optional:
#   FLICK_SIMULATOR="iPhone 16" bash scripts/to-simulator.sh
#   FLICK_HARD=1 bash scripts/to-simulator.sh   # discard local changes (like to-phone.sh)
#   FLICK_TEST=1 bash scripts/to-simulator.sh   # flutter test before run
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BRANCH="${FLICK_BRANCH:-main}"
DEVICE="${FLICK_SIMULATOR:-ios}"

echo "==> Flick → iOS Simulator"
echo "    branch: $BRANCH"

echo "==> Sync origin/$BRANCH"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
if [[ "${FLICK_HARD:-}" == "1" ]]; then
  git reset --hard "origin/$BRANCH"
  git clean -fd
else
  git pull --rebase origin "$BRANCH"
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
# Let Simulator finish booting.
sleep 2

echo ""
echo "Running $(git -C "$ROOT" log -1 --oneline) on $DEVICE"
echo ""

flutter run -d "$DEVICE"
