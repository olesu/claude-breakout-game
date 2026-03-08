import SpriteKit

final class GameSummaryScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode.makeTitle("GAME OVER", color: Theme.Color.danger)
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        addChild(title)

        let prompt = SKLabelNode.makeBody("Tap to Play Again")
        prompt.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.promptOffsetY)
        addChild(prompt)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        present(SplashScene(size: size))
    }
}
