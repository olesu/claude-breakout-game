enum GameState: Equatable {
    case waitingToLaunch
    case playing
    case gameOver
}

class GameStateMachine {
    private(set) var state: GameState = .waitingToLaunch
    private(set) var lives: Int

    init(lives: Int = 3) {
        self.lives = lives
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
