#if os(macOS)
import AppKit
import QuartzCore

/// An overlay NSView that renders a neon gradient over one letterbox bar in fullscreen.
///
/// Placed on top of the SKView after the window enters fullscreen. Mouse/trackpad events
/// pass straight through (hitTest returns nil) so gameplay is unaffected.
final class LetterboxBarView: NSView {

    enum Side { case left, right }

    private static let neonColor = NSColor(
        calibratedRed: 0.22, green: 0.06, blue: 0.50, alpha: 1
    ).cgColor
    private static let clearColor = NSColor.clear.cgColor

    private let gradientLayer = CAGradientLayer()

    init(frame: NSRect, side: Side) {
        super.init(frame: frame)
        wantsLayer = true
        gradientLayer.type = .axial
        switch side {
        case .left:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .right:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        }
        gradientLayer.colors = [Self.neonColor, Self.clearColor]
        gradientLayer.frame = bounds
        layer?.addSublayer(gradientLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // Pass all events through so the SKView beneath handles them.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func layout() {
        super.layout()
        gradientLayer.frame = bounds
    }
}
#endif
