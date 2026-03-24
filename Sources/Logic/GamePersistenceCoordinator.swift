struct GamePersistenceCoordinator {
    private let store: GameSaveStore

    init(store: GameSaveStore = GameSaveStore()) {
        self.store = store
    }

    func gamePaused(snapshot: () -> SavedGame) {
        store.save(snapshot())
    }

    func sceneWillDisappear(isLevelComplete: Bool, phase: GamePhase, snapshot: () -> SavedGame) {
        guard !isLevelComplete && phase != .gameOver && phase != .paused else { return }
        store.save(snapshot())
    }

    func gameOver() {
        store.clear()
    }

    func levelVictory() {
        store.clear()
    }
}
