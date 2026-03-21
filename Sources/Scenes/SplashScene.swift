import SpriteKit

final class SplashScene: SKScene {
    private let saveStore = GameSaveStore()
    private var savedGame: SavedGame?

    override func didMove(to view: SKView) {
        backgroundColor = .black
        savedGame = saveStore.load()
        let starfield = AmbientStarfieldNode(sceneSize: size)
        starfield.position = CGPoint(x: frame.midX, y: frame.maxY)
        addChild(starfield)

        let title = SKLabelNode.makeTitle("BREAKOUT")
        title.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.titleOffsetY)
        addChild(title)

        if savedGame != nil {
            setupResumeLayout()
        } else {
            setupNewGameLayout()
        }

        let store = HighScoreStore()
        if store.highScore > 0 {
            let highScoreLabel = SKLabelNode.makeBody(
                highScoreText(store.highScore),
                color: Theme.Color.accent
            )
            highScoreLabel.position = CGPoint(
                x: frame.midX,
                y: frame.midY + Theme.Layout.highScoreOffsetY - 50
            )
            addChild(highScoreLabel)
        }
    }

    private func setupNewGameLayout() {
        #if os(iOS)
        let promptText = "Tap to Play"
        #else
        let promptText = "Click to Play"
        #endif
        let prompt = SKLabelNode.makeBody(promptText)
        prompt.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.promptOffsetY)
        addChild(prompt)
        prompt.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.3, duration: 0.8),
            .fadeAlpha(to: 1.0, duration: 0.8)
        ])))
    }

    private func setupResumeLayout() {
        let resume = SKLabelNode.makeBody("Resume", color: Theme.Color.accent)
        resume.name = "resumeButton"
        resume.position = CGPoint(x: frame.midX, y: frame.midY + Theme.Layout.promptOffsetY)
        addChild(resume)
        resume.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.4, duration: 0.8),
            .fadeAlpha(to: 1.0, duration: 0.8)
        ])))

        let newGame = SKLabelNode.makeBody("New Game", color: Theme.Color.secondary)
        newGame.name = "newGameButton"
        newGame.position = CGPoint(
            x: frame.midX,
            y: frame.midY + Theme.Layout.promptOffsetY - Theme.Layout.splashButtonSpacing
        )
        addChild(newGame)
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleInput(at: touch.location(in: self))
    }
    #endif

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        handleInput(at: event.location(in: self))
    }
    #endif

    private func handleInput(at location: CGPoint) {
        if let game = savedGame {
            let tapped = nodes(at: location)
            if tapped.contains(where: { $0.name == "resumeButton" }) {
                present(GameScene(
                    size: size,
                    levelIndex: game.levelIndex,
                    gameState: GameState(lives: game.lives, score: game.score),
                    savedBrickGrid: game.brickGrid
                ))
            } else if tapped.contains(where: { $0.name == "newGameButton" }) {
                saveStore.clear()
                present(GameScene(size: size, levelIndex: 0, gameState: GameState()))
            }
        } else {
            present(GameScene(size: size, levelIndex: 0, gameState: GameState()))
        }
    }
}
