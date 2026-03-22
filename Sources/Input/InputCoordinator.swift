import CoreGraphics

enum InputAction: Equatable {
    case none
    case pause
    case resume
    case movePaddle(x: CGFloat)
    case launchAndMovePaddle(x: CGFloat)
}

struct InputCoordinator {
    func action(at location: CGPoint, hittingPauseButton: Bool, phase: GamePhase) -> InputAction {
        let intent = touchIntent(hitsPauseButton: hittingPauseButton, phase: phase)
        switch intent {
        case .none:                return .none
        case .pause:               return .pause
        case .resume:              return .resume
        case .movePaddle:          return .movePaddle(x: location.x)
        case .launchAndMovePaddle: return .launchAndMovePaddle(x: location.x)
        }
    }
}
