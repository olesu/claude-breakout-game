struct Level {
    let name: String
    let grid: [[Bool]]  // true = brick present, row 0 = top row

    static let one = Level(name: "LEVEL 1", grid: [
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true],
        [true, true, true, true, true, true, true, true]
    ])
}
