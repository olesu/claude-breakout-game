struct GameState {
    let phase: GamePhase
    let lives: Int
    let score: Int

    init(lives: Int = 3, score: Int = 0) {
        self.phase = .waitingToLaunch
        self.lives = lives
        self.score = score
    }

    // Transitions internes uniquement — les appelants utilisent les méthodes publiques.
    private init(phase: GamePhase, lives: Int, score: Int) {
        self.phase = phase
        self.lives = lives
        self.score = score
    }

    // points doit être positif ; les valeurs négatives ou nulles sont ignorées silencieusement.
    func addScore(_ points: Int) -> GameState {
        guard phase == .playing, points > 0 else { return self }
        return GameState(phase: phase, lives: lives, score: score + points)
    }

    func launch() -> GameState {
        guard phase == .waitingToLaunch else { return self }
        return GameState(phase: .playing, lives: lives, score: score)
    }

    func ballLost() -> GameState {
        guard phase == .playing else { return self }
        let newLives = lives - 1
        let newPhase: GamePhase = newLives > 0 ? .waitingToLaunch : .gameOver
        return GameState(phase: newPhase, lives: newLives, score: score)
    }

    func pause() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: .paused, lives: lives, score: score)
    }

    func resume() -> GameState {
        guard phase == .paused else { return self }
        return GameState(phase: .playing, lives: lives, score: score)
    }

    func addLife() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: phase, lives: lives + 1, score: score)
    }

    func resetForNextLevel() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: .waitingToLaunch, lives: lives, score: score)
    }
}
