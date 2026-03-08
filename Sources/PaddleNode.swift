import SpriteKit

final class PaddleNode: SKSpriteNode {
    init(sceneWidth: CGFloat) {
        let width = sceneWidth * Theme.Layout.paddleWidthRatio
        let height = Theme.Layout.paddleHeight
        super.init(texture: nil, color: Theme.Color.primary, size: CGSize(width: width, height: height))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
