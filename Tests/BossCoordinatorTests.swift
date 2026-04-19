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
            paddleZoneY: 50
        )
    }

    // MARK: - Health ratio

    @Test func healthDropsAfterOneBrickDestroyed() {
        let bricks = (0..<4).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks)

        let result = boss.brickDestroyed()
        // 1 destroyed of 4 → 3/4
        #expect(result.healthRatio == 0.75)
    }

    @Test func healthDropsToZeroWhenAllDestroyed() {
        let bricks = (0..<2).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks)

        _ = boss.brickDestroyed()
        let result = boss.brickDestroyed()
        #expect(result.healthRatio == 0.0)
    }

    // MARK: - Wave spawn thresholds (bossPhases == 1)

    @Test func noWaveBeforeThresholdWithOnePhase() {
        // threshold for wave 1 of 1 = 1/(1+1) = 50% → need ≥2 of 4 destroyed
        let bricks = (0..<4).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks, bossPhases: 1)

        let result = boss.brickDestroyed()   // 25% — below threshold
        #expect(result.waveBricks.isEmpty)
    }

    @Test func waveFiresAtThresholdWithOnePhase() {
        // threshold = 50% of 4 → fires when destroyedCount reaches 2
        let bricks = (0..<4).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks, bossPhases: 1)

        _ = boss.brickDestroyed()            // 25%
        let result = boss.brickDestroyed()   // 50% — at threshold
        #expect(!result.waveBricks.isEmpty)
    }

    @Test func onlyOneWaveWithOnePhase() {
        let bricks = (0..<4).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks, bossPhases: 1)

        let wavesFired = (0..<4).reduce(0) { count, _ in
            count + (boss.brickDestroyed().waveBricks.isEmpty ? 0 : 1)
        }
        #expect(wavesFired == 1)
    }

    // MARK: - Wave spawn thresholds (bossPhases == 2)

    @Test func firstWaveFiresAtOneThirdWithTwoPhases() {
        // thresholds: 1/3 ≈ 33%, 2/3 ≈ 67% of 6 bricks → at 2 destroyed
        let bricks = (0..<6).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks, bossPhases: 2)

        let first = boss.brickDestroyed()    // 1/6 ≈ 17% — below first threshold
        #expect(first.waveBricks.isEmpty)
        let second = boss.brickDestroyed()   // 2/6 ≈ 33% — at first threshold
        #expect(!second.waveBricks.isEmpty)
    }

    @Test func secondWaveFiresAtTwoThirdsWithTwoPhases() {
        // second threshold 2/3 of 6 → at 4 destroyed
        let bricks = (0..<6).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks, bossPhases: 2)

        var wavesFired = 0
        for _ in 0..<3 { wavesFired += boss.brickDestroyed().waveBricks.isEmpty ? 0 : 1 }
        #expect(wavesFired == 1)
        let result = boss.brickDestroyed()   // 4/6 ≈ 67% — at second threshold
        #expect(!result.waveBricks.isEmpty)
    }

    @Test func noMoreThanTwoWavesWithTwoPhases() {
        let bricks = (0..<6).map { _ in makeBrick() }
        let boss = makeCoordinator(bricks: bricks, bossPhases: 2)

        let wavesFired = (0..<6).reduce(0) { count, _ in
            count + (boss.brickDestroyed().waveBricks.isEmpty ? 0 : 1)
        }
        #expect(wavesFired == 2)
    }
}
