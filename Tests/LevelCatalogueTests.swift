@testable import BreakoutGame
import Testing

struct LevelCatalogueTests {
    @Test func catalogueContainsOneHundredLevels() {
        #expect(Level.all.count == 100)
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

    @Test func handCraftedLevelsPreserved() {
        #expect(Level.all[0].name == "ROOKIE")
        #expect(Level.all[1].name == "HOTSHOT")
        #expect(Level.all[2].name == "ACE")
        #expect(Level.all[3].name == "LEGEND")
        #expect(Level.all[4].name == "MAZE")
    }

    @Test func bossLevelsAtEveryTenthIndex() {
        for world in 1...10 {
            let idx = world * 10 - 1
            #expect(Level.all[idx].isBoss == true)
        }
    }

    @Test func nonBossLevelsAreNotBoss() {
        for (idx, level) in Level.all.enumerated() {
            let expectedBoss = (idx + 1) % 10 == 0
            #expect(level.isBoss == expectedBoss)
        }
    }

    @Test func worldComputedProperty() {
        #expect(Level.all[0].world == 1)
        #expect(Level.all[9].world == 1)
        #expect(Level.all[10].world == 2)
        #expect(Level.all[99].world == 10)
    }

    @Test func indexInWorldComputedProperty() {
        #expect(Level.all[0].indexInWorld == 1)
        #expect(Level.all[9].indexInWorld == 10)
        #expect(Level.all[10].indexInWorld == 1)
        #expect(Level.all[99].indexInWorld == 10)
    }

    @Test func levelIndexMatchesPosition() {
        for (idx, level) in Level.all.enumerated() {
            #expect(level.levelIndex == idx)
        }
    }
}
