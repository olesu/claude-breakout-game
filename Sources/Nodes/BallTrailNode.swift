import SpriteKit

/// A continuous particle trail that follows the ball.
/// Add it as a child of the ball node so it moves automatically.
/// Call `activate(color:)` / `deactivate()` to match ball power-up state.
final class BallTrailNode: SKEmitterNode {
    override init() {
        super.init()
        particleBirthRate = 80
        numParticlesToEmit = 0            // emit forever until explicitly stopped
        particleLifetime = 0.25
        particleLifetimeRange = 0.10
        particleSpeed = 0
        particleSpeedRange = 0
        emissionAngle = 0
        emissionAngleRange = .pi * 2
        particleScale = 0.12
        particleScaleRange = 0.06
        particleScaleSpeed = -0.3
        particleAlpha = 0.6
        particleAlphaSpeed = -2.5
        particleColor = Theme.Color.primary
        particleColorBlendFactor = 1.0
        // Offset slightly behind the ball — keep zPosition below ball shape
        zPosition = 1
        // Emit at the node's position each frame (targetNode makes particles stay in scene coords)
    }

    /// Tint the trail to match the ball's active power-up color.
    func activate(color: UIColor) {
        particleColor = color
    }

    /// Reset trail to default ball color.
    func deactivate() {
        particleColor = Theme.Color.primary
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
