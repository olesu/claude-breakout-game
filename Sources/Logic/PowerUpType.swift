import Foundation

enum PowerUpType: CaseIterable {
    case powerBall
    case widePaddle
    case slowBall
    case extraLife

    var label: String {
        switch self {
        case .powerBall: return "PB"
        case .widePaddle: return "WP"
        case .slowBall: return "SB"
        case .extraLife: return "+1"
        }
    }

    var duration: TimeInterval? {
        switch self {
        case .powerBall: return Theme.Layout.powerUpDuration
        case .widePaddle: return Theme.Layout.powerUpDuration
        case .slowBall: return Theme.Layout.powerUpDuration
        case .extraLife: return nil
        }
    }
}
