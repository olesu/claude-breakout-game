import SpriteKit

final class PaddleNode: SKSpriteNode {
    private static let widePaddleKey = "widePaddle"
    private static let squashKey = "squash"

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
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.powerUp
        physicsBody = body
    }

    func activateWidePaddle() {
        removeAction(forKey: Self.widePaddleKey)
        run(
            .scaleX(to: Theme.Layout.paddleWidthMultiplier, duration: 0.25),
            withKey: Self.widePaddleKey
        )
    }

    func deactivateWidePaddle() {
        removeAction(forKey: Self.widePaddleKey)
        run(.scaleX(to: 1.0, duration: 0.25), withKey: Self.widePaddleKey)
    }

    func squash() {
        removeAction(forKey: Self.squashKey)
        run(.sequence([
            .scaleY(to: 0.45, duration: 0.06),
            .scaleY(to: 1.10, duration: 0.08),
            .scaleY(to: 1.00, duration: 0.06)
        ]), withKey: Self.squashKey)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
