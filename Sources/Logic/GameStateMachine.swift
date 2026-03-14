enum GameState: Equatable {
    case waitingToLaunch
    case playing
    case paused
    case gameOver
}

class GameStateMachine {
    private(set) var state: GameState = .waitingToLaunch
    private(set) var lives: Int
    private(set) var score: Int

    init(lives: Int = 3, score: Int = 0) {
        self.lives = lives
        self.score = score
    }

    func addScore(_ points: Int) {
        guard state == .playing else { return }
        score += points
    }

    func launch() {
        guard state == .waitingToLaunch else { return }
        state = .playing
    }

    func ballLost() {
        guard state == .playing else { return }
        lives -= 1
        state = lives > 0 ? .waitingToLaunch : .gameOver
    }

    func pause() {
        guard state == .playing else { return }
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        state = .playing
    }

    func resetForNextLevel() {
        guard state == .playing else { return }
        state = .waitingToLaunch
    }
}
