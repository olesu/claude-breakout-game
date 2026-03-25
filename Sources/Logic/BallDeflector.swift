import CoreGraphics

/// Returns a velocity vector for a ball that has just hit a paddle.
///
/// The outgoing angle is determined by where the ball contacted the paddle:
/// centre → straight up (0°), edges → up to ±`maxAngle` from vertical.
/// Total speed is preserved. `dy` is always positive (upward).
///
/// - Parameters:
///   - speed:          Current ball speed (magnitude of velocity).
///   - contactX:       X-position of the contact point.
///   - paddleCenterX:  X-position of the paddle's centre.
///   - halfPaddleWidth: Half the paddle's effective width.
///   - maxAngle:       Maximum outgoing angle from vertical, in radians.
func paddleReflectedVelocity(
    speed: CGFloat,
    contactX: CGFloat,
    paddleCenterX: CGFloat,
    halfPaddleWidth: CGFloat,
    maxAngle: CGFloat
) -> CGVector {
    guard speed > 0, halfPaddleWidth > 0 else { return .zero }
    let hitFraction = max(-1, min(1, (contactX - paddleCenterX) / halfPaddleWidth))
    let angle = hitFraction * maxAngle
    return CGVector(dx: speed * sin(angle), dy: speed * cos(angle))
}

/// Returns two velocity vectors diverging symmetrically from `primary` by `±spread` radians,
/// preserving the original speed. Used when spawning extra balls for the Multi Ball power-up.
///
/// - Parameters:
///   - primary: The reference velocity vector.
///   - spread:  Half-angle between the two output vectors, in radians (default π/6 = 30°).
func multiBallVelocities(primary: CGVector, spread: CGFloat = .pi / 6) -> (CGVector, CGVector) {
    let speed = hypot(primary.dx, primary.dy)
    guard speed > 0 else { return (.zero, .zero) }
    let angle = atan2(primary.dy, primary.dx)
    let v1 = CGVector(dx: cos(angle + spread) * speed, dy: sin(angle + spread) * speed)
    let v2 = CGVector(dx: cos(angle - spread) * speed, dy: sin(angle - spread) * speed)
    return (v1, v2)
}

/// Returns a velocity vector with its vertical component raised to at least
/// `minVerticalRatio` of the total speed. `dx` is rescaled to preserve speed.
///
/// This is a safety net against near-horizontal trajectories that can arise
/// from wall or brick bounces — **not** from paddle bounces, which are already
/// angle-controlled by `paddleReflectedVelocity`.
///
/// - Parameters:
///   - velocity:         Current velocity vector.
///   - minVerticalRatio: Minimum |dy| / speed (0…1). Values outside that range
///                       are clamped to [0, 1].
func clampedVerticalVelocity(velocity: CGVector, minVerticalRatio: CGFloat) -> CGVector {
    let speed = hypot(velocity.dx, velocity.dy)
    guard speed > 0 else { return .zero }
    let ratio = max(0, min(1, minVerticalRatio))
    let minDY = speed * ratio
    guard abs(velocity.dy) < minDY else { return velocity }
    let sign: CGFloat = velocity.dy >= 0 ? 1 : -1
    // Recompute |dx| to preserve total speed after raising |dy| to minDY.
    let dx = sqrt(max(0, speed * speed - minDY * minDY))
    return CGVector(dx: velocity.dx >= 0 ? dx : -dx, dy: sign * minDY)
}
