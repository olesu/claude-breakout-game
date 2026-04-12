#!/usr/bin/env bash
# Blocks git commits directly to main.
# Remind Claude (and humans) to use a worktree + feature branch instead.

command=$(jq -r '.tool_input.command // empty')

if echo "$command" | grep -q 'git commit'; then
  branch=$(git -C "$(dirname "$0")/../.." rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "$branch" = "main" ]; then
    echo "BLOCKED: You are on the main branch."
    echo "Create a worktree and feature branch first:"
    echo "  git worktree add ../breakout-game-<feature> -b <branch-name>"
    echo "Then re-run this task from inside that worktree."
    exit 2
  fi
fi
