import SpriteKit

/// A one-shot burst of spark particles that removes itself after the emission is complete.
final class BrickSparkNode: SKEmitterNode {
    init(color: UIColor) {
        super.init()
        numParticlesToEmit = 12
        particleBirthRate = 200
        particleLifetime = 0.35
        particleLifetimeRange = 0.15
        particleSpeed = 160
        particleSpeedRange = 80
        emissionAngle = 0
        emissionAngleRange = .pi * 2
        particleScale = 0.08
        particleScaleRange = 0.04
        particleScaleSpeed = -0.2
        particleAlpha = 1.0
        particleAlphaSpeed = -2.5
        particleColor = color
        particleColorBlendFactor = 1.0
        zPosition = 4

        run(.sequence([.wait(forDuration: 0.6), .removeFromParent()]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
