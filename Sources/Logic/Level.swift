private let e: BrickCell = .empty
private let n: BrickCell = .normal
private func m(_ hits: Int) -> BrickCell { .multiHit(hits) }

struct Level {
    let name: String
    let grid: [[BrickCell]]

    var brickCount: Int { grid.flatMap { $0 }.filter { $0 != .empty }.count }

    // 5 rows × 8 columns, fully packed — 40 bricks
    static let one = Level(name: "ROOKIE", grid: [
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n],
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

    // 7 rows × 8 columns, diamond — center row has 3-hit bricks
    static let three = Level(name: "ACE", grid: [
        [e, e, e, n, n, e, e, e],
        [e, e, n, n, n, n, e, e],
        [e, n, n, n, n, n, n, e],
        [n, n, n, m(3), m(3), n, n, n],
        [e, n, n, n, n, n, n, e],
        [e, e, n, n, n, n, e, e],
        [e, e, e, n, n, e, e, e]
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

    static let all: [Level] = [.one, .two, .three, .four]
}
