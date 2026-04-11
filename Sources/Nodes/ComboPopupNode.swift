import SpriteKit

/// Animated popup shown when the combo tier increases ("+COMBO ×N").
final class ComboPopupNode: SKLabelNode {
    enum Kind {
        case tierUp(multiplier: Int)
    }

    init(kind: Kind, at position: CGPoint) {
        super.init()
        fontName = Theme.Font.bold
        zPosition = 5
        self.position = position

        switch kind {
        case .tierUp(let multiplier):
            text = "+COMBO ×\(multiplier)"
            fontSize = Theme.FontSize.small
            fontColor = Theme.Color.danger
        }

        let move = SKAction.moveBy(x: 0, y: 50, duration: 0.7)
        let fade = SKAction.sequence([.wait(forDuration: 0.2), .fadeOut(withDuration: 0.5)])
        run(.sequence([.group([move, fade]), .removeFromParent()]))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
