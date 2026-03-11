#!/usr/bin/env bash
set -euo pipefail

SCHEME="BreakoutGame"
SIMULATOR="iPhone 16"
PROJECT="BreakoutGame.xcodeproj"

PRETTY=""
if command -v xcpretty &>/dev/null; then
  PRETTY="xcpretty"
fi

run_xcodebuild() {
  if [[ -n "$PRETTY" ]]; then
    xcodebuild "$@" | "$PRETTY"
  else
    xcodebuild "$@"
  fi
}

echo "==> Generating Xcode project..."
xcodegen generate

echo "==> Building $SCHEME..."
run_xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -configuration Debug \
  build

echo "==> Done."
