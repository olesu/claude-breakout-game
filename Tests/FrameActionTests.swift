@testable import BreakoutGame
import Testing

struct FrameActionTests {

    @Test func frameAction_whenPaused_returnsNothing() {
        let action = frameAction(phase: .paused, ballsAllLost: false, levelComplete: false)
        #expect(action == .nothing)
    }

    @Test func frameAction_whenLevelComplete_returnsAdvanceLevel() {
        let action = frameAction(phase: .playing, ballsAllLost: false, levelComplete: true)
        #expect(action == .advanceLevel)
    }

    @Test func frameAction_whenWaitingToLaunch_returnsResetBall() {
        let action = frameAction(phase: .waitingToLaunch, ballsAllLost: false, levelComplete: false)
        #expect(action == .resetBall)
    }

    @Test func frameAction_whenPlaying_ballsNotLost_returnsNothing() {
        let action = frameAction(phase: .playing, ballsAllLost: false, levelComplete: false)
        #expect(action == .nothing)
    }

    @Test func frameAction_whenPlaying_ballsAllLost_returnsHandleBallLoss() {
        let action = frameAction(phase: .playing, ballsAllLost: true, levelComplete: false)
        #expect(action == .handleBallLoss)
    }

    @Test func frameAction_levelCompleteAndPaused_returnsNothing() {
        let action = frameAction(phase: .paused, ballsAllLost: false, levelComplete: true)
        #expect(action == .nothing)
    }

    @Test func frameAction_levelCompleteAndWaitingToLaunch_returnsAdvanceLevel() {
        let action = frameAction(phase: .waitingToLaunch, ballsAllLost: false, levelComplete: true)
        #expect(action == .advanceLevel)
    }

    @Test func frameAction_levelCompleteAndGameOver_returnsNothing() {
        let action = frameAction(phase: .gameOver, ballsAllLost: false, levelComplete: true)
        #expect(action == .nothing)
    }
}
