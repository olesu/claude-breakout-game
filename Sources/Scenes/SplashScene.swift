import SpriteKit

final class SplashScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode.makeTitle("BREAKOUT")
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        addChild(title)

        let prompt = SKLabelNode.makeBody("Tap to Play")
        prompt.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.promptOffsetY)
        addChild(prompt)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        present(GameScene(size: size, levelIndex: 0, stateMachine: GameStateMachine()))
    }
}
