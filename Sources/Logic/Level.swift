struct Level {
    let name: String
    let grid: [[Bool]]  // true = brick present, row 0 = top row

    var brickCount: Int { grid.flatMap { $0 }.filter { $0 }.count }

    static let one = Level(name: "LEVEL 1", grid: [
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true]
    ])
}
