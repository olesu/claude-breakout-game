import SpriteKit

extension SKLabelNode {
    static func makeTitle(_ text: String, color: UIColor = Theme.Color.primary) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = Theme.Font.bold
        label.fontSize = Theme.FontSize.large
        label.fontColor = color
        return label
    }

    static func makeBody(_ text: String, color: UIColor = Theme.Color.secondary) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = Theme.Font.regular
        label.fontSize = Theme.FontSize.small
        label.fontColor = color
        return label
    }
}
