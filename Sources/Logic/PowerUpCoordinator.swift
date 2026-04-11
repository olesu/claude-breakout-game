import SpriteKit

enum PowerUpEffect: Equatable {
    case activatePowerBall
    case deactivatePowerBall
    case activateSlowBall
    case deactivateSlowBall
    case activateWidePaddle
    case deactivateWidePaddle
}

enum CollectResult {
    case activated(PowerUpType)
    case instant(PowerUpType)
    case none
}

struct CollectOutcome {
    let result: CollectResult
    let effects: [PowerUpEffect]
}

final class PowerUpCoordinator {
    private var nodes: [PowerUpNode] = []
    private var laserNodes: [LaserNode] = []
    private var laserCooldown: TimeInterval = 0
    private var state = PowerUpState()
    private let dropProbability: Double

    var isPowerBallActive: Bool { state.active == .powerBall }
    var isLaserActive: Bool { state.active == .laser }

    init(dropProbability: Double = Theme.Layout.powerUpDropProbability) {
        self.dropProbability = dropProbability
    }

    @discardableResult
    func update(delta: TimeInterval, floorY: CGFloat) -> [PowerUpEffect] {
        let before = state
        state = state.tick(delta: delta)
        var effects: [PowerUpEffect] = []
        if before.isActive && !state.isActive, let type = before.active {
            effects = deactivationEffects(for: type)
        }
        nodes = nodes.filter { node in
            if node.position.y < floorY - 20 {
                node.removeFromParent()
                return false
            }
            return true
        }
        laserNodes = laserNodes.filter { $0.parent != nil }
        laserCooldown = max(0, laserCooldown - delta)
        return effects
    }

    func spawnIfEligible(at position: CGPoint) -> PowerUpNode? {
        guard !state.isActive,
              Double.random(in: 0..<1) < dropProbability else { return nil }
        // Safe: allCases is always non-empty for a non-empty enum.
        let type = PowerUpType.allCases.randomElement()!
        let node = PowerUpNode(type: type)
        node.position = position
        // Safe: PowerUpNode.init unconditionally assigns physicsBody.
        node.physicsBody!.velocity = CGVector(dx: 0, dy: -Theme.Layout.powerUpFallSpeed)
        nodes.append(node)
        return node
    }

    // Intentionally ignores active-state check — bonus bricks always drop.
    func spawnGuaranteed(at position: CGPoint) -> PowerUpNode {
        // Safe: allCases is always non-empty for a non-empty enum.
        let type = PowerUpType.allCases.randomElement()!
        let node = PowerUpNode(type: type)
        node.position = position
        // Safe: PowerUpNode.init unconditionally assigns physicsBody.
        node.physicsBody!.velocity = CGVector(dx: 0, dy: -Theme.Layout.powerUpFallSpeed)
        nodes.append(node)
        return node
    }

    @discardableResult
    func collect(_ node: PowerUpNode) -> CollectOutcome {
        node.removeFromParent()
        nodes.removeAll { $0 === node }
        let type = node.type
        guard type.duration != nil else {
            return CollectOutcome(result: .instant(type), effects: [])
        }
        let newState = state.collect(type)
        // Defensive: unreachable today (timed types always produce an active state),
        // but guards against future changes to PowerUpState.collect semantics.
        guard newState.isActive else { return CollectOutcome(result: .none, effects: []) }
        var effects: [PowerUpEffect] = []
        if let previous = state.active {
            effects += deactivationEffects(for: previous)
        }
        state = newState
        effects += activationEffects(for: type)
        return CollectOutcome(result: .activated(type), effects: effects)
    }

    /// Returns effects that should be applied to a newly added ball.
    /// Call after setting the ball's velocity — `activateSlowBall` captures it immediately.
    func effectsForNewBall() -> [PowerUpEffect] {
        guard let type = state.active else { return [] }
        switch type {
        case .powerBall: return [.activatePowerBall]
        case .slowBall:  return [.activateSlowBall]
        case .widePaddle, .extraLife, .multiBall, .laser: return []
        }
    }

    func fireLasers(from paddlePosition: CGPoint, paddleHalfWidth: CGFloat) -> [LaserNode] {
        guard isLaserActive, laserCooldown <= 0 else { return [] }
        laserCooldown = Theme.Layout.laserFireCooldown
        let yStart = paddlePosition.y + Theme.Layout.paddleHeight / 2
            + Theme.Layout.laserSize.height / 2
        let offsets: [CGFloat] = [-paddleHalfWidth * 0.5, paddleHalfWidth * 0.5]
        let newLasers = offsets.map { dx -> LaserNode in
            let node = LaserNode()
            node.position = CGPoint(x: paddlePosition.x + dx, y: yStart)
            // Safe: LaserNode.init unconditionally assigns physicsBody.
            node.physicsBody!.velocity = CGVector(dx: 0, dy: Theme.Layout.laserSpeed)
            return node
        }
        laserNodes.append(contentsOf: newLasers)
        return newLasers
    }

    @discardableResult
    func clearAll() -> [PowerUpEffect] {
        var effects: [PowerUpEffect] = []
        if state.isActive, let type = state.active {
            effects = deactivationEffects(for: type)
            state = state.clear()
        }
        // Nodes may be falling but not yet collected; always clear them.
        nodes.forEach { $0.removeFromParent() }
        nodes.removeAll()
        laserNodes.forEach { $0.removeFromParent() }
        laserNodes.removeAll()
        return effects
    }

    // MARK: - Effect dispatch

    private func activationEffects(for type: PowerUpType) -> [PowerUpEffect] {
        switch type {
        case .powerBall:  return [.activatePowerBall]
        case .widePaddle: return [.activateWidePaddle]
        case .slowBall:   return [.activateSlowBall]
        case .extraLife, .multiBall, .laser: return []
        }
    }

    private func deactivationEffects(for type: PowerUpType) -> [PowerUpEffect] {
        switch type {
        case .powerBall:  return [.deactivatePowerBall]
        case .widePaddle: return [.deactivateWidePaddle]
        case .slowBall:   return [.deactivateSlowBall]
        case .extraLife, .multiBall, .laser: return []
        }
    }
}
