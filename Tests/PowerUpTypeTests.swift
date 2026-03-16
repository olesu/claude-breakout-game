@testable import BreakoutGame
import Testing

struct PowerUpTypeTests {

    // MARK: - label

    @Test func powerBall_label_isPB() {
        #expect(PowerUpType.powerBall.label == "PB")
    }

    @Test func widePaddle_label_isWP() {
        #expect(PowerUpType.widePaddle.label == "WP")
    }

    // MARK: - duration

    @Test func powerBall_duration_isEightSeconds() {
        #expect(PowerUpType.powerBall.duration == 8.0)
    }

    @Test func widePaddle_duration_isEightSeconds() {
        #expect(PowerUpType.widePaddle.duration == 8.0)
    }

}
