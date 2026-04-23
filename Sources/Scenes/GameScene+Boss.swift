import SpriteKit

// MARK: - Boss

extension GameScene {
    func setupBossCoordinator(bossPhases: Int) {
        let cols = level.grid.first?.count ?? 1
        bossCoordinator = makeBossCoordinator(
            phases: bossPhases, cols: cols, frame: frame, bricks: bricks
        )
        gameCamera.activateBossHealthBar()
    }

    func applyBossTickResult(_ result: BossTickResult) {
        result.waveBricks.forEach { addChild($0) }
        bricks.append(contentsOf: result.waveBricks)
        if let h = result.healthRatio { gameCamera.updateBossHealth(h) }
        if result.lifeLost { handleBossLifeLoss() }
    }

    func handleBossLifeLoss() {
        ballCoordinator.removeExtras()
        handleBallLoss()
    }
}
