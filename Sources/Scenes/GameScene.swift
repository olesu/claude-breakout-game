import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let levelIndex: Int
    private let level: Level
    private var gameState: GameState
    private var gameCamera: GameCameraNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!
    private var bricks: [BrickNode] = []
    private var powerUp: PowerUpCoordinator!
    private var levelComplete = false
    private let saveStore = GameSaveStore()
    private var lastUpdateTime: TimeInterval = 0
    private let savedBrickGrid: [[Bool]]?

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
        let cam = GameCameraNode(
            sceneSize: size, levelName: level.name, topSafeArea: view.safeAreaInsets.top
        )
        addChild(cam)
        camera = cam
        gameCamera = cam
        gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        makeWallNodes(for: frame).forEach { addChild($0) }
        setupNodes()
    }

    private func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = restingBallPosition()
        addChild(ball)

        bricks = makeBrickNodes(for: level, sceneFrame: frame, savedGrid: savedBrickGrid)
        bricks.forEach { addChild($0) }

        powerUp = PowerUpCoordinator(scene: self, ball: ball, paddle: paddle)
    }

    // MARK: - Game loop

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

        powerUp.update(delta: delta)
    }

    // MARK: - Touch handling

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
            gameState = gameState.pause()
            applyPauseState()
        case .resume:
            gameState = gameState.resume()
            applyPauseState()
        case .movePaddle:
            movePaddle(to: touches)
        case .launchAndMovePaddle:
            gameState = gameState.launch()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
            movePaddle(to: touches)
            spawnLaunchRipple(at: ball.position)
            ball.physicsBody?.velocity = Theme.Layout.ballLaunchVelocity
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase != .paused else { return }
        movePaddle(to: touches)
    }

    private func movePaddle(to touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let x = clampedPaddleX(
            touchX: touch.location(in: self).x,
            sceneWidth: frame.width,
            halfPaddleWidth: paddle.size.width * paddle.xScale / 2  // xScale grows with wide paddle
        )
        paddle.position.x = x
    }

    // MARK: - Physics contact

    func didBegin(_ contact: SKPhysicsContact) {
        if let brick = (contact.bodyA.node as? BrickNode) ?? (contact.bodyB.node as? BrickNode),
           brick.physicsBody != nil {
            handleBrickContact(brick, contactPoint: contact.contactPoint)
        } else if let node = (contact.bodyA.node as? PowerUpNode)
            ?? (contact.bodyB.node as? PowerUpNode) {
            if let type = powerUp.collect(node) {
                spawnPowerUpActivationEffect(for: type)
            }
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.paddle
            || contact.bodyB.categoryBitMask == PhysicsCategory.paddle {
            paddle.squash()
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
            lastUpdateTime = 0
        }
    }

    override func willMove(from view: SKView) {
        // Skip if already saved by applyPauseState(), or if game has ended / level is advancing.
        guard !levelComplete
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

    private func resetBall() {
        ball.physicsBody?.velocity = .zero
        ball.position = restingBallPosition()
    }

    private func restingBallPosition() -> CGPoint {
        ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
    }
}

// MARK: - Contact handlers

private extension GameScene {
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
        spawnScorePopup(at: contactPoint, points: points)
        spawnSparks(at: contactPoint, color: color)
        brick.destroy { [weak self] in
            guard let self else { return }
            if bricks.isEmpty && !levelComplete { levelComplete = true }
        }
        if spawnPowerUp { powerUp.spawnIfEligible(at: brick.position) }
    }
}

// MARK: - Visual effects

private extension GameScene {
    func spawnScorePopup(at position: CGPoint, points: Int) {
        let label = SKLabelNode(fontNamed: Theme.Font.bold)
        label.text = "+\(points)"
        label.fontSize = Theme.FontSize.small
        label.fontColor = Theme.Color.accent
        label.position = position
        label.zPosition = 5
        let move = SKAction.moveBy(x: 0, y: 40, duration: 0.6)
        let fade = SKAction.sequence([.wait(forDuration: 0.2), .fadeOut(withDuration: 0.4)])
        let remove = SKAction.removeFromParent()
        label.run(.sequence([.group([move, fade]), remove]))
        addChild(label)
    }

    func spawnSparks(at position: CGPoint, color: UIColor) {
        let emitter = makeBrickSparkEmitter(color: color)
        emitter.position = position
        addChild(emitter)
        emitter.run(.sequence([.wait(forDuration: 0.6), .removeFromParent()]))
    }

    func spawnLaunchRipple(at position: CGPoint) {
        spawnRippleRing(at: position, delay: 0, scale: 4.0, alpha: 1.0, lineWidth: 2.0)
        spawnRippleRing(at: position, delay: 0.12, scale: 5.0, alpha: 0.6, lineWidth: 1.5)
    }

    func spawnPowerUpActivationEffect(for type: PowerUpType) {
        switch type {
        case .powerBall:
            spawnRippleRing(at: ball.position, delay: 0, scale: 6.0, alpha: 1.0, lineWidth: 2.5)
            spawnRippleRing(at: ball.position, delay: 0.1, scale: 8.0, alpha: 0.5, lineWidth: 1.5)
        case .widePaddle:
            spawnRippleRing(at: paddle.position, delay: 0, scale: 5.0, alpha: 1.0, lineWidth: 2.0)
            spawnRippleRing(at: paddle.position, delay: 0.1, scale: 7.0, alpha: 0.5, lineWidth: 1.5)
        }
    }

    func spawnRippleRing(
        at position: CGPoint,
        delay: TimeInterval,
        scale: CGFloat,
        alpha: CGFloat,
        lineWidth: CGFloat
    ) {
        let ring = SKShapeNode(circleOfRadius: Theme.Layout.ballRadius)
        ring.fillColor = .clear
        ring.strokeColor = .white
        ring.lineWidth = lineWidth
        ring.alpha = 0
        ring.zPosition = 3
        ring.position = position
        addChild(ring)
        ring.run(.sequence([
            .wait(forDuration: delay),
            .fadeAlpha(to: alpha, duration: 0),
            .group([
                .scale(to: scale, duration: 0.5),
                .fadeOut(withDuration: 0.5)
            ]),
            .removeFromParent()
        ]))
    }
}
