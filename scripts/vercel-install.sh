#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_DIR="${FLUTTER_DIR:-$ROOT/.flutter-sdk}"

if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
  echo "Cloning Flutter stable into $FLUTTER_DIR"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter config --no-analytics
flutter precache --web
cd "$ROOT/app"
flutter pub get
