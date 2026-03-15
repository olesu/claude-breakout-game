# Plan: Functional Core / Imperative Shell

## Goal

Reach the architecture described in `architecture.md`: all game logic lives in
plain Swift with no SpriteKit dependency and is written test-first. SpriteKit
code becomes a thin shell that reads pure state and applies mutations.

## Architecture at Completion

```text
GameState (struct, value type)
  ├── phase: GamePhase          ← renamed from GameState enum
  ├── lives: Int
  └── score: Int
  └── mutating transition methods (pure logic, fully tested)

GameScene (SpriteKit shell)
  ├── var gameState: GameState  ← owns the value directly
  ├── update() → compute FrameAction → apply
  └── touchesBegan() → compute TouchIntent → apply

Free pure functions (no SpriteKit imports)
  ├── frameAction(phase:ballY:floorY:levelComplete:) → FrameAction
  └── touchIntent(hitsPauseButton:phase:) → TouchIntent
```

`GameStateMachine` is deleted. `GameScene` is the only mutator of `gameState`.
All decisions about *what should happen* are made in pure, testable functions
before any SpriteKit mutation runs.

---

## Step 1 — Rename `GameState` enum to `GamePhase`

**Why first:** The name `GameState` needs to be freed for the struct in Step 2.
The word "phase" is also more accurate — it describes position in the lifecycle,
not the complete game state.

**No TDD needed.** This is a mechanical rename with no logic changes.

### Changes

- `Sources/Logic/GameStateMachine.swift` — rename enum declaration and all
  internal references (`state: GameState` → `state: GamePhase`)
- `Sources/Scenes/GameScene.swift` — all `stateMachine.state == .playing` etc.
  references remain valid; only the type name changes if referenced explicitly
- `Tests/GameStateMachineTests.swift` — update any explicit `GameState`
  references to `GamePhase`

### Verify — Step 1

`scripts/build.sh` passes with no changes to test count or behaviour.

---

## Step 2 — Introduce `GameState` struct (TDD)

**Why:** This is the functional core. All transition logic moves from the class
into a value type. The struct is the thing we test, and it has no SpriteKit
dependency.

### 2a — Write `Tests/GameStateTests.swift` first

All tests use `import Testing`. No `GameStateMachine` — only `GameState`.

#### Initial state

- `init_defaults_phaseIsWaitingToLaunch` — `GameState()` starts in
  `.waitingToLaunch`
- `init_livesAndScore_arePreserved` — values passed to init are stored as-is

**`addScore`**

- `addScore_whilePlaying_incrementsScore` — score increases by the given amount
- `addScore_whileWaitingToLaunch_isIgnored` — score unchanged
- `addScore_whilePaused_isIgnored` — score unchanged
- `addScore_whileGameOver_isIgnored` — score unchanged
- `addScore_negative_isIgnored` — guard against invalid input; score unchanged

**`launch`**

- `launch_fromWaitingToLaunch_movesToPlaying`
- `launch_whilePlaying_isIgnored` — idempotent; no crash
- `launch_whilePaused_isIgnored`
- `launch_whileGameOver_isIgnored`

**`ballLost` — lives remaining**

- `ballLost_withLivesRemaining_decrementsLives`
- `ballLost_withLivesRemaining_phaseBecomesWaitingToLaunch`

**`ballLost` — last life**

- `ballLost_lastLife_phaseBecomesGameOver`
- `ballLost_lastLife_livesAreZero` — lives never go below zero
- `ballLost_whileNotPlaying_isIgnored`

**`pause` / `resume`**

- `pause_whilePlaying_movesToPaused`
- `pause_whileNotPlaying_isIgnored`
- `resume_whilePaused_movesToPlaying`
- `resume_whileNotPaused_isIgnored`

**`resetForNextLevel`**

- `resetForNextLevel_whilePlaying_movesToWaitingToLaunch`
- `resetForNextLevel_whileNotPlaying_isIgnored`

#### Value semantics

- `copy_mutatingOriginal_doesNotAffectCopy` — mutate a var, verify a `let` copy
  is unchanged. Proves value semantics; would fail if this were a class.

### 2b — Implement `Sources/Logic/GameState.swift`

```swift
struct GameState {
    var phase: GamePhase
    var lives: Int
    var score: Int

    init(lives: Int = 3, score: Int = 0) {
        self.phase = .waitingToLaunch
        self.lives = lives
        self.score = score
    }

    mutating func addScore(_ points: Int) { ... }
    mutating func launch() { ... }
    mutating func ballLost() { ... }
    mutating func pause() { ... }
    mutating func resume() { ... }
    mutating func resetForNextLevel() { ... }
}
```

All logic is identical to `GameStateMachine` — it is moved, not rewritten.

### Verify — Step 2

All 20 new `GameStateTests` pass. Existing tests unaffected.

---

## Step 3 — Make `GameStateMachine` delegate to `GameState`

**Why:** Decouples the introduction of `GameState` from the `GameScene` change.
After this step the struct is proven and the wrapper is trivial. `GameScene`
still compiles unchanged.

### Changes to `Sources/Logic/GameStateMachine.swift`

```swift
class GameStateMachine {
    private(set) var gameState: GameState

    // Backwards-compatible surface so GameScene requires no changes yet
    var state: GamePhase { gameState.phase }
    var lives: Int { gameState.lives }
    var score: Int { gameState.score }

    init(lives: Int = 3, score: Int = 0) {
        gameState = GameState(lives: lives, score: score)
    }

    func addScore(_ points: Int) { gameState.addScore(points) }
    func launch()                { gameState.launch() }
    func ballLost()              { gameState.ballLost() }
    func pause()                 { gameState.pause() }
    func resume()                { gameState.resume() }
    func resetForNextLevel()     { gameState.resetForNextLevel() }
}
```

### Delete `Tests/GameStateMachineTests.swift`

`GameStateMachine` is now a delegation scaffold; its behaviour is already
covered by `GameStateTests`. Keeping both would duplicate the test suite and
give false confidence to a class that is about to be deleted.

### Verify — Step 3

`scripts/build.sh` passes. Test count decreases by 21 (deleted) and increases
by 20 (new `GameStateTests`) — net −1.

---

## Step 4 — Wire `GameScene` and `SplashScene` to `GameState` directly

**Why:** Removes the last reason for `GameStateMachine` to exist.

### Changes to `Sources/Scenes/GameScene.swift`

- `private let stateMachine: GameStateMachine` → `private var gameState: GameState`
- `init` parameter: `stateMachine: GameStateMachine` → `gameState: GameState`
- All call sites update mechanically:

| Before | After |
| --- | --- |
| `stateMachine.state` | `gameState.phase` |
| `stateMachine.lives` | `gameState.lives` |
| `stateMachine.score` | `gameState.score` |
| `stateMachine.addScore(x)` | `gameState.addScore(x)` |
| `stateMachine.launch()` | `gameState.launch()` |
| `stateMachine.ballLost()` | `gameState.ballLost()` |
| `stateMachine.pause()` | `gameState.pause()` |
| `stateMachine.resume()` | `gameState.resume()` |
| `stateMachine.resetForNextLevel()` | `gameState.resetForNextLevel()` |

### Changes to `Sources/Scenes/SplashScene.swift`

```swift
// Before
GameStateMachine(lives: game.lives, score: game.score)
GameStateMachine()

// After
GameState(lives: game.lives, score: game.score)
GameState()
```

Update the `GameScene` init call sites to pass `gameState:` instead of
`stateMachine:`.

### Delete `Sources/Logic/GameStateMachine.swift`

### Verify — Step 4

`scripts/build.sh` passes. No test count changes.

---

## Step 5 — Extract pure frame-logic functions (TDD)

**Why:** The remaining mixing of calculations and mutations lives in `GameScene`'s
event handlers. The decisions — *what should happen this frame?*, *what does
this touch mean?* — are pure calculations that can be extracted, named, and
tested independently of SpriteKit.

Two new pure functions are extracted. Each follows the same TDD pattern:
write tests, implement, wire into `GameScene`.

---

### 5a — `frameAction` (from `update`)

**Write `Tests/FrameActionTests.swift` first**

```swift
// frameAction(phase:ballY:floorY:levelComplete:) -> FrameAction
```

- `frameAction_whenPaused_returnsNothing` — paused state suppresses all actions
- `frameAction_whenLevelComplete_returnsAdvanceLevel` — levelComplete flag wins
- `frameAction_whenWaitingToLaunch_returnsResetBall`
- `frameAction_whenPlaying_ballAboveFloor_returnsNothing`
- `frameAction_whenPlaying_ballAtFloor_returnsHandleBallLoss` — boundary:
  `ballY == floorY`
- `frameAction_whenPlaying_ballBelowFloor_returnsHandleBallLoss`
- `frameAction_levelCompleteAndPaused_returnsNothing` — paused always wins

**Implement `Sources/Logic/FrameAction.swift`**

```swift
enum FrameAction {
    case nothing
    case resetBall
    case handleBallLoss
    case advanceLevel
}

func frameAction(
    phase: GamePhase,
    ballY: CGFloat,
    floorY: CGFloat,
    levelComplete: Bool
) -> FrameAction {
    guard phase != .paused else { return .nothing }
    if levelComplete { return .advanceLevel }
    if phase == .waitingToLaunch { return .resetBall }
    if phase == .playing && ballY < floorY { return .handleBallLoss }
    return .nothing
}
```

**Wire into `GameScene.update`**

```swift
override func update(_ currentTime: TimeInterval) {
    let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
    lastUpdateTime = currentTime

    // Pure calculation
    let action = frameAction(
        phase: gameState.phase,
        ballY: ball.position.y,
        floorY: frame.minY,
        levelComplete: levelComplete
    )

    // Apply
    switch action {
    case .nothing:        break
    case .resetBall:      resetBall()
    case .handleBallLoss: handleBallLoss()
    case .advanceLevel:   advanceLevel()
    }

    powerUp.update(delta: delta, ball: ball)
}
```

Extract `resetBall()` as a private helper that sets velocity to zero and
repositions the ball.

---

### 5b — `touchIntent` (from `touchesBegan`)

**Write `Tests/TouchIntentTests.swift` first**

```swift
// touchIntent(hitsPauseButton:phase:) -> TouchIntent
```

- `touchIntent_pauseButton_whilePlaying_returnsPause`
- `touchIntent_pauseButton_whilePaused_returnsResume`
- `touchIntent_pauseButton_whileWaiting_returnsNone` — pause button inactive
  when not yet launched
- `touchIntent_pauseButton_whileGameOver_returnsNone`
- `touchIntent_normalTouch_whilePaused_returnsNone` — whole scene suppressed
- `touchIntent_normalTouch_whileWaiting_returnsLaunchAndMove`
- `touchIntent_normalTouch_whilePlaying_returnsMove`
- `touchIntent_normalTouch_whileGameOver_returnsNone`

**Implement `Sources/Logic/TouchIntent.swift`**

```swift
enum TouchIntent {
    case pause
    case resume
    case launchAndMovePaddle
    case movePaddle
    case none
}

func touchIntent(hitsPauseButton: Bool, phase: GamePhase) -> TouchIntent {
    if hitsPauseButton {
        switch phase {
        case .playing: return .pause
        case .paused:  return .resume
        default:       return .none
        }
    }
    switch phase {
    case .paused, .gameOver:   return .none
    case .waitingToLaunch:     return .launchAndMovePaddle
    case .playing:             return .movePaddle
    }
}
```

**Wire into `GameScene.touchesBegan`**

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }

    // Pure calculation
    let onPauseButton = nodes(at: touch.location(in: self))
        .contains { $0.name == "pauseButton" }
    let intent = touchIntent(hitsPauseButton: onPauseButton, phase: gameState.phase)

    // Apply
    switch intent {
    case .none:
        break
    case .pause:
        gameState.pause()
        applyPauseState()
    case .resume:
        gameState.resume()
        applyPauseState()
    case .movePaddle:
        movePaddle(to: touches)
    case .launchAndMovePaddle:
        movePaddle(to: touches)
        spawnLaunchRipple(at: ball.position)
        gameState.launch()
        ball.physicsBody?.velocity = Theme.Layout.ballLaunchVelocity
    }
}
```

### Verify — Step 5

All new tests pass. `scripts/build.sh` passes. Game behaviour unchanged.

---

## Step 6 — Restructure remaining `GameScene` handlers (calculate then apply)

**Why:** `handleBrickContact` and `handleBallLoss` still interleave reads and
writes. This step applies the same discipline — capture all inputs before any
mutation runs — but without extracting new pure functions, since the logic is
too simple to warrant separate tests.

**No new tests.** The changes are structural only; all observable behaviour is
already covered.

### `handleBrickContact`

```swift
private func handleBrickContact(_ brick: BrickNode, at point: CGPoint) {
    // Capture all inputs before any mutation
    let points    = Theme.Layout.brickPoints
    let color     = brick.color
    let spawnPowerUp = !powerUp.isPowerBallActive

    // State mutations
    bricks.removeAll { $0 === brick }
    gameState.addScore(points)
    gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)

    // Visual side-effects
    spawnScorePopup(at: point, points: points)
    spawnSparks(at: point, color: color)
    brick.destroy { [weak self] in
        guard let self else { return }
        if bricks.isEmpty && !levelComplete { levelComplete = true }
    }
    if spawnPowerUp { powerUp.spawnIfEligible(at: brick.position) }
}
```

### `handleBallLoss`

```swift
private func handleBallLoss() {
    // Capture before mutation
    let hadPowerBall = powerUp.isPowerBallActive

    // State mutations
    powerUp.clearAll(ball: ball)
    gameState.ballLost()
    let isGameOver = gameState.phase == .gameOver

    // Visual side-effects
    gameCamera.shake()
    gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)

    // Scene transition (side-effect, happens last)
    if isGameOver {
        saveStore.clear()
        present(GameSummaryScene(size: size, outcome: .gameOver, score: gameState.score))
    }
}
```

### Verify — Step 6

`scripts/build.sh` passes. Behaviour unchanged.

---

## Summary

| Step | Tests written | Tests deleted | Tests modified |
| --- | --- | --- | --- |
| 1 — Rename enum | — | — | `GameStateMachineTests` (type names) |
| 2 — `GameState` struct | `GameStateTests` (+20) | — | — |
| 3 — `GameStateMachine` delegates | — | `GameStateMachineTests` (−21) | — |
| 4 — Wire scenes, delete class | — | — | — |
| 5a — `frameAction` | `FrameActionTests` (+7) | — | — |
| 5b — `touchIntent` | `TouchIntentTests` (+8) | — | — |
| 6 — Restructure handlers | — | — | — |

Net new tests: **+35**, net deleted: **−21**.

Each step leaves the build and test suite in a passing state. Steps 1–4 are
pure structural moves with no logic changes. New logic (the pure functions in
Step 5) is test-driven from the start.
