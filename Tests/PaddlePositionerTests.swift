@testable import BreakoutGame
import CoreGraphics
import Testing

struct PaddlePositionerTests {
    // sceneWidth = 390, halfPaddleWidth = 39 (20% of 390 / 2)
    let sceneWidth: CGFloat = 390
    let halfPaddleWidth: CGFloat = 39

    @Test func touchInMiddleReturnsExactX() {
        let result = clampedPaddleX(
            touchX: 195, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth
        )
        #expect(result == 195)
    }

    @Test func touchPastLeftEdgeClamps() {
        let result = clampedPaddleX(
            touchX: 10, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth
        )
        #expect(result == halfPaddleWidth)
    }

    @Test func touchPastRightEdgeClamps() {
        let result = clampedPaddleX(
            touchX: 385, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth
        )
        #expect(result == sceneWidth - halfPaddleWidth)
    }

    @Test func touchExactlyAtLeftBoundaryNotClamped() {
        let result = clampedPaddleX(
            touchX: halfPaddleWidth, sceneWidth: sceneWidth, halfPaddleWidth: halfPaddleWidth
        )
        #expect(result == halfPaddleWidth)
    }

    @Test func touchExactlyAtRightBoundaryNotClamped() {
        let result = clampedPaddleX(
            touchX: sceneWidth - halfPaddleWidth,
            sceneWidth: sceneWidth,
            halfPaddleWidth: halfPaddleWidth
        )
        #expect(result == sceneWidth - halfPaddleWidth)
    }
}
