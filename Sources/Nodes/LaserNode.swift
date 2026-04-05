import SpriteKit

final class LaserNode: SKShapeNode {
    override init() {
        super.init()
        let size = Theme.Layout.laserSize
        let rect = CGRect(
            origin: CGPoint(x: -size.width / 2, y: -size.height / 2),
            size: size
        )
        path = CGPath(rect: rect, transform: nil)
        fillColor = Theme.Color.laser
        strokeColor = .clear
        glowWidth = 4

        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.linearDamping = 0
        body.categoryBitMask    = PhysicsCategory.laser
        body.collisionBitMask   = 0
        body.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.wall
        physicsBody = body
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
