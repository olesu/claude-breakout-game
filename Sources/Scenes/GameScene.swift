import SpriteKit
#if os(macOS)
import AppKit
#endif

final class GameScene: SKScene, SKPhysicsContactDelegate {
    let levelIndex: Int
    let level: Level
    var gameState: GameState
    // swiftlint:disable:next force_cast
    var gameCamera: GameCameraNode { camera as! GameCameraNode }
    var paddle: PaddleNode!
    var ballCoordinator: BallCoordinator!
    var bricks: [BrickNode] = []
    var permanentBricks: [BrickNode] = []
    var powerUp: PowerUpCoordinator!
    var gameLoop: GameLoopCoordinator!
    var contactCoordinator: ContactCoordinator!
    var bossCoordinator: BossCoordinator?
    let persistence = GamePersistenceCoordinator()
    let sound = SoundCoordinator()
    let savedBrickGrid: [[BrickCell]]?
    let inputCoordinator = InputCoordinator()
    #if os(macOS)
    let mouseTracker = MouseInputTracker()
    var mouseMovedMonitor: Any?
    #endif

    init(
        size: CGSize,
        levelIndex: Int,
        gameState: GameState,
        savedBrickGrid: [[BrickCell]]? = nil
    ) {
        precondition(Level.all.indices.contains(levelIndex), "levelIndex out of range")
        self.levelIndex = levelIndex
        self.level = Level.all[levelIndex]
        self.gameState = gameState
        self.savedBrickGrid = savedBrickGrid
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        if let result = bossCoordinator?.update(
            currentTime: currentTime, phase: gameState.phase, bricks: bricks
        ) { applyBossTickResult(result) }
        ballCoordinator.cullFallen(floorY: frame.minY)
        let tick = gameLoop.tick(
            currentTime: currentTime,
            phase: gameState.phase,
            floorY: frame.minY,
            balls: ballCoordinator.balls,
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2
        )
        applyPowerUpEffects(tick.powerUpEffects)
        if tick.expiredPowerUpType != nil {
            sound.playPowerUpExpire()
        }
        switch tick.action {
        case .handleBallLoss:    handleBallLoss()
        case .advanceLevel:      advanceLevel()
        case .nothing, .resetBall: break
        }
    }

    // MARK: - Physics contact

    func didBegin(_ contact: SKPhysicsContact) {
        apply(contactCoordinator.handle(
            contact, balls: ballCoordinator.balls, gamePhase: gameState.phase
        ))
    }

    private func apply(_ outcome: ContactOutcome) {
        if outcome.pointsScored > 0 {
            gameState = gameState.addScore(outcome.pointsScored)
            gameCamera.updateHUD(
                lives: gameState.lives, score: gameState.score,
                comboMultiplier: outcome.comboMultiplier
            )
        }
        if outcome.lifeAwarded {
            gameState = gameState.addLife()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
        }
        if let spawn = outcome.extraBallSpawn {
            ballCoordinator.spawnExtra(
                at: spawn.position, velocity: spawn.velocity, powerUp: powerUp
            )
        }
        applyPowerUpEffects(outcome.powerUpEffects)
    }

    // MARK: - Game lifecycle

    override func willMove(from view: SKView) {
        #if os(macOS)
        mouseTracker.uninstall(from: view)
        if let monitor = mouseMovedMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMovedMonitor = nil
        }
        #endif
        sound.stopEngine()
        persistence.sceneWillDisappear(
            isLevelComplete: gameLoop.levelComplete,
            phase: gameState.phase,
            snapshot: makeSnapshot
        )
    }
}

// MARK: - Lifecycle helpers

extension GameScene {
    func applyPauseState() {
        let isPaused = gameState.phase == .paused
        physicsWorld.speed = isPaused ? 0 : 1
        gameCamera.setPaused(isPaused)
        if isPaused {
            persistence.gamePaused(snapshot: makeSnapshot)
        } else {
            gameLoop.resetLastUpdateTime()
        }
    }

    func makeSnapshot() -> SavedGame {
        SavedGame(
            levelIndex: levelIndex,
            score: gameState.score,
            lives: gameState.lives,
            brickGrid: brickGrid(from: bricks + permanentBricks, level: level)
        )
    }

    func handleBallLoss() {
        contactCoordinator.resetCombo()
        applyPowerUpEffects(powerUp.clearAll())
        gameState = gameState.ballLost()
        let isGameOver = gameState.phase == .gameOver

        gameCamera.shake()
        gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
        SceneEffects.spawnBallLossFlash(
            sceneSize: size, center: CGPoint(x: frame.midX, y: frame.midY)
        ).forEach(addChild)

        if isGameOver {
            persistence.gameOver()
            present(GameSummaryScene(size: size, outcome: .gameOver, score: gameState.score))
        } else {
            sound.playBallLoss()
        }
    }

    func advanceLevel() {
        let nextIndex = levelIndex + 1
        if nextIndex < Level.all.count {
            sound.playLevelComplete()
            gameState = gameState.resetForNextLevel()
            present(GameScene(size: size, levelIndex: nextIndex, gameState: gameState))
        } else {
            persistence.levelVictory()
            present(GameSummaryScene(size: size, outcome: .victory, score: gameState.score))
        }
    }

    func fireLasersIfActive() {
        let halfWidth = paddle.size.width * paddle.xScale / 2
        powerUp.fireLasers(from: paddle.position, paddleHalfWidth: halfWidth)
            .forEach(addChild)
    }

    /// Applies effects to all current balls and to the paddle.
    func applyPowerUpEffects(_ effects: [PowerUpEffect]) {
        ballCoordinator.applyEffects(effects)
        for effect in effects {
            switch effect {
            case .activateWidePaddle:   paddle.activateWidePaddle()
            case .deactivateWidePaddle: paddle.deactivateWidePaddle()
            default: break
            }
        }
    }
}
