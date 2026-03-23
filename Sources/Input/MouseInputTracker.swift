#if os(macOS)
import AppKit

final class MouseInputTracker {
    private var trackingArea: NSTrackingArea?

    func install(on view: NSView) {
        let ta = NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect],
            owner: view,
            userInfo: nil
        )
        view.addTrackingArea(ta)
        trackingArea = ta
    }

    func uninstall(from view: NSView) {
        if let ta = trackingArea { view.removeTrackingArea(ta) }
    }
}
#endif
