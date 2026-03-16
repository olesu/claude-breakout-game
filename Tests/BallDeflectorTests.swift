@testable import BreakoutGame
import CoreGraphics
import Testing

private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
    abs(a - b) < tolerance
}

struct BallDeflectorTests {
    let speed: CGFloat = 500
    let halfWidth: CGFloat = 50
    let maxAngle: CGFloat = .pi / 3  // 60°

    // MARK: - paddleReflectedVelocity

    @Test func centreHit_goesStraightUp() {
        let v = paddleReflectedVelocity(
            speed: speed, contactX: 100, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        #expect(isClose(v.dx, 0))
        #expect(isClose(v.dy, speed))
    }

    @Test func rightEdgeHit_angleIsMaxAngle() {
        let v = paddleReflectedVelocity(
            speed: speed, contactX: 150, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        // cos(60°) = 0.5
        #expect(isClose(v.dy, speed * 0.5))
        #expect(v.dx > 0)
    }

    @Test func leftEdgeHit_angleIsMaxAngle() {
        let v = paddleReflectedVelocity(
            speed: speed, contactX: 50, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        #expect(isClose(v.dy, speed * 0.5))
        #expect(v.dx < 0)
    }

    @Test func beyondRightEdge_clampedToEdge() {
        let edge = paddleReflectedVelocity(
            speed: speed, contactX: 150, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        let beyond = paddleReflectedVelocity(
            speed: speed, contactX: 200, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        #expect(isClose(beyond.dx, edge.dx))
        #expect(isClose(beyond.dy, edge.dy))
    }

    @Test func speedIsPreserved_atCentre() {
        let v = paddleReflectedVelocity(
            speed: speed, contactX: 100, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        #expect(isClose(hypot(v.dx, v.dy), speed))
    }

    @Test func speedIsPreserved_atEdge() {
        let v = paddleReflectedVelocity(
            speed: speed, contactX: 150, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        #expect(isClose(hypot(v.dx, v.dy), speed))
    }

    @Test func dyIsAlwaysPositive() {
        for fraction in stride(from: -1.0, through: 1.0, by: 0.1) {
            let v = paddleReflectedVelocity(
                speed: speed,
                contactX: 100 + halfWidth * fraction,
                paddleCenterX: 100,
                halfPaddleWidth: halfWidth,
                maxAngle: maxAngle
            )
            #expect(v.dy >= 0)
        }
    }

    @Test func zeroSpeed_returnsZeroVector() {
        let v = paddleReflectedVelocity(
            speed: 0, contactX: 120, paddleCenterX: 100,
            halfPaddleWidth: halfWidth, maxAngle: maxAngle
        )
        #expect(v.dx == 0)
        #expect(v.dy == 0)
    }

    @Test func zeroHalfPaddleWidth_returnsZeroVector() {
        let v = paddleReflectedVelocity(
            speed: speed, contactX: 120, paddleCenterX: 100,
            halfPaddleWidth: 0, maxAngle: maxAngle
        )
        #expect(v.dx == 0)
        #expect(v.dy == 0)
    }

    // MARK: - clampedVerticalVelocity

    @Test func nearHorizontalUpward_dyRaisedToMinimum() {
        let input = CGVector(dx: 499, dy: 10)
        let v = clampedVerticalVelocity(velocity: input, minVerticalRatio: 0.2)
        let s = hypot(input.dx, input.dy)
        #expect(v.dy >= s * 0.2 - 0.001)
    }

    @Test func nearHorizontalDownward_dyLoweredToNegativeMinimum() {
        let input = CGVector(dx: 499, dy: -10)
        let v = clampedVerticalVelocity(velocity: input, minVerticalRatio: 0.2)
        let s = hypot(input.dx, input.dy)
        #expect(v.dy <= -(s * 0.2) + 0.001)
    }

    @Test func steepAngle_unchanged() {
        let input = CGVector(dx: 200, dy: 450)
        let v = clampedVerticalVelocity(velocity: input, minVerticalRatio: 0.2)
        #expect(v.dx == input.dx)
        #expect(v.dy == input.dy)
    }

    @Test func exactlyAtThreshold_unchanged() {
        // speed = 500, dy = 100 = 0.2 * 500 → exactly at threshold
        let input = CGVector(dx: CGFloat(sqrt(500.0 * 500.0 - 100.0 * 100.0)), dy: 100)
        let v = clampedVerticalVelocity(velocity: input, minVerticalRatio: 0.2)
        #expect(isClose(v.dx, input.dx))
        #expect(isClose(v.dy, input.dy))
    }

    @Test func speedIsPreserved_afterClamping() {
        let input = CGVector(dx: 499, dy: 10)
        let v = clampedVerticalVelocity(velocity: input, minVerticalRatio: 0.2)
        #expect(isClose(hypot(v.dx, v.dy), hypot(input.dx, input.dy)))
    }

    @Test func zeroVelocity_returnsZeroVector() {
        let v = clampedVerticalVelocity(velocity: .zero, minVerticalRatio: 0.2)
        #expect(v.dx == 0)
        #expect(v.dy == 0)
    }

    @Test func dxSignIsPreserved_leftwardBall() {
        let v = clampedVerticalVelocity(
            velocity: CGVector(dx: -499, dy: 10), minVerticalRatio: 0.2
        )
        #expect(v.dx < 0)
    }

    @Test func ratioAboveOne_clampedToOne_forcesVertical() {
        // ratio > 1 clamps to 1 → ball forced straight up (dx → 0)
        let v = clampedVerticalVelocity(velocity: CGVector(dx: 300, dy: 400), minVerticalRatio: 1.5)
        #expect(isClose(v.dx, 0))
        #expect(isClose(hypot(v.dx, v.dy), hypot(300, 400)))
    }

    @Test func negativRatio_clampedToZero_noMinimumEnforced() {
        // ratio < 0 clamps to 0 → no minimum, so near-horizontal velocity passes through
        let input = CGVector(dx: 499, dy: 1)
        let v = clampedVerticalVelocity(velocity: input, minVerticalRatio: -0.1)
        #expect(v.dx == input.dx)
        #expect(v.dy == input.dy)
    }
}
