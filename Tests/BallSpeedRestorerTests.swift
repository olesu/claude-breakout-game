@testable import BreakoutGame
import CoreGraphics
import Testing

private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
    abs(a - b) < tolerance
}

struct BallSpeedRestorerTests {
    // MARK: - restoredVelocity

    @Test func restoresSpeedToSavedValue() {
        // Ball slowed to half speed diagonally; should be restored to 500.
        let v = restoredVelocity(
            current: CGVector(dx: 150, dy: 200),
            savedSpeed: 500
        )
        #expect(isClose(hypot(v.dx, v.dy), 500))
    }

    @Test func preservesDirection() {
        let current = CGVector(dx: 150, dy: 200)
        let v = restoredVelocity(current: current, savedSpeed: 500)
        // Angle must match: atan2(dy, dx) should be equal.
        let originalAngle = atan2(current.dy, current.dx)
        let restoredAngle = atan2(v.dy, v.dx)
        #expect(isClose(restoredAngle, originalAngle, tolerance: 0.0001))
    }

    @Test func zeroCurrentSpeed_returnsZero() {
        let v = restoredVelocity(current: .zero, savedSpeed: 500)
        #expect(v.dx == 0)
        #expect(v.dy == 0)
    }

    @Test func zeroSavedSpeed_returnsZeroMagnitude() {
        let v = restoredVelocity(current: CGVector(dx: 150, dy: 200), savedSpeed: 0)
        #expect(isClose(hypot(v.dx, v.dy), 0))
    }

    @Test func alreadyAtCorrectSpeed_returnsUnchanged() {
        let current = CGVector(dx: 300, dy: 400)  // speed = 500
        let v = restoredVelocity(current: current, savedSpeed: 500)
        #expect(isClose(v.dx, 300))
        #expect(isClose(v.dy, 400))
    }

    @Test func negativeComponents_preservedAfterRestore() {
        let current = CGVector(dx: -150, dy: -200)
        let v = restoredVelocity(current: current, savedSpeed: 500)
        #expect(isClose(hypot(v.dx, v.dy), 500))
        #expect(v.dx < 0)
        #expect(v.dy < 0)
    }
}
