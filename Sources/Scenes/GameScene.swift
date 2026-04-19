import SpriteKit
#if os(macOS)
import AppKit
#endif

// Thin orchestrator; body length reflects coordinator wiring, not logic.
// swiftlint:disable:next type_body_length
final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let levelIndex: Int
    private let level: Level
    private var gameState: GameState
    // swiftlint:disable:next force_cast
    var gameCamera: GameCameraNode { camera as! GameCameraNode }
    private var paddle: PaddleNode!
    private var balls: [BallNode] = []
    var bricks: [BrickNode] = []
    private var permanentBricks: [BrickNode] = []
    private var powerUp: PowerUpCoordinator!
    private var gameLoop: GameLoopCoordinator!
    private var contactCoordinator: ContactCoordinator!
    var bossCoordinator: BossCoordinator?
    private let persistence = GamePersistenceCoordinator()
    private let sound = SoundCoordinator()
    private let savedBrickGrid: [[BrickCell]]?
    private let inputCoordinator = InputCoordinator()
    #if os(macOS)
    private let mouseTracker = MouseInputTracker()
    private var mouseMovedMonitor: Any?
    #endif

    init(
        size: CGSize,
        levelIndex: Int,
        gameState: GameState,
        savedBrickGrid: [[BrickCell]]? = nil
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
        mouseMovedMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
            (NSApp.delegate as? AppDelegate)?.hideCursor()
            return event
        }
        #endif
    }

    private func setupCamera(in view: SKView) {
        let cam = GameCameraNode(
            sceneSize: size, levelName: level.name, topSafeArea: topSafeAreaInset(for: view)
        )
        addChild(cam)
        camera = cam
        cam.updateHUD(lives: gameState.lives, score: gameState.score)
        cam.updateMuteButton(isMuted: sound.isMuted)
    }

    private func configurePhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func setupBackground() {
        backgroundColor = .black
        let backdrop = BackdropNode(size: frame.size)
        backdrop.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(backdrop)
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

        let allBricks = makeBrickNodes(for: level, sceneFrame: frame, savedGrid: savedBrickGrid)
        permanentBricks = allBricks.filter { $0.isIndestructible }
        bricks = allBricks.filter { !$0.isIndestructible }
        allBricks.forEach { addChild($0) }

        powerUp = PowerUpCoordinator()
        gameLoop = GameLoopCoordinator(powerUp: powerUp)
        contactCoordinator = ContactCoordinator(
            powerUp: powerUp,
            paddle: paddle,
            gameLoop: gameLoop,
            addToScene: { [weak self] nodes in nodes.forEach { self?.addChild($0) } },
            removeBrick: { [weak self] brick in
                self?.bricks.removeAll { $0 === brick }
                self?.bossCoordinator?.brickDestroyed()
            },
            remainingBrickCount: { [weak self] in self?.bricks.count ?? 0 }
        )
        contactCoordinator.sound = sound
        contactCoordinator.totalRows = level.grid.count

        let bossPhases = level.metadata.bossPhases
        guard level.isBoss, bossPhases > 0 else { return }
        setupBossCoordinator(bossPhases: bossPhases)
    }

    private func setupBossCoordinator(bossPhases: Int) {
        let columns = level.grid.first?.count ?? 1
        let boss = buildBossCoordinator(bossPhases: bossPhases, columns: columns)
        boss.onLifeLost = { [weak self] in self?.handleBossLifeLoss() }
        bossCoordinator = boss
        gameCamera.activateBossHealthBar()
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        bossCoordinator?.update(currentTime: currentTime, phase: gameState.phase)
        // Indices are descending — safe to remove without shifting earlier positions.
        // No coordinator notification needed when a ball is culled: PowerUpCoordinator holds no
        // ball refs. Deactivation effects reach only balls still in the scene-owned `balls` array.
        for idx in fallenExtraBallIndices(balls: balls, floorY: frame.minY) {
            let fallen = balls[idx]
            fallen.removeFromParent()
            balls.remove(at: idx)
        }
        let tick = gameLoop.tick(
            currentTime: currentTime,
            phase: gameState.phase,
            floorY: frame.minY,
            balls: balls,
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2
        )
        applyPowerUpEffects(tick.powerUpEffects)
        if tick.expiredPowerUpType != nil {
            sound.playPowerUpExpire()
        }
        switch tick.action {
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
        case .toggleMute:
            sound.toggleMute()
            gameCamera.updateMuteButton(isMuted: sound.isMuted)
        case .movePaddle(let x):
            movePaddle(to: x)
        case .launchAndMovePaddle(let x):
            guard let primary = balls.first else { return }
            gameState = gameState.launch()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
            movePaddle(to: x)
            SceneEffects.spawnLaunchRipple(at: primary.position).forEach(addChild)
            sound.playLaunch()
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
        let hitNodes = nodes(at: loc)
        let hitPause = hitNodes.contains { $0.name == "pauseButton" }
        let hitMute = hitNodes.contains { $0.name == "muteButton" }
        handle(inputCoordinator.action(
            at: loc,
            hittingPauseButton: hitPause,
            hittingMuteButton: hitMute,
            phase: gameState.phase
        ))
        if gameState.phase == .playing && !(hitPause || hitMute) { fireLasersIfActive() }
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
        let hitNodes = nodes(at: loc)
        handle(inputCoordinator.action(
            at: loc,
            hittingPauseButton: hitNodes.contains { $0.name == "pauseButton" },
            hittingMuteButton: hitNodes.contains { $0.name == "muteButton" },
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
        case "m" where gameState.phase == .playing || gameState.phase == .waitingToLaunch:
            handle(.toggleMute)
        case " " where gameState.phase == .playing:
            fireLasersIfActive()
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
        apply(contactCoordinator.handle(contact, balls: balls, gamePhase: gameState.phase))
    }

    private func apply(_ outcome: ContactOutcome) {
        if outcome.pointsScored > 0 {
            gameState = gameState.addScore(outcome.pointsScored)
            gameCamera.updateHUD(
                lives: gameState.lives, score: gameState.score,
                comboMultiplier: outcome.comboMultiplier
            )
        }
        if outcome.lifeAwarded {
            gameState = gameState.addLife()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
        }
        if let spawn = outcome.extraBallSpawn {
            spawnExtraBalls(at: spawn.position, velocity: spawn.velocity)
        }
        applyPowerUpEffects(outcome.powerUpEffects)
    }

    // MARK: - Game lifecycle

    override func willMove(from view: SKView) {
        #if os(macOS)
        mouseTracker.uninstall(from: view)
        if let monitor = mouseMovedMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMovedMonitor = nil
        }
        #endif
        sound.stopEngine()
        persistence.sceneWillDisappear(
            isLevelComplete: gameLoop.levelComplete,
            phase: gameState.phase,
            snapshot: makeSnapshot
        )
    }

}

// MARK: - Game lifecycle helpers

private extension GameScene {
    func applyPauseState() {
        let isPaused = gameState.phase == .paused
        physicsWorld.speed = isPaused ? 0 : 1
        gameCamera.setPaused(isPaused)
        if isPaused {
            persistence.gamePaused(snapshot: makeSnapshot)
        } else {
            gameLoop.resetLastUpdateTime()
        }
    }

    func makeSnapshot() -> SavedGame {
        SavedGame(
            levelIndex: levelIndex,
            score: gameState.score,
            lives: gameState.lives,
            brickGrid: brickGrid(from: bricks + permanentBricks, level: level)
        )
    }

    func handleBossLifeLoss() {
        // Boss march reached the paddle zone. Formation is already reset by BossCoordinator.
        // Remove extra balls so the player restarts with one ball on the paddle.
        for idx in stride(from: balls.count - 1, through: 1, by: -1) {
            balls[idx].removeFromParent()
            balls.remove(at: idx)
        }
        handleBallLoss()
    }

    func handleBallLoss() {
        // State mutations
        contactCoordinator.resetCombo()
        applyPowerUpEffects(powerUp.clearAll())
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
        } else {
            sound.playBallLoss()
        }
    }
}

// MARK: - Multi Ball

private extension GameScene {
    func spawnExtraBalls(at position: CGPoint, velocity: CGVector) {
        for spec in makeExtraBalls(
            at: position, primaryVelocity: velocity, radius: Theme.Layout.ballRadius
        ) {
            // velocity must be set before effectsForNewBall(): activateSlowBall reads
            // physicsBody.velocity immediately to capture speedBeforeSlowBall.
            spec.ball.physicsBody?.velocity = spec.velocity
            addChild(spec.ball)
            spec.ball.attachTrail(to: self)
            balls.append(spec.ball)
            applyPowerUpEffects(powerUp.effectsForNewBall(), to: spec.ball)
        }
    }
}

// MARK: - Power-up effects

private extension GameScene {
    /// Applies effects to all current balls and the paddle.
    func applyPowerUpEffects(_ effects: [PowerUpEffect]) {
        for effect in effects {
            switch effect {
            case .activatePowerBall:    balls.forEach { $0.activatePowerBall() }
            case .deactivatePowerBall:  balls.forEach { $0.deactivatePowerBall() }
            case .activateSlowBall:     balls.forEach { $0.activateSlowBall() }
            case .deactivateSlowBall:   balls.forEach { $0.deactivateSlowBall() }
            case .activateWidePaddle:   paddle.activateWidePaddle()
            case .deactivateWidePaddle: paddle.deactivateWidePaddle()
            }
        }
    }

    /// Applies effects to a single ball (used when a new ball is added mid-power-up).
    func applyPowerUpEffects(_ effects: [PowerUpEffect], to ball: BallNode) {
        for effect in effects {
            switch effect {
            case .activatePowerBall: ball.activatePowerBall()
            case .activateSlowBall:  ball.activateSlowBall()
            default: break
            }
        }
    }
}

// MARK: - Game actions

private extension GameScene {
    func advanceLevel() {
        let nextIndex = levelIndex + 1
        if nextIndex < Level.all.count {
            sound.playLevelComplete()
            gameState = gameState.resetForNextLevel()
            present(GameScene(size: size, levelIndex: nextIndex, gameState: gameState))
        } else {
            persistence.levelVictory()
            present(GameSummaryScene(size: size, outcome: .victory, score: gameState.score))
        }
    }

    func fireLasersIfActive() {
        let halfWidth = paddle.size.width * paddle.xScale / 2
        powerUp.fireLasers(from: paddle.position, paddleHalfWidth: halfWidth)
            .forEach(addChild)
    }
}
