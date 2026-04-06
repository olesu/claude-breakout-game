@testable import BreakoutGame
import SpriteKit
import Testing

struct GameLoopCoordinatorTests {

    private func makeCoordinator() -> GameLoopCoordinator {
        let powerUp = PowerUpCoordinator(balls: [], paddle: PaddleNode(sceneWidth: 400))
        return GameLoopCoordinator(powerUp: powerUp)
    }

    // MARK: - resetBall path

    @Test func tick_waitingToLaunch_nilBall_doesNotCrash() {
        let coordinator = makeCoordinator()
        let action = coordinator.tick(
            currentTime: 1,
            phase: .waitingToLaunch,
            floorY: -300,
            balls: [],
            paddlePosition: CGPoint(x: 200, y: 50),
            paddleHalfHeight: 10
        )
        #expect(action == .resetBall)
    }

    @Test func tick_waitingToLaunch_resetsBallToRestingPosition() {
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = .zero
        let paddlePosition = CGPoint(x: 200, y: 50)
        let paddleHalfHeight: CGFloat = 10

        _ = coordinator.tick(
            currentTime: 1,
            phase: .waitingToLaunch,
            floorY: -300,
            balls: [ball],
            paddlePosition: paddlePosition,
            paddleHalfHeight: paddleHalfHeight
        )

        let expected = ballRestingPosition(
            paddlePosition: paddlePosition,
            paddleHalfHeight: paddleHalfHeight,
            ballRadius: Theme.Layout.ballRadius
        )
        #expect(ball.position == expected)
    }

    // MARK: - markLevelComplete

    @Test func markLevelComplete_causesAdvanceLevelAction() {
        let coordinator = makeCoordinator()
        coordinator.markLevelComplete()
        let action = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )
        #expect(action == .advanceLevel)
    }
}
