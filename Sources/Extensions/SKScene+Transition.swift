import SpriteKit

extension SKScene {
    func present(_ next: SKScene) {
        next.scaleMode = scaleMode
        view?.presentScene(next, transition: .fade(withDuration: Theme.Layout.transitionDuration))
    }
}
