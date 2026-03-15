enum TouchIntent {
    case pause
    case resume
    case launchAndMovePaddle
    case movePaddle
    case none
}

func touchIntent(hitsPauseButton: Bool, phase: GamePhase) -> TouchIntent {
    if hitsPauseButton {
        switch phase {
        case .playing: return .pause
        case .paused:  return .resume
        default:       return .none
        }
    }
    switch phase {
    case .paused, .gameOver:  return .none
    case .waitingToLaunch:    return .launchAndMovePaddle
    case .playing:            return .movePaddle
    }
}
