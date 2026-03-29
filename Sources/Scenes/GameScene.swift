import SpriteKit
#if os(macOS)
import AppKit
#endif

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let levelIndex: Int
    private let level: Level
    private var gameState: GameState
    // swiftlint:disable:next force_cast
    private var gameCamera: GameCameraNode { camera as! GameCameraNode }
    private var paddle: PaddleNode!
    private var balls: [BallNode] = []
    private var bricks: [BrickNode] = []
    private var powerUp: PowerUpCoordinator!
    private var gameLoop: GameLoopCoordinator!
    private let persistence = GamePersistenceCoordinator()
    private let savedBrickGrid: [[Bool]]?
    private let inputCoordinator = InputCoordinator()
    #if os(macOS)
    private let mouseTracker = MouseInputTracker()
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
        setupCamera(in: view)
        configurePhysics()
        setupBackground()
        setupNodes()
        #if os(macOS)
        mouseTracker.install(on: view)
        (NSApp.delegate as? AppDelegate)?.hideCursor()
        #endif
    }

    private func setupCamera(in view: SKView) {
        let cam = GameCameraNode(
            sceneSize: size, levelName: level.name, topSafeArea: topSafeAreaInset(for: view)
        )
        addChild(cam)
        camera = cam
        cam.updateHUD(lives: gameState.lives, score: gameState.score)
    }

    private func configurePhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func setupBackground() {
        backgroundColor = .black
        makeWallNodes(for: frame).forEach { addChild($0) }
        let starfield = AmbientStarfieldNode(sceneSize: size)
        starfield.position = CGPoint(x: frame.midX, y: frame.maxY)
        addChild(starfield)
    }

    private func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        let primaryBall = BallNode(radius: Theme.Layout.ballRadius)
        primaryBall.position = ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
        addChild(primaryBall)
        primaryBall.attachTrail(to: self)
        balls = [primaryBall]

        bricks = makeBrickNodes(for: level, sceneFrame: frame, savedGrid: savedBrickGrid)
        bricks.forEach { addChild($0) }

        powerUp = PowerUpCoordinator(balls: balls, paddle: paddle)
        gameLoop = GameLoopCoordinator(paddle: paddle, powerUp: powerUp)
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        // Indices are descending — safe to remove without shifting earlier positions.
        for idx in fallenExtraBallIndices(balls: balls, floorY: frame.minY) {
            let fallen = balls[idx]
            fallen.removeFromParent()
            balls.remove(at: idx)
            powerUp.removeBall(fallen)
        }
        switch gameLoop.tick(
            currentTime: currentTime, phase: gameState.phase, floorY: frame.minY, balls: balls
        ) {
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
            guard let primary = balls.first else { return }
            gameState = gameState.launch()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
            movePaddle(to: x)
            SceneEffects.spawnLaunchRipple(at: primary.position).forEach(addChild)
            primary.launch()
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
        switch event.characters?.lowercased() {
        case "p":
            switch gameState.phase {
            case .playing: handle(.pause)
            case .paused:  handle(.resume)
            default:       break
            }
        #if DEBUG
        case "w" where gameState.phase == .playing || gameState.phase == .waitingToLaunch:
            bricks.forEach { $0.destroy(completion: {}) }  // completion unused: level marked below
            bricks.removeAll()
            gameLoop.markLevelComplete()
        #endif
        default: break
        }
    }
    #endif

    // MARK: - Physics contact

    func didBegin(_ contact: SKPhysicsContact) {
        switch classifyContact(contact) {
        case .brick(let brick, let point):
            handleBrickContact(brick, contactPoint: point)
        case .powerUp(let node):
            handlePowerUpContact(node)
        case .paddleHit(let ball, let point):
            paddle.squash()
            if let ball { reflectBallOffPaddle(contactPoint: point, ball: ball) }
        case .wallHit(let wall):
            wall.flash()
        case .unknown:
            break
        }
    }

    // MARK: - Game lifecycle

    private func applyPauseState() {
        let isPaused = gameState.phase == .paused
        physicsWorld.speed = isPaused ? 0 : 1
        gameCamera.setPaused(isPaused)
        if isPaused {
            persistence.gamePaused(snapshot: makeSnapshot)
        } else {
            gameLoop.resetLastUpdateTime()
        }
    }

    override func willMove(from view: SKView) {
        #if os(macOS)
        mouseTracker.uninstall(from: view)
        #endif
        persistence.sceneWillDisappear(
            isLevelComplete: gameLoop.levelComplete,
            phase: gameState.phase,
            snapshot: makeSnapshot
        )
    }

    private func makeSnapshot() -> SavedGame {
        SavedGame(
            levelIndex: levelIndex,
            score: gameState.score,
            lives: gameState.lives,
            brickGrid: brickGrid(from: bricks, level: level)
        )
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
            persistence.gameOver()
            present(GameSummaryScene(size: size, outcome: .gameOver, score: gameState.score))
        }
    }

    private func advanceLevel() {
        let nextIndex = levelIndex + 1
        if nextIndex < Level.all.count {
            gameState = gameState.resetForNextLevel()
            present(GameScene(size: size, levelIndex: nextIndex, gameState: gameState))
        } else {
            persistence.levelVictory()
            present(GameSummaryScene(size: size, outcome: .victory, score: gameState.score))
        }
    }

}

// MARK: - Multi Ball

private extension GameScene {
    func spawnExtraBalls(at position: CGPoint, velocity: CGVector) {
        for spec in makeExtraBalls(
            at: position, primaryVelocity: velocity, radius: Theme.Layout.ballRadius
        ) {
            // velocity must be set before powerUp.addBall(_:): activateSlowBall reads
            // physicsBody.velocity immediately to capture speedBeforeSlowBall.
            spec.ball.physicsBody?.velocity = spec.velocity
            addChild(spec.ball)
            spec.ball.attachTrail(to: self)
            balls.append(spec.ball)
            powerUp.addBall(spec.ball)
        }
    }
}

// MARK: - Contact handlers

private extension GameScene {
    func handlePowerUpContact(_ node: PowerUpNode) {
        switch powerUp.collect(node) {
        case .activated(let type):
            let ballPos = balls.first?.position ?? paddle.position
            SceneEffects.spawnPowerUpActivationEffect(
                for: type, ballPosition: ballPos, paddlePosition: paddle.position
            ).forEach(addChild)
        case .instant(.extraLife):
            gameState = gameState.addLife()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
            let ballPos = balls.first?.position ?? paddle.position
            SceneEffects.spawnPowerUpActivationEffect(
                for: .extraLife, ballPosition: ballPos, paddlePosition: paddle.position
            ).forEach(addChild)
        case .instant(.multiBall):
            // Only spawn while playing: in waitingToLaunch the ball has zero velocity,
            // so extra balls would be spawned motionless and never receive launch velocity.
            guard gameState.phase == .playing,
                  let primary = balls.first,
                  let vel = primary.physicsBody?.velocity else { return }
            spawnExtraBalls(at: primary.position, velocity: vel)
            SceneEffects.spawnPowerUpActivationEffect(
                for: .multiBall, ballPosition: primary.position, paddlePosition: paddle.position
            ).forEach(addChild)
        case .instant:
            break  // New instant types need explicit handling above this line.
        case .none:
            break
        }
    }

    /// Overrides ball velocity based on where it hit the paddle.
    /// Ignores sub-paddle contacts (physics glitch guard).
    func reflectBallOffPaddle(contactPoint: CGPoint, ball: BallNode) {
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
        if spawnPowerUp, let node = powerUp.spawnIfEligible(at: brick.position) { addChild(node) }
    }
}
