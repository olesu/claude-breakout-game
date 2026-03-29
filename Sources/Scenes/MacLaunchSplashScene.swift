#if os(macOS)
import SpriteKit

/// Displayed on macOS during the ~1 s fullscreen transition.
/// AppDelegateMac fades to SplashScene once the window has entered fullscreen.
final class MacLaunchSplashScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        let splash = SKSpriteNode(imageNamed: "MacSplash")
        splash.position = CGPoint(x: frame.midX, y: frame.midY)
        if splash.size.width > 0 && splash.size.height > 0 {
            let scaleX = size.width / splash.size.width
            let scaleY = size.height / splash.size.height
            splash.setScale(min(scaleX, scaleY))
        } else {
            assertionFailure("MacSplash image not found or has zero size")
        }
        addChild(splash)
    }
}
#endif
