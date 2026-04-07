/// Suit les destructions de briques consécutives et calcule le multiplicateur de score.
final class ComboTracker {
    private(set) var consecutiveHits: Int = 0

    /// Multiplicateur actuel basé sur les hits consécutifs.
    /// Paliers : 1–4 hits → ×1, 5–9 → ×2, 10–19 → ×3, 20+ → ×5
    var multiplier: Int {
        switch consecutiveHits {
        case 0..<5:   return 1
        case 5..<10:  return 2
        case 10..<20: return 3
        default:      return 5
        }
    }

    /// Enregistre un hit et retourne le multiplicateur APRÈS cette incrémentation.
    func recordHit() -> Int {
        consecutiveHits += 1
        return multiplier
    }

    /// Réinitialise le compteur (appeler à chaque perte de balle).
    func reset() {
        consecutiveHits = 0
    }
}
