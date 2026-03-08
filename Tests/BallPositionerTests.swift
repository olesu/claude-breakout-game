@testable import BreakoutGame
import CoreGraphics
import Testing

struct BallPositionerTests {
    let paddleHalfHeight: CGFloat = 7  // Theme.Layout.paddleHeight / 2
    let ballRadius: CGFloat = 10       // Theme.Layout.ballRadius

    @Test func ballXMatchesPaddleX() {
        let pos = ballRestingPosition(
            paddlePosition: CGPoint(x: 195, y: 60),
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: ballRadius
        )
        #expect(pos.x == 195)
    }

    @Test func ballYIsPaddleYPlusHalfHeightPlusRadius() {
        let pos = ballRestingPosition(
            paddlePosition: CGPoint(x: 195, y: 60),
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: ballRadius
        )
        #expect(pos.y == 60 + paddleHalfHeight + ballRadius)
    }

    @Test func ballYIsIndependentOfPaddleX() {
        let pos1 = ballRestingPosition(
            paddlePosition: CGPoint(x: 100, y: 60),
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: ballRadius
        )
        let pos2 = ballRestingPosition(
            paddlePosition: CGPoint(x: 300, y: 60),
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: ballRadius
        )
        #expect(pos1.y == pos2.y)
    }

    @Test func zeroPaddleOrigin() {
        let pos = ballRestingPosition(
            paddlePosition: .zero,
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: ballRadius
        )
        #expect(pos.x == 0)
        #expect(pos.y == paddleHalfHeight + ballRadius)
    }

    @Test func movedPaddleUpdatesX() {
        let pos = ballRestingPosition(
            paddlePosition: CGPoint(x: 50, y: 60),
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: ballRadius
        )
        #expect(pos.x == 50)
    }
}
