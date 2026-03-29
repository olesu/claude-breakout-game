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

    let validSavedGrid = savedGrid.flatMap { saved -> [[BrickCell]]? in
        guard saved.count == level.grid.count,
              saved.first?.count == level.grid.first?.count else { return nil }
        return saved
    }

    var nodes: [BrickNode] = []
    for (rowIndex, row) in level.grid.enumerated() {
        for (colIndex, levelCell) in row.enumerated() {
            guard levelCell != .empty else { continue }
            let cell: BrickCell
            if let saved = validSavedGrid {
                let savedCell = saved[rowIndex][colIndex]
                guard savedCell != .empty else { continue }
                cell = savedCell
            } else {
                cell = levelCell
            }
            let brick = BrickNode(size: size, row: rowIndex, col: colIndex, cell: cell)
            brick.position = brickPosition(
                column: colIndex, row: rowIndex,
                size: size, spacing: spacing, gridOrigin: gridOrigin
            )
            nodes.append(brick)
        }
    }
    return nodes
}
