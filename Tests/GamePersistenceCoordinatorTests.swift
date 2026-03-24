@testable import BreakoutGame
import Foundation
import Testing

struct GamePersistenceCoordinatorTests {
    private func makeCoordinator() throws -> (GamePersistenceCoordinator, GameSaveStore) {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let store = GameSaveStore(defaults: defaults)
        return (GamePersistenceCoordinator(store: store), store)
    }

    private let snapshot = SavedGame(levelIndex: 0, score: 100, lives: 3, brickGrid: [[true]])

    @Test func gamePausedSavesSnapshot() throws {
        let (coordinator, store) = try makeCoordinator()
        coordinator.gamePaused(snapshot: { snapshot })
        #expect(store.load() != nil)
    }

    @Test(arguments: [GamePhase.waitingToLaunch, .playing])
    func sceneWillDisappearWithActivePhasesSaves(phase: GamePhase) throws {
        let (coordinator, store) = try makeCoordinator()
        coordinator.sceneWillDisappear(
            isLevelComplete: false, phase: phase, snapshot: { snapshot }
        )
        #expect(store.load() != nil)
    }

    @Test func sceneWillDisappearWhenPausedSkips() throws {
        let (coordinator, store) = try makeCoordinator()
        coordinator.sceneWillDisappear(
            isLevelComplete: false, phase: .paused, snapshot: { snapshot }
        )
        #expect(store.load() == nil)
    }

    @Test func sceneWillDisappearWhenLevelCompleteSkips() throws {
        let (coordinator, store) = try makeCoordinator()
        coordinator.sceneWillDisappear(
            isLevelComplete: true, phase: .playing, snapshot: { snapshot }
        )
        #expect(store.load() == nil)
    }

    @Test func sceneWillDisappearWhenGameOverSkips() throws {
        let (coordinator, store) = try makeCoordinator()
        coordinator.sceneWillDisappear(
            isLevelComplete: false, phase: .gameOver, snapshot: { snapshot }
        )
        #expect(store.load() == nil)
    }

    @Test func gameOverClearsSave() throws {
        let (coordinator, store) = try makeCoordinator()
        store.save(snapshot)
        coordinator.gameOver()
        #expect(store.load() == nil)
    }

    @Test func levelVictoryClearsSave() throws {
        let (coordinator, store) = try makeCoordinator()
        store.save(snapshot)
        coordinator.levelVictory()
        #expect(store.load() == nil)
    }
}
