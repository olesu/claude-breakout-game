import SpriteKit

final class BrickNode: SKSpriteNode {
    let row: Int
    let col: Int
    let isIndestructible: Bool
    let isBonus: Bool
    private var brickState: BrickState
    private let initialHits: Int
    private var hitHandled = false

    private let isArmored: Bool

    var currentCell: BrickCell {
        if isIndestructible { return .indestructible }
        // Only report .bonus while intact; destroyed falls through to .empty via brickState.asCell
        if isBonus, case .intact = brickState { return .bonus }
        return brickState.asCell
    }

    init(size: CGSize, row: Int, col: Int, cell: BrickCell) {
        self.row = row
        self.col = col
        self.isIndestructible = (cell == .indestructible)
        self.isBonus = (cell == .bonus)
        self.brickState = cell.initialState
        switch self.brickState {
        case .intact(let n): self.initialHits = n
        case .destroyed: self.initialHits = 1
        }
        if case .multiHit = cell { self.isArmored = true } else { self.isArmored = false }
        let rowColor: PlatformColor
        if isIndestructible {
            rowColor = Theme.Color.indestructible
        } else if self.isArmored {
            rowColor = Theme.Color.armored
        } else {
            rowColor = Theme.Color.brickColors[row % Theme.Color.brickColors.count]
        }
        super.init(texture: nil, color: rowColor, size: size)
        addChild(ShadowNode.makeBrickShadow(size: size, color: rowColor))
        physicsBody = BrickNode.makeBrickPhysicsBody(size: size)

        if case .multiHit(let n) = cell {
            // Secondary label in bottom-right corner — crack overlay is the primary visual
            let label = SKLabelNode(fontNamed: Theme.Font.bold)
            label.name = "hitLabel"
            label.fontSize = 7
            label.fontColor = PlatformColor(white: 0.9, alpha: 0.7)
            label.verticalAlignmentMode = .bottom
            label.horizontalAlignmentMode = .right
            label.position = CGPoint(x: size.width / 2 - 2, y: -size.height / 2 + 1)
            label.text = "x\(n)"
            addChild(label)
        }

        if isIndestructible {
            addChild(makeHatchNode(size: size))
            addChild(makeIndestructibleBorderNode(size: size))
        }
        if isBonus { makeBonusOverlayNodes(size: size).forEach(addChild) }
        addBevelOverlays(size: size)
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

        if isArmored {
            addCrackOverlay(hitsRemaining: remainingHits, size: size)
            spawnDebris()
        }
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

// MARK: - Armored brick crack overlays

private extension BrickNode {

    func addCrackOverlay(hitsRemaining: Int, size: CGSize) {
        childNode(withName: "crackOverlay")?.removeFromParent()
        guard hitsRemaining < initialHits else { return }
        let path = crackPath(hitsRemaining: hitsRemaining, size: size)
        let node = SKShapeNode(path: path)
        node.name = "crackOverlay"
        node.strokeColor = PlatformColor(white: 0.0, alpha: 0.60)
        node.lineWidth = 1.0
        node.zPosition = 2
        addChild(node)
    }

    func crackPath(hitsRemaining: Int, size: CGSize) -> CGPath {
        let path = CGMutablePath()
        let w = size.width / 2
        let h = size.height / 2
        // Normalized damage ratio: 0 = fresh, 1 = one hit before destruction
        let damage = Double(initialHits - hitsRemaining) / Double(max(initialHits - 1, 1))

        if damage <= 0.5 {
            // Lightly damaged: single diagonal crack
            path.move(to: CGPoint(x: -w + 5, y: h - 2))
            path.addLine(to: CGPoint(x: -1, y: 1))
            path.addLine(to: CGPoint(x: 3, y: -h + 2))
        } else {
            // Heavily damaged: two crossed cracks + chipped corners
            path.move(to: CGPoint(x: -w + 5, y: h - 2))
            path.addLine(to: CGPoint(x: -1, y: 1))
            path.addLine(to: CGPoint(x: 3, y: -h + 2))
            path.move(to: CGPoint(x: w - 4, y: h - 2))
            path.addLine(to: CGPoint(x: 2, y: 0))
            path.addLine(to: CGPoint(x: -4, y: -h + 2))
            // Chipped corners
            path.move(to: CGPoint(x: -w + 2, y: -h + 3))
            path.addLine(to: CGPoint(x: -w + 5, y: -h + 6))
            path.move(to: CGPoint(x: w - 2, y: h - 3))
            path.addLine(to: CGPoint(x: w - 6, y: h - 2))
        }
        return path
    }

    // 3 small silver debris pieces that scatter on each armored brick hit
    func spawnDebris() {
        guard let parent = parent else { return }
        let debrisColor = PlatformColor(white: 0.85, alpha: 1)
        for idx in 0..<3 {
            let piece = SKSpriteNode(color: debrisColor, size: CGSize(width: 3, height: 2))
            piece.position = position
            piece.zPosition = zPosition + 5
            parent.addChild(piece)
            let angle = Double(idx) * (2.0 * .pi / 3.0) + .pi / 4.0
            let distance: CGFloat = 12
            let target = CGPoint(
                x: position.x + CGFloat(cos(angle)) * distance,
                y: position.y + CGFloat(sin(angle)) * distance
            )
            let move = SKAction.move(to: target, duration: 0.18)
            let fade = SKAction.fadeOut(withDuration: 0.18)
            piece.run(.sequence([.group([move, fade]), .removeFromParent()]))
        }
    }
}

// MARK: - Private helpers

extension BrickNode {
    private static func makeBrickPhysicsBody(size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.brick
        body.contactTestBitMask = PhysicsCategory.ball
        return body
    }
}

private extension BrickNode {
    func deflect() {
        let flash = SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.04)
        let recover = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12)
        run(.sequence([flash, recover]))
    }

    func addBevelOverlays(size: CGSize) {
        let inset: CGFloat = 1.5
        let halfW = size.width / 2
        let halfH = size.height / 2

        let highlightPath = CGMutablePath()
        highlightPath.move(to: CGPoint(x: -halfW + inset, y: halfH - inset))
        highlightPath.addLine(to: CGPoint(x: halfW - inset, y: halfH - inset))
        highlightPath.move(to: CGPoint(x: -halfW + inset, y: halfH - inset))
        highlightPath.addLine(to: CGPoint(x: -halfW + inset, y: -halfH + inset))

        let highlight = SKShapeNode(path: highlightPath)
        highlight.strokeColor = .white
        highlight.lineWidth = 1.5
        highlight.alpha = 0.35
        highlight.zPosition = 1

        let shadowPath = CGMutablePath()
        shadowPath.move(to: CGPoint(x: -halfW + inset, y: -halfH + inset))
        shadowPath.addLine(to: CGPoint(x: halfW - inset, y: -halfH + inset))
        shadowPath.move(to: CGPoint(x: halfW - inset, y: halfH - inset))
        shadowPath.addLine(to: CGPoint(x: halfW - inset, y: -halfH + inset))

        let shadow = SKShapeNode(path: shadowPath)
        shadow.strokeColor = .black
        shadow.lineWidth = 1.5
        shadow.alpha = 0.45
        shadow.zPosition = 1

        addChild(highlight)
        addChild(shadow)
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

private func makeBonusOverlayNodes(size: CGSize) -> [SKNode] {
    let border = SKShapeNode(rectOf: size)
    border.fillColor = .clear
    border.strokeColor = Theme.Color.powerUp
    border.lineWidth = 1.5
    border.run(.repeatForever(.sequence([
        .fadeAlpha(to: 0.2, duration: 0.5),
        .fadeAlpha(to: 1.0, duration: 0.5)
    ])))

    let star = SKLabelNode(fontNamed: Theme.Font.bold)
    star.text = "★"
    star.fontSize = 9
    star.fontColor = .white
    star.verticalAlignmentMode = .center
    star.horizontalAlignmentMode = .center

    return [border, star]
}

private func makeIndestructibleBorderNode(size: CGSize) -> SKShapeNode {
    let border = SKShapeNode(rectOf: size)
    border.fillColor = .clear
    border.strokeColor = Theme.Color.indestructibleBorder
    border.lineWidth = 1.5
    border.run(.repeatForever(.sequence([
        .fadeAlpha(to: 0.3, duration: 0.8),
        .fadeAlpha(to: 1.0, duration: 0.8)
    ])))
    return border
}
