import SpriteKit

final class PaddleNode: SKSpriteNode {
    init(sceneWidth: CGFloat) {
        let width = sceneWidth * Theme.Layout.paddleWidthRatio
        let height = Theme.Layout.paddleHeight
        let size = CGSize(width: width, height: height)
        super.init(texture: nil, color: Theme.Color.primary, size: size)

        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.paddle
        physicsBody = body
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
