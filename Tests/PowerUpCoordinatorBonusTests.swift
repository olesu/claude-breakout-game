@testable import BreakoutGame
import SpriteKit
import Testing

struct PowerUpCoordinatorBonusTests {

    private func makeCoordinator() -> PowerUpCoordinator {
        PowerUpCoordinator(dropProbability: 1.0)
    }

    private func makeCoordinatorWithActivePowerUp() -> PowerUpCoordinator {
        let coordinator = makeCoordinator()
        // node has no parent — removeFromParent() is a no-op; safe for test fixture use
        coordinator.collect(PowerUpNode(type: .powerBall))
        return coordinator
    }

    @Test func spawnGuaranteed_returnsNode() {
        let coordinator = makeCoordinator()
        let node = coordinator.spawnGuaranteed(at: .zero)
        #expect(node.physicsBody != nil)
    }

    @Test func spawnGuaranteed_whenPowerUpActive_stillReturnsNode() {
        let coordinator = makeCoordinatorWithActivePowerUp()
        let node = coordinator.spawnGuaranteed(at: .zero)
        #expect(node.physicsBody != nil)
    }

    @Test func spawnGuaranteed_nodeHasDownwardVelocity() {
        let coordinator = makeCoordinator()
        let node = coordinator.spawnGuaranteed(at: .zero)
        #expect((node.physicsBody?.velocity.dy ?? 0) < 0)
    }

    @Test func spawnGuaranteed_nodePositionMatchesInput() {
        let coordinator = makeCoordinator()
        let pos = CGPoint(x: 42, y: 100)
        let node = coordinator.spawnGuaranteed(at: pos)
        #expect(node.position == pos)
    }
}
