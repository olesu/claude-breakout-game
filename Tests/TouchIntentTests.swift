@testable import BreakoutGame
import Testing

struct TouchIntentTests {

    @Test func touchIntent_pauseButton_whilePlaying_returnsPause() {
        let intent = touchIntent(hitsPauseButton: true, hitsMuteButton: false, phase: .playing)
        #expect(intent == .pause)
    }

    @Test func touchIntent_pauseButton_whilePaused_returnsResume() {
        let intent = touchIntent(hitsPauseButton: true, hitsMuteButton: false, phase: .paused)
        #expect(intent == .resume)
    }

    @Test func touchIntent_pauseButton_whileWaiting_returnsNone() {
        let intent = touchIntent(
            hitsPauseButton: true, hitsMuteButton: false, phase: .waitingToLaunch
        )
        #expect(intent == .none)
    }

    @Test func touchIntent_pauseButton_whileGameOver_returnsNone() {
        let intent = touchIntent(hitsPauseButton: true, hitsMuteButton: false, phase: .gameOver)
        #expect(intent == .none)
    }

    @Test func touchIntent_normalTouch_whilePaused_returnsNone() {
        let intent = touchIntent(hitsPauseButton: false, hitsMuteButton: false, phase: .paused)
        #expect(intent == .none)
    }

    @Test func touchIntent_normalTouch_whileWaiting_returnsLaunchAndMove() {
        let intent = touchIntent(
            hitsPauseButton: false, hitsMuteButton: false, phase: .waitingToLaunch
        )
        #expect(intent == .launchAndMovePaddle)
    }

    @Test func touchIntent_normalTouch_whilePlaying_returnsMove() {
        let intent = touchIntent(hitsPauseButton: false, hitsMuteButton: false, phase: .playing)
        #expect(intent == .movePaddle)
    }

    @Test func touchIntent_normalTouch_whileGameOver_returnsNone() {
        let intent = touchIntent(hitsPauseButton: false, hitsMuteButton: false, phase: .gameOver)
        #expect(intent == .none)
    }

    @Test func touchIntent_muteButton_whilePlaying_returnsToggleMute() {
        let intent = touchIntent(hitsPauseButton: false, hitsMuteButton: true, phase: .playing)
        #expect(intent == .toggleMute)
    }

    @Test func touchIntent_muteButton_whileWaiting_returnsToggleMute() {
        let intent = touchIntent(
            hitsPauseButton: false, hitsMuteButton: true, phase: .waitingToLaunch
        )
        #expect(intent == .toggleMute)
    }

    @Test func touchIntent_muteButton_whilePaused_returnsNone() {
        let intent = touchIntent(hitsPauseButton: false, hitsMuteButton: true, phase: .paused)
        #expect(intent == .none)
    }

    @Test func touchIntent_muteButton_whileGameOver_returnsNone() {
        let intent = touchIntent(hitsPauseButton: false, hitsMuteButton: true, phase: .gameOver)
        #expect(intent == .none)
    }
}
