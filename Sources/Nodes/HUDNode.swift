import SpriteKit

final class HUDNode: SKNode {
    private let livesLabel: SKLabelNode
    private let scoreLabel: SKLabelNode

    init(sceneFrame: CGRect) {
        livesLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        scoreLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        super.init()
        livesLabel.position = CGPoint(x: sceneFrame.midX, y: sceneFrame.midY)
        scoreLabel.position = CGPoint(
            x: sceneFrame.midX, y: sceneFrame.maxY - Theme.Layout.scoreOffsetY
        )
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
