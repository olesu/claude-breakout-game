# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

iOS breakout game built with Swift + SpriteKit. Single-player, portrait orientation,
touch controls. See `user-story-map.md` for scope and story slices.

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

After implementing code changes, always run `scripts/build.sh`. It generates the
Xcode project, builds, and runs all tests.

## Testing Conventions

Use Swift Testing (`import Testing`, `@Test`, `#expect`) — not XCTest.
