#!/usr/bin/env bash
SCHEME="BreakoutGame"
SIMULATOR="iPhone 16,OS=18.4"
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
