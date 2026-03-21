#if os(macOS)
import AppKit
import SpriteKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var didEnterFullScreen = false

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

        let skView = SKView(frame: NSRect(origin: .zero, size: contentSize))
        skView.autoresizingMask = [.width, .height]

        let scene = SplashScene(size: contentSize)
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)

        window.contentView = skView
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(skView)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
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
        guard !didEnterFullScreen else { return }
        didEnterFullScreen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let window = self?.window else { return }
            window.toggleFullScreen(nil)
        }
    }
}
#endif
