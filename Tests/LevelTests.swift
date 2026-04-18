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
}
