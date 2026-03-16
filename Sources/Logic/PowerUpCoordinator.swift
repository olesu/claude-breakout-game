import SpriteKit

enum CollectResult {
    case activated(PowerUpType)
    case instant(PowerUpType)
    case none
}

final class PowerUpCoordinator {
    private weak var scene: SKScene?
    private weak var ball: BallNode?
    private weak var paddle: PaddleNode?
    private var nodes: [PowerUpNode] = []
    private var state = PowerUpState()

    var isPowerBallActive: Bool { state.active == .powerBall }

    init(scene: SKScene, ball: BallNode, paddle: PaddleNode) {
        self.scene = scene
        self.ball = ball
        self.paddle = paddle
    }

    func update(delta: TimeInterval) {
        let before = state
        state = state.tick(delta: delta)
        if before.isActive && !state.isActive, let type = before.active {
            removeEffect(for: type)
        }
        guard let scene else { return }
        nodes = nodes.filter { node in
            if node.position.y < scene.frame.minY - 20 {
                node.removeFromParent()
                return false
            }
            return true
        }
    }

    func spawnIfEligible(at position: CGPoint) {
        guard !state.isActive,
              Double.random(in: 0..<1) < Theme.Layout.powerUpDropProbability,
              let scene else { return }
        // Safe: allCases is always non-empty for a non-empty enum.
        let type = PowerUpType.allCases.randomElement()!
        let node = PowerUpNode(type: type)
        node.position = position
        scene.addChild(node)
        node.physicsBody?.velocity = CGVector(dx: 0, dy: -Theme.Layout.powerUpFallSpeed)
        nodes.append(node)
    }

    @discardableResult
    func collect(_ node: PowerUpNode) -> CollectResult {
        node.removeFromParent()
        nodes.removeAll { $0 === node }
        let type = node.type
        guard type.duration != nil else { return .instant(type) }
        let newState = state.collect(type)
        guard newState.isActive else { return .none }
        if let previous = state.active {
            removeEffect(for: previous)
        }
        state = newState
        applyEffect(for: type)
        return .activated(type)
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
        case .powerBall: ball?.activatePowerBall()
        case .widePaddle: paddle?.activateWidePaddle()
        case .slowBall: ball?.activateSlowBall()
        case .extraLife: break  // instant effect; handled by caller via CollectResult
        }
    }

    private func removeEffect(for type: PowerUpType) {
        switch type {
        case .powerBall: ball?.deactivatePowerBall()
        case .widePaddle: paddle?.deactivateWidePaddle()
        case .slowBall: ball?.deactivateSlowBall()
        case .extraLife: break  // no ongoing effect to remove
        }
    }
}
