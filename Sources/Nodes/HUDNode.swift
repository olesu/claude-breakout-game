import SpriteKit

final class HUDNode: SKNode {
    private let livesLabel: SKLabelNode
    private let scoreLabel: SKLabelNode
    private let pauseButton: SKLabelNode

    init(sceneFrame: CGRect, topSafeArea: CGFloat) {
        livesLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        scoreLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        pauseButton = SKLabelNode.makeBody(Theme.Symbol.pause, color: Theme.Color.primary)
        super.init()
        let hudY = sceneFrame.maxY - topSafeArea - Theme.Layout.hudTopPadding
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: sceneFrame.minX + Theme.Layout.hudSideMargin, y: hudY)
        scoreLabel.position = CGPoint(x: sceneFrame.midX, y: hudY)
        pauseButton.horizontalAlignmentMode = .right
        pauseButton.position = CGPoint(x: sceneFrame.maxX - Theme.Layout.hudSideMargin, y: hudY)
        pauseButton.name = "pauseButton"
        addChild(livesLabel)
        addChild(scoreLabel)
        addChild(pauseButton)
    }

    func update(lives: Int, score: Int) {
        livesLabel.text = livesText(lives)
        scoreLabel.text = scoreText(score)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
