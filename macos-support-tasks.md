# macOS Support — Implementation Tasks

Tracking the work to add a native macOS target alongside the existing iOS app.
See the Enhancement Ideas section of `user-story-map.md` for the design rationale.

All game logic (`GameState`, `Level`, `BallDeflector`, `PaddlePositioner`, etc.)
and most SpriteKit scene code is already platform-agnostic. The port surface is
narrow: the app entry point, color types, input handling, and build configuration.

The game launches directly into fullscreen. macOS will animate the transition
briefly on first launch — this is acceptable.

Each phase ends with a working, runnable checkpoint.

---

## Phase 1 — Add macOS Target

**Checkpoint**: `xcodegen generate` succeeds and the macOS target is visible in
Xcode. The target will not build yet (UIKit compile errors are fixed in Phase 2).

- [ ] **1.1 Add macOS target in `project.yml`**
  - Add a new application target (e.g. `BreakoutGameMac`) with `platform: macOS`
    and `deploymentTarget: macOS: "13.0"`.
  - Copy source files from the iOS target; exclude `AppDelegate.swift` and add a
    new `AppDelegateMac.swift` (created in Phase 2).
  - Remove iOS-specific Info.plist keys
    (`INFOPLIST_KEY_UILaunchScreen_Generation`,
    `SUPPORTED_INTERFACE_ORIENTATIONS`, `TARGETED_DEVICE_FAMILY`).
  - Add macOS-required Info.plist keys: `NSPrincipalClass = NSApplication`,
    `CFBundlePackageType = APPL`.
  - Run `xcodegen generate` and confirm the new target appears in Xcode.

---

## Phase 2 — First Working Build (Fullscreen)

All compile errors preventing the macOS target from building, fixed together.
Fullscreen is part of the initial setup — there is no windowed mode.

**Checkpoint**: app launches directly into fullscreen, all three scenes transition
correctly (Splash → Game → Summary → Splash), and the paddle responds to mouse drag.

### App Entry Point

Current file: `Sources/AppDelegate.swift` — uses `UIKit`, `UIWindow`,
`UIViewController`, `UIScreen.main.bounds`.

- [ ] **2.1 Wrap the iOS `AppDelegate` in `#if os(iOS)`**
  - Guard the entire `Sources/AppDelegate.swift` with `#if os(iOS) ... #endif`
    so it is excluded from the macOS compile.

- [ ] **2.2 Create `Sources/AppDelegateMac.swift`**
  - Guard with `#if os(macOS)`.
  - Implement `NSApplicationDelegate`:
    - Create an `NSWindow` sized to the chosen portrait resolution (e.g. 390 × 844).
    - Set `styleMask` to `[.titled, .closable, .miniaturizable, .fullScreen]`.
    - Set `window.collectionBehavior` to include `.fullScreenPrimary`.
    - Embed an `NSViewController` whose view is an `SKView`.
    - Set `skView.scene?.scaleMode = .aspectFit` so the portrait scene is
      letterboxed automatically in fullscreen.
    - Present `SplashScene` as the initial scene (mirroring the iOS flow).
    - Call `window.center()`, `window.makeKeyAndOrderFront(nil)`, then
      `window.toggleFullScreen(nil)` to enter fullscreen on launch.
  - Add `@main` annotation (or a `main.swift` shim) guarded by platform so both
    targets have exactly one entry point.

### Color Types

Current issue: `Sources/Constants/Theme.swift` imports `UIKit` for `UIColor`.
`UIColor` is used throughout nodes and scenes as color parameters.

- [ ] **2.3 Introduce a `PlatformColor` typealias in `Theme.swift`**

  ```swift
  #if canImport(UIKit)
  import UIKit
  typealias PlatformColor = UIColor
  #else
  import AppKit
  typealias PlatformColor = NSColor
  #endif
  ```

- [ ] **2.4 Replace `UIColor` with `PlatformColor` in `Theme.swift`**
  - Change all constant declarations from `UIColor` to `PlatformColor`.
  - Remove the bare `import UIKit` (it is now inside the `#if` block).

- [ ] **2.5 Update call sites that accept `UIColor` explicitly**
  - `BrickSparkNode.swift` — `init(color: UIColor)` → `init(color: PlatformColor)`.
  - `PowerUpNode.swift` — `var nodeColor: UIColor` → `var nodeColor: PlatformColor`.
  - `GameScene.swift` — `spawnSparks(at:color: UIColor)` → `PlatformColor`.
  - `SKLabelNode+Factory.swift` — any `color: UIColor` parameters.
  - Note: `SKColor` is already a cross-platform typealias in SpriteKit; only
    explicit `UIColor` annotations need changing.

### Input Handling

`UITouch` and `UIEvent` are UIKit types that do not exist on macOS. The macOS
target is optimised for trackpad: a two-finger horizontal swipe moves the paddle
via `scrollWheel`, and a tap/click launches the ball and hits buttons via
`mouseDown`. The paddle logic already funnels through `movePaddle(to x:)` in
`PaddlePositioner`, so the surface area is small.

- [ ] **2.6 Guard `touchesBegan`/`touchesMoved` in all three scenes**
  - Wrap the existing touch overrides in `GameScene`, `SplashScene`, and
    `GameSummaryScene` with `#if os(iOS) ... #endif`.

- [ ] **2.7 `GameScene` — add macOS trackpad input**
  - Add, guarded by `#if os(macOS)`:
    - `override func scrollWheel(with event: NSEvent)` — primary paddle
      control. Accumulate `event.scrollingDeltaX` into the paddle's current
      scene-space X position and call `movePaddle(to:)`. Clamp to scene bounds.
    - `override func mouseDown(with event: NSEvent)` — check pause button hit
      test, then call `launchAndMovePaddle` / `movePaddle` depending on game
      state (mirrors `touchesBegan`). Use `event.location(in: self)`.

- [ ] **2.8 `SplashScene` — add macOS click override**
  - Add `#if os(macOS)` override for `mouseDown(with:)` mirroring
    `touchesBegan` (hit-test resume/new game buttons, transition to `GameScene`).

- [ ] **2.9 `GameSummaryScene` — add macOS click override**
  - Add `#if os(macOS)` override for `mouseDown(with:)` mirroring
    `touchesBegan` (any click returns to `SplashScene`).

### Safe Area

- [ ] **2.10 Guard `view.safeAreaInsets` in `GameScene.didMove(to:)`**
  - Current code: `topSafeArea: view.safeAreaInsets.top`
  - Replace with:

    ```swift
    #if os(iOS)
    let topSafeArea = view.safeAreaInsets.top
    #else
    let topSafeArea: CGFloat = 0
    #endif
    ```

  - On macOS the HUD sits at the top of the scene with no notch offset, which
    is correct.

---

## Phase 3 — Validation & Polish

**Checkpoint**: clean build with no lint warnings; all smoke tests pass.

- [ ] **3.1 Smoke test fullscreen**
  - Confirm app launches directly into fullscreen.
  - Confirm paddle tracks mouse drag.
  - Confirm click launches ball from paddle.
  - Confirm pause button responds to click.
  - Confirm letterboxing appears correctly (black bars on each side).
  - Confirm app quits cleanly on window close / Cmd-Q.
  - Confirm game save/resume works (`GameSaveStore` uses `UserDefaults` —
    the macOS suite is separate from iOS, which is expected).

- [ ] **3.2 SwiftLint**
  - Run SwiftLint with `--strict`; fix any warnings introduced by the
    platform-conditional blocks.

- [ ] **3.4 Update `user-story-map.md`**
  - Move macOS Support from Enhancement Ideas to a tracked scope section.

---

## Out of Scope for This Work

- **Mac Catalyst** — faster path but less native; rejected per story map.
- **Windowed mode** — the game runs fullscreen-only on macOS.
- **Landscape layout** — letterboxing in fullscreen is acceptable; a full
  landscape redesign is not planned.
- **Trackpad tilt / accelerometer** — not available on macOS.
- **App Store submission for macOS** — requires a separate bundle ID, signing
  certificate, and Notarization; tracked separately.
