#!/usr/bin/env bash
# Pull latest iOS branch on Mac, discard common local blockers, reinstall to device.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH="${FLICK_IOS_BRANCH:-cursor/fix-ios-deploy-target-983e}"
DEVICE="${FLICK_IOS_DEVICE:-}"

cd "$REPO_ROOT"

echo "==> Fetch $BRANCH"
git fetch origin "$BRANCH"

# --- Overcome local changes (pick one block if you need to keep edits) ---

echo "==> Discard local edits to files that often block pull/merge"
git restore --source=HEAD --staged --worktree \
  app/pubspec.lock \
  app/pubspec.yaml \
  app/ios/Flutter/AppFrameworkInfo.plist \
  app/ios/Runner.xcodeproj/project.pbxproj \
  app/ios/Runner/Info.plist \
  2>/dev/null || true

# Untracked Podfile from an old partial checkout can block checkout:
if git status --porcelain app/ios/Podfile 2>/dev/null | grep -q '^??'; then
  echo "==> Remove untracked app/ios/Podfile (will come from branch)"
  rm -f app/ios/Podfile
fi

echo "==> Checkout and pull"
git checkout "$BRANCH"
git pull origin "$BRANCH"

echo "==> Sanity check (new UX should be present)"
grep -q 'tabIndex = 1' app/lib/state/flick_controller.dart || {
  echo "ERROR: Missing Library-first launch — wrong commit?"
  exit 1
}
grep -q "label: Text('Brief')" app/lib/screens/now_player.dart || {
  echo "ERROR: Missing Brief TLDR label — wrong commit?"
  exit 1
}
echo "OK: on $(git log -1 --oneline)"

echo "==> Clean build + pods"
bash "$REPO_ROOT/scripts/ios-reinstall-pods.sh"

cd "$REPO_ROOT/app"
flutter clean
rm -rf build/ios

RUN=(flutter run -d)
if [[ -n "$DEVICE" ]]; then
  RUN+=( "$DEVICE" )
else
  RUN+=( ios )
fi
RUN+=( --release )

echo "==> Install to device: ${RUN[*]}"
echo "    (Set FLICK_IOS_DEVICE=rPhone17 to target a named device)"
"${RUN[@]}"
