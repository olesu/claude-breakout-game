struct Level {
    let name: String
    let grid: [[Bool]]  // true = brick present, row 0 = top row

    var brickCount: Int { grid.flatMap { $0 }.filter { $0 }.count }

    // 5 rows × 8 columns, fully packed — 40 bricks
    static let one = Level(name: "ROOKIE", grid: [
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true]
    ])

    // 6 rows × 8 columns, checkerboard — 24 bricks
    static let two = Level(name: "HOTSHOT", grid: [
        [true, false, true, false, true, false, true, false],
        [false, true, false, true, false, true, false, true],
        [true, false, true, false, true, false, true, false],
        [false, true, false, true, false, true, false, true],
        [true, false, true, false, true, false, true, false],
        [false, true, false, true, false, true, false, true]
    ])

    // 7 rows × 8 columns, diamond — 32 bricks
    static let three = Level(name: "ACE", grid: [
        [false, false, false, true, true, false, false, false],
        [false, false, true, true, true, true, false, false],
        [false, true, true, true, true, true, true, false],
        [true, true, true, true, true, true, true, true],
        [false, true, true, true, true, true, true, false],
        [false, false, true, true, true, true, false, false],
        [false, false, false, true, true, false, false, false]
    ])

    // 7 rows × 8 columns, fully packed — 56 bricks
    static let four = Level(name: "LEGEND", grid: [
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true]
    ])

    static let all: [Level] = [.one, .two, .three, .four]
}
