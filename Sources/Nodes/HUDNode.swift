import SpriteKit
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

final class HUDNode: SKNode {
    private let livesLabel: SKLabelNode
    private let scoreLabel: SKLabelNode
    private let pauseButton: SKLabelNode
    private let muteButton: SKSpriteNode
    private let comboLabel: SKLabelNode
    private var lastScore: Int = 0
    private var lastComboMultiplier: Int = 1

    init(sceneSize: CGSize, topSafeArea: CGFloat) {
        livesLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        scoreLabel = SKLabelNode.makeBody("", color: Theme.Color.accent)
        pauseButton = SKLabelNode.makeBody(Theme.Symbol.pause, color: Theme.Color.primary)
        muteButton = SKSpriteNode(texture: HUDNode.muteTexture(muted: false))
        comboLabel = SKLabelNode.makeBody("", color: Theme.Color.danger)
        super.init()
        let hudY = sceneSize.height / 2 - topSafeArea - Theme.Layout.hudTopPadding
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: -sceneSize.width / 2 + Theme.Layout.hudSideMargin, y: hudY)
        scoreLabel.position = CGPoint(x: 0, y: hudY)
        pauseButton.horizontalAlignmentMode = .right
        pauseButton.position = CGPoint(x: sceneSize.width / 2 - Theme.Layout.hudSideMargin, y: hudY)
        pauseButton.name = "pauseButton"
        muteButton.color = Theme.Color.primary
        muteButton.colorBlendFactor = 1
        muteButton.position = CGPoint(
            x: sceneSize.width / 2 - Theme.Layout.hudSideMargin - Theme.Layout.muteButtonOffset,
            y: hudY
        )
        muteButton.name = "muteButton"
        // Combo label sits below the score, hidden while multiplier is ×1
        comboLabel.position = CGPoint(x: 0, y: hudY + Theme.Layout.highScoreOffsetY)
        comboLabel.alpha = 0
        addChild(livesLabel)
        addChild(scoreLabel)
        addChild(pauseButton)
        addChild(muteButton)
        addChild(comboLabel)
    }

    func setMuted(_ muted: Bool) {
        muteButton.texture = HUDNode.muteTexture(muted: muted)
    }

    private static func muteTexture(muted: Bool) -> SKTexture {
        let symbolName = muted ? "speaker.slash" : "speaker.wave.2"
        #if canImport(UIKit)
        let config = UIImage.SymbolConfiguration(pointSize: Theme.FontSize.small, weight: .regular)
        // swiftlint:disable:next force_unwrapping
        let image = UIImage(systemName: symbolName, withConfiguration: config)!
        #else
        // swiftlint:disable:next force_unwrapping
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)!
        #endif
        return SKTexture(image: image)
    }

    func update(lives: Int, score: Int, comboMultiplier: Int = 1) {
        livesLabel.text = livesText(lives)
        if score != lastScore {
            lastScore = score
            scoreLabel.text = scoreText(score)
            scoreLabel.removeAction(forKey: "scorePop")
            let pop = SKAction.sequence([
                .scale(to: 1.3, duration: 0.07),
                .scale(to: 1.0, duration: 0.10)
            ])
            scoreLabel.run(pop, withKey: "scorePop")
        }
        updateComboLabel(multiplier: comboMultiplier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

// MARK: - Combo label

private extension HUDNode {
    func updateComboLabel(multiplier: Int) {
        if multiplier <= 1 {
            if lastComboMultiplier > 1 {
                comboLabel.removeAllActions()
                comboLabel.run(.fadeOut(withDuration: 0.25))
            }
            lastComboMultiplier = multiplier
            return
        }
        comboLabel.text = "×\(multiplier) COMBO"
        if comboLabel.alpha < 0.1 {
            comboLabel.run(.fadeIn(withDuration: 0.15))
        }
        if multiplier != lastComboMultiplier {
            comboLabel.removeAction(forKey: "comboPulse")
            comboLabel.run(.sequence([
                .scale(to: 1.45, duration: 0.06),
                .scale(to: 1.0, duration: 0.10)
            ]), withKey: "comboPulse")
        }
        lastComboMultiplier = multiplier
    }
}
