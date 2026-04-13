#!/usr/bin/env bash
set -euo pipefail

SCHEME="BreakoutGameMac"
PROJECT="BreakoutGame.xcodeproj"
DERIVED_DATA="$(pwd)/.derived-data-mac"

echo "==> Building $SCHEME..."
xcodebuild -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=macOS" \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  build | xcpretty 2>/dev/null || true

APP_PATH="$DERIVED_DATA/Build/Products/Debug/BreakoutGameMac.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: could not find $APP_PATH" >&2
  exit 1
fi

echo "==> Launching $APP_PATH"
"$APP_PATH/Contents/MacOS/BreakoutGameMac"
