import SpriteKit

final class PowerUpNode: SKNode {
    let type: PowerUpType

    init(type: PowerUpType) {
        self.type = type
        super.init()

        let size = Theme.Layout.powerUpSize
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.powerUp
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.paddle
        physicsBody = body

        let bloom = SKEffectNode()
        if let filter = CIFilter(name: "CIBloom") {
            filter.setValue(6.0, forKey: "inputRadius")
            filter.setValue(0.9, forKey: "inputIntensity")
            bloom.filter = filter
            bloom.shouldRasterize = true
        }

        let rect = CGRect(
            x: -size.width / 2, y: -size.height / 2,
            width: size.width, height: size.height
        )
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: size.height / 2, cornerHeight: size.height / 2)
        let shape = SKShapeNode(path: path)
        shape.fillColor = .clear
        shape.strokeColor = type.nodeColor
        shape.lineWidth = 1.5

        let label = SKLabelNode(fontNamed: Theme.Font.bold)
        label.text = type.label
        label.fontSize = 10
        label.fontColor = type.nodeColor
        label.verticalAlignmentMode = .center

        bloom.addChild(shape)
        bloom.addChild(label)
        addChild(bloom)

        run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.5, duration: 0.4),
            .fadeAlpha(to: 1.0, duration: 0.4)
        ])))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

private extension PowerUpType {
    var nodeColor: PlatformColor {
        switch self {
        case .powerBall: return Theme.Color.powerUp
        case .widePaddle: return Theme.Color.widePaddle
        case .slowBall: return Theme.Color.slowBall
        case .extraLife: return Theme.Color.extraLife
        }
    }
}
