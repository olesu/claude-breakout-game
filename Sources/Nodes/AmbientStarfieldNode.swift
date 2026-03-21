import SpriteKit

/// A looping background emitter that produces a sparse field of slow-drifting dim particles,
/// giving the black background depth without distracting from gameplay.
final class AmbientStarfieldNode: SKEmitterNode {
    init(sceneSize: CGSize) {
        super.init()
        particleBirthRate = 3
        numParticlesToEmit = 0            // emit forever
        particleLifetime = 6.0
        particleLifetimeRange = 3.0
        // Spawn across the full scene width, from the top
        particlePositionRange = CGVector(dx: sceneSize.width, dy: 0)
        particleSpeed = 28
        particleSpeedRange = 16
        emissionAngle = -.pi / 2          // fall downward
        emissionAngleRange = .pi / 8
        particleScale = 0.04
        particleScaleRange = 0.03
        particleScaleSpeed = 0
        particleAlpha = 0.25
        particleAlphaRange = 0.15
        particleAlphaSpeed = 0
        particleColor = Theme.Color.primary
        particleColorBlendFactor = 1.0
        zPosition = -1                    // behind all game nodes
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
