import SpriteKit
#if os(macOS)
import AppKit
#endif

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let levelIndex: Int
    private let level: Level
    private var gameState: GameState
    private var gameCamera: GameCameraNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!
    private var bricks: [BrickNode] = []
    private var powerUp: PowerUpCoordinator!
    private var gameLoop: GameLoopCoordinator!
    private let saveStore = GameSaveStore()
    private let savedBrickGrid: [[Bool]]?
    private let inputCoordinator = InputCoordinator()
    #if os(macOS)
    private var trackingArea: NSTrackingArea?
    #endif

    init(
        size: CGSize,
        levelIndex: Int,
        gameState: GameState,
        savedBrickGrid: [[Bool]]? = nil
    ) {
        precondition(Level.all.indices.contains(levelIndex), "levelIndex out of range")
        self.levelIndex = levelIndex
        self.level = Level.all[levelIndex]
        self.gameState = gameState
        self.savedBrickGrid = savedBrickGrid
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Setup

    override func didMove(to view: SKView) {
        #if os(iOS)
        let topSafeArea = view.safeAreaInsets.top
        #else
        let topSafeArea: CGFloat = 28  // clears the auto-hiding macOS menu bar in fullscreen
        #endif
        let cam = GameCameraNode(
            sceneSize: size, levelName: level.name, topSafeArea: topSafeArea
        )
        addChild(cam)
        camera = cam
        gameCamera = cam
        gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        makeWallNodes(for: frame).forEach { addChild($0) }
        let starfield = AmbientStarfieldNode(sceneSize: size)
        starfield.position = CGPoint(x: frame.midX, y: frame.maxY)
        addChild(starfield)
        setupNodes()
        #if os(macOS)
        let ta = NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect],
            owner: view,
            userInfo: nil
        )
        view.addTrackingArea(ta)
        trackingArea = ta
        #endif
    }

    private func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
        addChild(ball)
        ball.attachTrail(to: self)

        bricks = makeBrickNodes(for: level, sceneFrame: frame, savedGrid: savedBrickGrid)
        bricks.forEach { addChild($0) }

        powerUp = PowerUpCoordinator(scene: self, ball: ball, paddle: paddle)
        gameLoop = GameLoopCoordinator(ball: ball, paddle: paddle, powerUp: powerUp)
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        switch gameLoop.tick(currentTime: currentTime, phase: gameState.phase, floorY: frame.minY) {
        case .handleBallLoss:    handleBallLoss()
        case .advanceLevel:      advanceLevel()
        case .nothing, .resetBall: break
        }
    }

    // MARK: - Touch / mouse handling

    private func handle(_ action: InputAction) {
        switch action {
        case .none:
            break
        case .pause:
            gameState = gameState.pause()
            applyPauseState()
        case .resume:
            gameState = gameState.resume()
            applyPauseState()
        case .movePaddle(let x):
            movePaddle(to: x)
        case .launchAndMovePaddle(let x):
            gameState = gameState.launch()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
            movePaddle(to: x)
            SceneEffects.spawnLaunchRipple(at: ball.position).forEach(addChild)
            ball.physicsBody?.velocity = Theme.Layout.ballLaunchVelocity
        }
    }

    private func movePaddle(to x: CGFloat) {
        paddle.position.x = clampedPaddleX(
            touchX: x,
            sceneWidth: frame.width,
            halfPaddleWidth: paddle.size.width * paddle.xScale / 2  // xScale grows with wide paddle
        )
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 2 {
            switch gameState.phase {
            case .playing: handle(.pause)
            case .paused:  handle(.resume)
            default:       break
            }
            return
        }
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        handle(inputCoordinator.action(
            at: loc,
            hittingPauseButton: nodes(at: loc).contains { $0.name == "pauseButton" },
            phase: gameState.phase
        ))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase != .paused else { return }
        guard let touch = touches.first else { return }
        movePaddle(to: touch.location(in: self).x)
    }
    #endif

    #if os(macOS)
    override func mouseMoved(with event: NSEvent) {
        guard gameState.phase != .paused else { return }
        movePaddle(to: event.location(in: self).x)
    }

    override func mouseDown(with event: NSEvent) {
        let loc = event.location(in: self)
        handle(inputCoordinator.action(
            at: loc,
            hittingPauseButton: nodes(at: loc).contains { $0.name == "pauseButton" },
            phase: gameState.phase
        ))
    }

    override func keyDown(with event: NSEvent) {
        guard event.characters?.lowercased() == "p" else { return }
        switch gameState.phase {
        case .playing: handle(.pause)
        case .paused:  handle(.resume)
        default:       break
        }
    }
    #endif

    // MARK: - Physics contact

    func didBegin(_ contact: SKPhysicsContact) {
        if let brick = (contact.bodyA.node as? BrickNode) ?? (contact.bodyB.node as? BrickNode),
           brick.physicsBody != nil {
            handleBrickContact(brick, contactPoint: contact.contactPoint)
        } else if let node = (contact.bodyA.node as? PowerUpNode)
            ?? (contact.bodyB.node as? PowerUpNode) {
            switch powerUp.collect(node) {
            case .activated(let type):
                SceneEffects.spawnPowerUpActivationEffect(
                    for: type, ballPosition: ball.position, paddlePosition: paddle.position
                ).forEach(addChild)
            case .instant(.extraLife):
                gameState = gameState.addLife()
                gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
                SceneEffects.spawnPowerUpActivationEffect(
                    for: .extraLife, ballPosition: ball.position, paddlePosition: paddle.position
                ).forEach(addChild)
            case .instant:
                break  // New instant types need explicit handling above this line.
            case .none:
                break
            }
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.paddle
            || contact.bodyB.categoryBitMask == PhysicsCategory.paddle {
            paddle.squash()
            reflectBallOffPaddle(contactPoint: contact.contactPoint)
        } else if let wall = (contact.bodyA.node as? WallNode)
            ?? (contact.bodyB.node as? WallNode) {
            wall.flash()
        }
    }

    // MARK: - Game lifecycle

    private func applyPauseState() {
        let isPaused = gameState.phase == .paused
        physicsWorld.speed = isPaused ? 0 : 1
        gameCamera.setPaused(isPaused)
        if isPaused {
            saveGame()
        } else {
            gameLoop.resetLastUpdateTime()
        }
    }

    override func willMove(from view: SKView) {
        #if os(macOS)
        if let ta = trackingArea { view.removeTrackingArea(ta) }
        #endif
        // Skip if already saved by applyPauseState(), or if game has ended / level is advancing.
        guard !gameLoop.levelComplete
            && gameState.phase != .gameOver
            && gameState.phase != .paused else { return }
        saveGame()
    }

    private func saveGame() {
        var grid = Array(
            repeating: Array(repeating: false, count: level.grid[0].count),
            count: level.grid.count
        )
        for brick in bricks {
            grid[brick.row][brick.col] = true
        }
        saveStore.save(SavedGame(
            levelIndex: levelIndex,
            score: gameState.score,
            lives: gameState.lives,
            brickGrid: grid
        ))
    }

    private func handleBallLoss() {
        // State mutations
        powerUp.clearAll()
        gameState = gameState.ballLost()
        let isGameOver = gameState.phase == .gameOver

        // Visual side-effects
        gameCamera.shake()
        gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
        SceneEffects.spawnBallLossFlash(
            sceneSize: size, center: CGPoint(x: frame.midX, y: frame.midY)
        ).forEach(addChild)

        // Scene transition (happens last)
        if isGameOver {
            saveStore.clear()
            present(GameSummaryScene(size: size, outcome: .gameOver, score: gameState.score))
        }
    }

    private func advanceLevel() {
        let nextIndex = levelIndex + 1
        if nextIndex < Level.all.count {
            gameState = gameState.resetForNextLevel()
            present(GameScene(size: size, levelIndex: nextIndex, gameState: gameState))
        } else {
            saveStore.clear()
            present(GameSummaryScene(size: size, outcome: .victory, score: gameState.score))
        }
    }

}

// MARK: - Contact handlers

private extension GameScene {
    /// Overrides ball velocity based on where it hit the paddle.
    /// Ignores sub-paddle contacts (physics glitch guard).
    func reflectBallOffPaddle(contactPoint: CGPoint) {
        guard contactPoint.y >= paddle.position.y, let body = ball.physicsBody else { return }
        let speed = hypot(body.velocity.dx, body.velocity.dy)
        let halfWidth = paddle.size.width * paddle.xScale / 2
        body.velocity = paddleReflectedVelocity(
            speed: speed,
            contactX: contactPoint.x,
            paddleCenterX: paddle.position.x,
            halfPaddleWidth: halfWidth,
            maxAngle: Theme.Layout.paddleMaxAngle
        )
    }

    func handleBrickContact(_ brick: BrickNode, contactPoint: CGPoint) {
        // Capture all inputs before any mutation
        let points = Theme.Layout.brickPoints
        let color = brick.color
        let spawnPowerUp = !powerUp.isPowerBallActive

        // State mutations
        bricks.removeAll { $0 === brick }
        gameState = gameState.addScore(points)
        gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)

        // Visual side-effects
        SceneEffects.spawnScorePopup(at: contactPoint, points: points).forEach(addChild)
        SceneEffects.spawnSparks(at: contactPoint, color: color).forEach(addChild)
        brick.destroy { [weak self] in
            guard let self else { return }
            if bricks.isEmpty && !gameLoop.levelComplete { gameLoop.markLevelComplete() }
        }
        if spawnPowerUp { powerUp.spawnIfEligible(at: brick.position) }
    }
}
