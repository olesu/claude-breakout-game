struct LevelMetadata {
    let bossPhases: Int
}

struct Level {
    let name: String
    let grid: [[BrickCell]]
    let levelIndex: Int

    init(name: String, grid: [[BrickCell]], levelIndex: Int = 0) {
        self.name = name
        self.grid = grid
        self.levelIndex = levelIndex
    }

    var world: Int { (levelIndex / 10) + 1 }
    var indexInWorld: Int { (levelIndex % 10) + 1 }
    var isBoss: Bool { indexInWorld == 10 }

    /// Boss phase count scales with world (1 wave for worlds 1–3, 2 for 4–6, 3 for 7–9).
    /// World 10 (level 100) returns 0 — its encounter is handled separately.
    var metadata: LevelMetadata {
        guard isBoss, world < 10 else { return LevelMetadata(bossPhases: 0) }
        return LevelMetadata(bossPhases: min(3, (world + 2) / 3))
    }

    var brickCount: Int {
        grid.flatMap { $0 }.filter { $0 != .empty && $0 != .indestructible }.count
    }

    static let all: [Level] = allLevelGrids.enumerated().map { idx, entry in
        Level(name: entry.name, grid: entry.grid, levelIndex: idx)
    }
}
