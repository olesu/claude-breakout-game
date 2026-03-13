@testable import BreakoutGame
import Testing

struct LabelFormatterTests {
    @Test func scoreTextZero() {
        #expect(scoreText(0) == "Score: 0")
    }

    @Test func scoreTextNonZero() {
        #expect(scoreText(1200) == "Score: 1200")
    }

    @Test func livesTextZero() {
        #expect(livesText(0) == "Lives: 0")
    }

    @Test func livesTextNonZero() {
        #expect(livesText(3) == "Lives: 3")
    }

    @Test func highScoreTextZero() {
        #expect(highScoreText(0) == "HIGH SCORE: 0")
    }

    @Test func highScoreTextNonZero() {
        #expect(highScoreText(1500) == "HIGH SCORE: 1500")
    }
}
