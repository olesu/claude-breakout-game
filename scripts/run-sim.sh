#!/usr/bin/env bash
set -euo pipefail

SCHEME="BreakoutGame"
BUNDLE_ID="com.example.BreakoutGame"
SIMULATOR="iPhone 16"
PROJECT="BreakoutGame.xcodeproj"

echo "==> Building $SCHEME..."
xcodebuild -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -configuration Debug \
  build | xcpretty 2>/dev/null || true

# Find the built .app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "BreakoutGame.app" \
  -path "*/Debug-iphonesimulator/*" | head -1)

if [[ -z "$APP_PATH" ]]; then
  echo "Error: could not find BreakoutGame.app in DerivedData" >&2
  exit 1
fi

echo "==> Booting simulator: $SIMULATOR"
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
open -a Simulator

echo "==> Installing app..."
xcrun simctl install booted "$APP_PATH"

echo "==> Launching $BUNDLE_ID"
xcrun simctl launch --console-pty booted "$BUNDLE_ID"
