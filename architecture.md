# Architecture

Architectural decisions and boundaries for the Breakout Game.

---

## Ground Rules

- **Modularisation**: continuously look for opportunities to break things apart
- **Cohesion**: keep things that change together, together
- **Abstraction**: look for better abstractions as the design emerges
- **Coupling**: keep it balanced — loose where it matters, explicit where it helps
- **Composition over inheritance**: favour composing behaviour from small, focused
  types rather than building hierarchies; use extensions and protocols instead of
  base classes

These principles will naturally push game rules, state and data into plain Swift
that has no dependency on SpriteKit or any other framework. That code will be
written **test-first (TDD)**.

SpriteKit-specific code (scenes, nodes, rendering) is treated as a thin
presentation layer. It is deliberately kept ignorant of game logic and does not
need to be tested.

The pattern that guides this separation is **Functional Core / Imperative
Shell**:

- **Functional core** — pure Swift types and functions that model game state
  and decisions. No SpriteKit imports. State transitions return new values
  rather than mutating in place. Fully unit-tested.
- **Imperative shell** — SpriteKit scenes and nodes that own the mutable
  world. Calls into the core to decide *what* should happen, then applies
  those decisions as mutations (moving nodes, running actions, transitioning
  scenes).

The discipline is: calculate first, mutate after. A handler should read all
the inputs it needs, compute an outcome, and only then apply changes to the
scene. Calculations and mutations must not be interleaved.

---

## Platform & Technology

- **Platform**: iOS 16+, iPhone only, portrait orientation
- **Language**: Swift 5
- **Framework**: SpriteKit

---

## Scene Structure

The app is organised as a set of `SKScene` subclasses with explicit transitions
between them:

```text
SplashScene → GameScene → GameSummaryScene → SplashScene
```

Each scene owns its own logic. No shared mutable state between scenes.

---

## Game Screen State Machine

`GameScene` manages a state machine governing gameplay flow:

```text
WaitingToLaunch → Playing → BallLost → (lives > 0) → WaitingToLaunch
                                      → (lives = 0) → GameOver
```

---

## Level Data

Level layouts are defined in data, not code. A level config describes the brick
grid (positions, types, colours). `GameScene` reads the config and renders the
grid from it.
