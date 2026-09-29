#!/usr/bin/env bash
# Wipe and reinstall iOS pods so RevenueCat cannot stay stuck on 5.67.x.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"
cd "$APP"

echo "==> purchases_flutter in pubspec.lock:"
grep -A6 'purchases_flutter:' pubspec.lock | head -8

flutter pub get

echo "==> wiping ios/Pods + Podfile.lock"
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks
rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/Runner-* 2>/dev/null || true

cd ios
# RevenueCat is on the CocoaPods CDN (trunk) — there is no "RevenueCat" spec repo.
pod install --repo-update

echo "==> RevenueCat resolved to:"
grep -E 'RevenueCat \(' Podfile.lock | head -5

echo "Done. From app/: flutter run -d ios"
