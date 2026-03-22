import SpriteKit

final class GameLoopCoordinator {
    private let ball: BallNode
    private let paddle: PaddleNode
    private let powerUp: PowerUpCoordinator

    private var lastUpdateTime: TimeInterval = 0
    private(set) var levelComplete = false

    init(ball: BallNode, paddle: PaddleNode, powerUp: PowerUpCoordinator) {
        self.ball = ball
        self.paddle = paddle
        self.powerUp = powerUp
    }

    func markLevelComplete() {
        levelComplete = true
    }

    func tick(currentTime: TimeInterval, phase: GamePhase, floorY: CGFloat) -> FrameAction {
        let delta = frameDelta(last: lastUpdateTime, current: currentTime)
        lastUpdateTime = currentTime

        let action = frameAction(
            phase: phase,
            ballY: ball.position.y,
            floorY: floorY,
            levelComplete: levelComplete
        )

        // resetBall runs before enforceMinimumVerticalSpeed. This is safe because
        // resetBall only triggers in .waitingToLaunch, which the speed guard excludes.
        if case .resetBall = action { resetBall() }
        enforceMinimumVerticalSpeed(phase: phase)
        powerUp.update(delta: delta)

        return action
    }

    func resetLastUpdateTime() {
        lastUpdateTime = 0
    }

    private func resetBall() {
        ball.physicsBody?.velocity = .zero
        ball.position = ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
    }

    private func enforceMinimumVerticalSpeed(phase: GamePhase) {
        guard phase == .playing, let body = ball.physicsBody else { return }
        body.velocity = clampedVerticalVelocity(
            velocity: body.velocity,
            minVerticalRatio: Theme.Layout.ballMinVerticalRatio
        )
    }
}
