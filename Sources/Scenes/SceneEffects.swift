import SpriteKit

enum SceneEffects {
    static func spawnScorePopup(at position: CGPoint, points: Int, multiplier: Int? = nil) -> [SKNode] {
        let popup = ScorePopupNode(points: points, multiplier: multiplier)
        popup.position = position
        return [popup]
    }

    static func spawnSparks(at position: CGPoint, color: PlatformColor) -> [SKNode] {
        let sparks = BrickSparkNode(color: color)
        sparks.position = position
        return [sparks]
    }

    static func spawnLaunchRipple(at position: CGPoint) -> [SKNode] {
        [
            rippleRing(at: position, delay: 0, scale: 4.0, alpha: 1.0, lineWidth: 2.0),
            rippleRing(at: position, delay: 0.12, scale: 5.0, alpha: 0.6, lineWidth: 1.5)
        ]
    }

    static func spawnPowerUpActivationEffect(
        for type: PowerUpType,
        ballPosition: CGPoint,
        paddlePosition: CGPoint
    ) -> [SKNode] {
        switch type {
        case .powerBall:
            return [
                rippleRing(at: ballPosition, delay: 0, scale: 6.0, alpha: 1.0, lineWidth: 2.5),
                rippleRing(at: ballPosition, delay: 0.1, scale: 8.0, alpha: 0.5, lineWidth: 1.5)
            ]
        case .widePaddle:
            return [
                rippleRing(at: paddlePosition, delay: 0, scale: 5.0, alpha: 1.0, lineWidth: 2.0),
                rippleRing(at: paddlePosition, delay: 0.1, scale: 7.0, alpha: 0.5, lineWidth: 1.5)
            ]
        case .slowBall:
            return [
                rippleRing(at: ballPosition, delay: 0, scale: 5.0, alpha: 1.0, lineWidth: 2.0),
                rippleRing(at: ballPosition, delay: 0.1, scale: 7.0, alpha: 0.5, lineWidth: 1.5)
            ]
        case .extraLife:
            return [
                rippleRing(at: ballPosition, delay: 0, scale: 4.0, alpha: 1.0, lineWidth: 2.5),
                rippleRing(at: ballPosition, delay: 0.08, scale: 6.0, alpha: 0.6, lineWidth: 1.5),
                rippleRing(at: ballPosition, delay: 0.16, scale: 8.0, alpha: 0.3, lineWidth: 1.0)
            ]
        case .multiBall:
            return [
                rippleRing(at: ballPosition, delay: 0, scale: 5.0, alpha: 1.0, lineWidth: 2.0),
                rippleRing(at: ballPosition, delay: 0.1, scale: 7.0, alpha: 0.5, lineWidth: 1.5)
            ]
        case .laser:
            return [
                rippleRing(at: paddlePosition, delay: 0, scale: 4.0, alpha: 1.0, lineWidth: 2.0),
                rippleRing(at: paddlePosition, delay: 0.1, scale: 6.0, alpha: 0.5, lineWidth: 1.5)
            ]
        }
    }

    static func spawnBallLossFlash(sceneSize: CGSize, center: CGPoint) -> [SKNode] {
        let flash = SKSpriteNode(color: Theme.Color.danger, size: sceneSize)
        flash.position = center
        flash.alpha = 0
        flash.zPosition = 20
        flash.run(.sequence([
            .fadeAlpha(to: 0.35, duration: 0.05),
            .fadeOut(withDuration: 0.30),
            .removeFromParent()
        ]))
        return [flash]
    }

    private static func rippleRing(
        at position: CGPoint,
        delay: TimeInterval,
        scale: CGFloat,
        alpha: CGFloat,
        lineWidth: CGFloat
    ) -> RingNode {
        let ring = RingNode(
            radius: Theme.Layout.ballRadius, delay: delay,
            scale: scale, alpha: alpha, lineWidth: lineWidth
        )
        ring.position = position
        return ring
    }
}
