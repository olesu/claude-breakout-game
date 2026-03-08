import SpriteKit

final class GameScene: SKScene {
    private let stateMachine = GameStateMachine()
    private var livesLabel: SKLabelNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero
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
    }

    private func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = restingBallPosition()
        addChild(ball)
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

    private func handleBallLoss() {
        stateMachine.ballLost()
        livesLabel.text = livesText

        if stateMachine.state == .gameOver {
            present(GameSummaryScene(size: size))
        }
    }
}
