import SpriteKit
#if os(macOS)
import AppKit
#endif

// MARK: - Setup

extension GameScene {
    override func didMove(to view: SKView) {
        setupCamera(in: view)
        configurePhysics()
        setupBackground()
        setupNodes()
        #if os(macOS)
        mouseTracker.install(on: view)
        (NSApp.delegate as? AppDelegate)?.hideCursor()
        mouseMovedMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
            (NSApp.delegate as? AppDelegate)?.hideCursor()
            return event
        }
        #endif
    }

    func setupCamera(in view: SKView) {
        let cam = GameCameraNode(
            sceneSize: size, levelName: level.name, topSafeArea: topSafeAreaInset(for: view)
        )
        addChild(cam)
        camera = cam
        cam.updateHUD(lives: gameState.lives, score: gameState.score)
        cam.updateMuteButton(isMuted: sound.isMuted)
    }

    func configurePhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    func setupBackground() {
        backgroundColor = .black
        let backdrop = BackdropNode(size: frame.size)
        backdrop.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(backdrop)
        makeWallNodes(for: frame).forEach { addChild($0) }
        let starfield = AmbientStarfieldNode(sceneSize: size)
        starfield.position = CGPoint(x: frame.midX, y: frame.maxY)
        addChild(starfield)
    }

    func setupNodes() {
        paddle = PaddleNode(sceneWidth: frame.width)
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + Theme.Layout.paddleOffsetY)
        addChild(paddle)

        let primaryBall = BallNode(radius: Theme.Layout.ballRadius)
        primaryBall.position = ballRestingPosition(
            paddlePosition: paddle.position,
            paddleHalfHeight: paddle.size.height / 2,
            ballRadius: Theme.Layout.ballRadius
        )
        addChild(primaryBall)
        primaryBall.attachTrail(to: self)

        ballCoordinator = BallCoordinator(
            addToScene: { [weak self] node in self?.addChild(node) },
            attachTrail: { [weak self] ball in
                guard let self else { return }
                ball.attachTrail(to: self)
            }
        )
        ballCoordinator.setup(primary: primaryBall)

        let allBricks = makeBrickNodes(for: level, sceneFrame: frame, savedGrid: savedBrickGrid)
        permanentBricks = allBricks.filter { $0.isIndestructible }
        bricks = allBricks.filter { !$0.isIndestructible }
        allBricks.forEach { addChild($0) }

        setupCoordinators()

        let bossPhases = level.metadata.bossPhases
        guard level.isBoss, bossPhases > 0 else { return }
        setupBossCoordinator(bossPhases: bossPhases)
    }

    private func setupCoordinators() {
        powerUp = PowerUpCoordinator()
        gameLoop = GameLoopCoordinator(powerUp: powerUp)
        contactCoordinator = ContactCoordinator(
            powerUp: powerUp,
            paddle: paddle,
            gameLoop: gameLoop,
            addToScene: { [weak self] nodes in nodes.forEach { self?.addChild($0) } },
            removeBrick: { [weak self] brick in
                self?.bricks.removeAll { $0 === brick }
                if let r = self?.bossCoordinator?.brickDestroyed() { self?.applyBossTickResult(r) }
            },
            remainingBrickCount: { [weak self] in self?.bricks.count ?? 0 }
        )
        contactCoordinator.sound = sound
        contactCoordinator.totalRows = level.grid.count
    }
}
