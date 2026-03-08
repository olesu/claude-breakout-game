import SpriteKit

final class GameScene: SKScene {
    private let stateMachine = GameStateMachine()
    private let ballLossInterval: TimeInterval = 1.0
    private var livesLabel: SKLabelNode!
    private var paddle: PaddleNode!
    private var ball: BallNode!

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode(text: "GAME SCENE")
        title.fontName = Theme.Font.bold
        title.fontSize = Theme.FontSize.medium
        title.fontColor = Theme.Color.primary
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.paddleOffsetY)
        addChild(title)

        livesLabel = SKLabelNode.makeBody(livesText, color: Theme.Color.accent)
        livesLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(livesLabel)

        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = restingBallPosition()
        addChild(ball)

        scheduleBallLoss()
    }

    override func update(_ currentTime: TimeInterval) {
        ball.position = restingBallPosition()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        movePaddle(to: touches)
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

    private func scheduleBallLoss() {
        run(.sequence([
            .wait(forDuration: ballLossInterval),
            .run { [weak self] in self?.handleBallLoss() }
        ]))
    }

    private func handleBallLoss() {
        stateMachine.ballLost()
        livesLabel.text = livesText

        if stateMachine.state == .gameOver {
            present(GameSummaryScene(size: size))
        } else {
            stateMachine.launch()
            scheduleBallLoss()
        }
    }
}
