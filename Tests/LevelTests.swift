@testable import BreakoutGame
import Testing

struct LevelTests {
    @Test func brickCountFullGrid() {
        // Level.one is 5 rows × 8 columns, all true → 40 bricks
        #expect(Level.one.brickCount == 40)
    }

    @Test func brickCountSparseGrid() {
        let level = Level(name: "TEST", grid: [
            [true, false, true],
            [false, false, true]
        ])
        #expect(level.brickCount == 3)
    }

    @Test func brickCountEmptyGrid() {
        let level = Level(name: "EMPTY", grid: [[false, false], [false, false]])
        #expect(level.brickCount == 0)
    }
}
