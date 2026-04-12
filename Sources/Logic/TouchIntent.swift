enum TouchIntent {
    case pause
    case resume
    case toggleMute
    case launchAndMovePaddle
    case movePaddle
    case none
}

func touchIntent(hitsPauseButton: Bool, hitsMuteButton: Bool, phase: GamePhase) -> TouchIntent {
    if hitsPauseButton {
        switch phase {
        case .playing: return .pause
        case .paused:  return .resume
        default:       return .none
        }
    }
    if hitsMuteButton {
        switch phase {
        case .waitingToLaunch, .playing: return .toggleMute
        default:                         return .none
        }
    }
    switch phase {
    case .paused, .gameOver:  return .none
    case .waitingToLaunch:    return .launchAndMovePaddle
    case .playing:            return .movePaddle
    }
}
