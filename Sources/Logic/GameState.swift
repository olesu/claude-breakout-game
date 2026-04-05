struct GameState {
    let phase: GamePhase
    let lives: Int
    let score: Int
    // Nombre de briques détruites consécutivement sans contact avec la raquette
    let consecutiveHits: Int

    /// Paliers : 1–4 hits → ×1, 5–9 → ×2, 10–14 → ×3, 15–19 → ×4, 20+ → ×5
    var comboMultiplier: Int {
        switch consecutiveHits {
        case 0..<5:  return 1
        case 5..<10: return 2
        case 10..<15: return 3
        case 15..<20: return 4
        default: return 5
        }
    }

    init(lives: Int = 3, score: Int = 0) {
        self.phase = .waitingToLaunch
        self.lives = lives
        self.score = score
        self.consecutiveHits = 0
    }

    // Internal transitions only — callers must use the public transition methods.
    private init(phase: GamePhase, lives: Int, score: Int, consecutiveHits: Int) {
        self.phase = phase
        self.lives = lives
        self.score = score
        self.consecutiveHits = consecutiveHits
    }

    // points must be positive; negative or zero values are silently ignored.
    func addScore(_ points: Int) -> GameState {
        guard phase == .playing, points > 0 else { return self }
        return GameState(phase: phase, lives: lives, score: score + points, consecutiveHits: consecutiveHits)
    }

    // Incrémente le compteur de hits consécutifs lors de la destruction d'une brique
    func brickDestroyed() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: phase, lives: lives, score: score, consecutiveHits: consecutiveHits + 1)
    }

    // Remet le compteur à zéro lors d'un contact balle–raquette
    func paddleContact() -> GameState {
        guard phase == .playing, consecutiveHits > 0 else { return self }
        return GameState(phase: phase, lives: lives, score: score, consecutiveHits: 0)
    }

    func launch() -> GameState {
        guard phase == .waitingToLaunch else { return self }
        return GameState(phase: .playing, lives: lives, score: score, consecutiveHits: consecutiveHits)
    }

    func ballLost() -> GameState {
        guard phase == .playing else { return self }
        let newLives = lives - 1
        let newPhase: GamePhase = newLives > 0 ? .waitingToLaunch : .gameOver
        // La perte de balle remet aussi le combo à zéro
        return GameState(phase: newPhase, lives: newLives, score: score, consecutiveHits: 0)
    }

    func pause() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: .paused, lives: lives, score: score, consecutiveHits: consecutiveHits)
    }

    func resume() -> GameState {
        guard phase == .paused else { return self }
        return GameState(phase: .playing, lives: lives, score: score, consecutiveHits: consecutiveHits)
    }

    func addLife() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: phase, lives: lives + 1, score: score, consecutiveHits: consecutiveHits)
    }

    func resetForNextLevel() -> GameState {
        guard phase == .playing else { return self }
        return GameState(phase: .waitingToLaunch, lives: lives, score: score, consecutiveHits: 0)
    }
}
