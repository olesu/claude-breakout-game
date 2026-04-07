@testable import BreakoutGame
import SpriteKit
import Testing

struct PowerUpCoordinatorTests {

    // MARK: - Helpers

    private func makeCoordinator() -> PowerUpCoordinator {
        // dropProbability: 1.0 makes spawnIfEligible deterministic in tests.
        PowerUpCoordinator(dropProbability: 1.0)
    }

    // Returns a coordinator whose PowerUpState is active with powerBall.
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

    // MARK: - update(delta:floorY:) — deactivation effects

    @Test func update_whenTimerExpires_returnsPowerBallDeactivationEffect() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        let effects = coordinator.update(delta: Theme.Layout.powerUpDuration + 1, floorY: -999)
        #expect(effects == [.deactivatePowerBall])
    }

    @Test func update_whenTimerExpires_returnsWidePaddleDeactivationEffect() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .widePaddle))
        let effects = coordinator.update(delta: Theme.Layout.powerUpDuration + 1, floorY: -999)
        #expect(effects == [.deactivateWidePaddle])
    }

    @Test func update_whenTimerExpires_returnsSlowBallDeactivationEffect() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .slowBall))
        let effects = coordinator.update(delta: Theme.Layout.powerUpDuration + 1, floorY: -999)
        #expect(effects == [.deactivateSlowBall])
    }

    @Test func update_beforeTimerExpires_returnsNoEffects() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        let effects = coordinator.update(delta: 0.1, floorY: -999)
        #expect(effects.isEmpty)
    }

    @Test func update_whenNoActivePowerUp_returnsNoEffects() {
        let coordinator = makeCoordinator()
        let effects = coordinator.update(delta: Theme.Layout.powerUpDuration + 1, floorY: -999)
        #expect(effects.isEmpty)
    }

    // MARK: - collect — returned effects

    @Test func collect_powerBall_returnsActivationEffect() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .powerBall))
        #expect(outcome.effects == [.activatePowerBall])
    }

    @Test func collect_widePaddle_returnsActivationEffect() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .widePaddle))
        #expect(outcome.effects == [.activateWidePaddle])
    }

    @Test func collect_slowBall_returnsActivationEffect() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .slowBall))
        #expect(outcome.effects == [.activateSlowBall])
    }

    @Test func collect_laser_returnsNoEffects() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .laser))
        #expect(outcome.effects.isEmpty)
    }

    @Test func collect_extraLife_returnsNoEffects() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .extraLife))
        #expect(outcome.effects.isEmpty)
    }

    @Test func collect_multiBall_returnsNoEffects() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .multiBall))
        #expect(outcome.effects.isEmpty)
    }

    @Test func collect_replacingActivePowerUp_includesDeactivationAndActivation() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        let outcome = coordinator.collect(PowerUpNode(type: .widePaddle))
        #expect(outcome.effects.contains(.deactivatePowerBall))
        #expect(outcome.effects.contains(.activateWidePaddle))
    }

    // MARK: - collect — CollectResult

    @Test func collect_timedPowerUp_returnsActivatedResult() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .powerBall))
        if case .activated(.powerBall) = outcome.result { } else {
            Issue.record("Expected .activated(.powerBall), got \(outcome.result)")
        }
    }

    @Test func collect_extraLife_returnsInstantResult() {
        let coordinator = makeCoordinator()
        let outcome = coordinator.collect(PowerUpNode(type: .extraLife))
        if case .instant(.extraLife) = outcome.result { } else {
            Issue.record("Expected .instant(.extraLife), got \(outcome.result)")
        }
    }

    // MARK: - spawnIfEligible

    @Test func spawnIfEligible_whenPowerUpActive_returnsNil() {
        // Deterministic: the isActive guard fires before the probability check.
        let coordinator = makeCoordinatorWithActivePowerUp()
        #expect(coordinator.spawnIfEligible(at: .zero) == nil)
    }

    // MARK: - effectsForNewBall

    @Test func effectsForNewBall_whenPowerBallActive_returnsPowerBallEffect() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        #expect(coordinator.effectsForNewBall() == [.activatePowerBall])
    }

    @Test func effectsForNewBall_whenSlowBallActive_returnsSlowBallEffect() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .slowBall))
        #expect(coordinator.effectsForNewBall() == [.activateSlowBall])
    }

    @Test func effectsForNewBall_whenWidePaddleActive_returnsNoEffects() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .widePaddle))
        #expect(coordinator.effectsForNewBall().isEmpty)
    }

    @Test func effectsForNewBall_whenNoPowerUpActive_returnsEmpty() {
        let coordinator = makeCoordinator()
        #expect(coordinator.effectsForNewBall().isEmpty)
    }

    @Test func effectsForNewBall_afterPowerUpExpires_returnsEmpty() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        coordinator.update(delta: Theme.Layout.powerUpDuration + 1, floorY: -999)
        #expect(coordinator.effectsForNewBall().isEmpty)
    }

    // MARK: - clearAll — returned effects

    @Test func clearAll_whenPowerBallActive_returnsDeactivationEffect() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .powerBall))
        let effects = coordinator.clearAll()
        #expect(effects == [.deactivatePowerBall])
    }

    @Test func clearAll_whenNoPowerUpActive_returnsEmpty() {
        let coordinator = makeCoordinator()
        let effects = coordinator.clearAll()
        #expect(effects.isEmpty)
    }

    @Test func clearAll_removesNodesFromParent() {
        let coordinator = makeCoordinator()
        let node = coordinator.spawnIfEligible(at: .zero)!
        let parent = SKNode()
        parent.addChild(node)
        coordinator.clearAll()
        #expect(node.parent == nil)
    }

    // MARK: - fireLasers

    @Test func fireLasers_whenLaserNotActive_returnsEmpty() {
        let coordinator = makeCoordinator()
        #expect(coordinator.fireLasers(from: .zero, paddleHalfWidth: 50).isEmpty)
    }

    @Test func fireLasers_whenLaserActive_returnsTwoNodes() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .laser))
        let nodes = coordinator.fireLasers(from: .zero, paddleHalfWidth: 50)
        #expect(nodes.count == 2)
    }

    @Test func fireLasers_withinCooldown_returnsEmpty() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .laser))
        _ = coordinator.fireLasers(from: .zero, paddleHalfWidth: 50)
        #expect(coordinator.fireLasers(from: .zero, paddleHalfWidth: 50).isEmpty)
    }

    @Test func fireLasers_afterCooldownExpires_returnsTwoNodes() {
        let coordinator = makeCoordinator()
        coordinator.collect(PowerUpNode(type: .laser))
        _ = coordinator.fireLasers(from: .zero, paddleHalfWidth: 50)
        coordinator.update(delta: Theme.Layout.laserFireCooldown + 0.01, floorY: -999)
        #expect(coordinator.fireLasers(from: .zero, paddleHalfWidth: 50).count == 2)
    }
}
