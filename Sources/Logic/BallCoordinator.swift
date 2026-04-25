import SpriteKit

/// Owns the `balls` array and the ball-lifecycle operations that used to live in `GameScene`.
///
/// Follows the `ContactCoordinator` pattern: scene-mutation side-effects are injected as closures
/// so `BallCoordinator` itself stays scene-independent and fully testable.
@MainActor
final class BallCoordinator {
    private(set) var balls: [BallNode] = []
    private let addToScene: (SKNode) -> Void
    /// Wires a newly spawned ball's particle trail to the scene coordinate system.
    private let attachTrail: (BallNode) -> Void

    init(
        addToScene: @escaping (SKNode) -> Void,
        attachTrail: @escaping (BallNode) -> Void
    ) {
        self.addToScene = addToScene
        self.attachTrail = attachTrail
    }

    // MARK: - Lifecycle

    func setup(primary: BallNode) {
        balls = [primary]
    }

    /// Removes any extra balls that have fallen below `floorY`.
    /// Call each frame before passing `balls` to the game loop.
    func cullFallen(floorY: CGFloat) {
        for idx in fallenExtraBallIndices(balls: balls, floorY: floorY) {
            let fallen = balls[idx]
            fallen.removeFromParent()
            balls.remove(at: idx)
        }
    }

    /// Spawns extra balls from a multi-ball contact event and applies any active power-up state.
    func spawnExtra(at position: CGPoint, velocity: CGVector, powerUp: PowerUpCoordinator) {
        for spec in makeExtraBalls(
            at: position, primaryVelocity: velocity, radius: Theme.Layout.ballRadius
        ) {
            // velocity must be set before effectsForNewBall(): activateSlowBall reads
            // physicsBody.velocity immediately to capture speedBeforeSlowBall.
            spec.ball.physicsBody?.velocity = spec.velocity
            addToScene(spec.ball)
            attachTrail(spec.ball)
            balls.append(spec.ball)
            applyEffects(powerUp.effectsForNewBall(), to: spec.ball)
        }
    }

    /// Removes all balls except the primary (index 0). Used on boss life-loss.
    func removeExtras() {
        guard balls.count > 1 else { return }
        balls[1...].forEach { $0.removeFromParent() }
        balls.removeSubrange(1...)
    }

    // MARK: - Power-up effects

    /// Applies ball-related effects to all current balls.
    /// Paddle effects are ignored here — `GameScene` handles those directly.
    func applyEffects(_ effects: [PowerUpEffect]) {
        for effect in effects {
            switch effect {
            case .activatePowerBall:    balls.forEach { $0.activatePowerBall() }
            case .deactivatePowerBall:  balls.forEach { $0.deactivatePowerBall() }
            case .activateSlowBall:     balls.forEach { $0.activateSlowBall() }
            case .deactivateSlowBall:   balls.forEach { $0.deactivateSlowBall() }
            case .activateWidePaddle, .deactivateWidePaddle: break
            }
        }
    }

    /// Applies ball-related effects to a single ball (used when a new ball is added mid-power-up).
    func applyEffects(_ effects: [PowerUpEffect], to ball: BallNode) {
        for effect in effects {
            switch effect {
            case .activatePowerBall: ball.activatePowerBall()
            case .activateSlowBall:  ball.activateSlowBall()
            default: break
            }
        }
    }
}
