import SpriteKit

/// A one-shot celebration emitter spawned on the victory summary screen.
/// Fires a large burst of coloured sparks that fan out from the centre of the screen.
final class VictoryBurstNode: SKEmitterNode {
    init(sceneSize: CGSize) {
        super.init()
        numParticlesToEmit = 120
        particleBirthRate = 300
        particleLifetime = 1.8
        particleLifetimeRange = 0.6
        // Spread particles across the full width
        particlePositionRange = CGVector(dx: sceneSize.width * 0.6, dy: 0)
        particleSpeed = 320
        particleSpeedRange = 160
        emissionAngle = .pi / 2           // fire upward
        emissionAngleRange = .pi          // full 180° fan
        particleScale = 0.18
        particleScaleRange = 0.10
        particleScaleSpeed = -0.08
        particleAlpha = 1.0
        particleAlphaSpeed = -0.55
        // Cycle through the brick color palette by using a white base and random color sequences
        particleColor = Theme.Color.accent
        particleColorBlendFactor = 1.0
        particleColorSequence = makeColorSequence()
        particleTexture = VictoryBurstNode.makeCircleTexture()
        zPosition = 5
        // Auto-remove after all particles have died (lifetime + range + birth window)
        run(.sequence([.wait(forDuration: 2.8), .removeFromParent()]))
    }

    private static func makeCircleTexture(radius: CGFloat = 8) -> SKTexture {
        let side = Int(radius * 2)
        guard let ctx = CGContext(
            data: nil,
            width: side, height: side,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return SKTexture() }
        ctx.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: side, height: side))
        guard let image = ctx.makeImage() else { return SKTexture() }
        return SKTexture(cgImage: image)
    }

    private func makeColorSequence() -> SKKeyframeSequence {
        let colors = Theme.Color.brickColors
        let count = Float(colors.count)
        let times = colors.indices.map { NSNumber(value: Float($0) / count) }
        let seq = SKKeyframeSequence(keyframeValues: colors, times: times)
        seq.interpolationMode = .linear
        return seq
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
