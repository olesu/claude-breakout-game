import CoreImage
import SpriteKit

final class BallNode: SKNode {
    private(set) var isPowerBall: Bool = false
    private let shape: SKShapeNode
    private let bloom: SKEffectNode

    init(radius: CGFloat) {
        let bloomNode = SKEffectNode()
        if let filter = CIFilter(name: "CIBloom") {
            filter.setValue(8.0, forKey: "inputRadius")
            filter.setValue(1.0, forKey: "inputIntensity")
            bloomNode.filter = filter
            bloomNode.shouldRasterize = true
        }

        let diameter = radius * 2
        let shapeNode = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(x: -radius, y: -radius, width: diameter, height: diameter),
                transform: nil
            )
        )
        shapeNode.fillColor = Theme.Color.primary
        shapeNode.strokeColor = .clear

        bloom = bloomNode
        shape = shapeNode
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

        bloomNode.addChild(shapeNode)
        addChild(bloomNode)
    }

    func activatePowerBall() {
        isPowerBall = true
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.paddle
        shape.fillColor = Theme.Color.powerUp
        (bloom.filter as? CIFilter)?.setValue(16.0, forKey: "inputRadius")
        bloom.shouldRasterize = true
    }

    func deactivatePowerBall() {
        isPowerBall = false
        physicsBody?.collisionBitMask =
            PhysicsCategory.wall | PhysicsCategory.paddle | PhysicsCategory.brick
        shape.fillColor = Theme.Color.primary
        (bloom.filter as? CIFilter)?.setValue(8.0, forKey: "inputRadius")
        bloom.shouldRasterize = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
