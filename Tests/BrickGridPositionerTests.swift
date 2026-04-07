@testable import BreakoutGame
import Testing
import CoreGraphics

private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
    abs(a - b) < tolerance
}

// swiftlint:disable:next type_body_length
struct BrickGridPositionerTests {
    // Arbitrary fixture size for positional math tests; brickSizeHeightEqualsThemeConstant
    // covers the theme constant.
    let size = CGSize(width: 34.5, height: 20)
    let origin = CGPoint(x: 8, y: 500)

    // brickSize tests

    @Test func brickSizeWidthFillsAvailableSpace() {
        // sceneWidth=320, 8 columns, spacing=4, margin=8
        // totalWidth = 320 - 16 = 304
        // brickWidth = (304 - 4*7) / 8 = 276 / 8 = 34.5
        let s = brickSize(sceneWidth: 320, columns: 8, spacing: 4, margin: 8)
        #expect(isClose(s.width, 34.5))
    }

    @Test func brickSizeHeightEqualsThemeConstant() {
        let s = brickSize(sceneWidth: 320, columns: 8, spacing: 4, margin: 8)
        #expect(isClose(s.height, Theme.Layout.brickHeight))
    }

    // brickPosition tests

    @Test func brickPositionFirstBrick() {
        let pos = brickPosition(column: 0, row: 0, size: size, spacing: 4, gridOrigin: origin)
        // x = 8 + 0*(38.5) + 17.25 = 25.25
        // y = 500 - 0*(24) - 10 = 490
        #expect(isClose(pos.x, 25.25))
        #expect(isClose(pos.y, 490))
    }

    @Test func brickPositionSecondColumnFirstRow() {
        let pos = brickPosition(column: 1, row: 0, size: size, spacing: 4, gridOrigin: origin)
        // x = 8 + 1*(38.5) + 17.25 = 63.75
        // y = 490
        #expect(isClose(pos.x, 63.75))
        #expect(isClose(pos.y, 490))
    }

    @Test func brickPositionFirstColumnSecondRow() {
        let pos = brickPosition(column: 0, row: 1, size: size, spacing: 4, gridOrigin: origin)
        // x = 25.25
        // y = 500 - 1*(24) - 10 = 466
        #expect(isClose(pos.x, 25.25))
        #expect(isClose(pos.y, 466))
    }

    @Test func brickPositionLastColumnLastRow() {
        let pos = brickPosition(column: 7, row: 4, size: size, spacing: 4, gridOrigin: origin)
        // x = 8 + 7*(38.5) + 17.25 = 294.75
        // y = 500 - 4*(24) - 10 = 394
        #expect(isClose(pos.x, 294.75))
        #expect(isClose(pos.y, 394))
    }

    // brickGrid(from:level:) tests

    @Test func brickGridAllBricksPresent() {
        let level = Level(name: "T", grid: [[.normal, .normal], [.normal, .normal]])
        let brickSize = CGSize(width: 10, height: 10)
        let bricks = [
            BrickNode(size: brickSize, row: 0, col: 0, cell: .normal),
            BrickNode(size: brickSize, row: 0, col: 1, cell: .normal),
            BrickNode(size: brickSize, row: 1, col: 0, cell: .normal),
            BrickNode(size: brickSize, row: 1, col: 1, cell: .normal)
        ]
        let grid = brickGrid(from: bricks, level: level)
        #expect(grid == [[.normal, .normal], [.normal, .normal]])
    }

    @Test func brickGridNoBricks() {
        let level = Level(name: "T", grid: [[.normal, .normal], [.normal, .normal]])
        let grid = brickGrid(from: [], level: level)
        #expect(grid == [[.empty, .empty], [.empty, .empty]])
    }

    @Test func brickGridSparsePattern() {
        let level = Level(name: "T", grid: [[.normal, .normal], [.normal, .normal]])
        let brickSize = CGSize(width: 10, height: 10)
        let bricks = [
            BrickNode(size: brickSize, row: 0, col: 1, cell: .normal),
            BrickNode(size: brickSize, row: 1, col: 0, cell: .normal)
        ]
        let grid = brickGrid(from: bricks, level: level)
        #expect(grid == [[.empty, .normal], [.normal, .empty]])
    }

    @Test func brickGridSnapshotsIndestructible() {
        let level = Level(name: "T", grid: [[.indestructible, .normal], [.normal, .normal]])
        let brickSize = CGSize(width: 10, height: 10)
        let brick = BrickNode(size: brickSize, row: 0, col: 0, cell: .indestructible)
        let grid = brickGrid(from: [brick], level: level)
        #expect(grid[0][0] == .indestructible)
        #expect(grid[0][1] == .empty)
    }

    @Test func brickGridSnapshotsBonusAsBonus() {
        let level = Level(name: "T", grid: [[.bonus, .normal], [.normal, .normal]])
        let brickSize = CGSize(width: 10, height: 10)
        let brick = BrickNode(size: brickSize, row: 0, col: 0, cell: .bonus)
        let grid = brickGrid(from: [brick], level: level)
        #expect(grid[0][0] == .bonus)
        #expect(grid[0][1] == .empty)
    }

    @Test func brickGridSnapshotsDamagedMultiHit() {
        let level = Level(name: "T", grid: [[.multiHit(3), .normal], [.normal, .normal]])
        let brickSize = CGSize(width: 10, height: 10)
        let damagedBrick = BrickNode(size: brickSize, row: 0, col: 0, cell: .multiHit(2))
        let bricks = [damagedBrick]
        let grid = brickGrid(from: bricks, level: level)
        // Snapshot captures the cell's current state, not the original level cell
        #expect(grid[0][0] == .multiHit(2))
        #expect(grid[0][1] == .empty)
    }

    // positionedBrickNode tests

    var layout: BrickLayout { BrickLayout(size: size, spacing: 4, gridOrigin: origin) }

    @Test func positionedBrickNodeEmptyLevelCell() {
        let node = positionedBrickNode(
            row: 0, col: 0, levelCell: .empty, savedGrid: nil, layout: layout
        )
        #expect(node == nil)
    }

    @Test func positionedBrickNodeBonusCell() {
        let node = positionedBrickNode(
            row: 0, col: 0, levelCell: .bonus, savedGrid: nil, layout: layout
        )
        #expect(node?.isBonus == true)
    }

    @Test func positionedBrickNodeNormalCell() {
        let node = positionedBrickNode(
            row: 0, col: 0, levelCell: .normal, savedGrid: nil, layout: layout
        )
        #expect(node?.row == 0)
        #expect(node?.col == 0)
    }

    @Test func positionedBrickNodePositionMatchesBrickPosition() {
        let node = positionedBrickNode(
            row: 1, col: 2, levelCell: .normal, savedGrid: nil, layout: layout
        )
        let expected = brickPosition(column: 2, row: 1, size: size, spacing: 4, gridOrigin: origin)
        #expect(node?.position == expected)
    }

    @Test func positionedBrickNodeSavedCellEmpty() {
        let saved: [[BrickCell]] = [[.empty, .normal]]
        let node = positionedBrickNode(
            row: 0, col: 0, levelCell: .normal, savedGrid: saved, layout: layout
        )
        #expect(node == nil)
    }

    // validatedSavedGrid tests

    @Test func validatedSavedGridNilInput() {
        let shape: [[BrickCell]] = [[.normal, .normal], [.normal, .normal]]
        #expect(validatedSavedGrid(nil, matchingShape: shape) == nil)
    }

    @Test func validatedSavedGridMatchingDimensions() {
        let grid: [[BrickCell]] = [[.normal, .empty], [.empty, .normal]]
        let shape: [[BrickCell]] = [[.normal, .normal], [.normal, .normal]]
        #expect(validatedSavedGrid(grid, matchingShape: shape) == grid)
    }

    @Test func validatedSavedGridRowCountMismatch() {
        let grid: [[BrickCell]] = [[.normal, .normal]]
        let shape: [[BrickCell]] = [[.normal, .normal], [.normal, .normal]]
        #expect(validatedSavedGrid(grid, matchingShape: shape) == nil)
    }

    @Test func validatedSavedGridColumnCountMismatch() {
        let grid: [[BrickCell]] = [[.normal, .normal, .normal], [.normal, .normal, .normal]]
        let shape: [[BrickCell]] = [[.normal, .normal], [.normal, .normal]]
        #expect(validatedSavedGrid(grid, matchingShape: shape) == nil)
    }

    // resolvedBrickCell tests

    @Test func resolvedBrickCellEmptyLevelCell() {
        #expect(resolvedBrickCell(levelCell: .empty, row: 0, col: 0, savedGrid: nil) == nil)
    }

    @Test func resolvedBrickCellNoSavedGrid() {
        #expect(resolvedBrickCell(levelCell: .normal, row: 0, col: 0, savedGrid: nil) == .normal)
    }

    @Test func resolvedBrickCellSavedCellNonEmpty() {
        let saved: [[BrickCell]] = [[.multiHit(2), .normal]]
        let result = resolvedBrickCell(levelCell: .normal, row: 0, col: 0, savedGrid: saved)
        #expect(result == .multiHit(2))
    }

    @Test func resolvedBrickCellSavedCellEmpty() {
        let saved: [[BrickCell]] = [[.empty, .normal]]
        #expect(resolvedBrickCell(levelCell: .normal, row: 0, col: 0, savedGrid: saved) == nil)
    }

    @Test func resolvedBrickCellIndestructibleOverriddenBySavedEmpty() {
        // A saved .empty suppresses even an indestructible level cell.
        // In practice this cannot occur (indestructible bricks are never destroyed),
        // but the function makes no special exception for .indestructible.
        let saved: [[BrickCell]] = [[.empty]]
        let result = resolvedBrickCell(levelCell: .indestructible, row: 0, col: 0, savedGrid: saved)
        #expect(result == nil)
    }

    // brickGridOrigin tests

    @Test func brickGridOriginX() {
        let o = brickGridOrigin(sceneMinX: 0, sceneMaxY: 800, margin: 8)
        #expect(isClose(o.x, 8))
    }

    @Test func brickGridOriginY() {
        let o = brickGridOrigin(sceneMinX: 0, sceneMaxY: 800, margin: 8)
        #expect(isClose(o.y, 800 - Theme.Layout.brickTopMargin))
    }

    @Test func brickGridOriginRespectsNonZeroSceneMinX() {
        let o = brickGridOrigin(sceneMinX: 10, sceneMaxY: 800, margin: 8)
        #expect(isClose(o.x, 18))
    }
}
