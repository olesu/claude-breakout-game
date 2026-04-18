---
title: Architecture
layout: page
---

<small>Built: {{ site.time | date: "%Y-%m-%d %H:%M UTC" }}</small>

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
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a',
  'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff',
  'lineColor': '#ff6b9d',
  'clusterBkg': '#0a1628',
  'clusterBorder': '#5a189a',
  'titleColor': '#00d4ff',
  'edgeLabelBackground': '#0d1b2a'
}}}%%
graph TD
    subgraph Shell["Imperative Shell · SpriteKit"]
        direction TB
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
        end
    end

    subgraph Core["Functional Core · Pure Swift"]
        direction TB
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
        direction TB
        SoundCoordinator
        InputCoordinator
        GamePersistenceCoordinator
        GameSaveStore
        HighScoreStore
    end

    Shell -->|"reads/mutates"| Core
    Shell -->|"delegates to"| Platform
</pre>

---

## Scene Flow

<pre class="mermaid">
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a',
  'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff',
  'lineColor': '#ff6b9d',
  'edgeLabelBackground': '#0d1b2a'
}}}%%
flowchart TD
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
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#0d1b2a',
  'primaryTextColor': '#e8f4f8',
  'primaryBorderColor': '#00d4ff',
  'lineColor': '#ff6b9d',
  'stateBkg': '#0d1b2a',
  'stateBorder': '#00d4ff',
  'labelBackgroundColor': '#0a1628',
  'transitionColor': '#ff6b9d'
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

<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
<script>mermaid.initialize({ startOnLoad: true });</script>
