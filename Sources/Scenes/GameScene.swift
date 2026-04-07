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
    private var permanentBricks: [BrickNode] = []
    private var powerUp: PowerUpCoordinator!
    private var gameLoop: GameLoopCoordinator!
    private let persistence = GamePersistenceCoordinator()
    private let savedBrickGrid: [[BrickCell]]?
    private let inputCoordinator = InputCoordinator()
    /// Suivi du combo de destructions consécutives de briques
    private let comboTracker = ComboTracker()
    #if os(macOS)
    private let mouseTracker = MouseInputTracker()
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
        #endif
    }

    private func setupCamera(in view: SKView) {
        let cam = GameCameraNode(
            sceneSize: size, levelName: level.name, topSafeArea: topSafeAreaInset(for: view)
        )
        addChild(cam)
        camera = cam
        cam.updateHUD(lives: gameState.lives, score: gameState.score, comboMultiplier: comboTracker.multiplier)
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

        powerUp = PowerUpCoordinator(balls: balls, paddle: paddle)
        gameLoop = GameLoopCoordinator(paddle: paddle, powerUp: powerUp)
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        // Les indices sont décroissants — suppression sûre sans décalage des positions précédentes.
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
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score, comboMultiplier: comboTracker.multiplier)
            movePaddle(to: x)
            SceneEffects.spawnLaunchRipple(at: primary.position).forEach(addChild)
            primary.launch()
        }
    }

    private func movePaddle(to x: CGFloat) {
        paddle.position.x = clampedPaddleX(
            touchX: x,
            sceneWidth: frame.width,
            halfPaddleWidth: paddle.size.width * paddle.xScale / 2  // xScale grandit avec le wide paddle
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
        if gameState.phase == .playing { fireLasersIfActive() }
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
        case " " where gameState.phase == .playing:
            fireLasersIfActive()
        #if DEBUG
        case "w" where gameState.phase == .playing || gameState.phase == .waitingToLaunch:
            bricks.forEach { $0.destroy(completion: {}) }  // completion inutilisée : level marqué ci-dessous
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
            if gameState.phase != .waitingToLaunch { paddle.squash() }
            if let ball { reflectBallOffPaddle(contactPoint: point, ball: ball) }
        case .wallHit(let wall):
            wall.flash()
        case .laser(let laser, let brick, let point):
            handleLaserContact(laser, brick: brick, contactPoint: point)
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
            brickGrid: brickGrid(from: bricks + permanentBricks, level: level)
        )
    }

    private func handleBallLoss() {
        // Réinitialise le combo à chaque perte de balle
        comboTracker.reset()
        // Mutations d'état
        powerUp.clearAll()
        gameState = gameState.ballLost()
        let isGameOver = gameState.phase == .gameOver

        // Effets visuels
        gameCamera.shake()
        gameCamera.updateHUD(lives: gameState.lives, score: gameState.score, comboMultiplier: comboTracker.multiplier)
        SceneEffects.spawnBallLossFlash(
            sceneSize: size, center: CGPoint(x: frame.midX, y: frame.midY)
        ).forEach(addChild)

        // Transition de scène (en dernier)
        if isGameOver {
            persistence.gameOver()
            present(GameSummaryScene(size: size, outcome: .gameOver, score: gameState.score))
        }
    }

}

// MARK: - Multi Ball

private extension GameScene {
    func spawnExtraBalls(at position: CGPoint, velocity: CGVector) {
        for spec in makeExtraBalls(
            at: position, primaryVelocity: velocity, radius: Theme.Layout.ballRadius
        ) {
            // La velocity doit être définie avant powerUp.addBall(_:) : activateSlowBall lit
            // physicsBody.velocity immédiatement pour capturer speedBeforeSlowBall.
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
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score, comboMultiplier: comboTracker.multiplier)
            let ballPos = balls.first?.position ?? paddle.position
            SceneEffects.spawnPowerUpActivationEffect(
                for: .extraLife, ballPosition: ballPos, paddlePosition: paddle.position
            ).forEach(addChild)
        case .instant(.multiBall):
            // Spawn uniquement en phase playing : en waitingToLaunch la balle a une velocity nulle,
            // les balles supplémentaires seraient donc immobiles et ne recevraient jamais la velocity de lancement.
            guard gameState.phase == .playing,
                  let primary = balls.first,
                  let vel = primary.physicsBody?.velocity else { return }
            spawnExtraBalls(at: primary.position, velocity: vel)
            SceneEffects.spawnPowerUpActivationEffect(
                for: .multiBall, ballPosition: primary.position, paddlePosition: paddle.position
            ).forEach(addChild)
        case .instant:
            break  // Les nouveaux types instant doivent être gérés explicitement au-dessus.
        case .none:
            break
        }
    }

    func advanceLevel() {
        let nextIndex = levelIndex + 1
        if nextIndex < Level.all.count {
            gameState = gameState.resetForNextLevel()
            present(GameScene(size: size, levelIndex: nextIndex, gameState: gameState))
        } else {
            persistence.levelVictory()
            present(GameSummaryScene(size: size, outcome: .victory, score: gameState.score))
        }
    }

    /// Recalcule la velocity de la balle selon l'endroit où elle a touché la raquette.
    /// Ignore les contacts sous la raquette (protection contre les glitches physiques).
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
        let color = brick.color
        SceneEffects.spawnSparks(at: contactPoint, color: color).forEach(addChild)

        switch brick.hit() {
        case .intact(let remaining):
            brick.applyDamage(remainingHits: remaining)
        case .destroyed:
            // Enregistrer le hit et obtenir le multiplicateur courant
            let prevMultiplier = comboTracker.multiplier
            let currentMultiplier = comboTracker.recordHit()
            let earnedPoints = Theme.Layout.brickPoints * currentMultiplier

            let spawnPowerUp = !powerUp.isPowerBallActive
            bricks.removeAll { $0 === brick }
            gameState = gameState.addScore(earnedPoints)
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score, comboMultiplier: currentMultiplier)
            SceneEffects.spawnScorePopup(
                at: contactPoint,
                points: earnedPoints,
                multiplier: currentMultiplier > 1 ? currentMultiplier : nil
            ).forEach(addChild)

            // Popup de tier combo si le multiplicateur vient de monter
            if currentMultiplier > prevMultiplier {
                addChild(ComboPopupNode(
                    kind: .tierUp(multiplier: currentMultiplier),
                    at: CGPoint(x: contactPoint.x, y: contactPoint.y + 20)
                ))
            }

            brick.destroy { [weak self] in
                guard let self else { return }
                if bricks.isEmpty && !gameLoop.levelComplete { gameLoop.markLevelComplete() }
            }
            if brick.isBonus {
                addChild(powerUp.spawnGuaranteed(at: brick.position))
            } else if spawnPowerUp, let node = powerUp.spawnIfEligible(at: brick.position) {
                addChild(node)
            }
        }
    }

    func handleLaserContact(_ laser: LaserNode, brick: BrickNode?, contactPoint: CGPoint) {
        laser.removeFromParent()
        if let brick { handleBrickContact(brick, contactPoint: contactPoint) }
    }

    func fireLasersIfActive() {
        let halfWidth = paddle.size.width * paddle.xScale / 2
        powerUp.fireLasers(from: paddle.position, paddleHalfWidth: halfWidth)
            .forEach(addChild)
    }

}
