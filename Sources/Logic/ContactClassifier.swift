import SpriteKit

enum ContactEvent {
    case brick(BrickNode, contactPoint: CGPoint)
    case powerUp(PowerUpNode)
    case paddleHit(ball: BallNode?, contactPoint: CGPoint)
    case wallHit(WallNode)
    case laser(LaserNode, brick: BrickNode?, contactPoint: CGPoint)
    case unknown
}

/// Classifies an `SKPhysicsContact` into a typed `ContactEvent`.
/// Returns `.unknown` for any contact combination not explicitly handled.
func classifyContact(_ contact: SKPhysicsContact) -> ContactEvent {
    classifyContact(
        nodeA: contact.bodyA.node,
        nodeB: contact.bodyB.node,
        contactPoint: contact.contactPoint
    )
}

func classifyContact(nodeA: SKNode?, nodeB: SKNode?, contactPoint: CGPoint) -> ContactEvent {
    if let laser = (nodeA as? LaserNode) ?? (nodeB as? LaserNode) {
        let brick = (nodeA as? BrickNode) ?? (nodeB as? BrickNode)
        return .laser(laser, brick: brick, contactPoint: contactPoint)
    }
    if let brick = (nodeA as? BrickNode) ?? (nodeB as? BrickNode), brick.physicsBody != nil {
        return .brick(brick, contactPoint: contactPoint)
    }
    if let node = (nodeA as? PowerUpNode) ?? (nodeB as? PowerUpNode) {
        return .powerUp(node)
    }
    if (nodeA as? PaddleNode) != nil || (nodeB as? PaddleNode) != nil {
        return .paddleHit(
            ball: (nodeA as? BallNode) ?? (nodeB as? BallNode),
            contactPoint: contactPoint
        )
    }
    if let wall = (nodeA as? WallNode) ?? (nodeB as? WallNode) {
        return .wallHit(wall)
    }
    return .unknown
}
