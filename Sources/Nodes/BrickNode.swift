import SpriteKit

final class BrickNode: SKSpriteNode {
    init(size: CGSize, row: Int) {
        let rowColor = Theme.Color.brickColors[row % Theme.Color.brickColors.count]
        super.init(texture: nil, color: rowColor, size: size)
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.brick
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    func destroy(completion: @escaping () -> Void) {
        physicsBody = nil
        let flash = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.05)
        let colorBack = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.10)
        let scaleOut = SKAction.scale(to: 0, duration: 0.10)
        let fadeOut = SKAction.fadeOut(withDuration: 0.10)
        let firstPhase = SKAction.group([flash, scaleUp])
        let secondPhase = SKAction.group([colorBack, scaleOut, fadeOut])
        let remove = SKAction.removeFromParent()
        let done = SKAction.run(completion)
        run(.sequence([firstPhase, secondPhase, done, remove]))
    }
}
