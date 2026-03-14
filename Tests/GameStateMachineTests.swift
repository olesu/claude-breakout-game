@testable import BreakoutGame
import Testing

struct GameStateMachineTests {

    @Test func initialStateIsWaitingToLaunch() {
        let machine = GameStateMachine()
        #expect(machine.state == .waitingToLaunch)
    }

    @Test func launchTransitionsToPlaying() {
        let machine = GameStateMachine()
        machine.launch()
        #expect(machine.state == .playing)
    }

    @Test func ballLostDecrementsLives() {
        let machine = GameStateMachine(lives: 3)
        machine.launch()
        machine.ballLost()
        #expect(machine.lives == 2)
    }

    @Test func ballLostWithLivesRemainingTransitionsToWaitingToLaunch() {
        let machine = GameStateMachine(lives: 3)
        machine.launch()
        machine.ballLost()
        #expect(machine.state == .waitingToLaunch)
    }

    @Test func ballLostWithNoLivesRemainingTransitionsToGameOver() {
        let machine = GameStateMachine(lives: 1)
        machine.launch()
        machine.ballLost()
        #expect(machine.state == .gameOver)
    }

    @Test func initialScoreIsZero() {
        let machine = GameStateMachine()
        #expect(machine.score == 0)
    }

    @Test func addScoreIncrementsWhilePlaying() {
        let machine = GameStateMachine()
        machine.launch()
        machine.addScore(10)
        #expect(machine.score == 10)
    }

    @Test func addScoreAccumulates() {
        let machine = GameStateMachine()
        machine.launch()
        machine.addScore(10)
        machine.addScore(10)
        #expect(machine.score == 20)
    }

    @Test func addScoreIgnoredWhenNotPlaying() {
        let machine = GameStateMachine()
        machine.addScore(10)
        #expect(machine.score == 0)
    }

    @Test func resetForNextLevelTransitionsToWaitingToLaunch() {
        let machine = GameStateMachine()
        machine.launch()
        machine.resetForNextLevel()
        #expect(machine.state == .waitingToLaunch)
    }

    @Test func resetForNextLevelPreservesLivesAndScore() {
        let machine = GameStateMachine(lives: 2)
        machine.launch()
        machine.addScore(50)
        machine.resetForNextLevel()
        #expect(machine.lives == 2)
        #expect(machine.score == 50)
    }

    @Test func resetForNextLevelIgnoredWhenWaitingToLaunch() {
        let machine = GameStateMachine()
        machine.resetForNextLevel()
        #expect(machine.state == .waitingToLaunch)
    }

    @Test func resetForNextLevelIgnoredWhenGameOver() {
        let machine = GameStateMachine(lives: 1)
        machine.launch()
        machine.ballLost()
        machine.resetForNextLevel()
        #expect(machine.state == .gameOver)
    }

    @Test func pauseTransitionsFromPlayingToPaused() {
        let machine = GameStateMachine()
        machine.launch()
        machine.pause()
        #expect(machine.state == .paused)
    }

    @Test func resumeTransitionsFromPausedToPlaying() {
        let machine = GameStateMachine()
        machine.launch()
        machine.pause()
        machine.resume()
        #expect(machine.state == .playing)
    }

    @Test func pauseIgnoredWhenNotPlaying() {
        let machine = GameStateMachine()
        machine.pause()
        #expect(machine.state == .waitingToLaunch)
    }

    @Test func pauseIgnoredWhenGameOver() {
        let machine = GameStateMachine(lives: 1)
        machine.launch()
        machine.ballLost()
        machine.pause()
        #expect(machine.state == .gameOver)
    }

    @Test func resumeIgnoredWhenNotPaused() {
        let machine = GameStateMachine()
        machine.launch()
        machine.resume()
        #expect(machine.state == .playing)
    }

    @Test func addScoreIgnoredWhenPaused() {
        let machine = GameStateMachine()
        machine.launch()
        machine.pause()
        machine.addScore(10)
        #expect(machine.score == 0)
    }
}
