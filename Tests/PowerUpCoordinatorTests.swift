@testable import BreakoutGame
import SpriteKit
import Testing

struct PowerUpCoordinatorTests {

    // MARK: - Helpers

    private func makeCoordinator() -> PowerUpCoordinator {
        // dropProbability: 1.0 makes spawnIfEligible deterministic in tests.
        PowerUpCoordinator(balls: [], paddle: PaddleNode(sceneWidth: 400), dropProbability: 1.0)
    }

    // Returns a coordinator whose PowerUpState is active.
    // Note: nodes is empty — collect() removes the node from tracking.
    private func makeCoordinatorWithActivePowerUp() -> PowerUpCoordinator {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        return coordinator
    }

    // MARK: - update(delta:floorY:) — floor culling

    @Test func update_nodeBelowFloor_isRemovedFromParent() {
        let coordinator = makeCoordinator()
        let node = coordinator.spawnIfEligible(at: .zero)!
        let parent = SKNode()
        parent.addChild(node)
        node.position = CGPoint(x: 0, y: -121)
        coordinator.update(delta: 0, floorY: -100)
        #expect(node.parent == nil)
        #expect(parent.children.isEmpty)
    }

    @Test func update_nodeAboveFloor_isRetainedInParent() {
        let coordinator = makeCoordinator()
        let node = coordinator.spawnIfEligible(at: .zero)!
        let parent = SKNode()
        parent.addChild(node)
        node.position = CGPoint(x: 0, y: 0)
        coordinator.update(delta: 0, floorY: -100)
        #expect(node.parent != nil)
    }

    @Test func update_nodeExactlyAtFloorMinus20_isRetainedInParent() {
        let coordinator = makeCoordinator()
        let node = coordinator.spawnIfEligible(at: .zero)!
        let parent = SKNode()
        parent.addChild(node)
        node.position = CGPoint(x: 0, y: -120)  // == floorY(-100) - 20, not strictly less
        coordinator.update(delta: 0, floorY: -100)
        #expect(node.parent != nil)
    }

    // MARK: - spawnIfEligible

    @Test func spawnIfEligible_whenPowerUpActive_returnsNil() {
        // Deterministic: the isActive guard fires before the probability check.
        let coordinator = makeCoordinatorWithActivePowerUp()
        #expect(coordinator.spawnIfEligible(at: .zero) == nil)
    }
}
