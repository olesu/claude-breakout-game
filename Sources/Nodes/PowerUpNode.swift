import SpriteKit

final class PowerUpNode: SKNode {
    let type: PowerUpType

    init(type: PowerUpType) {
        self.type = type
        super.init()

        let size = Theme.Layout.powerUpSize
        physicsBody = makePowerUpBody(size: size)

        let bloom = makePowerUpBloom()
        bloom.addChild(makePillShape(size: size, color: type.nodeColor))
        bloom.addChild(makePillHighlight(size: size))
        bloom.addChild(makeTypeLabel(type: type))
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
        case .multiBall: return Theme.Color.powerUp
        case .laser: return Theme.Color.laser
        }
    }
}

// MARK: - Private helpers

private func makePowerUpBody(size: CGSize) -> SKPhysicsBody {
    let body = SKPhysicsBody(rectangleOf: size)
    body.isDynamic = true
    body.affectedByGravity = false
    body.categoryBitMask = PhysicsCategory.powerUp
    body.collisionBitMask = 0
    body.contactTestBitMask = PhysicsCategory.paddle
    return body
}

private func makePowerUpBloom() -> SKEffectNode {
    let bloom = SKEffectNode()
    if let filter = CIFilter(name: "CIBloom") {
        filter.setValue(6.0, forKey: "inputRadius")
        filter.setValue(0.9, forKey: "inputIntensity")
        bloom.filter = filter
    }
    return bloom
}

private func makePillShape(size: CGSize, color: PlatformColor) -> SKShapeNode {
    let rect = CGRect(
        x: -size.width / 2, y: -size.height / 2,
        width: size.width, height: size.height
    )
    let path = CGMutablePath()
    path.addRoundedRect(in: rect, cornerWidth: size.height / 2, cornerHeight: size.height / 2)
    let shape = SKShapeNode(path: path)
    shape.fillColor = .clear
    shape.strokeColor = color
    shape.lineWidth = 1.5
    return shape
}

private func makePillHighlight(size: CGSize) -> SKShapeNode {
    let capRadius = size.height / 2
    let path = CGMutablePath()
    path.move(to: CGPoint(x: -(size.width / 2 - capRadius), y: size.height * 0.25))
    path.addLine(to: CGPoint(x: size.width / 2 - capRadius, y: size.height * 0.25))
    let highlight = SKShapeNode(path: path)
    highlight.strokeColor = .white
    highlight.lineWidth = 1
    highlight.alpha = 0.45
    highlight.zPosition = 1
    highlight.isUserInteractionEnabled = false
    return highlight
}

private func makeTypeLabel(type: PowerUpType) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: Theme.Font.bold)
    label.text = type.label
    label.fontSize = 10
    label.fontColor = type.nodeColor
    label.verticalAlignmentMode = .center
    label.zPosition = 2
    return label
}
