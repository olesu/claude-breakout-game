import SpriteKit

/// Returns indices in `balls[1...]` whose y-position is below `floorY`,
/// sorted descending so callers can safely remove by index without shifting.
func fallenExtraBallIndices(balls: [BallNode], floorY: CGFloat) -> [Int] {
    balls.indices.dropFirst()
        .filter { balls[$0].position.y < floorY }
        .sorted(by: >)
}
