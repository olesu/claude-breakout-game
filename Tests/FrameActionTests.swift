@testable import BreakoutGame
import Testing

struct FrameActionTests {

    @Test func frameAction_whenPaused_returnsNothing() {
        let action = frameAction(phase: .paused, ballY: 0, floorY: 0, levelComplete: false)
        #expect(action == .nothing)
    }

    @Test func frameAction_whenLevelComplete_returnsAdvanceLevel() {
        let action = frameAction(phase: .playing, ballY: 100, floorY: 0, levelComplete: true)
        #expect(action == .advanceLevel)
    }

    @Test func frameAction_whenWaitingToLaunch_returnsResetBall() {
        let action = frameAction(
            phase: .waitingToLaunch, ballY: 50, floorY: 0, levelComplete: false
        )
        #expect(action == .resetBall)
    }

    @Test func frameAction_whenPlaying_ballAboveFloor_returnsNothing() {
        let action = frameAction(phase: .playing, ballY: 10, floorY: 0, levelComplete: false)
        #expect(action == .nothing)
    }

    @Test func frameAction_whenPlaying_ballAtFloor_returnsHandleBallLoss() {
        let action = frameAction(phase: .playing, ballY: 0, floorY: 0, levelComplete: false)
        #expect(action == .handleBallLoss)
    }

    @Test func frameAction_whenPlaying_ballBelowFloor_returnsHandleBallLoss() {
        let action = frameAction(phase: .playing, ballY: -5, floorY: 0, levelComplete: false)
        #expect(action == .handleBallLoss)
    }

    @Test func frameAction_levelCompleteAndPaused_returnsNothing() {
        let action = frameAction(phase: .paused, ballY: 0, floorY: 0, levelComplete: true)
        #expect(action == .nothing)
    }

    @Test func frameAction_levelCompleteAndWaitingToLaunch_returnsAdvanceLevel() {
        let action = frameAction(
            phase: .waitingToLaunch, ballY: 0, floorY: 0, levelComplete: true
        )
        #expect(action == .advanceLevel)
    }

    @Test func frameAction_levelCompleteAndGameOver_returnsNothing() {
        let action = frameAction(phase: .gameOver, ballY: 0, floorY: 0, levelComplete: true)
        #expect(action == .nothing)
    }
}
