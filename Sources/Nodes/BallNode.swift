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
        bloomNode.addChild(BallNode.makeShadeNode(radius: radius))
        bloomNode.addChild(BallNode.makeSpecularHighlight(radius: radius))

        let shadowNode = BallNode.makeShadowNode(radius: radius)
        addChild(shadowNode)
        addChild(bloomNode)
        addChild(trail)
    }

    private static func makeSpecularHighlight(radius: CGFloat) -> SKShapeNode {
        let node = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(
                    x: -radius * 0.35,
                    y: radius * 0.22,
                    width: radius * 0.35,
                    height: radius * 0.25
                ),
                transform: nil
            )
        )
        node.fillColor = .white
        node.strokeColor = .clear
        node.alpha = 0.55
        node.isUserInteractionEnabled = false
        return node
    }

    private static func makeShadeNode(radius: CGFloat) -> SKShapeNode {
        let node = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(
                    x: -radius * 0.3,
                    y: -radius * 0.8,
                    width: radius * 1.1,
                    height: radius * 1.1
                ),
                transform: nil
            )
        )
        node.fillColor = .black
        node.strokeColor = .clear
        node.alpha = 0.28
        node.isUserInteractionEnabled = false
        return node
    }

    private static func makeShadowNode(radius: CGFloat) -> SKEffectNode {
        let effectNode = SKEffectNode()
        if let blur = CIFilter(name: "CIGaussianBlur") {
            blur.setValue(4.0, forKey: "inputRadius")
            effectNode.filter = blur
            effectNode.shouldRasterize = true
        }
        let shadow = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(
                    x: -radius * 1.6,
                    y: -(radius * 0.5) - radius * 0.15,
                    width: radius * 3.2,
                    height: radius
                ),
                transform: nil
            )
        )
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.isUserInteractionEnabled = false
        effectNode.addChild(shadow)
        effectNode.alpha = 0.35
        effectNode.zPosition = -1
        effectNode.isUserInteractionEnabled = false
        return effectNode
    }

    /// Wire the trail's targetNode so particles stay in scene coordinates as the ball moves.
    /// Call this once after the ball is added to the scene.
    func attachTrail(to scene: SKScene) {
        trail.targetNode = scene
    }

    /// Sets the ball's initial velocity to begin a new serve.
    /// Call only after the ball has been added to the scene.
    func launch() {
        assert(physicsBody != nil, "BallNode.launch() called with no physics body")
        physicsBody!.velocity = Theme.Layout.ballLaunchVelocity // safe: set unconditionally in init
    }

    func activatePowerBall() {
        isPowerBall = true
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.paddle
        shape.fillColor = Theme.Color.powerUp
        bloom.filter?.setValue(16.0, forKey: "inputRadius")
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
        body.velocity = restoredVelocity(current: body.velocity, savedSpeed: savedSpeed)
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
        trail.deactivate()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
