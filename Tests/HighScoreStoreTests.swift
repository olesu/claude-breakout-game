@testable import BreakoutGame
import Foundation
import Testing

struct HighScoreStoreTests {
    private func makeStore() throws -> HighScoreStore {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        return HighScoreStore(defaults: defaults)
    }

    @Test func initialHighScoreIsZero() throws {
        #expect(try makeStore().highScore == 0)
    }

    @Test func submitScoreStoresFirstScore() throws {
        let store = try makeStore()
        store.submitScore(100)
        #expect(store.highScore == 100)
    }

    @Test func submitScoreReturnsTrueForNewRecord() throws {
        #expect(try makeStore().submitScore(100) == true)
    }

    @Test func submitHigherScoreUpdatesHighScore() throws {
        let store = try makeStore()
        store.submitScore(100)
        store.submitScore(200)
        #expect(store.highScore == 200)
    }

    @Test func submitLowerScoreDoesNotUpdate() throws {
        let store = try makeStore()
        store.submitScore(200)
        store.submitScore(100)
        #expect(store.highScore == 200)
    }

    @Test func submitLowerScoreReturnsFalse() throws {
        let store = try makeStore()
        store.submitScore(200)
        #expect(store.submitScore(100) == false)
    }

    @Test func submitEqualScoreDoesNotUpdate() throws {
        let store = try makeStore()
        store.submitScore(100)
        #expect(store.submitScore(100) == false)
    }
}
