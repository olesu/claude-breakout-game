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

    // MARK: - addBall / removeBall

    @Test func addBall_whenSlowBallActive_activatesSlowBallOnNewBall() {
        let coordinator = makeCoordinator()
        // Start with a moving ball so slow-ball has a speed to reduce.
        let existing = BallNode(radius: 8)
        existing.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        coordinator.addBall(existing)
        coordinator.collect(PowerUpNode(type: .slowBall))

        let newBall = BallNode(radius: 8)
        newBall.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        coordinator.addBall(newBall)

        let speed = newBall.physicsBody.map { hypot($0.velocity.dx, $0.velocity.dy) } ?? 500
        #expect(speed < 500)
    }

    @Test func addBall_whenPowerBallActive_activatesPowerBallOnNewBall() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))

        let newBall = BallNode(radius: 8)
        coordinator.addBall(newBall)

        #expect(newBall.isPowerBall)
    }

    @Test func removeBall_effectNotRestoredWhenEffectExpires() {
        // If a ball is removed from the coordinator, deactivateSlowBall should NOT be
        // called on it when the timed effect expires — so its velocity stays at the
        // slowed value rather than being restored to the original speed.
        let ball = BallNode(radius: 8)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        let coordinator = PowerUpCoordinator(balls: [ball], paddle: PaddleNode(sceneWidth: 400))
        coordinator.collect(PowerUpNode(type: .slowBall))

        let slowedSpeed = ball.physicsBody.map { hypot($0.velocity.dx, $0.velocity.dy) } ?? 500
        coordinator.removeBall(ball)

        // Advance past the effect duration — this triggers removeEffect on tracked balls.
        coordinator.update(delta: Theme.Layout.powerUpDuration + 1, floorY: -999)

        // Ball was removed, so its speed must still be the slowed value (not 500).
        let speedAfterExpiry = ball.physicsBody.map { hypot($0.velocity.dx, $0.velocity.dy) } ?? 0
        #expect(abs(speedAfterExpiry - slowedSpeed) < 0.001)
    }
}
