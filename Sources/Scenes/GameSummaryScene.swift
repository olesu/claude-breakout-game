import SpriteKit
#if os(macOS)
import AppKit
import CoreGraphics
#endif

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
        #if os(macOS)
        (NSApp.delegate as? AppDelegate)?.showCursor()
        let displayBounds = CGDisplayBounds(CGMainDisplayID())
        CGWarpMouseCursorPosition(CGPoint(x: displayBounds.midX, y: displayBounds.midY))
        #endif
        backgroundColor = .black
        let starfield = AmbientStarfieldNode(sceneSize: size)
        starfield.position = CGPoint(x: frame.midX, y: frame.maxY)
        addChild(starfield)

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

        #if os(iOS)
        let promptText = "Tap to Play Again"
        #else
        let promptText = "Click to Play Again"
        #endif
        let prompt = SKLabelNode.makeBody(promptText)
        prompt.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.promptOffsetY)
        addChild(prompt)
        let pulse = SKAction.sequence([
            .fadeAlpha(to: 0.3, duration: 0.8),
            .fadeAlpha(to: 1.0, duration: 0.8)
        ])
        prompt.run(.repeatForever(pulse))

        if outcome == .victory {
            let burst = VictoryBurstNode(sceneSize: size)
            burst.position = CGPoint(x: frame.midX, y: frame.midY - 40)
            addChild(burst)
        }
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        present(SplashScene(size: size))
    }
    #endif

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        present(SplashScene(size: size))
    }
    #endif
}
