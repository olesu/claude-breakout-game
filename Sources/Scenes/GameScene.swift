import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let levelIndex: Int
    private let level: Level
    private let stateMachine: GameStateMachine
    // set in didMove(to:) via setupUI/setupNodes
    private var gameCamera: SKCameraNode!
    private var hud: HUDNode!
    private var pauseOverlay: PauseOverlayNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!
    private var bricks: [BrickNode] = []

    private var levelComplete = false

    init(size: CGSize, levelIndex: Int, stateMachine: GameStateMachine) {
        precondition(Level.all.indices.contains(levelIndex), "levelIndex out of range")
        self.levelIndex = levelIndex
        self.level = Level.all[levelIndex]
        self.stateMachine = stateMachine
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        setupCamera()
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupWalls()
        setupUI()
        setupNodes()
    }

    private func setupCamera() {
        let cam = SKCameraNode()
        cam.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(cam)
        self.camera = cam
        gameCamera = cam
    }

    private func setupUI() {
        let title = SKLabelNode.makeTitle(level.name)
        let finalPosition = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        title.position = CGPoint(x: finalPosition.x, y: finalPosition.y - 60)
        title.alpha = 0
        let entry = SKAction.group([
            .fadeIn(withDuration: 0.35),
            .move(to: finalPosition, duration: 0.35)
        ])
        title.run(.sequence([entry, .wait(forDuration: 1.5), .fadeOut(withDuration: 0.5)]))
        addChild(title)

        hud = HUDNode(sceneSize: size, topSafeArea: view?.safeAreaInsets.top ?? 0)
        hud.update(lives: stateMachine.lives, score: stateMachine.score)
        gameCamera.addChild(hud)

        pauseOverlay = PauseOverlayNode(sceneSize: size)
        pauseOverlay.position = CGPoint(x: 0, y: 0)
        pauseOverlay.isHidden = true
        gameCamera.addChild(pauseOverlay)
    }

    private func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = restingBallPosition()
        addChild(ball)

        setupBricks(level: level)
    }

    private func setupWalls() {
        func wallNode(from: CGPoint, to: CGPoint) -> SKNode {
            let node = SKNode()
            let body = SKPhysicsBody(edgeFrom: from, to: to)
            body.restitution = 1
            body.friction = 0
            body.categoryBitMask = PhysicsCategory.wall
            node.physicsBody = body
            return node
        }

        addChild(wallNode(
            from: CGPoint(x: frame.minX, y: frame.maxY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        ))
        addChild(wallNode(
            from: CGPoint(x: frame.minX, y: frame.minY),
            to: CGPoint(x: frame.minX, y: frame.maxY)
        ))
        addChild(wallNode(
            from: CGPoint(x: frame.maxX, y: frame.minY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        ))
    }

    private func setupBricks(level: Level) {
        let columns = level.grid[0].count
        let spacing = Theme.Layout.brickSpacing
        let margin = Theme.Layout.brickSideMargin
        let size = brickSize(
            sceneWidth: frame.width, columns: columns, spacing: spacing, margin: margin
        )
        let gridOrigin = brickGridOrigin(
            sceneMinX: frame.minX, sceneMaxY: frame.maxY, margin: margin
        )

        for (rowIndex, row) in level.grid.enumerated() {
            for (colIndex, present) in row.enumerated() {
                guard present else { continue }
                let brick = BrickNode(size: size, row: rowIndex)
                brick.position = brickPosition(
                    column: colIndex, row: rowIndex,
                    size: size, spacing: spacing, gridOrigin: gridOrigin
                )
                addChild(brick)
                bricks.append(brick)
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // physicsWorld.speed handles physics; guard prevents state logic from running while paused.
        guard stateMachine.state != .paused else { return }
        if stateMachine.state == .waitingToLaunch {
            ball.physicsBody?.velocity = .zero
            ball.position = restingBallPosition()
        } else if stateMachine.state == .playing && ball.position.y < frame.minY {
            handleBallLoss()
        }

        if levelComplete {
            advanceLevel()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // Only the pause button toggles pause; taps elsewhere are suppressed while paused.
        if nodes(at: touch.location(in: self)).contains(where: { $0.name == "pauseButton" }) {
            if stateMachine.state == .playing {
                stateMachine.pause()
                applyPauseState()
                return
            } else if stateMachine.state == .paused {
                stateMachine.resume()
                applyPauseState()
                return
            }
        }
        guard stateMachine.state != .paused else { return }
        movePaddle(to: touches)
        if stateMachine.state == .waitingToLaunch {
            spawnLaunchRipple(at: ball.position)
            stateMachine.launch()
            ball.physicsBody?.velocity = Theme.Layout.ballLaunchVelocity
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.state != .paused else { return }
        movePaddle(to: touches)
    }

    private func applyPauseState() {
        let isPaused = stateMachine.state == .paused
        physicsWorld.speed = isPaused ? 0 : 1
        pauseOverlay.isHidden = !isPaused
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if let brick = (contact.bodyA.node as? BrickNode) ?? (contact.bodyB.node as? BrickNode),
           brick.physicsBody != nil {
            let brickColor = brick.color // capture before destroy animation alters colorBlendFactor
            bricks.removeAll { $0 === brick }
            stateMachine.addScore(Theme.Layout.brickPoints)
            hud.update(lives: stateMachine.lives, score: stateMachine.score)
            spawnScorePopup(at: contact.contactPoint, points: Theme.Layout.brickPoints)
            spawnSparks(at: contact.contactPoint, color: brickColor)
            brick.destroy { [weak self] in
                guard let self else { return }
                if bricks.isEmpty && !levelComplete {
                    levelComplete = true
                }
            }
        }

        let involvesPaddle = contact.bodyA.categoryBitMask == PhysicsCategory.paddle
            || contact.bodyB.categoryBitMask == PhysicsCategory.paddle
        let involvesBall = contact.bodyA.categoryBitMask == PhysicsCategory.ball
            || contact.bodyB.categoryBitMask == PhysicsCategory.ball
        if involvesPaddle && involvesBall {
            paddle.squash()
        }
    }

    private func movePaddle(to touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let x = clampedPaddleX(
            touchX: touch.location(in: self).x,
            sceneWidth: frame.width,
            halfPaddleWidth: paddle.size.width / 2
        )
        paddle.position.x = x
    }

    private func restingBallPosition() -> CGPoint {
        ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
    }

    private func advanceLevel() {
        let nextIndex = levelIndex + 1
        if nextIndex < Level.all.count {
            stateMachine.resetForNextLevel()
            present(GameScene(size: size, levelIndex: nextIndex, stateMachine: stateMachine))
        } else {
            present(GameSummaryScene(size: size, outcome: .victory, score: stateMachine.score))
        }
    }

    private func handleBallLoss() {
        shakeCamera()
        stateMachine.ballLost()
        hud.update(lives: stateMachine.lives, score: stateMachine.score)

        if stateMachine.state == .gameOver {
            present(GameSummaryScene(size: size, outcome: .gameOver, score: stateMachine.score))
        }
    }

    private func shakeCamera(duration: TimeInterval = 0.4, magnitude: CGFloat = 12) {
        let origin = CGPoint(x: frame.midX, y: frame.midY)
        let count = 6
        let step = duration / Double(count)
        var actions: [SKAction] = []
        for i in 0..<count {
            let sign: CGFloat = i % 2 == 0 ? 1 : -1
            let decay = magnitude * (1 - CGFloat(i) / CGFloat(count))
            actions.append(.move(
                to: CGPoint(x: origin.x + sign * decay, y: origin.y + sign * decay * 0.5),
                duration: step
            ))
        }
        actions.append(.move(to: origin, duration: step))
        gameCamera.run(.sequence(actions), withKey: "shake")
    }
}

// MARK: - Particle helpers

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
        let wait = SKAction.wait(forDuration: 0.6)
        let remove = SKAction.removeFromParent()
        emitter.run(.sequence([wait, remove]))
    }

    func spawnLaunchRipple(at position: CGPoint) {
        spawnRippleRing(at: position, delay: 0, scale: 4.0, alpha: 1.0, lineWidth: 2.0)
        spawnRippleRing(at: position, delay: 0.12, scale: 5.0, alpha: 0.6, lineWidth: 1.5)
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
        ring.alpha = alpha
        ring.zPosition = 3
        ring.position = position
        addChild(ring)
        ring.run(.sequence([
            .wait(forDuration: delay),
            .group([
                .scale(to: scale, duration: 0.5),
                .fadeOut(withDuration: 0.5)
            ]),
            .removeFromParent()
        ]))
    }
}
