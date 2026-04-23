import SpriteKit
#if os(macOS)
import AppKit
#endif

// MARK: - Input

extension GameScene {
    func handle(_ action: InputAction) {
        switch action {
        case .none:
            break
        case .pause:
            gameState = gameState.pause()
            applyPauseState()
        case .resume:
            gameState = gameState.resume()
            applyPauseState()
        case .toggleMute:
            sound.toggleMute()
            gameCamera.updateMuteButton(isMuted: sound.isMuted)
        case .movePaddle(let x):
            movePaddle(to: x)
        case .launchAndMovePaddle(let x):
            guard let primary = ballCoordinator.balls.first else { return }
            gameState = gameState.launch()
            gameCamera.updateHUD(lives: gameState.lives, score: gameState.score)
            movePaddle(to: x)
            SceneEffects.spawnLaunchRipple(at: primary.position).forEach(addChild)
            sound.playLaunch()
            primary.launch()
        }
    }

    func movePaddle(to x: CGFloat) {
        paddle.position.x = clampedPaddleX(
            touchX: x,
            sceneWidth: frame.width,
            halfPaddleWidth: paddle.size.width * paddle.xScale / 2  // xScale grows with wide paddle
        )
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 2 {
            switch gameState.phase {
            case .playing: handle(.pause)
            case .paused:  handle(.resume)
            default:       break
            }
            return
        }
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hitNodes = nodes(at: loc)
        let hitPause = hitNodes.contains { $0.name == "pauseButton" }
        let hitMute = hitNodes.contains { $0.name == "muteButton" }
        handle(inputCoordinator.action(
            at: loc,
            hittingPauseButton: hitPause,
            hittingMuteButton: hitMute,
            phase: gameState.phase
        ))
        if gameState.phase == .playing && !(hitPause || hitMute) { fireLasersIfActive() }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase != .paused else { return }
        guard let touch = touches.first else { return }
        movePaddle(to: touch.location(in: self).x)
    }
    #endif

    #if os(macOS)
    override func mouseMoved(with event: NSEvent) {
        guard gameState.phase != .paused else { return }
        movePaddle(to: event.location(in: self).x)
    }

    override func mouseDown(with event: NSEvent) {
        let loc = event.location(in: self)
        let hitNodes = nodes(at: loc)
        handle(inputCoordinator.action(
            at: loc,
            hittingPauseButton: hitNodes.contains { $0.name == "pauseButton" },
            hittingMuteButton: hitNodes.contains { $0.name == "muteButton" },
            phase: gameState.phase
        ))
    }

    override func keyDown(with event: NSEvent) {
        switch event.characters?.lowercased() {
        case "p":
            switch gameState.phase {
            case .playing: handle(.pause)
            case .paused:  handle(.resume)
            default:       break
            }
        case "m" where gameState.phase == .playing || gameState.phase == .waitingToLaunch:
            handle(.toggleMute)
        case " " where gameState.phase == .playing:
            fireLasersIfActive()
        #if DEBUG
        case "w" where gameState.phase == .playing || gameState.phase == .waitingToLaunch:
            bricks.forEach { $0.destroy(completion: {}) }  // completion unused: level marked below
            bricks.removeAll()
            gameLoop.markLevelComplete()
        #endif
        default: break
        }
    }
    #endif
}
