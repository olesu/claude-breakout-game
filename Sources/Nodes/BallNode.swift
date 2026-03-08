import SpriteKit

final class BallNode: SKShapeNode {
    init(radius: CGFloat) {
        super.init()
        let diameter = radius * 2
        path = CGPath(
            ellipseIn: CGRect(x: -radius, y: -radius, width: diameter, height: diameter),
            transform: nil
        )
        fillColor = Theme.Color.primary
        strokeColor = .clear

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.restitution = 1
        body.friction = 0
        body.linearDamping = 0
        body.angularDamping = 0
        body.isDynamic = true
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.ball
        body.collisionBitMask =
            PhysicsCategory.wall | PhysicsCategory.paddle | PhysicsCategory.brick
        physicsBody = body
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
