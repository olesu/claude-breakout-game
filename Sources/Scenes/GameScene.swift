import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let stateMachine = GameStateMachine()
    private var livesLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!
    private var bricks: [BrickNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupWalls()
        setupUI()
        setupNodes()
    }

    private func setupUI() {
        let title = SKLabelNode.makeTitle("GAME SCENE")
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        addChild(title)

        livesLabel = SKLabelNode.makeBody(livesText, color: Theme.Color.accent)
        livesLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(livesLabel)

        scoreLabel = SKLabelNode.makeBody(scoreText, color: Theme.Color.accent)
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - Theme.Layout.scoreOffsetY)
        addChild(scoreLabel)
    }

    private func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = restingBallPosition()
        addChild(ball)

        setupBricks(level: .one)
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
        let size = brickSize(sceneWidth: frame.width, columns: columns, spacing: spacing, margin: margin)
        let gridOrigin = CGPoint(x: frame.minX + margin, y: frame.maxY - Theme.Layout.brickTopMargin)

        for (rowIndex, row) in level.grid.enumerated() {
            for (colIndex, present) in row.enumerated() {
                guard present else { continue }
                let brick = BrickNode(size: size)
                brick.position = brickPosition(column: colIndex, row: rowIndex, size: size, spacing: spacing, gridOrigin: gridOrigin)
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
        guard let brick = (contact.bodyA.node as? BrickNode) ?? (contact.bodyB.node as? BrickNode) else { return }
        brick.removeFromParent()
        bricks.removeAll { $0 === brick }
        stateMachine.addScore(Theme.Layout.brickPoints)
        scoreLabel.text = scoreText

        if bricks.isEmpty {
            present(GameSummaryScene(size: size, outcome: .victory))
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

    private var livesText: String { "Lives: \(stateMachine.lives)" }
    private var scoreText: String { "Score: \(stateMachine.score)" }

    private func handleBallLoss() {
        stateMachine.ballLost()
        livesLabel.text = livesText

        if stateMachine.state == .gameOver {
            present(GameSummaryScene(size: size, outcome: .gameOver))
        }
    }
}
