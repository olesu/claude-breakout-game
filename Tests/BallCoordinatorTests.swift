@testable import BreakoutGame
import SpriteKit
import Testing

@MainActor
@Suite("BallCoordinator")
struct BallCoordinatorTests {

    // MARK: - Helpers

    private func makeBall() -> BallNode {
        BallNode(radius: 8)
    }

    private func makeCoordinator(scene: SKScene? = nil) -> BallCoordinator {
        BallCoordinator(
            addToScene: { scene?.addChild($0) },
            attachTrail: { _ in }
        )
    }

    // MARK: - removeExtras()

    @Test func removeExtrasOnEmptyArrayIsNoop() {
        let coordinator = makeCoordinator()
        // balls is empty — must not crash
        coordinator.removeExtras()
        #expect(coordinator.balls.isEmpty)
    }

    @Test func removeExtrasWithOneBallIsNoop() {
        let coordinator = makeCoordinator()
        let primary = makeBall()
        coordinator.setup(primary: primary)

        coordinator.removeExtras()

        #expect(coordinator.balls.count == 1)
        #expect(coordinator.balls.first === primary)
    }

    @Test func removeExtrasWithTwoBallsRemovesExtra() {
        let scene = SKScene(size: CGSize(width: 390, height: 844))
        let coordinator = makeCoordinator(scene: scene)
        let primary = makeBall()
        scene.addChild(primary)
        coordinator.setup(primary: primary)

        // spawnExtra adds 2 extra balls; coordinator.balls becomes [primary, extra1, extra2]
        coordinator.spawnExtra(
            at: .zero,
            velocity: CGVector(dx: 0, dy: 300),
            powerUp: PowerUpCoordinator()
        )
        #expect(coordinator.balls.count == 3)

        coordinator.removeExtras()

        #expect(coordinator.balls.count == 1)
        #expect(coordinator.balls.first === primary)
    }

    @Test func removeExtrasDetachesExtrasFromScene() {
        let scene = SKScene(size: CGSize(width: 390, height: 844))
        let coordinator = makeCoordinator(scene: scene)
        let primary = makeBall()
        scene.addChild(primary)
        coordinator.setup(primary: primary)

        coordinator.spawnExtra(
            at: .zero,
            velocity: CGVector(dx: 0, dy: 300),
            powerUp: PowerUpCoordinator()
        )
        let extrasBefore = scene.children.count - 1   // exclude primary

        coordinator.removeExtras()

        let extrasAfter = scene.children.count - 1
        #expect(extrasBefore > 0)
        #expect(extrasAfter == 0)
    }
}
