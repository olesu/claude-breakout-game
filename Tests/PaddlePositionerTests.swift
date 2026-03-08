@testable import BreakoutGame
import CoreGraphics
import Testing

struct PaddlePositionerTests {
    // sceneWidth = 390, halfPaddleWidth = 39 (20% of 390 / 2)
    let sceneWidth: CGFloat = 390
    let halfPaddleWidth: CGFloat = 39

    @Test func touchInMiddleReturnsExactX() {
        #expect(clampedPaddleX(touchX: 195, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth) == 195)
    }

    @Test func touchPastLeftEdgeClamps() {
        #expect(clampedPaddleX(touchX: 10, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth) == halfPaddleWidth)
    }

    @Test func touchPastRightEdgeClamps() {
        #expect(clampedPaddleX(touchX: 385, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth) == sceneWidth - halfPaddleWidth)
    }

    @Test func touchExactlyAtLeftBoundaryNotClamped() {
        #expect(clampedPaddleX(touchX: halfPaddleWidth, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth) == halfPaddleWidth)
    }

    @Test func touchExactlyAtRightBoundaryNotClamped() {
        #expect(clampedPaddleX(touchX: sceneWidth - halfPaddleWidth, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth) == sceneWidth - halfPaddleWidth)
    }
}
