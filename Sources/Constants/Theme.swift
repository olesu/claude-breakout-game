import UIKit

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
        static let primary: UIColor = .white
        static let secondary: UIColor = .lightGray
        static let accent: UIColor = .yellow
        static let danger: UIColor = .red
        static let brick: UIColor = .cyan
        static let brickColors: [UIColor] = [
            UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1), // coral-red
            UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1), // orange
            UIColor(red: 1.0, green: 0.95, blue: 0.2, alpha: 1), // yellow
            UIColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1), // green
            UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1), // cyan
            UIColor(red: 0.5, green: 0.3, blue: 1.0, alpha: 1), // blue-violet
            UIColor(red: 0.85, green: 0.2, blue: 1.0, alpha: 1) // purple
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
        static let brickHeight: CGFloat = 20
        static let brickSideMargin: CGFloat = 8
        static let brickTopMargin: CGFloat = 120
        static let brickPoints: Int = 10
        static let hudTopPadding: CGFloat = 8
        static let hudSideMargin: CGFloat = 16
        static let highScoreOffsetY: CGFloat = -30
        static let splashButtonSpacing: CGFloat = 44
    }
}
