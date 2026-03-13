import Foundation

struct HighScoreStore {
    private static let key = "highScore"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var highScore: Int {
        defaults.integer(forKey: Self.key)
    }

    // Mutates the underlying UserDefaults reference; safe to call on a let binding.
    @discardableResult
    func submitScore(_ score: Int) -> Bool {
        guard score > highScore else { return false }
        defaults.set(score, forKey: Self.key)
        return true
    }
}
