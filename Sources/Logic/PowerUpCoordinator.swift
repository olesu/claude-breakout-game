import SpriteKit

enum CollectResult {
    case activated(PowerUpType)
    case instant(PowerUpType)
    case none
}

final class PowerUpCoordinator {
    private var balls: [BallNode]
    private let paddle: PaddleNode
    private var nodes: [PowerUpNode] = []
    private var state = PowerUpState()
    private let dropProbability: Double

    var isPowerBallActive: Bool { state.active == .powerBall }

    init(
        balls: [BallNode],
        paddle: PaddleNode,
        dropProbability: Double = Theme.Layout.powerUpDropProbability
    ) {
        self.balls = balls
        self.paddle = paddle
        self.dropProbability = dropProbability
    }

    func update(delta: TimeInterval, floorY: CGFloat) {
        let before = state
        state = state.tick(delta: delta)
        if before.isActive && !state.isActive, let type = before.active {
            removeEffect(for: type)
        }
        nodes = nodes.filter { node in
            if node.position.y < floorY - 20 {
                node.removeFromParent()
                return false
            }
            return true
        }
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
    func collect(_ node: PowerUpNode) -> CollectResult {
        node.removeFromParent()
        nodes.removeAll { $0 === node }
        let type = node.type
        guard type.duration != nil else { return .instant(type) }
        let newState = state.collect(type)
        // Defensive: unreachable today (timed types always produce an active state),
        // but guards against future changes to PowerUpState.collect semantics.
        guard newState.isActive else { return .none }
        if let previous = state.active {
            removeEffect(for: previous)
        }
        state = newState
        applyEffect(for: type)
        return .activated(type)
    }

    /// Adds `ball` to the tracked set and immediately applies any currently active timed effect.
    func addBall(_ ball: BallNode) {
        balls.append(ball)
        if let type = state.active {
            applyEffect(for: type, to: ball)
        }
    }

    /// Removes `ball` from the tracked set (e.g. when an extra ball is silently culled).
    func removeBall(_ ball: BallNode) {
        balls.removeAll { $0 === ball }
    }

    func clearAll() {
        if state.isActive, let type = state.active {
            state = state.clear()
            removeEffect(for: type)
        }
        // Nodes may be falling but not yet collected; always clear them.
        nodes.forEach { $0.removeFromParent() }
        nodes.removeAll()
    }

    // MARK: - Effect dispatch

    private func applyEffect(for type: PowerUpType) {
        switch type {
        case .powerBall: balls.forEach { applyEffect(for: type, to: $0) }
        case .widePaddle: paddle.activateWidePaddle()
        case .slowBall: balls.forEach { applyEffect(for: type, to: $0) }
        case .extraLife: break  // instant effect; handled by caller via CollectResult
        case .multiBall: break  // activation handled separately via CollectResult
        }
    }

    private func applyEffect(for type: PowerUpType, to ball: BallNode) {
        switch type {
        case .powerBall: ball.activatePowerBall()
        case .slowBall: ball.activateSlowBall()
        case .widePaddle, .extraLife, .multiBall: break
        }
    }

    private func removeEffect(for type: PowerUpType) {
        switch type {
        case .powerBall: balls.forEach { $0.deactivatePowerBall() }
        case .widePaddle: paddle.deactivateWidePaddle()
        case .slowBall: balls.forEach { $0.deactivateSlowBall() }
        case .extraLife: break  // no ongoing effect to remove
        case .multiBall: break  // ended when all extra balls are lost
        }
    }
}
