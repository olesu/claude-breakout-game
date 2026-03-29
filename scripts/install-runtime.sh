#!/usr/bin/env bash
# Installs the latest iOS simulator runtime, removes all older iOS runtimes,
# and updates the SIMULATOR variable in scripts/common.sh to match.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON="$SCRIPT_DIR/common.sh"

echo "==> Downloading latest iOS simulator runtime (this may take a while)..."
xcodebuild -downloadPlatform iOS

# Collect identifiers and versions of all ready iOS runtimes.
# xcrun simctl runtime list output looks like:
#   iOS 18.6 (18.6 - 22G81) (com.apple.CoreSimulator.SimRuntime.iOS-18-6) - Ready
mapfile -t RUNTIME_LINES < <(
  xcrun simctl runtime list | grep -E "^iOS [0-9]" | grep -i "Ready"
)

if [[ ${#RUNTIME_LINES[@]} -eq 0 ]]; then
  echo "No ready iOS runtimes found after download — check Xcode > Settings > Components."
  exit 1
fi

# Sort by version and split into latest vs older.
LATEST_LINE=$(printf '%s\n' "${RUNTIME_LINES[@]}" \
  | sort -t' ' -k2 -V | tail -1)
LATEST_VERSION=$(echo "$LATEST_LINE" | sed -E 's/^iOS ([0-9]+\.[0-9]+).*/\1/')
LATEST_ID=$(echo "$LATEST_LINE" | sed -E 's/.*\((com\.[^)]+)\).*/\1/')

echo ""
echo "==> Latest runtime: iOS $LATEST_VERSION ($LATEST_ID)"

# Delete every ready iOS runtime that isn't the latest.
DELETED=0
for LINE in "${RUNTIME_LINES[@]}"; do
  ID=$(echo "$LINE" | sed -E 's/.*\((com\.[^)]+)\).*/\1/')
  if [[ "$ID" != "$LATEST_ID" ]]; then
    VERSION=$(echo "$LINE" | sed -E 's/^iOS ([0-9]+\.[0-9]+).*/\1/')
    echo "==> Removing old runtime: iOS $VERSION ($ID)"
    xcrun simctl runtime delete "$ID"
    DELETED=$((DELETED + 1))
  fi
done

[[ $DELETED -eq 0 ]] && echo "==> No old runtimes to remove."

# Update common.sh.
DEVICE="iPhone 16,OS=$LATEST_VERSION"
echo ""
echo "==> Updating SIMULATOR in scripts/common.sh to: $DEVICE"
sed -i '' "s|^SIMULATOR=.*|SIMULATOR=\"$DEVICE\"|" "$COMMON"

echo "==> Done."
