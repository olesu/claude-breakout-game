import Foundation

/// Returns the frame delta for `currentTime`, treating `lastUpdateTime == 0`
/// as the first frame and yielding zero so the first tick is a no-op.
func frameDelta(
    last lastUpdateTime: TimeInterval,
    current currentTime: TimeInterval
) -> TimeInterval {
    lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
}
