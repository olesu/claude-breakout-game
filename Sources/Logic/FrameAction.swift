import CoreGraphics

enum FrameAction {
    case nothing
    case resetBall
    case handleBallLoss
    case advanceLevel
}

func frameAction(
    phase: GamePhase,
    ballsAllLost: Bool,
    levelComplete: Bool
) -> FrameAction {
    guard phase != .paused, phase != .gameOver else { return .nothing }
    if levelComplete { return .advanceLevel }
    if phase == .waitingToLaunch { return .resetBall }
    if phase == .playing && ballsAllLost { return .handleBallLoss }
    return .nothing
}
