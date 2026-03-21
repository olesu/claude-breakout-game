import SpriteKit

/// A one-shot burst of spark particles that removes itself after the emission is complete.
/// A secondary dust emitter provides slower, larger fragments for an organic destruction feel.
final class BrickSparkNode: SKNode {
    init(color: PlatformColor) {
        super.init()

        // Primary: tight fast sparks
        let sparks = SKEmitterNode()
        sparks.numParticlesToEmit = 12
        sparks.particleBirthRate = 200
        sparks.particleLifetime = 0.35
        sparks.particleLifetimeRange = 0.15
        sparks.particleSpeed = 160
        sparks.particleSpeedRange = 80
        sparks.emissionAngle = 0
        sparks.emissionAngleRange = .pi * 2
        sparks.particleScale = 0.08
        sparks.particleScaleRange = 0.04
        sparks.particleScaleSpeed = -0.2
        sparks.particleAlpha = 1.0
        sparks.particleAlphaSpeed = -2.5
        sparks.particleColor = color
        sparks.particleColorBlendFactor = 1.0
        sparks.zPosition = 4

        // Secondary: slow chunky dust fragments
        let dust = SKEmitterNode()
        dust.numParticlesToEmit = 6
        dust.particleBirthRate = 120
        dust.particleLifetime = 0.55
        dust.particleLifetimeRange = 0.20
        dust.particleSpeed = 60
        dust.particleSpeedRange = 40
        dust.emissionAngle = 0
        dust.emissionAngleRange = .pi * 2
        dust.particleScale = 0.20
        dust.particleScaleRange = 0.10
        dust.particleScaleSpeed = -0.25
        dust.particleAlpha = 0.7
        dust.particleAlphaSpeed = -1.2
        dust.particleColor = color
        dust.particleColorBlendFactor = 0.7   // slightly desaturated vs. the sparks
        dust.zPosition = 3

        addChild(sparks)
        addChild(dust)

        // 0.85 s > max dust particle life (0.65 s)
        run(.sequence([.wait(forDuration: 0.85), .removeFromParent()]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
