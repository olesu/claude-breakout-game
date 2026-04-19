import SpriteKit

extension GameScene {
    /// Constructs a `BossCoordinator` for the current boss level, wiring all callbacks
    /// except `onLifeLost` — the caller wires that one (it needs access to private members).
    func buildBossCoordinator(bossPhases: Int, columns: Int) -> BossCoordinator {
        let spacing = Theme.Layout.brickSpacing
        let margin = Theme.Layout.brickSideMargin
        let layout = BrickLayout(
            size: brickSize(
                sceneWidth: frame.width, columns: columns,
                spacing: spacing, margin: margin
            ),
            spacing: spacing,
            gridOrigin: brickGridOrigin(
                sceneMinX: frame.minX, sceneMaxY: frame.maxY, margin: margin
            )
        )
        let paddleZoneY = frame.minY
            + Theme.Layout.paddleOffsetY
            + Theme.Layout.paddleHeight / 2
            + BossCoordinator.paddleZoneOffset
        let boss = BossCoordinator(
            initialBricks: bricks,
            bossPhases: bossPhases,
            layout: layout,
            columns: columns,
            sceneMaxY: frame.maxY,
            paddleZoneY: paddleZoneY,
            getBricks: { [weak self] in self?.bricks ?? [] }
        )
        boss.onWaveBricksSpawned = { [weak self] newBricks in
            guard let self else { return }
            newBricks.forEach { self.addChild($0) }
            self.bricks.append(contentsOf: newBricks)
        }
        boss.onHealthChanged = { [weak self] health in
            self?.gameCamera.updateBossHealth(health)
        }
        return boss
    }
}
