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
    }

    enum Layout {
        static let titleOffsetY: CGFloat = 40
        static let promptOffsetY: CGFloat = -20
        static let paddleOffsetY: CGFloat = 60
        static let paddleWidthRatio: CGFloat = 0.2
        static let paddleHeight: CGFloat = 14
        static let ballRadius: CGFloat = 10
        static let ballLaunchVelocity = CGVector(dx: 300, dy: 500)
        static let transitionDuration: TimeInterval = 0.4
    }
}
