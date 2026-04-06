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

    // MARK: - Ball loss detection

    @Test func tick_playing_allBallsBelowFloor_returnsHandleBallLoss() {
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = CGPoint(x: 0, y: -301)
        let action = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [ball],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )
        #expect(action == .handleBallLoss)
    }

    @Test func tick_playing_ballAtFloor_returnsHandleBallLoss() {
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = CGPoint(x: 0, y: -300)
        let action = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [ball],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )
        #expect(action == .handleBallLoss)
    }

    @Test func tick_playing_ballAboveFloor_returnsNothing() {
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = CGPoint(x: 0, y: 0)
        let action = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [ball],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )
        #expect(action == .nothing)
    }

    @Test func tick_playing_emptyBalls_returnsNothing() {
        // Vacuous-truth guard: !balls.isEmpty prevents allSatisfy from triggering on []
        let coordinator = makeCoordinator()
        let action = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )
        #expect(action == .nothing)
    }

    // MARK: - Minimum vertical velocity enforcement

    @Test func tick_playing_nearHorizontalVelocity_dyIsClamped() {
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = CGPoint(x: 0, y: 0)
        // Speed 100, dy=1 → |dy|/speed ≈ 0.01, below threshold of 0.2
        ball.physicsBody?.velocity = CGVector(dx: 100, dy: 1)

        _ = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [ball],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )

        let dy = ball.physicsBody?.velocity.dy ?? 0
        let speed = hypot(ball.physicsBody?.velocity.dx ?? 0, dy)
        #expect(abs(dy) / speed >= Theme.Layout.ballMinVerticalRatio - 1e-6)
    }

    @Test func tick_playing_sufficientVerticalVelocity_dyUnchanged() {
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = CGPoint(x: 0, y: 0)
        // dy/speed = 0.6, well above threshold of 0.2 — dy must not be raised
        ball.physicsBody?.velocity = CGVector(dx: 80, dy: 60)

        _ = coordinator.tick(
            currentTime: 1,
            phase: .playing,
            floorY: -300,
            balls: [ball],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )

        // Box2D stores velocity as float32. The read→return→write cycle quantises dx
        // by ~1e-5; dy stays exact here because 60 is representable without error.
        // We assert dy only: it confirms clamping did not occur (dy was not raised).
        #expect(ball.physicsBody?.velocity.dy == 60)
    }

    @Test func tick_paused_doesNotEnforceVerticalSpeed() {
        // enforceMinimumVerticalSpeed is guarded to .playing only.
        // .paused skips both resetBall and enforcement, so the near-horizontal
        // velocity must remain untouched.
        let coordinator = makeCoordinator()
        let ball = BallNode(radius: Theme.Layout.ballRadius)
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 100, dy: 1)

        _ = coordinator.tick(
            currentTime: 1,
            phase: .paused,
            floorY: -300,
            balls: [ball],
            paddlePosition: .zero,
            paddleHalfHeight: 10
        )

        #expect(ball.physicsBody?.velocity.dy == 1)
    }
}
