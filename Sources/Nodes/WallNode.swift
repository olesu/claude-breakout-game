import SpriteKit

private let idleAlpha: CGFloat = 0.35

final class WallNode: SKNode {
    private let line: SKShapeNode

    init(from start: CGPoint, to end: CGPoint) {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        let lineNode = SKShapeNode(path: path)
        lineNode.strokeColor = Theme.Color.primary
        lineNode.lineWidth = 2
        lineNode.glowWidth = 6
        lineNode.alpha = idleAlpha

        line = lineNode
        super.init()

        let body = SKPhysicsBody(edgeFrom: start, to: end)
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.wall
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body

        addChild(lineNode)
    }

    func flash() {
        let key = "wallFlash"
        line.removeAction(forKey: key)
        line.run(.sequence([
            .fadeAlpha(to: 1.0, duration: 0.05),
            .fadeAlpha(to: idleAlpha, duration: 0.2)
        ]), withKey: key)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

func makeWallNodes(for frame: CGRect) -> [WallNode] {
    [
        WallNode(
            from: CGPoint(x: frame.minX, y: frame.maxY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        ),
        WallNode(
            from: CGPoint(x: frame.minX, y: frame.minY),
            to: CGPoint(x: frame.minX, y: frame.maxY)
        ),
        WallNode(
            from: CGPoint(x: frame.maxX, y: frame.minY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        )
    ]
}
