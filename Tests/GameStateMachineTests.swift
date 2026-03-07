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
}
