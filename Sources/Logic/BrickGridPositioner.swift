import SpriteKit

func brickSize(sceneWidth: CGFloat, columns: Int, spacing: CGFloat, margin: CGFloat) -> CGSize {
    let totalWidth = sceneWidth - 2 * margin
    let brickWidth = (totalWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
    return CGSize(width: brickWidth, height: Theme.Layout.brickHeight)
}

func brickPosition(
    column: Int, row: Int, size: CGSize, spacing: CGFloat, gridOrigin: CGPoint
) -> CGPoint {
    let x = gridOrigin.x + CGFloat(column) * (size.width + spacing) + size.width / 2
    let y = gridOrigin.y - CGFloat(row) * (size.height + spacing) - size.height / 2
    return CGPoint(x: x, y: y)
}

func brickGridOrigin(sceneMinX: CGFloat, sceneMaxY: CGFloat, margin: CGFloat) -> CGPoint {
    CGPoint(x: sceneMinX + margin, y: sceneMaxY - Theme.Layout.brickTopMargin)
}

func brickGrid(from bricks: [BrickNode], level: Level) -> [[BrickCell]] {
    precondition(!level.grid.isEmpty, "Level grid must not be empty")
    var grid = Array(
        repeating: Array(repeating: BrickCell.empty, count: level.grid[0].count),
        count: level.grid.count
    )
    for brick in bricks {
        grid[brick.row][brick.col] = brick.currentCell
    }
    return grid
}

/// Returns `saved` if its dimensions match `shape`, otherwise `nil`.
/// Column count is compared on the first row only — safe because all grids in this project
/// are rectangular (guaranteed by level authoring and serialization).
func validatedSavedGrid(
    _ saved: [[BrickCell]]?,
    matchingShape shape: [[BrickCell]]
) -> [[BrickCell]]? {
    guard let saved,
          saved.count == shape.count,
          saved.first?.count == shape.first?.count else { return nil }
    return saved
}

struct BrickLayout {
    let size: CGSize
    let spacing: CGFloat
    let gridOrigin: CGPoint
}

/// Creates a positioned `BrickNode` for `(row, col)` if a brick should exist there,
/// otherwise `nil`.
func positionedBrickNode(
    row: Int,
    col: Int,
    levelCell: BrickCell,
    savedGrid: [[BrickCell]]?,
    layout: BrickLayout
) -> BrickNode? {
    guard let cell = resolvedBrickCell(
        levelCell: levelCell, row: row, col: col, savedGrid: savedGrid
    ) else { return nil }
    let brick = BrickNode(size: layout.size, row: row, col: col, cell: cell)
    brick.position = brickPosition(
        column: col, row: row,
        size: layout.size, spacing: layout.spacing, gridOrigin: layout.gridOrigin
    )
    return brick
}

/// Returns the cell to place at `(row, col)`, or `nil` if no brick should be placed.
func resolvedBrickCell(
    levelCell: BrickCell,
    row: Int,
    col: Int,
    savedGrid: [[BrickCell]]?
) -> BrickCell? {
    guard levelCell != .empty else { return nil }
    guard let saved = savedGrid else { return levelCell }
    let savedCell = saved[row][col]
    guard savedCell != .empty else { return nil }
    return savedCell
}

func makeBrickNodes(
    for level: Level,
    sceneFrame: CGRect,
    savedGrid: [[BrickCell]]?
) -> [BrickNode] {
    precondition(!level.grid.isEmpty, "Level grid must not be empty")
    let columns = level.grid[0].count
    let spacing = Theme.Layout.brickSpacing
    let margin = Theme.Layout.brickSideMargin
    let size = brickSize(
        sceneWidth: sceneFrame.width, columns: columns, spacing: spacing, margin: margin
    )
    let gridOrigin = brickGridOrigin(
        sceneMinX: sceneFrame.minX, sceneMaxY: sceneFrame.maxY, margin: margin
    )
    let validSavedGrid = validatedSavedGrid(savedGrid, matchingShape: level.grid)
    let layout = BrickLayout(size: size, spacing: spacing, gridOrigin: gridOrigin)

    return level.grid.enumerated().flatMap { (rowIndex, row) in
        row.enumerated().compactMap { (colIndex, levelCell) in
            positionedBrickNode(
                row: rowIndex, col: colIndex, levelCell: levelCell,
                savedGrid: validSavedGrid, layout: layout
            )
        }
    }
}
