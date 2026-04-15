#if os(macOS)
import AppKit
import SpriteKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var containerView: NSView!
    private var skView: SKView!
    private var didEnterFullScreen = false
    private var cursorHidden = false

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        let contentSize = CGSize(width: 390, height: 844)
        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.collectionBehavior = [.fullScreenPrimary]

        containerView = NSView(frame: NSRect(origin: .zero, size: contentSize))
        containerView.autoresizingMask = [.width, .height]

        skView = SKView(frame: NSRect(origin: .zero, size: contentSize))
        skView.autoresizingMask = [.width, .height]

        let scene = MacLaunchSplashScene(size: contentSize)
        skView.presentScene(scene)

        containerView.addSubview(skView)
        window.contentView = containerView
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(skView)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationWillResignActive(_ notification: Notification) {
        showCursor()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if window.isKeyWindow {
            if let scene = skView.scene, scene is GameScene {
                // Reset flag before hiding: macOS may have called NSCursor.unhide()
                // internally (e.g. for the fullscreen menu bar), leaving cursorHidden
                // stale at true while the cursor is actually visible.
                cursorHidden = false
                hideCursor()
            }
        }
    }

    func hideCursor() {
        guard !cursorHidden else { return }
        NSCursor.hide()
        cursorHidden = true
    }

    func showCursor() {
        guard cursorHidden else { return }
        NSCursor.unhide()
        cursorHidden = false
    }

    private func setupMenu() {
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(
            title: "Quit Breakout",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        let mainMenu = NSMenu()
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowDidBecomeKey(_ notification: Notification) {
        if skView.scene is GameScene {
            cursorHidden = false
            hideCursor()
        }
        guard !didEnterFullScreen else { return }
        didEnterFullScreen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let window = self?.window else { return }
            window.toggleFullScreen(nil)
        }
    }

    func windowDidResignKey(_ notification: Notification) {
        showCursor()
    }

    func windowDidEnterFullScreen(_ notification: Notification) {
        // Remove stale bars from any previous fullscreen session.
        containerView.subviews
            .filter { $0 is LetterboxBarView }
            .forEach { $0.removeFromSuperview() }
        let size = containerView.bounds.size
        let scale = size.height / 844.0
        let barWidth = (size.width - 390.0 * scale) / 2.0
        if barWidth > 1 {
            let leftFrame = NSRect(x: 0, y: 0, width: barWidth, height: size.height)
            let rightFrame = NSRect(
                x: size.width - barWidth, y: 0, width: barWidth, height: size.height
            )
            containerView.addSubview(LetterboxBarView(frame: leftFrame, side: .left))
            containerView.addSubview(LetterboxBarView(frame: rightFrame, side: .right))
        }
        let splash = SplashScene(size: CGSize(width: 390, height: 844))
        splash.scaleMode = .aspectFit
        let fade = SKTransition.fade(withDuration: Theme.Layout.transitionDuration)
        skView.presentScene(splash, transition: fade)
        window.makeFirstResponder(skView)
    }
}
#endif
