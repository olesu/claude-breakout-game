import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let levelIndex: Int
    private let level: Level
    private let stateMachine: GameStateMachine
    private var hud: HUDNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!
    private var bricks: [BrickNode] = []

    private var levelComplete = false

    init(size: CGSize, levelIndex: Int, stateMachine: GameStateMachine) {
        self.levelIndex = levelIndex
        self.level = Level.all[levelIndex]
        self.stateMachine = stateMachine
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupWalls()
        setupUI()
        setupNodes()
    }

    private func setupUI() {
        let title = SKLabelNode.makeTitle(level.name)
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        title.run(.sequence([.wait(forDuration: 2), .fadeOut(withDuration: 0.5)]))
        addChild(title)

        hud = HUDNode(sceneFrame: frame, topSafeArea: view?.safeAreaInsets.top ?? 0)
        hud.update(lives: stateMachine.lives, score: stateMachine.score)
        addChild(hud)
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
                let brick = BrickNode(size: size)
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
        if stateMachine.state == .waitingToLaunch {
            ball.physicsBody?.velocity = .zero
            ball.position = restingBallPosition()
        } else if stateMachine.state == .playing && ball.position.y < frame.minY {
            handleBallLoss()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        movePaddle(to: touches)
        if stateMachine.state == .waitingToLaunch {
            stateMachine.launch()
            ball.physicsBody?.velocity = Theme.Layout.ballLaunchVelocity
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        movePaddle(to: touches)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let brick = (contact.bodyA.node as? BrickNode) ?? (contact.bodyB.node as? BrickNode)
        guard let brick else { return }
        brick.removeFromParent()
        bricks.removeAll { $0 === brick }
        stateMachine.addScore(Theme.Layout.brickPoints)
        hud.update(lives: stateMachine.lives, score: stateMachine.score)

        if bricks.isEmpty && !levelComplete {
            levelComplete = true
            let nextIndex = levelIndex + 1
            if nextIndex < Level.all.count {
                stateMachine.resetForNextLevel()
                present(GameScene(size: size, levelIndex: nextIndex, stateMachine: stateMachine))
            } else {
                present(GameSummaryScene(size: size, outcome: .victory, score: stateMachine.score))
            }
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

    private func handleBallLoss() {
        stateMachine.ballLost()
        hud.update(lives: stateMachine.lives, score: stateMachine.score)

        if stateMachine.state == .gameOver {
            present(GameSummaryScene(size: size, outcome: .gameOver, score: stateMachine.score))
        }
    }
}
