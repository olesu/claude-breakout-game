#if os(iOS)
import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = UIViewController()
        let skView = SKView(frame: window.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(skView)

        let scene = SplashScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
#endif
