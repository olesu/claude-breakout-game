import UIKit

enum PowerUpType {
    case powerBall

    var label: String {
        switch self {
        case .powerBall: return "PB"
        }
    }

    var color: UIColor {
        switch self {
        case .powerBall: return Theme.Color.powerUp
        }
    }

    var duration: TimeInterval? {
        switch self {
        case .powerBall: return 8.0
        }
    }
}
