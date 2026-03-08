enum GameState: Equatable {
    case waitingToLaunch
    case playing
    case gameOver
}

class GameStateMachine {
    private(set) var state: GameState = .waitingToLaunch
    private(set) var lives: Int
    private(set) var score: Int = 0

    init(lives: Int = 3) {
        self.lives = lives
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
}
