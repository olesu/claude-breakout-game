final class GameStateMachine {
    private(set) var gameState: GameState

    // Backwards-compatible surface so GameScene requires no changes yet
    var state: GamePhase { gameState.phase }
    var lives: Int { gameState.lives }
    var score: Int { gameState.score }

    init(lives: Int = 3, score: Int = 0) {
        gameState = GameState(lives: lives, score: score)
    }

    func addScore(_ points: Int) {
        gameState = gameState.addScore(points)
    }

    func launch() {
        gameState = gameState.launch()
    }

    func ballLost() {
        gameState = gameState.ballLost()
    }

    func pause() {
        gameState = gameState.pause()
    }

    func resume() {
        gameState = gameState.resume()
    }

    func resetForNextLevel() {
        gameState = gameState.resetForNextLevel()
    }
}
