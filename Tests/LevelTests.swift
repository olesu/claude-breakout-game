@testable import BreakoutGame
import Testing

struct LevelTests {
    @Test func brickCountFullGrid() {
        // Level.one is 5 rows × 8 columns, all normal → 40 bricks
        #expect(Level.one.brickCount == 40)
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
}
