import CoreGraphics

enum FrameAction {
    case nothing
    case resetBall
    case handleBallLoss
    case advanceLevel
}

func frameAction(
    phase: GamePhase,
    ballY: CGFloat,
    floorY: CGFloat,
    levelComplete: Bool
) -> FrameAction {
    guard phase != .paused, phase != .gameOver else { return .nothing }
    if levelComplete { return .advanceLevel }
    if phase == .waitingToLaunch { return .resetBall }
    if phase == .playing && ballY <= floorY { return .handleBallLoss }
    return .nothing
}
