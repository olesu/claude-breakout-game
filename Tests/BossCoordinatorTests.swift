@testable import BreakoutGame
import SpriteKit
import Testing

@MainActor
@Suite("BossCoordinator")
struct BossCoordinatorTests {

    // MARK: - Helpers

    private func makeBrick() -> BrickNode {
        BrickNode(size: CGSize(width: 40, height: 15), row: 0, col: 0, cell: .normal)
    }

    private func makeCoordinator(
        bricks: [BrickNode],
        bossPhases: Int = 1
    ) -> BossCoordinator {
        let layout = BrickLayout(
            size: CGSize(width: 40, height: 15),
            spacing: 4,
            gridOrigin: CGPoint(x: 0, y: 600)
        )
        return BossCoordinator(
            initialBricks: bricks,
            bossPhases: bossPhases,
            layout: layout,
            columns: 10,
            sceneMaxY: 700,
            paddleZoneY: 50,
            getBricks: { bricks }
        )
    }

    // MARK: - Health ratio

    @Test func healthIsOneAtStart() {
        let bricks = (0..<4).map { _ in makeBrick() }
        var reported: Float = -1
        let boss = makeCoordinator(bricks: bricks)
        boss.onHealthChanged = { reported = $0 }

        boss.brickDestroyed()
        // 1 destroyed of 4 → 3/4
        #expect(reported == 0.75)
    }

    @Test func healthDropsToZeroWhenAllDestroyed() {
        let bricks = (0..<2).map { _ in makeBrick() }
        var reported: Float = -1
        let boss = makeCoordinator(bricks: bricks)
        boss.onHealthChanged = { reported = $0 }

        boss.brickDestroyed()
        boss.brickDestroyed()
        #expect(reported == 0.0)
    }

    // MARK: - Wave spawn thresholds (bossPhases == 1)

    @Test func noWaveBeforeThresholdWithOnePhase() {
        // threshold for wave 1 of 1 = 1/(1+1) = 50% → need ≥2 of 4 destroyed
        let bricks = (0..<4).map { _ in makeBrick() }
        var wavesFired = 0
        let boss = makeCoordinator(bricks: bricks, bossPhases: 1)
        boss.onWaveBricksSpawned = { _ in wavesFired += 1 }

        boss.brickDestroyed()   // 25% — below threshold
        #expect(wavesFired == 0)
    }

    @Test func waveFiresAtThresholdWithOnePhase() {
        // threshold = 50% of 4 → fires when destroyedCount reaches 2
        let bricks = (0..<4).map { _ in makeBrick() }
        var wavesFired = 0
        let boss = makeCoordinator(bricks: bricks, bossPhases: 1)
        boss.onWaveBricksSpawned = { _ in wavesFired += 1 }

        boss.brickDestroyed()   // 25%
        boss.brickDestroyed()   // 50% — at threshold
        #expect(wavesFired == 1)
    }

    @Test func onlyOneWaveWithOnePhase() {
        let bricks = (0..<4).map { _ in makeBrick() }
        var wavesFired = 0
        let boss = makeCoordinator(bricks: bricks, bossPhases: 1)
        boss.onWaveBricksSpawned = { _ in wavesFired += 1 }

        for _ in 0..<4 { boss.brickDestroyed() }
        #expect(wavesFired == 1)
    }

    // MARK: - Wave spawn thresholds (bossPhases == 2)

    @Test func firstWaveFiresAtOneThirdWithTwoPhases() {
        // thresholds: 1/3 ≈ 33%, 2/3 ≈ 67% of 6 bricks → at 2 destroyed
        let bricks = (0..<6).map { _ in makeBrick() }
        var wavesFired = 0
        let boss = makeCoordinator(bricks: bricks, bossPhases: 2)
        boss.onWaveBricksSpawned = { _ in wavesFired += 1 }

        boss.brickDestroyed()   // 1/6 ≈ 17% — below first threshold
        #expect(wavesFired == 0)
        boss.brickDestroyed()   // 2/6 ≈ 33% — at first threshold
        #expect(wavesFired == 1)
    }

    @Test func secondWaveFiresAtTwoThirdsWithTwoPhases() {
        // second threshold 2/3 of 6 → at 4 destroyed
        let bricks = (0..<6).map { _ in makeBrick() }
        var wavesFired = 0
        let boss = makeCoordinator(bricks: bricks, bossPhases: 2)
        boss.onWaveBricksSpawned = { _ in wavesFired += 1 }

        for _ in 0..<3 { boss.brickDestroyed() }   // 1 wave fired
        #expect(wavesFired == 1)
        boss.brickDestroyed()   // 4/6 ≈ 67% — at second threshold
        #expect(wavesFired == 2)
    }

    @Test func noMoreThanTwoWavesWithTwoPhases() {
        let bricks = (0..<6).map { _ in makeBrick() }
        var wavesFired = 0
        let boss = makeCoordinator(bricks: bricks, bossPhases: 2)
        boss.onWaveBricksSpawned = { _ in wavesFired += 1 }

        for _ in 0..<6 { boss.brickDestroyed() }
        #expect(wavesFired == 2)
    }
}
