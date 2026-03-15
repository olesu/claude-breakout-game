import SpriteKit

final class PowerUpCoordinator {
    private weak var scene: SKScene?
    private var nodes: [PowerUpNode] = []
    private var isActive = false
    private var timeRemaining: TimeInterval = 0

    var isPowerBallActive: Bool { isActive }

    init(scene: SKScene) {
        self.scene = scene
    }

    func update(delta: TimeInterval, ball: BallNode) {
        if isActive {
            timeRemaining -= delta
            if timeRemaining <= 0 {
                isActive = false
                ball.deactivatePowerBall()
            }
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
        guard !isActive,
              Double.random(in: 0..<1) < Theme.Layout.powerUpDropProbability,
              let scene else { return }
        let node = PowerUpNode()
        node.position = position
        node.physicsBody?.velocity = CGVector(dx: 0, dy: -Theme.Layout.powerUpFallSpeed)
        scene.addChild(node)
        nodes.append(node)
    }

    func collect(_ node: PowerUpNode, ball: BallNode) {
        node.removeFromParent()
        nodes.removeAll { $0 === node }
        isActive = true
        timeRemaining = Theme.Layout.powerUpDuration
        ball.activatePowerBall()
    }

    func clearAll(ball: BallNode) {
        if isActive {
            isActive = false
            ball.deactivatePowerBall()
        }
        nodes.forEach { $0.removeFromParent() }
        nodes.removeAll()
    }
}
