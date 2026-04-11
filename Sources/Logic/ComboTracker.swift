/// Tracks consecutive brick destructions and calculates the score multiplier.
final class ComboTracker {
    private(set) var consecutiveHits: Int = 0

    /// Current multiplier based on consecutive hits.
    /// Tiers: 1–4 hits → ×1, 5–9 → ×2, 10–19 → ×3, 20+ → ×5
    var multiplier: Int {
        switch consecutiveHits {
        case 0..<5:   return 1
        case 5..<10:  return 2
        case 10..<20: return 3
        default:      return 5
        }
    }

    /// Records a hit and returns the multiplier AFTER incrementing.
    @discardableResult
    func recordHit() -> Int {
        consecutiveHits += 1
        return multiplier
    }

    /// Resets the counter (call on each ball loss).
    func reset() {
        consecutiveHits = 0
    }
}
