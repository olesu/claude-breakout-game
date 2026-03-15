import SpriteKit

final class GameCameraNode: SKCameraNode {
    private let restPosition: CGPoint
    private let hud: HUDNode
    private let pauseOverlay: PauseOverlayNode

    init(sceneSize: CGSize, levelName: String, topSafeArea: CGFloat) {
        let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        restPosition = center
        hud = HUDNode(sceneSize: sceneSize, topSafeArea: topSafeArea)
        pauseOverlay = PauseOverlayNode(sceneSize: sceneSize)
        super.init()
        position = center
        addChild(hud)
        pauseOverlay.isHidden = true
        addChild(pauseOverlay)
        spawnLevelTitle(levelName)
    }

    func updateHUD(lives: Int, score: Int) {
        hud.update(lives: lives, score: score)
    }

    func setPaused(_ isPaused: Bool) {
        pauseOverlay.isHidden = !isPaused
    }

    func shake(duration: TimeInterval = 0.4, magnitude: CGFloat = 12) {
        let count = 6
        let step = duration / Double(count)
        var actions: [SKAction] = []
        for i in 0..<count {
            let sign: CGFloat = i % 2 == 0 ? 1 : -1
            let decay = magnitude * (1 - CGFloat(i) / CGFloat(count))
            actions.append(.move(
                to: CGPoint(
                    x: restPosition.x + sign * decay,
                    y: restPosition.y + sign * decay * 0.5
                ),
                duration: step
            ))
        }
        actions.append(.move(to: restPosition, duration: step))
        run(.sequence(actions), withKey: "shake")
    }

    private func spawnLevelTitle(_ name: String) {
        let title = SKLabelNode.makeTitle(name)
        // Camera-relative coords: (0, 0) is screen centre
        let finalPosition = CGPoint(x: 0, y: Theme.Layout.titleOffsetY)
        title.position = CGPoint(x: 0, y: finalPosition.y - 60)
        title.alpha = 0
        let entry = SKAction.group([
            .fadeIn(withDuration: 0.35),
            .move(to: finalPosition, duration: 0.35)
        ])
        title.run(.sequence([
            entry, .wait(forDuration: 1.5), .fadeOut(withDuration: 0.5), .removeFromParent()
        ]))
        addChild(title)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
