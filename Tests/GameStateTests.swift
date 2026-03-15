@testable import BreakoutGame
import Testing

struct GameStateTests {

    // MARK: - Init

    @Test func init_defaults_phaseIsWaitingToLaunch() {
        #expect(GameState().phase == .waitingToLaunch)
    }

    @Test func init_livesAndScore_arePreserved() {
        let state = GameState(lives: 5, score: 100)
        #expect(state.lives == 5)
        #expect(state.score == 100)
    }

    // MARK: - addScore

    @Test func addScore_whilePlaying_incrementsScore() {
        let state = GameState().launch().addScore(10)
        #expect(state.score == 10)
    }

    @Test func addScore_accumulates_incrementsTotal() {
        let state = GameState().launch().addScore(10).addScore(10)
        #expect(state.score == 20)
    }

    @Test func addScore_whileWaitingToLaunch_isIgnored() {
        #expect(GameState().addScore(10).score == 0)
    }

    @Test func addScore_whilePaused_isIgnored() {
        let state = GameState().launch().pause().addScore(10)
        #expect(state.score == 0)
    }

    @Test func addScore_whileGameOver_isIgnored() {
        let state = GameState(lives: 1).launch().ballLost().addScore(10)
        #expect(state.score == 0)
    }

    @Test func addScore_zero_isIgnored() {
        #expect(GameState().launch().addScore(0).score == 0)
    }

    @Test func addScore_negative_isIgnored() {
        #expect(GameState().launch().addScore(-5).score == 0)
    }

    // MARK: - launch

    @Test func launch_fromWaitingToLaunch_movesToPlaying() {
        #expect(GameState().launch().phase == .playing)
    }

    @Test func launch_whilePlaying_isIgnored() {
        let state = GameState().launch().launch()
        #expect(state.phase == .playing)
    }

    @Test func launch_whilePaused_isIgnored() {
        let state = GameState().launch().pause().launch()
        #expect(state.phase == .paused)
    }

    @Test func launch_whileGameOver_isIgnored() {
        let state = GameState(lives: 1).launch().ballLost().launch()
        #expect(state.phase == .gameOver)
    }

    // MARK: - ballLost

    @Test func ballLost_withLivesRemaining_decrementsLives() {
        let state = GameState(lives: 3).launch().ballLost()
        #expect(state.lives == 2)
    }

    @Test func ballLost_withLivesRemaining_phaseBecomesWaitingToLaunch() {
        let state = GameState(lives: 3).launch().ballLost()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func ballLost_lastLife_phaseBecomesGameOver() {
        let state = GameState(lives: 1).launch().ballLost()
        #expect(state.phase == .gameOver)
    }

    @Test func ballLost_lastLife_livesAreZero() {
        let state = GameState(lives: 1).launch().ballLost()
        #expect(state.lives == 0)
    }

    @Test func ballLost_whileNotPlaying_isIgnored() {
        let state = GameState(lives: 3).ballLost()
        #expect(state.lives == 3)
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func ballLost_whileGameOver_isIgnored() {
        let gameOver = GameState(lives: 1).launch().ballLost()
        let after = gameOver.ballLost()
        #expect(after.lives == 0)
        #expect(after.phase == .gameOver)
    }

    // MARK: - pause / resume

    @Test func pause_whilePlaying_movesToPaused() {
        let state = GameState().launch().pause()
        #expect(state.phase == .paused)
    }

    @Test func pause_whileNotPlaying_isIgnored() {
        #expect(GameState().pause().phase == .waitingToLaunch)
    }

    @Test func resume_whilePaused_movesToPlaying() {
        let state = GameState().launch().pause().resume()
        #expect(state.phase == .playing)
    }

    @Test func resume_whileNotPaused_isIgnored() {
        #expect(GameState().resume().phase == .waitingToLaunch)
    }

    // MARK: - resetForNextLevel

    @Test func resetForNextLevel_whilePlaying_movesToWaitingToLaunch() {
        let state = GameState().launch().resetForNextLevel()
        #expect(state.phase == .waitingToLaunch)
    }

    @Test func resetForNextLevel_whileWaitingToLaunch_isIgnored() {
        #expect(GameState().resetForNextLevel().phase == .waitingToLaunch)
    }

    @Test func resetForNextLevel_whilePaused_isIgnored() {
        let state = GameState().launch().pause().resetForNextLevel()
        #expect(state.phase == .paused)
    }

    @Test func resetForNextLevel_whileGameOver_isIgnored() {
        let state = GameState(lives: 1).launch().ballLost().resetForNextLevel()
        #expect(state.phase == .gameOver)
    }

    @Test func resetForNextLevel_preservesLivesAndScore() {
        let state = GameState(lives: 2).launch().addScore(50).resetForNextLevel()
        #expect(state.lives == 2)
        #expect(state.score == 50)
    }

    // MARK: - Value semantics

    @Test func copy_originalUnchangedAfterTransition() {
        let original = GameState()
        let launched = original.launch()
        #expect(original.phase == .waitingToLaunch)
        #expect(launched.phase == .playing)
    }
}
