import Foundation

enum PowerUpType: CaseIterable {
    case powerBall
    case widePaddle

    var label: String {
        switch self {
        case .powerBall: return "PB"
        case .widePaddle: return "WP"
        }
    }

    var duration: TimeInterval? {
        switch self {
        case .powerBall: return Theme.Layout.powerUpDuration
        case .widePaddle: return Theme.Layout.powerUpDuration
        }
    }
}
