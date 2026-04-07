private let e: BrickCell = .empty
private let n: BrickCell = .normal
private let i: BrickCell = .indestructible
private let b: BrickCell = .bonus
private let x: BrickCell = .explosive
private func m(_ hits: Int) -> BrickCell { .multiHit(hits) }

struct Level {
    let name: String
    let grid: [[BrickCell]]

    var brickCount: Int {
        grid.flatMap { $0 }.filter { $0 != .empty && $0 != .indestructible }.count
    }

    // 5 rows x 10 columns, fully packed — 48 normal + 2 bonus = 50 bricks
    static let one = Level(name: "ROOKIE", grid: [
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, b, b, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n]
    ])

    // 8 rows x 10 columns, checkerboard avec briques explosives — 40 bricks
    static let two = Level(name: "HOTSHOT", grid: [
        [n, e, n, e, x, e, x, e, n, e],
        [e, n, e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e, n, e],
        [e, x, e, n, e, x, e, n, e, n]
    ])

    // 9 rows x 10 columns, diamond — 2 bonus at each tip, center row has 3-hit bricks
    static let three = Level(name: "ACE", grid: [
        [e, e, e, e, b, b, e, e, e, e],
        [e, e, e, n, n, n, n, e, e, e],
        [e, e, n, n, n, n, n, n, e, e],
        [e, n, n, n, n, n, n, n, n, e],
        [n, n, n, n, m(3), m(3), n, n, n, n],
        [e, n, n, n, n, n, n, n, n, e],
        [e, e, n, n, n, n, n, n, e, e],
        [e, e, e, n, n, n, n, e, e, e],
        [e, e, e, e, b, b, e, e, e, e]
    ])

    // 7 rows x 10 columns, fully packed — top row has 2-hit bricks, cluster explosif au centre
    static let four = Level(name: "LEGEND", grid: [
        [m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2)],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, x, x, x, x, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n]
    ])

    // 10 rows x 10 columns, symmetric labyrinth — 44 bricks
    static let five = Level(name: "MAZE", grid: [
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
    ])

    static let all: [Level] = [.one, .two, .three, .four, .five]
}
