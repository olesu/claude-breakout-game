import SpriteKit

final class SplashScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let title = SKLabelNode(text: "BREAKOUT")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.midY + 40)
        addChild(title)

        let prompt = SKLabelNode(text: "Tap to Play")
        prompt.fontName = "AvenirNext-Regular"
        prompt.fontSize = 22
        prompt.fontColor = .lightGray
        prompt.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        addChild(prompt)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        present(GameScene(size: size))
    }
}
