---
title: Architecture
layout: page
---

<small>Built: {{ site.time | date: "%Y-%m-%d %H:%M UTC" }}</small>

The codebase follows the **Functional Core / Imperative Shell** pattern.
The functional core is pure Swift with no SpriteKit dependency; state transitions
return new values rather than mutating in place, and all core logic is unit-tested.
The imperative shell is SpriteKit scenes and nodes — a thin layer that delegates
decisions to the core and applies the results as mutations.

Diagrams use UML dependency notation: a dashed arrow (`..>`) means the source
type depends on the target. Stereotypes (`«use»`, `«create»`, `«call»`) clarify
the nature of each dependency.

---

## 1 · Scene Navigation

How the four scenes connect, and what data flows between transitions.

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a', 'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff', 'lineColor': '#ff6b9d',
  'mainBkg': '#0d1b2a', 'nodeBorder': '#00d4ff', 'classText': '#e8f4f8',
  'edgeLabelBackground': '#0a1628', 'clusterBkg': '#0a1628',
  'clusterBorder': '#5a189a', 'titleColor': '#00d4ff'
}}}%%
classDiagram
    direction TD

    class MacLaunchSplashScene {
        &lt;&lt;macOS only&gt;&gt;
    }
    class SplashScene
    class GameScene
    class GameSummaryScene
    class GameSaveStore {
        load() SavedGame?
        clear()
    }
    class HighScoreStore {
        submitScore(Int) Bool
        highScore: Int
    }

    MacLaunchSplashScene ..> SplashScene : «transition»
    SplashScene ..> GameScene : «create» new game
    SplashScene ..> GameScene : «create» resume with SavedGame
    GameScene ..> GameScene : «create» next level
    GameScene ..> GameSummaryScene : «create» .victory / .gameOver
    GameSummaryScene ..> SplashScene : «create»
    SplashScene ..> GameSaveStore : «use» load / clear
    SplashScene ..> HighScoreStore : «use» read
    GameSummaryScene ..> HighScoreStore : «use» submitScore
</pre>

---

## 2 · GameScene Wiring

`GameScene` is a thin orchestrator. It creates the coordinators, wires them
together, and delegates decisions to them — it does not contain logic itself.

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a', 'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff', 'lineColor': '#ff6b9d',
  'mainBkg': '#0d1b2a', 'nodeBorder': '#00d4ff', 'classText': '#e8f4f8',
  'edgeLabelBackground': '#0a1628', 'clusterBkg': '#0a1628',
  'clusterBorder': '#5a189a', 'titleColor': '#00d4ff'
}}}%%
classDiagram
    direction TD

    namespace Logic {
        class GameState {
            &lt;&lt;value type&gt;&gt;
        }
        class GameLoopCoordinator
        class ContactCoordinator
        class PowerUpCoordinator
    }
    namespace Platform {
        class SoundCoordinator
        class InputCoordinator
        class GamePersistenceCoordinator
    }
    namespace Nodes {
        class GameCameraNode
        class PaddleNode
        class BallNode
        class BrickNode
    }

    GameScene ..> GameState : «create / transition»
    GameScene ..> GameLoopCoordinator : «create / tick»
    GameScene ..> ContactCoordinator : «create / delegate»
    GameScene ..> PowerUpCoordinator : «create»
    GameScene ..> SoundCoordinator : «create»
    GameScene ..> InputCoordinator : «use»
    GameScene ..> GamePersistenceCoordinator : «use»
    GameScene ..> GameCameraNode : «create / update HUD»
    GameScene ..> PaddleNode : «create / move»
    GameScene ..> BallNode : «create / manage»
    GameScene ..> BrickNode : «create / manage»

    GameLoopCoordinator ..> PowerUpCoordinator : «calls update()»
    ContactCoordinator ..> PowerUpCoordinator : «collect / spawn»
    ContactCoordinator ..> GameLoopCoordinator : «markLevelComplete»
    ContactCoordinator ..> SoundCoordinator : «call»
</pre>

---

## 3 · Game Loop & Contact Pipeline

The two per-frame event handlers. Both return data structures that `GameScene`
applies as mutations — coordinators never touch the scene graph directly.

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a', 'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff', 'lineColor': '#ff6b9d',
  'mainBkg': '#0d1b2a', 'nodeBorder': '#00d4ff', 'classText': '#e8f4f8',
  'edgeLabelBackground': '#0a1628', 'clusterBkg': '#0a1628',
  'clusterBorder': '#5a189a', 'titleColor': '#00d4ff'
}}}%%
classDiagram
    direction TD

    namespace GameLoop {
        class GameLoopCoordinator {
            tick(...) TickResult
        }
        class TickResult {
            action: FrameAction
            powerUpEffects: PowerUpEffect[]
            expiredPowerUpType: PowerUpType?
        }
        class FrameAction {
            &lt;&lt;enumeration&gt;&gt;
            nothing / resetBall
            handleBallLoss / advanceLevel
        }
    }

    namespace Contact {
        class ContactCoordinator {
            handle(contact, ...) ContactOutcome
        }
        class ContactEvent {
            &lt;&lt;enumeration&gt;&gt;
            brick / paddleHit
            wallHit / powerUp / laser
        }
        class ContactOutcome {
            pointsScored: Int
            comboMultiplier: Int
            lifeAwarded: Bool
            extraBallSpawn: (CGPoint, CGVector)?
            powerUpEffects: PowerUpEffect[]
        }
        class ComboTracker
    }

    class PowerUpCoordinator
    class PowerUpEffect {
        &lt;&lt;enumeration&gt;&gt;
        activate / deactivate powerBall
        activate / deactivate slowBall
        activate / deactivate widePaddle
    }
    class BallNode
    class PaddleNode
    class BrickNode

    GameLoopCoordinator ..> TickResult : «returns»
    TickResult ..> FrameAction : contains
    TickResult ..> PowerUpEffect : contains
    GameLoopCoordinator ..> PowerUpCoordinator : «calls update()»
    GameLoopCoordinator ..> BallNode : «resets / guards speed»

    ContactCoordinator ..> ContactEvent : «classifies via»
    ContactCoordinator ..> ContactOutcome : «returns»
    ContactCoordinator ..> ComboTracker : «use»
    ContactCoordinator ..> PowerUpCoordinator : «collect / spawn»
    ContactCoordinator ..> BrickNode : «calls hit()»
    ContactOutcome ..> PowerUpEffect : contains

    PowerUpEffect ..> BallNode : «applied by GameScene»
    PowerUpEffect ..> PaddleNode : «applied by GameScene»
</pre>

---

## 4 · Power-Up System

A self-contained subsystem. `PowerUpCoordinator` manages falling nodes, active
state, and laser cooldown. All state lives in the immutable `PowerUpState` value
type, which the coordinator ticks forward each frame.

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a', 'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff', 'lineColor': '#ff6b9d',
  'mainBkg': '#0d1b2a', 'nodeBorder': '#00d4ff', 'classText': '#e8f4f8',
  'edgeLabelBackground': '#0a1628', 'clusterBkg': '#0a1628',
  'clusterBorder': '#5a189a', 'titleColor': '#00d4ff'
}}}%%
classDiagram
    direction TD

    class PowerUpCoordinator {
        spawnIfEligible(at) PowerUpNode?
        spawnGuaranteed(at) PowerUpNode
        collect(node) CollectOutcome
        update(delta, floorY)
        fireLasers(from, ...) LaserNode[]
        clearAll() PowerUpEffect[]
    }
    class PowerUpState {
        &lt;&lt;value type&gt;&gt;
        active: PowerUpType?
        timeRemaining: TimeInterval
        collect(type) PowerUpState
        tick(delta) PowerUpState
    }
    class PowerUpType {
        &lt;&lt;enumeration&gt;&gt;
        powerBall / widePaddle
        slowBall / extraLife
        multiBall / laser
    }
    class PowerUpEffect {
        &lt;&lt;enumeration&gt;&gt;
    }
    class CollectOutcome {
        result: CollectResult
        effects: PowerUpEffect[]
    }
    class PowerUpNode
    class LaserNode
    class BallNode
    class PaddleNode

    PowerUpCoordinator *-- PowerUpState : holds
    PowerUpCoordinator ..> PowerUpType : «use»
    PowerUpCoordinator ..> PowerUpNode : «spawns / removes»
    PowerUpCoordinator ..> LaserNode : «spawns»
    PowerUpCoordinator ..> CollectOutcome : «returns»
    PowerUpState ..> PowerUpType : references
    CollectOutcome ..> PowerUpEffect : contains
    PowerUpEffect ..> BallNode : «applied by GameScene»
    PowerUpEffect ..> PaddleNode : «applied by GameScene»
</pre>

---

## 5 · Game State Machine

`GameState` is a value type. All transitions are pure functions returning a new
instance — nothing mutates in place. `GameScene` holds the current value and
replaces it on each transition.

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a', 'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff', 'lineColor': '#ff6b9d',
  'stateBkg': '#0d1b2a', 'stateBorder': '#00d4ff',
  'labelBackgroundColor': '#0a1628', 'transitionColor': '#ff6b9d'
}}}%%
stateDiagram-v2
    [*] --> WaitingToLaunch
    WaitingToLaunch --> Playing : launch ball
    Playing --> WaitingToLaunch : ball lost · lives > 0
    Playing --> GameOver : ball lost · lives = 0
    Playing --> Paused : pause
    Paused --> Playing : resume
    Playing --> [*] : level cleared
    GameOver --> [*]
</pre>

---

## 6 · Persistence & Audio

Side-effecting infrastructure, deliberately separated from game logic.
`GamePersistenceCoordinator` mediates all save/restore decisions; raw
`UserDefaults` access is encapsulated in the two store types.

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a', 'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff', 'lineColor': '#ff6b9d',
  'mainBkg': '#0d1b2a', 'nodeBorder': '#00d4ff', 'classText': '#e8f4f8',
  'edgeLabelBackground': '#0a1628', 'clusterBkg': '#0a1628',
  'clusterBorder': '#5a189a', 'titleColor': '#00d4ff'
}}}%%
classDiagram
    direction TD

    namespace Persistence {
        class GamePersistenceCoordinator {
            gamePaused(snapshot)
            sceneWillDisappear(...)
            gameOver()
            levelVictory()
        }
        class GameSaveStore {
            save(SavedGame)
            load() SavedGame?
            clear()
        }
        class SavedGame {
            &lt;&lt;value type&gt;&gt;
            levelIndex: Int
            score: Int
            lives: Int
            brickGrid: BrickCell[][]
        }
        class HighScoreStore {
            submitScore(Int) Bool
            highScore: Int
        }
    }
    namespace Audio {
        class SoundCoordinator {
            playBrickHit(row, totalRows)
            playPaddleHit() / playWallHit()
            playLaunch() / playBallLoss()
            playGameOver() / playLevelComplete()
            playPowerUpCollect/Activate/Expire()
            toggleMute()
        }
    }

    class UserDefaults {
        &lt;&lt;system&gt;&gt;
    }
    class AVAudioEngine {
        &lt;&lt;system&gt;&gt;
    }

    GamePersistenceCoordinator ..> GameSaveStore : «use»
    GameSaveStore ..> SavedGame : «encode / decode»
    GameSaveStore ..> UserDefaults : «use»
    HighScoreStore ..> UserDefaults : «use»
    SoundCoordinator ..> AVAudioEngine : «use»
    SoundCoordinator ..> UserDefaults : «mute state»
</pre>

<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
<script>mermaid.initialize({ startOnLoad: true });</script>
