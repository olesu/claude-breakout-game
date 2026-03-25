import SpriteKit

final class GameLoopCoordinator {
    private let paddle: PaddleNode
    private let powerUp: PowerUpCoordinator

    private var lastUpdateTime: TimeInterval = 0
    private(set) var levelComplete = false

    init(paddle: PaddleNode, powerUp: PowerUpCoordinator) {
        self.paddle = paddle
        self.powerUp = powerUp
    }

    func markLevelComplete() {
        levelComplete = true
    }

    func tick(
        currentTime: TimeInterval,
        phase: GamePhase,
        floorY: CGFloat,
        balls: [BallNode]
    ) -> FrameAction {
        let delta = frameDelta(last: lastUpdateTime, current: currentTime)
        lastUpdateTime = currentTime

        let ballsAllLost = !balls.isEmpty && balls.allSatisfy { $0.position.y <= floorY }
        let action = frameAction(
            phase: phase,
            ballsAllLost: ballsAllLost,
            levelComplete: levelComplete
        )

        // resetBall runs before enforceMinimumVerticalSpeed. This is safe because
        // resetBall only triggers in .waitingToLaunch, which the speed guard excludes.
        if case .resetBall = action { resetBall(primary: balls.first) }
        enforceMinimumVerticalSpeed(phase: phase, balls: balls)
        powerUp.update(delta: delta, floorY: floorY)

        return action
    }

    func resetLastUpdateTime() {
        lastUpdateTime = 0
    }

    private func resetBall(primary: BallNode?) {
        guard let primary else { return }
        primary.physicsBody?.velocity = .zero
        primary.position = ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
    }

    private func enforceMinimumVerticalSpeed(phase: GamePhase, balls: [BallNode]) {
        guard phase == .playing else { return }
        for ball in balls {
            guard let body = ball.physicsBody else { continue }
            body.velocity = clampedVerticalVelocity(
                velocity: body.velocity,
                minVerticalRatio: Theme.Layout.ballMinVerticalRatio
            )
        }
    }
}
