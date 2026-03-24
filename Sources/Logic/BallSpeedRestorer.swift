import CoreGraphics

/// Returns a velocity vector rescaled so its magnitude equals `savedSpeed`,
/// preserving the direction of `current`.
///
/// Use this to restore a ball's pre-slow-ball speed after the slow-ball
/// power-up expires.
///
/// - Parameters:
///   - current:    The ball's current velocity vector.
///   - savedSpeed: The speed to restore (magnitude of the pre-slow velocity).
/// - Returns: A vector with the same direction as `current` and magnitude
///            equal to `savedSpeed`, or `.zero` if `current` has no magnitude.
func restoredVelocity(current: CGVector, savedSpeed: CGFloat) -> CGVector {
    let currentSpeed = hypot(current.dx, current.dy)
    guard currentSpeed > 0 else { return .zero }
    let scale = savedSpeed / currentSpeed
    return CGVector(dx: current.dx * scale, dy: current.dy * scale)
}
