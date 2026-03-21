import CoreImage
import SpriteKit

final class BallNode: SKNode {
    private(set) var isPowerBall: Bool = false
    private let shape: SKShapeNode
    private let bloom: SKEffectNode
    private let trail: BallTrailNode
    private var speedBeforeSlowBall: CGFloat?

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
        trail = BallTrailNode()
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
        addChild(trail)
    }

    /// Wire the trail's targetNode so particles stay in scene coordinates as the ball moves.
    /// Call this once after the ball is added to the scene.
    func attachTrail(to scene: SKScene) {
        trail.targetNode = scene
    }

    func activatePowerBall() {
        isPowerBall = true
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.paddle
        shape.fillColor = Theme.Color.powerUp
        bloom.filter?.setValue(16.0, forKey: "inputRadius")
        bloom.shouldRasterize = true
        trail.activate(color: Theme.Color.powerUp)
    }

    func activateSlowBall() {
        guard let body = physicsBody else { return }
        let speed = hypot(body.velocity.dx, body.velocity.dy)
        speedBeforeSlowBall = speed
        let f = Theme.Layout.slowBallFactor
        body.velocity = CGVector(dx: body.velocity.dx * f, dy: body.velocity.dy * f)
        shape.fillColor = Theme.Color.slowBall
        trail.activate(color: Theme.Color.slowBall)
    }

    func deactivateSlowBall() {
        guard let body = physicsBody, let savedSpeed = speedBeforeSlowBall else { return }
        let currentSpeed = hypot(body.velocity.dx, body.velocity.dy)
        if currentSpeed > 0 {
            let scale = savedSpeed / currentSpeed
            body.velocity = CGVector(dx: body.velocity.dx * scale, dy: body.velocity.dy * scale)
        }
        speedBeforeSlowBall = nil
        shape.fillColor = isPowerBall ? Theme.Color.powerUp : Theme.Color.primary
        trail.activate(color: isPowerBall ? Theme.Color.powerUp : Theme.Color.primary)
    }

    func deactivatePowerBall() {
        isPowerBall = false
        physicsBody?.collisionBitMask =
            PhysicsCategory.wall | PhysicsCategory.paddle | PhysicsCategory.brick
        shape.fillColor = Theme.Color.primary
        bloom.filter?.setValue(8.0, forKey: "inputRadius")
        bloom.shouldRasterize = true
        trail.deactivate()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
