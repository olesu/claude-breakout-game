struct GameState {
    var phase: GamePhase
    var lives: Int
    var score: Int

    init(lives: Int = 3, score: Int = 0) {
        self.phase = .waitingToLaunch
        self.lives = lives
        self.score = score
    }

    // points must be positive; negative or zero values are silently ignored.
    mutating func addScore(_ points: Int) {
        guard phase == .playing, points > 0 else { return }
        score += points
    }

    mutating func launch() {
        guard phase == .waitingToLaunch else { return }
        phase = .playing
    }

    mutating func ballLost() {
        guard phase == .playing else { return }
        lives -= 1
        phase = lives > 0 ? .waitingToLaunch : .gameOver
    }

    mutating func pause() {
        guard phase == .playing else { return }
        phase = .paused
    }

    mutating func resume() {
        guard phase == .paused else { return }
        phase = .playing
    }

    mutating func resetForNextLevel() {
        guard phase == .playing else { return }
        phase = .waitingToLaunch
    }
}
