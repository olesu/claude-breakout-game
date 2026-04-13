import SpriteKit

struct TickResult {
    let action: FrameAction
    let powerUpEffects: [PowerUpEffect]
    let expiredPowerUpType: PowerUpType?
}

final class GameLoopCoordinator {
    private let powerUp: PowerUpCoordinator

    private var lastUpdateTime: TimeInterval = 0
    private(set) var levelComplete = false

    init(powerUp: PowerUpCoordinator) {
        self.powerUp = powerUp
    }

    func markLevelComplete() {
        levelComplete = true
    }

    // swiftlint:disable:next function_parameter_count
    func tick(
        currentTime: TimeInterval,
        phase: GamePhase,
        floorY: CGFloat,
        balls: [BallNode],
        paddlePosition: CGPoint,
        paddleHalfHeight: CGFloat
    ) -> TickResult {
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
        if case .resetBall = action {
            resetBall(
                primary: balls.first,
                paddlePosition: paddlePosition,
                paddleHalfHeight: paddleHalfHeight
            )
        }
        enforceMinimumVerticalSpeed(phase: phase, balls: balls)
        let powerUpUpdate = powerUp.update(delta: delta, floorY: floorY)

        return TickResult(
            action: action,
            powerUpEffects: powerUpUpdate.effects,
            expiredPowerUpType: powerUpUpdate.expiredType
        )
    }

    func resetLastUpdateTime() {
        lastUpdateTime = 0
    }

    private func resetBall(primary: BallNode?, paddlePosition: CGPoint, paddleHalfHeight: CGFloat) {
        guard let primary else { return }
        primary.physicsBody?.velocity = .zero
        primary.position = ballRestingPosition(
            paddlePosition: paddlePosition,
            paddleHalfHeight: paddleHalfHeight,
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
