import SpriteKit

struct ExtraBallSpec {
    let ball: BallNode
    let velocity: CGVector
}

/// Creates two configured `BallNode` instances whose velocities diverge symmetrically
/// from `primaryVelocity`. Does not add the balls to any scene.
func makeExtraBalls(
    at position: CGPoint,
    primaryVelocity: CGVector,
    radius: CGFloat
) -> [ExtraBallSpec] {
    let (v1, v2) = multiBallVelocities(primary: primaryVelocity)
    return [v1, v2].map { vel in
        let ball = BallNode(radius: radius)
        ball.position = position
        return ExtraBallSpec(ball: ball, velocity: vel)
    }
}
