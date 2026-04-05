import Foundation

enum PowerUpType: CaseIterable {
    case powerBall
    case widePaddle
    case slowBall
    case extraLife
    case multiBall
    case laser

    var label: String {
        switch self {
        case .powerBall: return "PB"
        case .widePaddle: return "WP"
        case .slowBall: return "SB"
        case .extraLife: return "+1"
        case .multiBall: return "MB"
        case .laser: return "LZ"
        }
    }

    var duration: TimeInterval? {
        switch self {
        case .powerBall: return Theme.Layout.powerUpDuration
        case .widePaddle: return Theme.Layout.powerUpDuration
        case .slowBall: return Theme.Layout.powerUpDuration
        case .extraLife: return nil
        case .multiBall: return nil
        case .laser: return Theme.Layout.powerUpDuration
        }
    }
}
