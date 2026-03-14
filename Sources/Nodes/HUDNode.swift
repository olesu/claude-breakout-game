import SpriteKit

final class HUDNode: SKNode {
    private let livesLabel: SKLabelNode
    private let scoreLabel: SKLabelNode
    private let pauseButton: SKLabelNode
    private var lastScore: Int = 0

    init(sceneSize: CGSize, topSafeArea: CGFloat) {
        livesLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        scoreLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        pauseButton = SKLabelNode.makeBody(Theme.Symbol.pause, color: Theme.Color.primary)
        super.init()
        let hudY = sceneSize.height / 2 - topSafeArea - Theme.Layout.hudTopPadding
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: -sceneSize.width / 2 + Theme.Layout.hudSideMargin, y: hudY)
        scoreLabel.position = CGPoint(x: 0, y: hudY)
        pauseButton.horizontalAlignmentMode = .right
        pauseButton.position = CGPoint(x: sceneSize.width / 2 - Theme.Layout.hudSideMargin, y: hudY)
        pauseButton.name = "pauseButton"
        addChild(livesLabel)
        addChild(scoreLabel)
        addChild(pauseButton)
    }

    func update(lives: Int, score: Int) {
        livesLabel.text = livesText(lives)
        if score != lastScore {
            lastScore = score
            scoreLabel.text = scoreText(score)
            scoreLabel.removeAction(forKey: "scorePop")
            let pop = SKAction.sequence([
                .scale(to: 1.3, duration: 0.07),
                .scale(to: 1.0, duration: 0.10)
            ])
            scoreLabel.run(pop, withKey: "scorePop")
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
