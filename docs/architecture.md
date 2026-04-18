---
title: Architecture
layout: page
---

The codebase follows the **Functional Core / Imperative Shell** pattern:

- **Functional core** — plain Swift types with no SpriteKit dependency. State
  transitions return new values; nothing mutates in place. Fully unit-tested.
- **Imperative shell** — SpriteKit scenes and nodes that own the mutable world.
  They call into the core to decide *what* should happen, then apply those
  decisions as mutations.

The discipline is: *calculate first, mutate after.*

---

## Component Map

<pre class="mermaid">
graph TB
    subgraph Shell["Imperative Shell · SpriteKit"]
        subgraph Scenes["Scenes"]
            SplashScene
            GameScene
            GameSummaryScene
            MacLaunchSplashScene
        end
        subgraph Nodes["Nodes"]
            BallNode
            PaddleNode
            BrickNode
            HUDNode
            PowerUpNode
            BackdropNode
        end
    end

    subgraph Core["Functional Core · Plain Swift"]
        subgraph State["State"]
            GameState
            GamePhase
            PowerUpState
        end
        subgraph Logic["Logic"]
            GameLoopCoordinator
            ContactCoordinator
            PowerUpCoordinator
            ComboTracker
        end
        subgraph Data["Data & Levels"]
            Level
            BrickCell
            SavedGame
        end
    end

    subgraph Platform["Platform Layer"]
        SoundCoordinator
        InputCoordinator
        GamePersistenceCoordinator
        GameSaveStore
        HighScoreStore
    end

    GameScene --> Core
    GameScene --> Platform
    GameScene --> Nodes
    SplashScene -->|"new game"| GameScene
    GameScene -->|"game over / victory"| GameSummaryScene
    GameSummaryScene -->|"play again"| SplashScene
</pre>

---

## Scene Flow

<pre class="mermaid">
flowchart LR
    SplashScene -->|"tap Play"| GameScene
    GameScene -->|"all levels cleared"| GS_Victory["GameSummaryScene\n(victory)"]
    GameScene -->|"lives = 0"| GS_GameOver["GameSummaryScene\n(game over)"]
    GS_Victory -->|"play again"| SplashScene
    GS_GameOver -->|"play again"| SplashScene
</pre>

---

## Game State Machine

`GameScene` owns a `GameState` value that drives gameplay flow.
All transitions are pure functions — they return a new `GameState` rather than
mutating the existing one.

<pre class="mermaid">
stateDiagram-v2
    [*] --> WaitingToLaunch
    WaitingToLaunch --> Playing : launch ball
    Playing --> WaitingToLaunch : ball lost, lives > 0
    Playing --> GameOver : ball lost, lives = 0
    Playing --> Paused : pause
    Paused --> Playing : resume
    Playing --> [*] : level cleared → next level / victory
    GameOver --> [*]
</pre>
