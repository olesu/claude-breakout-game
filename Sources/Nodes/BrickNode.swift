import SpriteKit

final class BrickNode: SKSpriteNode {
    let row: Int
    let col: Int
    private var brickState: BrickState
    private let initialHits: Int
    private var hitHandled = false

    var currentCell: BrickCell { brickState.asCell }

    init(size: CGSize, row: Int, col: Int, cell: BrickCell) {
        self.row = row
        self.col = col
        self.brickState = cell.initialState
        switch self.brickState {
        case .intact(let n): self.initialHits = n
        case .destroyed: self.initialHits = 1
        }
        let rowColor = Theme.Color.brickColors[row % Theme.Color.brickColors.count]
        super.init(texture: nil, color: rowColor, size: size)
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.brick
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body

        if case .multiHit(let n) = cell {
            let label = SKLabelNode(fontNamed: Theme.Font.bold)
            label.name = "hitLabel"
            label.fontSize = 9
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.text = "x\(n)"
            addChild(label)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    func hit() -> BrickState {
        guard !hitHandled else { return brickState }
        hitHandled = true
        brickState = transition(brickState, on: .hit)
        run(.sequence([.wait(forDuration: 1.0 / 60.0), .run { [weak self] in
            self?.hitHandled = false
        }]))
        return brickState
    }

    func applyDamage(remainingHits: Int) {
        if let label = childNode(withName: "hitLabel") as? SKLabelNode {
            label.text = "x\(remainingHits)"
        }
        let blend = 1.0 - Double(remainingHits) / Double(initialHits)
        let wobble = SKAction.sequence([
            .rotate(byAngle: 0.08, duration: 0.04),
            .rotate(byAngle: -0.16, duration: 0.08),
            .rotate(byAngle: 0.08, duration: 0.04)
        ])
        let tint = SKAction.colorize(with: .white, colorBlendFactor: blend, duration: 0.10)
        run(.group([wobble, tint]))
    }

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
