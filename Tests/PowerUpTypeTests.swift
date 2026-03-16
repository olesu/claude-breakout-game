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

    @Test func slowBall_label_isSB() {
        #expect(PowerUpType.slowBall.label == "SB")
    }

    // MARK: - duration

    @Test func powerBall_duration_matchesThemeConstant() {
        #expect(PowerUpType.powerBall.duration == Theme.Layout.powerUpDuration)
    }

    @Test func widePaddle_duration_matchesThemeConstant() {
        #expect(PowerUpType.widePaddle.duration == Theme.Layout.powerUpDuration)
    }

    @Test func slowBall_duration_matchesThemeConstant() {
        #expect(PowerUpType.slowBall.duration == Theme.Layout.powerUpDuration)
    }

}
