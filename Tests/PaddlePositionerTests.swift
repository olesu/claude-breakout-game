import XCTest
@testable import BreakoutGame

final class PaddlePositionerTests: XCTestCase {
    // sceneWidth = 390, halfPaddleWidth = 39 (20% of 390 / 2)
    let sceneWidth: CGFloat = 390
    let halfPaddleWidth: CGFloat = 39

    func testTouchInMiddleReturnsExactX() {
        let x = clampedPaddleX(touchX: 195, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth)
        XCTAssertEqual(x, 195)
    }

    func testTouchPastLeftEdgeClamps() {
        let x = clampedPaddleX(touchX: 10, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth)
        XCTAssertEqual(x, halfPaddleWidth)
    }

    func testTouchPastRightEdgeClamps() {
        let x = clampedPaddleX(touchX: 385, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth)
        XCTAssertEqual(x, sceneWidth - halfPaddleWidth)
    }

    func testTouchExactlyAtLeftBoundaryNotClamped() {
        let x = clampedPaddleX(touchX: halfPaddleWidth, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth)
        XCTAssertEqual(x, halfPaddleWidth)
    }

    func testTouchExactlyAtRightBoundaryNotClamped() {
        let x = clampedPaddleX(touchX: sceneWidth - halfPaddleWidth, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth)
        XCTAssertEqual(x, sceneWidth - halfPaddleWidth)
    }
}
