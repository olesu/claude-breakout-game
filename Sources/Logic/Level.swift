private let e: BrickCell = .empty
private let n: BrickCell = .normal
private let i: BrickCell = .indestructible
private let b: BrickCell = .bonus
private let r: BrickCell = .regenerating
private func m(_ hits: Int) -> BrickCell { .multiHit(hits) }

struct Level {
    let name: String
    let grid: [[BrickCell]]

    var brickCount: Int {
        grid.flatMap { $0 }.filter { $0 != .empty && $0 != .indestructible }.count
    }

    static let one = Level(name: "ROOKIE", grid: [
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, b, b, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n]
    ])

    static let two = Level(name: "HOTSHOT", grid: [
        [n, e, n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n, e, n],
        [n, e, n, e, n, e, n, e, n, e],
        [e, n, e, n, e, n, e, n, e, n]
    ])

    // Diamond avec 2 briques régénérantes au centre
    static let three = Level(name: "ACE", grid: [
        [e, e, e, e, b, b, e, e, e, e],
        [e, e, e, n, n, n, n, e, e, e],
        [e, e, n, n, n, n, n, n, e, e],
        [e, n, n, n, n, n, n, n, n, e],
        [n, n, n, n, r, r, n, n, n, n],
        [e, n, n, n, n, n, n, n, n, e],
        [e, e, n, n, n, n, n, n, e, e],
        [e, e, e, n, n, n, n, e, e, e],
        [e, e, e, e, b, b, e, e, e, e]
    ])

    static let four = Level(name: "LEGEND", grid: [
        [m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2), m(2)],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n],
        [n, n, n, n, n, n, n, n, n, n]
    ])

    // Labyrinthe avec 4 briques régénérantes dans les coins intérieurs
    static let five = Level(name: "MAZE", grid: [
        [n, n, n, i, i, i, i, n, n, n],
        [n, e, e, e, e, e, e, e, e, n],
        [n, e, n, n, e, e, n, n, e, n],
        [i, e, n, e, n, n, e, n, e, i],
        [i, e, n, e, r, r, e, n, e, i],
        [i, e, n, e, r, r, e, n, e, i],
        [i, e, n, e, n, n, e, n, e, i],
        [n, e, n, n, e, e, n, n, e, n],
        [n, e, e, e, e, e, e, e, e, n],
        [n, n, n, i, i, i, i, n, n, n]
    ])

    static let all: [Level] = [.one, .two, .three, .four, .five]
}
