#!/usr/bin/env bash
# PreToolUse hook: warn or block when a Swift file is near/over the file_length limit.
# Reads file_path from the Claude tool-input JSON on stdin.
# Exit 0 = proceed (with optional additionalContext warning).
# Non-zero = block the edit.

set -euo pipefail

FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Only care about Swift files that already exist on disk.
[[ "$FILE" == *.swift ]] || exit 0
[[ -f "$FILE" ]] || exit 0

# Read limit from .swiftlint.yml (warning threshold); fall back to 400.
SWIFTLINT_YML="$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)/.swiftlint.yml"
LIMIT=400
if [[ -f "$SWIFTLINT_YML" ]]; then
    PARSED=$(grep -A2 '^file_length:' "$SWIFTLINT_YML" | grep 'warning:' | awk '{print $2}' | tr -d '[:space:]')
    [[ -n "$PARSED" ]] && LIMIT=$PARSED
fi

LINES=$(wc -l < "$FILE")
WARN_THRESHOLD=$(( LIMIT - 30 ))
FILENAME=$(basename "$FILE")

if (( LINES >= LIMIT )); then
    # Block: already at or over the limit. Adding more lines will fail the linter.
    jq -n \
        --arg msg "BLOCKED: $FILENAME is at $LINES lines (limit: $LIMIT). Refactor to reduce size before adding more code. Do not disable SwiftLint rules." \
        '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": $msg
            }
        }'
elif (( LINES >= WARN_THRESHOLD )); then
    REMAINING=$(( LIMIT - LINES ))
    # Warn: approaching the limit. Suggest a tidy pass first.
    jq -n \
        --arg ctx "WARNING: $FILENAME is at $LINES/$LIMIT lines ($REMAINING lines of headroom). If this edit adds lines, consider a tidy/extract pass first to stay under the limit." \
        '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": $ctx
            }
        }'
fi
