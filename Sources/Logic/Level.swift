struct LevelMetadata {}

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

    var brickCount: Int {
        grid.flatMap { $0 }.filter { $0 != .empty && $0 != .indestructible }.count
    }

    static let all: [Level] = allLevelGrids.enumerated().map { idx, entry in
        Level(name: entry.name, grid: entry.grid, levelIndex: idx)
    }
}
