import SpriteKit

final class BackdropNode: SKNode {
    init(size: CGSize) {
        super.init()
        zPosition = -5
        isUserInteractionEnabled = false

        let fill = SKSpriteNode(texture: nil, color: Theme.Color.backdropFill, size: size)
        fill.isUserInteractionEnabled = false
        addChild(fill)
        addChild(BackdropNode.makeGridNode(size: size))
    }

    private static func makeGridNode(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        let halfW = size.width / 2
        let halfH = size.height / 2
        let spacing = Theme.Layout.gridSpacing

        var x = -halfW
        while x <= halfW {
            path.move(to: CGPoint(x: x, y: -halfH))
            path.addLine(to: CGPoint(x: x, y: halfH))
            x += spacing
        }

        var y = -halfH
        while y <= halfH {
            path.move(to: CGPoint(x: -halfW, y: y))
            path.addLine(to: CGPoint(x: halfW, y: y))
            y += spacing
        }

        let node = SKShapeNode(path: path)
        node.strokeColor = Theme.Color.gridLine
        node.lineWidth = 1.0
        node.alpha = 0.25
        node.isUserInteractionEnabled = false
        return node
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
