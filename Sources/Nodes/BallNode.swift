import CoreImage
import SpriteKit

final class BallNode: SKNode {
    init(radius: CGFloat) {
        super.init()

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

        let bloom = SKEffectNode()
        if let filter = CIFilter(name: "CIBloom") {
            // CIBloom keys: inputRadius (pt), inputIntensity (0–1)
            filter.setValue(8.0, forKey: "inputRadius")
            filter.setValue(1.0, forKey: "inputIntensity")
            bloom.filter = filter
            bloom.shouldRasterize = true
        }

        let diameter = radius * 2
        let shape = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(x: -radius, y: -radius, width: diameter, height: diameter),
                transform: nil
            )
        )
        shape.fillColor = Theme.Color.primary
        shape.strokeColor = .clear

        bloom.addChild(shape)
        addChild(bloom)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
