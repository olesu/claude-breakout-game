@testable import BreakoutGame
import Testing

struct TouchIntentTests {

    @Test func touchIntent_pauseButton_whilePlaying_returnsPause() {
        let intent = touchIntent(hitsPauseButton: true, phase: .playing)
        #expect(intent == .pause)
    }

    @Test func touchIntent_pauseButton_whilePaused_returnsResume() {
        let intent = touchIntent(hitsPauseButton: true, phase: .paused)
        #expect(intent == .resume)
    }

    @Test func touchIntent_pauseButton_whileWaiting_returnsNone() {
        let intent = touchIntent(hitsPauseButton: true, phase: .waitingToLaunch)
        #expect(intent == .none)
    }

    @Test func touchIntent_pauseButton_whileGameOver_returnsNone() {
        let intent = touchIntent(hitsPauseButton: true, phase: .gameOver)
        #expect(intent == .none)
    }

    @Test func touchIntent_normalTouch_whilePaused_returnsNone() {
        let intent = touchIntent(hitsPauseButton: false, phase: .paused)
        #expect(intent == .none)
    }

    @Test func touchIntent_normalTouch_whileWaiting_returnsLaunchAndMove() {
        let intent = touchIntent(hitsPauseButton: false, phase: .waitingToLaunch)
        #expect(intent == .launchAndMovePaddle)
    }

    @Test func touchIntent_normalTouch_whilePlaying_returnsMove() {
        let intent = touchIntent(hitsPauseButton: false, phase: .playing)
        #expect(intent == .movePaddle)
    }

    @Test func touchIntent_normalTouch_whileGameOver_returnsNone() {
        let intent = touchIntent(hitsPauseButton: false, phase: .gameOver)
        #expect(intent == .none)
    }
}
