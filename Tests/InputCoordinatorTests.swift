@testable import BreakoutGame
import CoreGraphics
import Testing

struct InputCoordinatorTests {
    private let coordinator = InputCoordinator()

    @Test func movePaddle_carriesLocationX() {
        let action = coordinator.action(at: CGPoint(x: 123, y: 0),
                                        hittingPauseButton: false,
                                        phase: .playing)
        #expect(action == .movePaddle(x: 123))
    }

    @Test func launchAndMovePaddle_carriesLocationX() {
        let action = coordinator.action(at: CGPoint(x: 77, y: 0),
                                        hittingPauseButton: false,
                                        phase: .waitingToLaunch)
        #expect(action == .launchAndMovePaddle(x: 77))
    }

    @Test func pause_whenHittingPauseButtonWhilePlaying() {
        let action = coordinator.action(at: .zero, hittingPauseButton: true, phase: .playing)
        #expect(action == .pause)
    }

    @Test func resume_whenHittingPauseButtonWhilePaused() {
        let action = coordinator.action(at: .zero, hittingPauseButton: true, phase: .paused)
        #expect(action == .resume)
    }

    @Test func none_whenGameOver() {
        let action = coordinator.action(at: CGPoint(x: 50, y: 0),
                                        hittingPauseButton: false,
                                        phase: .gameOver)
        #expect(action == .none)
    }
}
