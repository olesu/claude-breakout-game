@testable import BreakoutGame
import CoreGraphics
import Testing

struct InputCoordinatorTests {
    private let coordinator = InputCoordinator()

    @Test func movePaddle_carriesLocationX() {
        let action = coordinator.action(
            at: CGPoint(x: 123, y: 0), hittingPauseButton: false, hittingMuteButton: false,
            phase: .playing
        )
        #expect(action == .movePaddle(x: 123))
    }

    @Test func launchAndMovePaddle_carriesLocationX() {
        let action = coordinator.action(
            at: CGPoint(x: 77, y: 0), hittingPauseButton: false, hittingMuteButton: false,
            phase: .waitingToLaunch
        )
        #expect(action == .launchAndMovePaddle(x: 77))
    }

    @Test func pause_whenHittingPauseButtonWhilePlaying() {
        let action = coordinator.action(
            at: .zero, hittingPauseButton: true, hittingMuteButton: false, phase: .playing
        )
        #expect(action == .pause)
    }

    @Test func resume_whenHittingPauseButtonWhilePaused() {
        let action = coordinator.action(
            at: .zero, hittingPauseButton: true, hittingMuteButton: false, phase: .paused
        )
        #expect(action == .resume)
    }

    @Test func none_whenGameOver() {
        let action = coordinator.action(
            at: CGPoint(x: 50, y: 0), hittingPauseButton: false, hittingMuteButton: false,
            phase: .gameOver
        )
        #expect(action == .none)
    }

    @Test func toggleMute_whenHittingMuteButtonWhilePlaying() {
        let action = coordinator.action(
            at: .zero, hittingPauseButton: false, hittingMuteButton: true, phase: .playing
        )
        #expect(action == .toggleMute)
    }

    @Test func toggleMute_whenHittingMuteButtonWhileWaiting() {
        let action = coordinator.action(
            at: .zero, hittingPauseButton: false, hittingMuteButton: true,
            phase: .waitingToLaunch
        )
        #expect(action == .toggleMute)
    }
}
