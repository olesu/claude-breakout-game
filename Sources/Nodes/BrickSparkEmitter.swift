import SpriteKit

func makeBrickSparkEmitter(color: UIColor) -> SKEmitterNode {
    let emitter = SKEmitterNode()
    emitter.numParticlesToEmit = 12
    emitter.particleBirthRate = 200
    emitter.particleLifetime = 0.35
    emitter.particleLifetimeRange = 0.15
    emitter.particleSpeed = 160
    emitter.particleSpeedRange = 80
    emitter.emissionAngle = 0
    emitter.emissionAngleRange = .pi * 2
    emitter.particleScale = 0.08
    emitter.particleScaleRange = 0.04
    emitter.particleScaleSpeed = -0.2
    emitter.particleAlpha = 1.0
    emitter.particleAlphaSpeed = -2.5
    emitter.particleColor = color
    emitter.particleColorBlendFactor = 1.0
    emitter.zPosition = 4
    return emitter
}
