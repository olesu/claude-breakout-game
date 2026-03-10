import SpriteKit

final class HUDNode: SKNode {
    private let livesLabel: SKLabelNode
    private let scoreLabel: SKLabelNode

    init(sceneFrame: CGRect, topSafeArea: CGFloat) {
        livesLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        scoreLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        super.init()
        let hudY = sceneFrame.maxY - topSafeArea - Theme.Layout.hudTopPadding
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: sceneFrame.minX + Theme.Layout.hudSideMargin, y: hudY)
        scoreLabel.position = CGPoint(x: sceneFrame.midX, y: hudY)
        addChild(livesLabel)
        addChild(scoreLabel)
    }

    func update(lives: Int, score: Int) {
        livesLabel.text = "Lives: \(lives)"
        scoreLabel.text = "Score: \(score)"
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
