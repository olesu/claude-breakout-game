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

    @Test func extraLife_label_isPlusOne() {
        #expect(PowerUpType.extraLife.label == "+1")
    }

    @Test func multiBall_label_isMB() {
        #expect(PowerUpType.multiBall.label == "MB")
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

    @Test func extraLife_duration_isNil() {
        #expect(PowerUpType.extraLife.duration == nil)
    }

    @Test func multiBall_duration_isNil() {
        #expect(PowerUpType.multiBall.duration == nil)
    }

    @Test func laser_label_isLZ() {
        #expect(PowerUpType.laser.label == "LZ")
    }

    @Test func laser_duration_matchesThemeConstant() {
        #expect(PowerUpType.laser.duration == Theme.Layout.powerUpDuration)
    }

}
