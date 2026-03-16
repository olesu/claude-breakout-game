import Foundation

enum PowerUpType {
    case powerBall

    var label: String {
        switch self {
        case .powerBall: return "PB"
        }
    }

    var duration: TimeInterval? {
        switch self {
        case .powerBall: return Theme.Layout.powerUpDuration
        }
    }
}
