#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

enum Theme {
    enum Font {
        static let bold = "AvenirNext-Bold"
        static let regular = "AvenirNext-Regular"
    }

    enum FontSize {
        static let large: CGFloat = 48
        static let medium: CGFloat = 28
        static let small: CGFloat = 22
    }

    enum Color {
        static let primary: PlatformColor = .white
        static let secondary: PlatformColor = .lightGray
        static let accent: PlatformColor = .yellow
        static let danger: PlatformColor = .red
        static let brick: PlatformColor = .cyan
        static let powerUp: PlatformColor =
            PlatformColor(red: 1.0, green: 0.45, blue: 0.05, alpha: 1)
        static let widePaddle: PlatformColor =
            PlatformColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1)
        static let slowBall: PlatformColor =
            PlatformColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
        static let extraLife: PlatformColor =
            PlatformColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1)
        static let indestructible: PlatformColor = PlatformColor(white: 0.3, alpha: 1.0)
        static let indestructibleBorder: PlatformColor =
            PlatformColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 0.7)
        static let brickColors: [PlatformColor] = [
            PlatformColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1), // coral-red
            PlatformColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1), // orange
            PlatformColor(red: 1.0, green: 0.95, blue: 0.2, alpha: 1), // yellow
            PlatformColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1), // green
            PlatformColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1), // cyan
            PlatformColor(red: 0.5, green: 0.3, blue: 1.0, alpha: 1), // blue-violet
            PlatformColor(red: 0.85, green: 0.2, blue: 1.0, alpha: 1) // purple
        ]
    }

    enum Symbol {
        static let pause = "II"
    }

    enum Layout {
        static let titleOffsetY: CGFloat = 40
        static let promptOffsetY: CGFloat = -60
        static let paddleOffsetY: CGFloat = 60
        static let paddleWidthRatio: CGFloat = 0.2
        static let paddleHeight: CGFloat = 14
        static let ballRadius: CGFloat = 10
        static let ballLaunchVelocity = CGVector(dx: 300, dy: 500)
        static let transitionDuration: TimeInterval = 0.4
        static let brickSpacing: CGFloat = 4
        static let brickHeight: CGFloat = 14
        static let brickSideMargin: CGFloat = 8
        static let brickTopMargin: CGFloat = 120
        static let brickPoints: Int = 10
        static let hudTopPadding: CGFloat = 8
        static let hudSideMargin: CGFloat = 16
        static let highScoreOffsetY: CGFloat = -30
        static let splashButtonSpacing: CGFloat = 44
        static let powerUpSize: CGSize = CGSize(width: 34, height: 14)
        static let powerUpFallSpeed: CGFloat = 180
        static let powerUpDuration: TimeInterval = 8.0
        static let powerUpDropProbability: Double = 0.12
        static let paddleWidthMultiplier: CGFloat = 1.5
        static let slowBallFactor: CGFloat = 0.6
        static let paddleMaxAngle: CGFloat = .pi / 3     // 60° from vertical at paddle edge
        static let ballMinVerticalRatio: CGFloat = 0.2   // safety-net: minimum |dy| / speed
    }
}
