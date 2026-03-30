private let e: BrickCell = .empty
private let n: BrickCell = .normal
private let i: BrickCell = .indestructible
private let b: BrickCell = .bonus
private func m(_ hits: Int) -> BrickCell { .multiHit(hits) }

struct Level {
    let name: String
    let grid: [[BrickCell]]

    var brickCount: Int {
        grid.flatMap { $0 }.filter { $0 != .empty && $0 != .indestructible }.count
    }

    // 5 rows × 8 columns, fully packed — 38 normal + 2 bonus = 40 bricks
    static let one = Level(name: "ROOKIE", grid: [
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, b, b, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n]
    ])

    // 6 rows × 8 columns, checkerboard — 24 bricks
    static let two = Level(name: "HOTSHOT", grid: [
        [n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n]
    ])

    // 7 rows × 8 columns, diamond — center row has 3-hit bricks, tips are bonus
    static let three = Level(name: "ACE", grid: [
        [e, e, e, b, b, e, e, e],
        [e, e, n, n, n, n, e, e],
        [e, n, n, n, n, n, n, e],
        [n, n, n, m(3), m(3), n, n, n],
        [e, n, n, n, n, n, n, e],
        [e, e, n, n, n, n, e, e],
        [e, e, e, b, b, e, e, e]
    ])

    // 7 rows × 8 columns, fully packed — top row has 2-hit bricks
    static let four = Level(name: "LEGEND", grid: [
        [m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2)],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n]
    ])

    // 8 rows × 8 columns, maze with indestructible pillars
    static let five = Level(name: "MAZE", grid: [
        [n, n, n, i, i, n, n, n],
        [n, e, e, e, e, e, e, n],
        [n, e, n, n, n, n, e, n],
        [i, e, n, m(2), m(2), n, e, i],
        [i, e, n, m(2), m(2), n, e, i],
        [n, e, n, n, n, n, e, n],
        [n, e, e, e, e, e, e, n],
        [n, n, n, i, i, n, n, n]
    ])

    static let all: [Level] = [.one, .two, .three, .four, .five]
}
