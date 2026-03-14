import Foundation

struct GameSaveStore {
    private static let key = "savedGame"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ game: SavedGame) {
        guard let data = try? JSONEncoder().encode(game) else { return }
        defaults.set(data, forKey: Self.key)
    }

    func load() -> SavedGame? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(SavedGame.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
    }
}
