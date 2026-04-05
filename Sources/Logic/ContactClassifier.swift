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
    let a = contact.bodyA.node
    let b = contact.bodyB.node

    if let laser = (a as? LaserNode) ?? (b as? LaserNode) {
        let brick = (a as? BrickNode) ?? (b as? BrickNode)
        return .laser(laser, brick: brick, contactPoint: contact.contactPoint)
    }
    if let brick = (a as? BrickNode) ?? (b as? BrickNode), brick.physicsBody != nil {
        return .brick(brick, contactPoint: contact.contactPoint)
    }
    if let node = (a as? PowerUpNode) ?? (b as? PowerUpNode) {
        return .powerUp(node)
    }
    if (a as? PaddleNode) != nil || (b as? PaddleNode) != nil {
        return .paddleHit(ball: (a as? BallNode) ?? (b as? BallNode),
                          contactPoint: contact.contactPoint)
    }
    if let wall = (a as? WallNode) ?? (b as? WallNode) {
        return .wallHit(wall)
    }
    return .unknown
}
