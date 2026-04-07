import SpriteKit

/// Anneau de ripple unique qui s'anime vers l'extérieur puis se retire automatiquement.
final class RingNode: SKShapeNode {
    init(
        radius: CGFloat,
        delay: TimeInterval,
        scale: CGFloat,
        alpha: CGFloat,
        lineWidth: CGFloat,
        color: PlatformColor = Theme.Color.primary
    ) {
        super.init()
        let diameter = radius * 2
        path = CGPath(
            ellipseIn: CGRect(x: -radius, y: -radius, width: diameter, height: diameter),
            transform: nil
        )
        fillColor = .clear
        strokeColor = color
        self.lineWidth = lineWidth
        self.alpha = 0
        zPosition = 3

        run(.sequence([
            .wait(forDuration: delay),
            .fadeAlpha(to: alpha, duration: 0),
            .group([
                .scale(to: scale, duration: 0.5),
                .fadeOut(withDuration: 0.5)
            ]),
            .removeFromParent()
        ]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
