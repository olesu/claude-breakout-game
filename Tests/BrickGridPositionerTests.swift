@testable import BreakoutGame
import Testing
import CoreGraphics

struct BrickGridPositionerTests {

    // brickSize tests

    @Test func brickSizeWidthFillsAvailableSpace() {
        // sceneWidth=320, 8 columns, spacing=4, margin=8
        // totalWidth = 320 - 16 = 304
        // brickWidth = (304 - 4*7) / 8 = 276 / 8 = 34.5
        let size = brickSize(sceneWidth: 320, columns: 8, spacing: 4, margin: 8)
        #expect(size.width == 34.5)
    }

    @Test func brickSizeHeightEqualsThemeConstant() {
        let size = brickSize(sceneWidth: 320, columns: 8, spacing: 4, margin: 8)
        #expect(size.height == 20)
    }

    // brickPosition tests

    @Test func brickPositionFirstBrick() {
        let size = CGSize(width: 34.5, height: 20)
        let origin = CGPoint(x: 8, y: 500)
        let pos = brickPosition(column: 0, row: 0, size: size, spacing: 4, gridOrigin: origin)
        // x = 8 + 0*(38.5) + 17.25 = 25.25
        // y = 500 - 0*(24) - 10 = 490
        #expect(pos.x == 25.25)
        #expect(pos.y == 490)
    }

    @Test func brickPositionSecondColumnFirstRow() {
        let size = CGSize(width: 34.5, height: 20)
        let origin = CGPoint(x: 8, y: 500)
        let pos = brickPosition(column: 1, row: 0, size: size, spacing: 4, gridOrigin: origin)
        // x = 8 + 1*(38.5) + 17.25 = 63.75
        // y = 490
        #expect(pos.x == 63.75)
        #expect(pos.y == 490)
    }

    @Test func brickPositionFirstColumnSecondRow() {
        let size = CGSize(width: 34.5, height: 20)
        let origin = CGPoint(x: 8, y: 500)
        let pos = brickPosition(column: 0, row: 1, size: size, spacing: 4, gridOrigin: origin)
        // x = 25.25
        // y = 500 - 1*(24) - 10 = 466
        #expect(pos.x == 25.25)
        #expect(pos.y == 466)
    }

    @Test func brickPositionLastColumnLastRow() {
        let size = CGSize(width: 34.5, height: 20)
        let origin = CGPoint(x: 8, y: 500)
        let pos = brickPosition(column: 7, row: 4, size: size, spacing: 4, gridOrigin: origin)
        // x = 8 + 7*(38.5) + 17.25 = 294.75
        // y = 500 - 4*(24) - 10 = 394
        #expect(pos.x == 294.75)
        #expect(pos.y == 394)
    }
}
