import SpriteKit

final class PowerUpCoordinator {
    private weak var scene: SKScene?
    private var nodes: [PowerUpNode] = []
    private var state = PowerUpState()

    var isPowerBallActive: Bool { state.active == .powerBall }

    init(scene: SKScene) {
        self.scene = scene
    }

    func update(delta: TimeInterval, ball: BallNode) {
        let before = state
        state = state.tick(delta: delta)
        if before.isActive && !state.isActive {
            ball.deactivatePowerBall()
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
        let node = PowerUpNode(type: .powerBall)
        node.position = position
        scene.addChild(node)
        node.physicsBody?.velocity = CGVector(dx: 0, dy: -Theme.Layout.powerUpFallSpeed)
        nodes.append(node)
    }

    func collect(_ node: PowerUpNode, ball: BallNode) {
        node.removeFromParent()
        nodes.removeAll { $0 === node }
        state = state.collect(node.type)
        ball.activatePowerBall()
    }

    func clearAll(ball: BallNode) {
        if state.isActive {
            state = state.clear()
            ball.deactivatePowerBall()
        }
        nodes.forEach { $0.removeFromParent() }
        nodes.removeAll()
    }
}
