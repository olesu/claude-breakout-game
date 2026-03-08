import SpriteKit

final class GameScene: SKScene {
    private let stateMachine = GameStateMachine()
    private let ballLossInterval: TimeInterval = 1.0
    private var livesLabel: SKLabelNode!
    private var paddle: PaddleNode!

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode(text: "GAME SCENE")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        addChild(title)

        livesLabel = SKLabelNode(text: livesText)
        livesLabel.fontName = "AvenirNext-Regular"
        livesLabel.fontSize = 22
        livesLabel.fontColor = .yellow
        livesLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(livesLabel)

        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 60)
        addChild(paddle)

        stateMachine.launch()
        scheduleBallLoss()
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
