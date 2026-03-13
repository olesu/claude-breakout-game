import SpriteKit

enum GameOutcome { case victory, gameOver }

final class GameSummaryScene: SKScene {
    private let outcome: GameOutcome
    private let score: Int

    init(size: CGSize, outcome: GameOutcome, score: Int) {
        self.outcome = outcome
        self.score = score
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let titleText = outcome == .victory ? "YOU WIN" : "GAME OVER"
        let titleColor = outcome == .victory ? Theme.Color.accent : Theme.Color.danger
        let title = SKLabelNode.makeTitle(titleText, color: titleColor)
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        addChild(title)

        let scoreLabel = SKLabelNode.makeBody(scoreText(score), color: Theme.Color.primary)
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(scoreLabel)

        let store = HighScoreStore()
        let isNewRecord = store.submitScore(score)
        let highScoreColor = isNewRecord ? Theme.Color.accent : Theme.Color.secondary
        let highScoreLabel = SKLabelNode.makeBody(
            highScoreText(store.highScore),
            color: highScoreColor
        )
        highScoreLabel.position = CGPoint(
            x: frame.midX,
            y: frame.midY + Theme.Layout.highScoreOffsetY
        )
        addChild(highScoreLabel)

        let prompt = SKLabelNode.makeBody("Tap to Play Again")
        prompt.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.promptOffsetY)
        addChild(prompt)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        present(SplashScene(size: size))
    }
}
