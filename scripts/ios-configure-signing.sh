#!/usr/bin/env bash
# Persist Apple Team ID outside project.pbxproj so hard-sync / git reset does not wipe signing.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/app/ios/Flutter/Signing.local.xcconfig"
TEAM="${FLICK_IOS_TEAM:-${1:-}}"

if [[ -z "$TEAM" ]]; then
  echo "Apple Development Team ID (10 characters, e.g. from Xcode Signing tab)."
  read -rp "DEVELOPMENT_TEAM: " TEAM
fi

TEAM="$(echo "$TEAM" | tr -d '[:space:]')"
if [[ ! "$TEAM" =~ ^[A-Z0-9]{10}$ ]]; then
  echo "Expected a 10-character Team ID (letters and digits)." >&2
  exit 1
fi

cat >"$OUT" <<EOF
// Local signing — gitignored. Safe across git reset --hard and agent updates.
DEVELOPMENT_TEAM=$TEAM
CODE_SIGN_STYLE=Automatic
EOF

echo "Wrote $OUT"
echo ""
echo "Next (required so Pods use the same Team):"
echo "  bash scripts/ios-reinstall-pods.sh"
echo ""
echo "Then: cd app && flutter run -d <device> --release"
echo "(No need to re-pick Team in Xcode unless you change Apple accounts.)"
