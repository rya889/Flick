#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_DIR="${FLUTTER_DIR:-$ROOT/.flutter-sdk}"

if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
  echo "Flutter SDK missing at $FLUTTER_DIR — run vercel-install.sh first"
  exit 1
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --version
cd "$ROOT/app"
flutter pub get
flutter build web --release --base-href /
# Keep SPA headers next to the build output for local/CLI deploys of build/web alone.
cp "$ROOT/app/web/vercel.json" "$ROOT/app/build/web/vercel.json" 2>/dev/null || true
