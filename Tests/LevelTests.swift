@testable import BreakoutGame
import Testing

struct LevelTests {
    @Test func brickCountFullGrid() {
        // Level 1 (ROOKIE) is 5 rows × 10 columns, 48 normal + 2 bonus → 50 bricks
        #expect(Level.all[0].brickCount == 50)
    }

    @Test func brickCountSparseGrid() {
        let level = Level(name: "TEST", grid: [
            [.normal, .empty, .normal],
            [.empty, .empty, .normal]
        ])
        #expect(level.brickCount == 3)
    }

    @Test func brickCountEmptyGrid() {
        let level = Level(name: "EMPTY", grid: [[.empty, .empty], [.empty, .empty]])
        #expect(level.brickCount == 0)
    }

    @Test func brickCountIncludesMultiHit() {
        let level = Level(name: "MULTI", grid: [
            [.normal, .multiHit(3)],
            [.multiHit(2), .empty]
        ])
        #expect(level.brickCount == 3)
    }

    @Test func brickCountExcludesIndestructible() {
        let level = Level(name: "INDESTRUCTIBLE", grid: [
            [.normal, .indestructible, .normal],
            [.indestructible, .empty, .normal]
        ])
        #expect(level.brickCount == 3)
    }

    @Test func brickCountIncludesBonus() {
        let level = Level(name: "BONUS", grid: [
            [.normal, .bonus, .normal],
            [.bonus, .empty, .normal]
        ])
        #expect(level.brickCount == 5)
    }

    // MARK: - metadata.bossPhases

    @Test func metadataZeroForNonBossLevel() {
        // levelIndex 0 → world 1, indexInWorld 1 (not a boss)
        let level = Level(name: "NON-BOSS", grid: [[.normal]], levelIndex: 0)
        #expect(level.metadata.bossPhases == 0)
    }

    @Test func metadataOnePhasForWorldOneBoss() {
        // levelIndex 9 → world 1, indexInWorld 10 (boss)
        let level = Level(name: "W1 BOSS", grid: [[.normal]], levelIndex: 9)
        #expect(level.isBoss)
        #expect(level.metadata.bossPhases == 1)
    }

    @Test func metadataTwoPhasesForWorldFourBoss() {
        // levelIndex 39 → world 4, indexInWorld 10 (boss)
        let level = Level(name: "W4 BOSS", grid: [[.normal]], levelIndex: 39)
        #expect(level.isBoss)
        #expect(level.metadata.bossPhases == 2)
    }

    @Test func metadataThreePhasesForWorldSevenBoss() {
        // levelIndex 69 → world 7, indexInWorld 10 (boss)
        let level = Level(name: "W7 BOSS", grid: [[.normal]], levelIndex: 69)
        #expect(level.isBoss)
        #expect(level.metadata.bossPhases == 3)
    }

    @Test func metadataZeroForWorldTenBoss() {
        // levelIndex 99 → world 10, handled separately → bossPhases == 0
        let level = Level(name: "W10 BOSS", grid: [[.normal]], levelIndex: 99)
        #expect(level.isBoss)
        #expect(level.metadata.bossPhases == 0)
    }
}
