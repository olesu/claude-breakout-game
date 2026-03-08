import SpriteKit

final class GameScene: SKScene {
    private let stateMachine = GameStateMachine()
    private let ballLossInterval: TimeInterval = 1.0
    private var livesLabel: SKLabelNode!

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

        stateMachine.launch()
        scheduleBallLoss()
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

        switch stateMachine.state {
        case .waitingToLaunch:
            stateMachine.launch()
            scheduleBallLoss()
        case .gameOver:
            let scene = GameSummaryScene(size: size)
            scene.scaleMode = scaleMode
            view?.presentScene(scene, transition: .fade(withDuration: 0.4))
        case .playing:
            break
        }
    }
}
