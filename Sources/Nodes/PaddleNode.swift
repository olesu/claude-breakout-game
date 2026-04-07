import CoreImage
import SpriteKit

// Visual rendering node; all layer factories belong on the type they serve.
// swiftlint:disable:next type_body_length
final class PaddleNode: SKSpriteNode {
    private static let widePaddleKey = "widePaddle"
    private static let squashKey = "squash"

    private let bodyLayer: SKShapeNode
    private let glowShape: SKShapeNode

    init(sceneWidth: CGFloat) {
        let width = sceneWidth * Theme.Layout.paddleWidthRatio
        let height = Theme.Layout.paddleHeight
        let size = CGSize(width: width, height: height)

        let bloomNode = PaddleNode.makeBloomNode(size: size)
        let glowNode = PaddleNode.makeGlowShape(size: size)
        bloomNode.addChild(glowNode)
        glowShape = glowNode

        let body = PaddleNode.makeBodyLayer(size: size)
        bodyLayer = body

        // Base sprite is transparent — all rendering is done via child shape layers.
        super.init(texture: nil, color: .clear, size: size)

        physicsBody = PaddleNode.makePhysicsBody(size: size)

        addChild(ShadowNode.makePaddleShadow(size: size))
        addChild(body)
        addChild(PaddleNode.makeBottomEdgeShade(size: size))
        addChild(bloomNode)
        addChild(PaddleNode.makeGrooveLayer(size: size))
        addChild(PaddleNode.makeSpecularLayer(size: size))
        addChild(PaddleNode.makeTopShineLayer(size: size))
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

    private func setGlowColor(_ tint: PlatformColor) {
        bodyLayer.fillColor = tint
        bodyLayer.strokeColor = tint
        glowShape.fillColor = tint
        glowShape.strokeColor = tint
    }

    // MARK: - Layer factories

    private static func makePhysicsBody(size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.paddle
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.powerUp
        return body
    }

    private static func makePillPath(size: CGSize) -> CGPath {
        let w = size.width
        let h = size.height
        let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
        return CGPath(
            roundedRect: rect,
            cornerWidth: h / 2,
            cornerHeight: h / 2,
            transform: nil
        )
    }

    private static func makeBloomNode(size: CGSize) -> SKEffectNode {
        let node = SKEffectNode()
        if let filter = CIFilter(name: "CIBloom") {
            filter.setValue(10.0, forKey: "inputRadius")
            filter.setValue(0.8, forKey: "inputIntensity")
            node.filter = filter
        }
        node.zPosition = 3
        return node
    }

    private static func makeGlowShape(size: CGSize) -> SKShapeNode {
        let node = SKShapeNode(path: makePillPath(size: size))
        node.fillColor = Theme.Color.primary
        node.strokeColor = Theme.Color.primary
        node.lineWidth = 2
        node.alpha = 0.55
        node.isUserInteractionEnabled = false
        return node
    }

    /// The main pill body — pill-shaped so corners are genuinely rounded.
    private static func makeBodyLayer(size: CGSize) -> SKShapeNode {
        let node = SKShapeNode(path: makePillPath(size: size))
        node.fillColor = Theme.Color.primary
        node.strokeColor = .clear
        node.zPosition = 0
        node.isUserInteractionEnabled = false
        return node
    }

    /// Pill shifted downward so only its top arc is visible inside the body pill,
    /// creating a curved dark bottom edge that makes the surface read as cylindrical.
    private static func makeBottomEdgeShade(size: CGSize) -> SKShapeNode {
        let w = size.width
        let h = size.height
        let shift = h * 0.40
        let rect = CGRect(x: -w / 2, y: -h / 2 - shift, width: w, height: h)
        let path = CGPath(
            roundedRect: rect,
            cornerWidth: h / 2,
            cornerHeight: h / 2,
            transform: nil
        )
        let node = SKShapeNode(path: path)
        node.fillColor = .black
        node.strokeColor = .clear
        node.alpha = 0.60
        node.zPosition = 1
        node.isUserInteractionEnabled = false
        return node
    }

    /// Thin centred stripe — the contrasting dark chrome groove.
    private static func makeGrooveLayer(size: CGSize) -> SKShapeNode {
        let inset: CGFloat = 6
        let gw = size.width - inset * 2
        let gh = max(2, size.height * 0.14)
        let path = CGPath(
            roundedRect: CGRect(x: -gw / 2, y: -gh / 2, width: gw, height: gh),
            cornerWidth: gh / 2,
            cornerHeight: gh / 2,
            transform: nil
        )
        let node = SKShapeNode(path: path)
        node.fillColor = .black
        node.strokeColor = .clear
        node.alpha = 0.70
        node.zPosition = 4
        node.isUserInteractionEnabled = false
        return node
    }

    /// Top strip specular — bright highlight on the upper face of the cylinder.
    private static func makeSpecularLayer(size: CGSize) -> SKShapeNode {
        let inset: CGFloat = 4
        let sw = size.width - inset * 2
        let sh = size.height * 0.36
        let yOrigin = size.height / 2 - sh
        let path = CGPath(
            roundedRect: CGRect(x: -sw / 2, y: yOrigin, width: sw, height: sh),
            cornerWidth: sh / 2,
            cornerHeight: sh / 2,
            transform: nil
        )
        let node = SKShapeNode(path: path)
        node.fillColor = .white
        node.strokeColor = .clear
        node.alpha = 0.70
        node.zPosition = 5
        node.isUserInteractionEnabled = false
        return node
    }

    /// Upper-left elliptical hot-spot — specular point that makes the surface read as curved.
    private static func makeTopShineLayer(size: CGSize) -> SKShapeNode {
        let w = size.width
        let h = size.height
        let node = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(
                    x: -(w * 0.3),
                    y: h * 0.15,
                    width: w * 0.28,
                    height: h * 0.30
                ),
                transform: nil
            )
        )
        node.fillColor = .white
        node.strokeColor = .clear
        node.alpha = 0.45
        node.zPosition = 6
        node.isUserInteractionEnabled = false
        return node
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
