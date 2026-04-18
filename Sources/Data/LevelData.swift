private let e: BrickCell = .empty
private let n: BrickCell = .normal
private let i: BrickCell = .indestructible
private let b: BrickCell = .bonus
private func m(_ hits: Int) -> BrickCell { .multiHit(hits) }

// MARK: - Hand-crafted levels (1–5)

private let levelOneGrid: [[BrickCell]] = [
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, b, b, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n]
]

private let levelTwoGrid: [[BrickCell]] = [
    [n, e, n, e, n, e, n, e, n, e],
    [e, n, e, n, e, n, e, n, e, n],
    [n, e, n, e, n, e, n, e, n, e],
    [e, n, e, n, e, n, e, n, e, n],
    [n, e, n, e, n, e, n, e, n, e],
    [e, n, e, n, e, n, e, n, e, n],
    [n, e, n, e, n, e, n, e, n, e],
    [e, n, e, n, e, n, e, n, e, n]
]

private let levelThreeGrid: [[BrickCell]] = [
    [e, e, e, e, b, b, e, e, e, e],
    [e, e, e, n, n, n, n, e, e, e],
    [e, e, n, n, n, n, n, n, e, e],
    [e, n, n, n, n, n, n, n, n, e],
    [n, n, n, n, m(3), m(3), n, n, n, n],
    [e, n, n, n, n, n, n, n, n, e],
    [e, e, n, n, n, n, n, n, e, e],
    [e, e, e, n, n, n, n, e, e, e],
    [e, e, e, e, b, b, e, e, e, e]
]

private let levelFourGrid: [[BrickCell]] = [
    [m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2)],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n],
    [n, n, n, n, n, n, n, n, n, n]
]

private let levelFiveGrid: [[BrickCell]] = [
    [n, n, n, i, i, i, i, n, n, n],
    [n, e, e, e, e, e, e, e, e, n],
    [n, e, n, n, e, e, n, n, e, n],
    [i, e, n, e, n, n, e, n, e, i],
    [i, e, n, e, m(2), m(2), e, n, e, i],
    [i, e, n, e, m(2), m(2), e, n, e, i],
    [i, e, n, e, n, n, e, n, e, i],
    [n, e, n, n, e, e, n, n, e, n],
    [n, e, e, e, e, e, e, e, e, n],
    [n, n, n, i, i, i, i, n, n, n]
]

// MARK: - Programmatic stub generator

/// Generates a simple placeholder grid for levels that have not yet been hand-crafted.
/// The pattern varies by level index so each level looks slightly different.
private func stubGrid(levelIndex: Int) -> [[BrickCell]] {
    let rows = min(4 + (levelIndex / 10), 10)
    let isBoss = (levelIndex + 1) % 10 == 0
    return (0..<rows).map { row in
        (0..<10).map { col in
            if isBoss && row == 0 { return m(3) }
            if (row + col + levelIndex) % 5 == 0 { return e }
            if (row + col) % 7 == 0 { return b }
            if isBoss && (row + col) % 4 == 0 { return i }
            return n
        }
    }
}

// MARK: - All 100 levels

let allLevelGrids: [(name: String, grid: [[BrickCell]])] = {
    var levels: [(name: String, grid: [[BrickCell]])] = []

    // Hand-crafted levels 1–5
    levels.append(("ROOKIE", levelOneGrid))
    levels.append(("HOTSHOT", levelTwoGrid))
    levels.append(("ACE", levelThreeGrid))
    levels.append(("LEGEND", levelFourGrid))
    levels.append(("MAZE", levelFiveGrid))

    // Programmatic stubs for levels 6–100
    for idx in 5..<100 {
        let number = idx + 1
        let world = (idx / 10) + 1
        let positionInWorld = (idx % 10) + 1
        let isBoss = positionInWorld == 10
        let name = isBoss ? "WORLD \(world) BOSS" : "LEVEL \(number)"
        levels.append((name, stubGrid(levelIndex: idx)))
    }

    return levels
}()
