import SpriteKit

final class BrickNode: SKSpriteNode {
    let row: Int
    let col: Int
    let isIndestructible: Bool
    let isBonus: Bool
    let isRegenerating: Bool
    private var brickState: BrickState
    private let initialHits: Int
    private var hitHandled = false

    var currentCell: BrickCell {
        if isIndestructible { return .indestructible }
        if isBonus, case .intact = brickState { return .bonus }
        if isRegenerating, case .intact = brickState { return .regenerating }
        return brickState.asCell
    }

    init(size: CGSize, row: Int, col: Int, cell: BrickCell) {
        self.row = row
        self.col = col
        self.isIndestructible = (cell == .indestructible)
        self.isBonus = (cell == .bonus)
        self.isRegenerating = (cell == .regenerating)
        self.brickState = cell.initialState
        switch self.brickState {
        case .intact(let n): self.initialHits = n
        case .destroyed: self.initialHits = 1
        }
        let rowColor: PlatformColor
        if isIndestructible {
            rowColor = Theme.Color.indestructible
        } else if isRegenerating {
            rowColor = Theme.Color.regenerating
        } else {
            rowColor = Theme.Color.brickColors[row % Theme.Color.brickColors.count]
        }
        super.init(texture: nil, color: rowColor, size: size)
        addChild(ShadowNode.makeBrickShadow(size: size, color: rowColor))
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

        if isBonus {
            makeBonusOverlayNodes(size: size).forEach(addChild)
        }

        if isRegenerating {
            makeRegeneratingOverlayNodes(size: size).forEach(addChild)
        }

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

    /// Démarre la phase de régénération : retire le corps physique, pulse à 12% d'opacité,
    /// puis remet la brique en jeu après 4 secondes.
    func beginRegeneration() {
        physicsBody = nil
        // Réinitialise la rotation issue des animations d'impact
        removeAllActions()
        xScale = 1.0
        yScale = 1.0
        zRotation = 0

        let fadeOut = SKAction.fadeAlpha(to: 0.12, duration: 0.25)
        let pulse = SKAction.repeatForever(.sequence([
            .fadeAlpha(to: 0.20, duration: 0.6),
            .fadeAlpha(to: 0.06, duration: 0.6)
        ]))
        let startPulse = SKAction.run { [weak self] in
            self?.run(pulse, withKey: "regen-pulse")
        }
        let wait = SKAction.wait(forDuration: 4.0)
        let rearmAction = SKAction.run { [weak self] in self?.rearm() }

        run(.sequence([fadeOut, startPulse, wait, rearmAction]), withKey: "regeneration")
    }
}

// MARK: - Private helpers

private extension BrickNode {
    func rearm() {
        removeAction(forKey: "regen-pulse")
        removeAction(forKey: "regeneration")

        // Remet l'état interne à intact
        brickState = .intact(hitsRemaining: 1)

        // Animation de réapparition : flash blanc puis retour à la couleur d'origine
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.20)
        let flashIn = SKAction.colorize(with: .white, colorBlendFactor: 0.9, duration: 0.08)
        let resetColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.25)
        let scaleIn = SKAction.sequence([
            .scale(to: 1.12, duration: 0.08),
            .scale(to: 1.0, duration: 0.12)
        ])
        run(.group([fadeIn, .sequence([flashIn, resetColor]), scaleIn]))

        // Restaure le corps physique
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.brick
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body
    }

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

private func makeRegeneratingOverlayNodes(size: CGSize) -> [SKNode] {
    // Bordure turquoise qui pulse lentement pour indiquer la régénération
    let border = SKShapeNode(rectOf: size)
    border.fillColor = .clear
    border.strokeColor = Theme.Color.regenerating
    border.lineWidth = 1.5
    border.run(.repeatForever(.sequence([
        .fadeAlpha(to: 0.3, duration: 0.7),
        .fadeAlpha(to: 1.0, duration: 0.7)
    ])))

    // Icône "↺" pour indiquer la régénération
    let icon = SKLabelNode(fontNamed: Theme.Font.bold)
    icon.text = "↺"
    icon.fontSize = 9
    icon.fontColor = .white
    icon.verticalAlignmentMode = .center
    icon.horizontalAlignmentMode = .center

    return [border, icon]
}
