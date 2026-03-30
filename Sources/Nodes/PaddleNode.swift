import CoreImage
import SpriteKit

final class PaddleNode: SKSpriteNode {
    private static let widePaddleKey = "widePaddle"
    private static let squashKey = "squash"

    // Glow overlay: a rounded-rect shape inside a bloom effect node.
    private let glowShape: SKShapeNode

    init(sceneWidth: CGFloat) {
        let width = sceneWidth * Theme.Layout.paddleWidthRatio
        let height = Theme.Layout.paddleHeight
        let size = CGSize(width: width, height: height)

        let bloomNode = SKEffectNode()
        if let filter = CIFilter(name: "CIBloom") {
            filter.setValue(10.0, forKey: "inputRadius")
            filter.setValue(0.8, forKey: "inputIntensity")
            bloomNode.filter = filter
            bloomNode.shouldRasterize = true
        }
        bloomNode.zPosition = 1

        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        let glowPath = CGPath(
            roundedRect: rect, cornerWidth: height / 2, cornerHeight: height / 2, transform: nil
        )
        let glowNode = SKShapeNode(path: glowPath)
        glowNode.fillColor = Theme.Color.primary
        glowNode.strokeColor = Theme.Color.primary
        glowNode.lineWidth = 2
        glowNode.alpha = 0.55

        glowShape = glowNode

        super.init(texture: nil, color: Theme.Color.primary, size: size)

        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.paddle
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.powerUp
        physicsBody = body

        bloomNode.addChild(glowNode)
        addChild(bloomNode)
        addChild(makeHighlightStrip(size: size))
    }

    func activateWidePaddle() {
        removeAction(forKey: Self.widePaddleKey)
        run(
            .scaleX(to: Theme.Layout.paddleWidthMultiplier, duration: 0.25),
            withKey: Self.widePaddleKey
        )
        setGlowColor(Theme.Color.widePaddle)
    }

    func deactivateWidePaddle() {
        removeAction(forKey: Self.widePaddleKey)
        run(.scaleX(to: 1.0, duration: 0.25), withKey: Self.widePaddleKey)
        setGlowColor(Theme.Color.primary)
    }

    func squash() {
        removeAction(forKey: Self.squashKey)
        run(.sequence([
            .scaleY(to: 0.45, duration: 0.06),
            .scaleY(to: 1.10, duration: 0.08),
            .scaleY(to: 1.00, duration: 0.06)
        ]), withKey: Self.squashKey)
    }

    private func makeHighlightStrip(size: CGSize) -> SKShapeNode {
        let stripHeight = size.height * 0.30
        let inset: CGFloat = 4
        let stripWidth = size.width - inset * 2
        let yCenter = size.height / 2 - stripHeight / 2
        let rect = CGRect(x: -stripWidth / 2, y: yCenter, width: stripWidth, height: stripHeight)
        let radius = stripHeight / 2
        let node = SKShapeNode(path: CGPath(
            roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil
        ))
        node.fillColor = .white
        node.strokeColor = .clear
        node.alpha = 0.18
        node.zPosition = 2
        return node
    }

    private func setGlowColor(_ tint: PlatformColor) {
        glowShape.fillColor = tint
        glowShape.strokeColor = tint
        color = tint
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
