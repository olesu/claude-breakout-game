@testable import BreakoutGame
import Testing

struct LevelCatalogueTests {
    @Test func catalogueContainsFiveLevels() {
        #expect(Level.all.count == 5)
    }

    @Test func allLevelsHaveAtLeastOneBrick() {
        for level in Level.all {
            #expect(level.brickCount > 0)
        }
    }

    @Test func allLevelsHaveConsistentColumnCounts() {
        for level in Level.all {
            let expectedColumns = level.grid[0].count
            for row in level.grid {
                #expect(row.count == expectedColumns)
            }
        }
    }

    @Test func levelNamesAreUnique() {
        let names = Level.all.map(\.name)
        #expect(Set(names).count == names.count)
    }

    @Test func levelNamesMatchArcadeTheme() {
        let names = Level.all.map(\.name)
        #expect(names == ["ROOKIE", "HOTSHOT", "ACE", "LEGEND", "MAZE"])
    }
}
