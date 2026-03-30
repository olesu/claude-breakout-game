import SpriteKit

final class BrickNode: SKSpriteNode {
    let row: Int
    let col: Int
    let isIndestructible: Bool
    private var brickState: BrickState
    private let initialHits: Int
    private var hitHandled = false

    var currentCell: BrickCell { isIndestructible ? .indestructible : brickState.asCell }

    init(size: CGSize, row: Int, col: Int, cell: BrickCell) {
        self.row = row
        self.col = col
        self.isIndestructible = (cell == .indestructible)
        self.brickState = cell.initialState
        switch self.brickState {
        case .intact(let n): self.initialHits = n
        case .destroyed: self.initialHits = 1
        }
        let rowColor = isIndestructible
            ? Theme.Color.indestructible
            : Theme.Color.brickColors[row % Theme.Color.brickColors.count]
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

        if isIndestructible {
            addChild(makeHatchNode(size: size))

            let border = SKShapeNode(rectOf: size)
            border.fillColor = .clear
            border.strokeColor = Theme.Color.indestructibleBorder
            border.lineWidth = 1.5
            border.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.3, duration: 0.8),
                .fadeAlpha(to: 1.0, duration: 0.8)
            ])))
            addChild(border)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    func hit() -> BrickState {
        guard !hitHandled else { return brickState }
        hitHandled = true
        run(.sequence([.wait(forDuration: 1.0 / 60.0), .run { [weak self] in
            self?.hitHandled = false
        }]))
        if isIndestructible {
            deflect()
            return brickState
        }
        brickState = transition(brickState, on: .hit)
        return brickState
    }

    func applyDamage(remainingHits: Int) {
        guard !isIndestructible else { return }
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

// MARK: - Private helpers

private extension BrickNode {
    func deflect() {
        let flash = SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.04)
        let recover = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12)
        run(.sequence([flash, recover]))
    }
}

private func makeHatchNode(size: CGSize) -> SKShapeNode {
    let path = CGMutablePath()
    let step: CGFloat = size.width / 3
    let halfW = size.width / 2
    let halfH = size.height / 2
    for idx in 0...3 {
        let offset = CGFloat(idx) * step - halfW
        path.move(to: CGPoint(x: offset, y: halfH))
        path.addLine(to: CGPoint(x: offset + size.height, y: -halfH))
    }
    let node = SKShapeNode(path: path)
    node.strokeColor = PlatformColor(white: 1.0, alpha: 0.25)
    node.lineWidth = 1
    return node
}
