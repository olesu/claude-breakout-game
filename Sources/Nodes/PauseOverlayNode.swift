import SpriteKit

final class PauseOverlayNode: SKNode {
    init(sceneSize: CGSize) {
        super.init()

        let backdrop = SKShapeNode(rectOf: sceneSize)
        backdrop.fillColor = .black
        backdrop.strokeColor = .clear
        backdrop.alpha = 0.6
        backdrop.zPosition = 10
        addChild(backdrop)

        let title = SKLabelNode.makeTitle("PAUSED")
        title.position = CGPoint(x: 0, y: Theme.Layout.titleOffsetY)
        title.zPosition = 11
        addChild(title)

        let prompt = SKLabelNode.makeBody("Tap \(Theme.Symbol.pause) to Resume")
        prompt.zPosition = 11
        addChild(prompt)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
