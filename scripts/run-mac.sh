#!/usr/bin/env bash
set -euo pipefail

SCHEME="BreakoutGameMac"
PROJECT="BreakoutGame.xcodeproj"

echo "==> Building $SCHEME..."
xcodebuild -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=macOS" \
  -configuration Debug \
  build | xcpretty 2>/dev/null || true

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "BreakoutGameMac.app" \
  -path "*/Debug/*" | head -1)

if [[ -z "$APP_PATH" ]]; then
  echo "Error: could not find BreakoutGameMac.app in DerivedData" >&2
  exit 1
fi

echo "==> Launching $APP_PATH"
"$APP_PATH/Contents/MacOS/BreakoutGameMac"
