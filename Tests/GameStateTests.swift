@testable import BreakoutGame
import Testing

struct GameStateTests {

    @Test func init_defaults_phaseIsWaitingToLaunch() {
        let state = GameState()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func init_livesAndScore_arePreserved() {
        let state = GameState(lives: 5, score: 100)
        #expect(state.lives == 5)
        #expect(state.score == 100)
    }

    @Test func addScore_whilePlaying_incrementsScore() {
        var state = GameState()
        state.launch()
        state.addScore(10)
        #expect(state.score == 10)
    }

    @Test func addScore_whileWaitingToLaunch_isIgnored() {
        var state = GameState()
        state.addScore(10)
        #expect(state.score == 0)
    }

    @Test func addScore_negative_isIgnored() {
        var state = GameState()
        state.launch()
        state.addScore(-5)
        #expect(state.score == 0)
    }

    @Test func addScore_accumulates_incrementsTotal() {
        var state = GameState()
        state.launch()
        state.addScore(10)
        state.addScore(10)
        #expect(state.score == 20)
    }

    @Test func addScore_whilePaused_isIgnored() {
        var state = GameState()
        state.launch()
        state.pause()
        state.addScore(10)
        #expect(state.score == 0)
    }

    @Test func addScore_whileGameOver_isIgnored() {
        var state = GameState(lives: 1)
        state.launch()
        state.ballLost()
        state.addScore(10)
        #expect(state.score == 0)
    }

    // MARK: - launch

    @Test func launch_fromWaitingToLaunch_movesToPlaying() {
        var state = GameState()
        state.launch()
        #expect(state.phase == .playing)
    }

    @Test func launch_whilePlaying_isIgnored() {
        var state = GameState()
        state.launch()
        state.launch()
        #expect(state.phase == .playing)
    }

    @Test func launch_whilePaused_isIgnored() {
        var state = GameState()
        state.launch()
        state.pause()
        state.launch()
        #expect(state.phase == .paused)
    }

    @Test func launch_whileGameOver_isIgnored() {
        var state = GameState(lives: 1)
        state.launch()
        state.ballLost()
        state.launch()
        #expect(state.phase == .gameOver)
    }

    // MARK: - ballLost

    @Test func ballLost_withLivesRemaining_decrementsLives() {
        var state = GameState(lives: 3)
        state.launch()
        state.ballLost()
        #expect(state.lives == 2)
    }

    @Test func ballLost_withLivesRemaining_phaseBecomesWaitingToLaunch() {
        var state = GameState(lives: 3)
        state.launch()
        state.ballLost()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func ballLost_lastLife_phaseBecomesGameOver() {
        var state = GameState(lives: 1)
        state.launch()
        state.ballLost()
        #expect(state.phase == .gameOver)
    }

    @Test func ballLost_lastLife_livesAreZero() {
        var state = GameState(lives: 1)
        state.launch()
        state.ballLost()
        #expect(state.lives == 0)
    }

    @Test func ballLost_whileNotPlaying_isIgnored() {
        var state = GameState(lives: 3)
        state.ballLost()
        #expect(state.lives == 3)
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func ballLost_whileGameOver_isIgnored() {
        var state = GameState(lives: 1)
        state.launch()
        state.ballLost()
        let livesAfterGameOver = state.lives
        state.ballLost()
        #expect(state.lives == livesAfterGameOver)
        #expect(state.phase == .gameOver)
    }

    // MARK: - pause / resume

    @Test func pause_whilePlaying_movesToPaused() {
        var state = GameState()
        state.launch()
        state.pause()
        #expect(state.phase == .paused)
    }

    @Test func pause_whileNotPlaying_isIgnored() {
        var state = GameState()
        state.pause()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func resume_whilePaused_movesToPlaying() {
        var state = GameState()
        state.launch()
        state.pause()
        state.resume()
        #expect(state.phase == .playing)
    }

    @Test func resume_whileNotPaused_isIgnored() {
        var state = GameState()
        state.resume()
        #expect(state.phase == .waitingToLaunch)
    }

    // MARK: - resetForNextLevel

    @Test func resetForNextLevel_whilePlaying_movesToWaitingToLaunch() {
        var state = GameState()
        state.launch()
        state.resetForNextLevel()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func resetForNextLevel_whileNotPlaying_isIgnored() {
        var state = GameState()
        state.resetForNextLevel()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func resetForNextLevel_preservesLivesAndScore() {
        var state = GameState(lives: 2)
        state.launch()
        state.addScore(50)
        state.resetForNextLevel()
        #expect(state.lives == 2)
        #expect(state.score == 50)
    }

    // MARK: - Value semantics

    @Test func copy_mutatingOriginal_doesNotAffectCopy() {
        var original = GameState()
        let copy = original
        original.launch()
        #expect(copy.phase == .waitingToLaunch)
    }
}
