@testable import BreakoutGame
import Foundation
import Testing

struct GameSaveStoreTests {
    private func makeStore() throws -> GameSaveStore {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        return GameSaveStore(defaults: defaults)
    }

    private let sampleGame = SavedGame(
        levelIndex: 1,
        score: 120,
        lives: 2,
        brickGrid: [[.normal, .empty], [.empty, .normal]]
    )

    @Test func loadReturnsNilWhenNoSave() throws {
        #expect(try makeStore().load() == nil)
    }

    @Test func saveAndLoadRoundTrip() throws {
        let store = try makeStore()
        store.save(sampleGame)
        let loaded = try #require(store.load())
        #expect(loaded.levelIndex == sampleGame.levelIndex)
        #expect(loaded.score == sampleGame.score)
        #expect(loaded.lives == sampleGame.lives)
        #expect(loaded.brickGrid == sampleGame.brickGrid)
    }

    @Test func clearRemovesSave() throws {
        let store = try makeStore()
        store.save(sampleGame)
        store.clear()
        #expect(store.load() == nil)
    }

    @Test func saveOverwritesPreviousSave() throws {
        let store = try makeStore()
        store.save(sampleGame)
        let updated = SavedGame(levelIndex: 2, score: 200, lives: 1, brickGrid: [[.normal]])
        store.save(updated)
        let loaded = try #require(store.load())
        #expect(loaded.levelIndex == 2)
        #expect(loaded.score == 200)
    }
}
