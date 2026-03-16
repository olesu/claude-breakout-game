@testable import BreakoutGame
import Testing

struct PowerUpTypeTests {

    // MARK: - label

    @Test func powerBall_label_isPB() {
        #expect(PowerUpType.powerBall.label == "PB")
    }

    // MARK: - duration

    @Test func powerBall_duration_isEightSeconds() {
        #expect(PowerUpType.powerBall.duration == 8.0)
    }

}
