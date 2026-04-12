import SpriteKit

// MARK: - ContactOutcome

/// The subset of contact-event consequences that require `GameScene` to mutate its own state.
struct ContactOutcome {
    let pointsScored: Int
    let comboMultiplier: Int
    let lifeAwarded: Bool
    let extraBallSpawn: (position: CGPoint, velocity: CGVector)?
    let powerUpEffects: [PowerUpEffect]

    init(
        pointsScored: Int = 0,
        comboMultiplier: Int = 1,
        lifeAwarded: Bool = false,
        extraBallSpawn: (position: CGPoint, velocity: CGVector)? = nil,
        powerUpEffects: [PowerUpEffect] = []
    ) {
        self.pointsScored = pointsScored
        self.comboMultiplier = comboMultiplier
        self.lifeAwarded = lifeAwarded
        self.extraBallSpawn = extraBallSpawn
        self.powerUpEffects = powerUpEffects
    }
}

// MARK: - ContactCoordinator

/// Handles physics contact events on behalf of `GameScene`.
/// `GameScene.didBegin(_:)` delegates immediately to `handle(_:balls:gamePhase:)`.
final class ContactCoordinator {
    private let powerUp: PowerUpCoordinator
    private let paddle: PaddleNode
    private let gameLoop: GameLoopCoordinator
    private let addToScene: ([SKNode]) -> Void
    private let removeBrick: (BrickNode) -> Void
    private let remainingBrickCount: () -> Int
    private let comboTracker = ComboTracker()

    // Optional — tests leave this nil so no AVAudioEngine is needed.
    weak var sound: SoundCoordinator?
    var totalRows: Int = 1

    func resetCombo() { comboTracker.reset() }

    init(
        powerUp: PowerUpCoordinator,
        paddle: PaddleNode,
        gameLoop: GameLoopCoordinator,
        addToScene: @escaping ([SKNode]) -> Void,
        removeBrick: @escaping (BrickNode) -> Void,
        remainingBrickCount: @escaping () -> Int
    ) {
        self.powerUp = powerUp
        self.paddle = paddle
        self.gameLoop = gameLoop
        self.addToScene = addToScene
        self.removeBrick = removeBrick
        self.remainingBrickCount = remainingBrickCount
    }

    func handle(
        _ contact: SKPhysicsContact,
        balls: [BallNode],
        gamePhase: GamePhase
    ) -> ContactOutcome {
        switch classifyContact(contact) {
        case .brick(let brick, let point):
            return handleBrick(brick, contactPoint: point)
        case .powerUp(let node):
            return handlePowerUp(node, balls: balls, gamePhase: gamePhase)
        case .paddleHit(let ball, let point):
            if gamePhase != .waitingToLaunch { paddle.squash() }
            if let ball { reflectBallOffPaddle(contactPoint: point, ball: ball) }
            sound?.playPaddleHit()
            return ContactOutcome()
        case .wallHit(let wall):
            wall.flash()
            sound?.playWallHit()
            return ContactOutcome()
        case .laser(let laser, let brick, let point):
            return handleLaser(laser, brick: brick, contactPoint: point)
        case .unknown:
            return ContactOutcome()
        }
    }
}

// MARK: - Contact handlers
// Internal (not private) so @testable imports in ContactCoordinatorTests can call handlers
// directly.
extension ContactCoordinator {
    func handleBrick(_ brick: BrickNode, contactPoint: CGPoint) -> ContactOutcome {
        addToScene(SceneEffects.spawnSparks(at: contactPoint, color: brick.color))
        sound?.playBrickHit(row: brick.row, totalRows: totalRows)
        switch brick.hit() {
        case .intact(let remaining):
            brick.applyDamage(remainingHits: remaining)
            return ContactOutcome()
        case .destroyed:
            let prevMultiplier = comboTracker.multiplier
            let multiplier = comboTracker.recordHit()
            let points = Theme.Layout.brickPoints * multiplier
            let spawnPowerUp = !powerUp.isPowerBallActive
            removeBrick(brick)
            brick.destroy { [weak self] in
                guard let self else { return }
                if remainingBrickCount() == 0 && !gameLoop.levelComplete {
                    gameLoop.markLevelComplete()
                }
            }
            var nodesToAdd = SceneEffects.spawnScorePopup(
                at: contactPoint, points: points,
                multiplier: multiplier > 1 ? multiplier : nil
            )
            if multiplier > prevMultiplier {
                nodesToAdd.append(ComboPopupNode(
                    kind: .tierUp(multiplier: multiplier),
                    at: CGPoint(x: contactPoint.x, y: contactPoint.y + 20)
                ))
            }
            if brick.isBonus {
                nodesToAdd.append(powerUp.spawnGuaranteed(at: brick.position))
            } else if spawnPowerUp, let node = powerUp.spawnIfEligible(at: brick.position) {
                nodesToAdd.append(node)
            }
            addToScene(nodesToAdd)
            return ContactOutcome(pointsScored: points, comboMultiplier: multiplier)
        }
    }

    func handlePowerUp(
        _ node: PowerUpNode,
        balls: [BallNode],
        gamePhase: GamePhase
    ) -> ContactOutcome {
        let ballPos = balls.first?.position ?? paddle.position
        let outcome = powerUp.collect(node)
        switch outcome.result {
        case .activated(let type):
            addToScene(SceneEffects.spawnPowerUpActivationEffect(
                for: type, ballPosition: ballPos, paddlePosition: paddle.position
            ))
            return ContactOutcome(powerUpEffects: outcome.effects)
        case .instant(.extraLife):
            addToScene(SceneEffects.spawnPowerUpActivationEffect(
                for: .extraLife, ballPosition: ballPos, paddlePosition: paddle.position
            ))
            return ContactOutcome(lifeAwarded: true)
        case .instant(.multiBall):
            guard gamePhase == .playing,
                  let primary = balls.first,
                  let vel = primary.physicsBody?.velocity else { return ContactOutcome() }
            addToScene(SceneEffects.spawnPowerUpActivationEffect(
                for: .multiBall, ballPosition: primary.position, paddlePosition: paddle.position
            ))
            return ContactOutcome(extraBallSpawn: (position: primary.position, velocity: vel))
        case .instant:
            return ContactOutcome()
        case .none:
            return ContactOutcome()
        }
    }

    func handleLaser(
        _ laser: LaserNode,
        brick: BrickNode?,
        contactPoint: CGPoint
    ) -> ContactOutcome {
        laser.removeFromParent()
        guard let brick else { return ContactOutcome() }
        return handleBrick(brick, contactPoint: contactPoint)
    }

    func reflectBallOffPaddle(contactPoint: CGPoint, ball: BallNode) {
        guard contactPoint.y >= paddle.position.y, let body = ball.physicsBody else { return }
        let speed = hypot(body.velocity.dx, body.velocity.dy)
        let halfWidth = paddle.size.width * paddle.xScale / 2
        body.velocity = paddleReflectedVelocity(
            speed: speed,
            contactX: contactPoint.x,
            paddleCenterX: paddle.position.x,
            halfPaddleWidth: halfWidth,
            maxAngle: Theme.Layout.paddleMaxAngle
        )
    }
}
