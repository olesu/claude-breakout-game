import SpriteKit

/// A one-shot floating score label that animates upward, fades out, and removes itself.
final class ScorePopupNode: SKLabelNode {
    init(points: Int, multiplier: Int? = nil) {
        super.init()
        fontName = Theme.Font.bold
        fontSize = Theme.FontSize.small
        zPosition = 5

        if let multiplier, multiplier > 1 {
            // Affichage combo : "+30 x3" en orange vif
            text = "+\(points) x\(multiplier)"
            fontColor = Theme.Color.powerUp
            fontSize = Theme.FontSize.small * 1.1
        } else {
            text = "+\(points)"
            fontColor = Theme.Color.accent
        }

        let move = SKAction.moveBy(x: 0, y: 40, duration: 0.6)
        // Reste opaque 0.2 s puis disparaît en 0.4 s
        let fade = SKAction.sequence([.wait(forDuration: 0.2), .fadeOut(withDuration: 0.4)])
        run(.sequence([.group([move, fade]), .removeFromParent()]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
