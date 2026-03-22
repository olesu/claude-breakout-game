# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

iOS breakout game built with Swift + SpriteKit. Single-player, portrait orientation,
touch controls.

## Project Setup (XcodeGen)

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate
the Xcode project from `project.yml`. The `.xcodeproj` is **not committed** —
it is generated locally from the spec.

**First time / after cloning:**

```bash
xcodegen generate
open BreakoutGame.xcodeproj
```

**When to re-run `xcodegen generate`:**

- After pulling changes to `project.yml`
- After changing build settings, targets, or dependencies
- Not needed for ordinary code changes — Xcode handles those automatically

**Key files:**

- `project.yml` — source of truth for project configuration (committed)
- `BreakoutGame.xcodeproj/` — generated, gitignored

## Build & Test

`scripts/build.sh` lints, generates the Xcode project, builds, and runs all tests.
The swift-code-reviewer agent runs this automatically after Swift changes.

## Linting

SwiftLint runs as the first step of `scripts/build.sh` with `--strict` (warnings
are errors). A PostToolUse hook also runs SwiftLint on each changed file immediately.
Configuration is in `.swiftlint.yml`:

- Line length limit: 100 characters
- Short identifier names allowed (e.g. `x`, `y` for coordinates)
- No trailing commas in collection literals

## Testing Conventions

Use Swift Testing (`import Testing`, `@Test`, `#expect`) — not XCTest.
The xctest-violation-checker agent enforces this on test file changes.

## GitHub Issues

When asked about open tasks, issues, or remaining work, check GitHub first:

```bash
env -u GITHUB_TOKEN gh issue list --state open
```
