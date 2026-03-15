import SpriteKit

func makeWallNodes(for frame: CGRect) -> [SKNode] {
    func wall(from start: CGPoint, to end: CGPoint) -> SKNode {
        let node = SKNode()
        let body = SKPhysicsBody(edgeFrom: start, to: end)
        body.restitution = 1
        body.friction = 0
        body.categoryBitMask = PhysicsCategory.wall
        node.physicsBody = body
        return node
    }

    return [
        wall(
            from: CGPoint(x: frame.minX, y: frame.maxY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        ),
        wall(
            from: CGPoint(x: frame.minX, y: frame.minY),
            to: CGPoint(x: frame.minX, y: frame.maxY)
        ),
        wall(
            from: CGPoint(x: frame.maxX, y: frame.minY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        )
    ]
}
