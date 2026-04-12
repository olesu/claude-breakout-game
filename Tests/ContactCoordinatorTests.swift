@testable import BreakoutGame
import SpriteKit
import Testing

@MainActor
@Suite("ContactCoordinator")
// swiftlint:disable:next type_body_length
struct ContactCoordinatorTests {

    // MARK: - Helpers

    private final class Collector {
        var bricks: [BrickNode] = []
        var added: [SKNode] = []
    }

    private func makeBrick(cell: BrickCell = .normal) -> BrickNode {
        BrickNode(size: CGSize(width: 40, height: 15), row: 0, col: 0, cell: cell)
    }

    private func makeCoordinator(collector: Collector) -> ContactCoordinator {
        let paddle = PaddleNode(sceneWidth: 400)
        let powerUp = PowerUpCoordinator(dropProbability: 0)
        let gameLoop = GameLoopCoordinator(powerUp: powerUp)
        return ContactCoordinator(
            powerUp: powerUp,
            paddle: paddle,
            gameLoop: gameLoop,
            addToScene: { nodes in collector.added.append(contentsOf: nodes) },
            removeBrick: { brick in collector.bricks.removeAll { $0 === brick } },
            remainingBrickCount: { collector.bricks.count }
        )
    }

    private func makeCoordinatorWithPowerBall(collector: Collector) -> ContactCoordinator {
        let paddle = PaddleNode(sceneWidth: 400)
        let powerUp = PowerUpCoordinator(dropProbability: 1.0)
        powerUp.collect(PowerUpNode(type: .powerBall))
        let gameLoop = GameLoopCoordinator(powerUp: powerUp)
        return ContactCoordinator(
            powerUp: powerUp,
            paddle: paddle,
            gameLoop: gameLoop,
            addToScene: { nodes in collector.added.append(contentsOf: nodes) },
            removeBrick: { brick in collector.bricks.removeAll { $0 === brick } },
            remainingBrickCount: { collector.bricks.count }
        )
    }

    // MARK: - handleBrick: intact

    @Test func handleBrick_intact_returnsNoScore() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let brick = makeBrick(cell: .multiHit(2))

        let outcome = coord.handleBrick(brick, contactPoint: .zero)

        #expect(outcome.pointsScored == 0)
        #expect(!outcome.lifeAwarded)
        #expect(outcome.extraBallSpawn == nil)
    }

    @Test func handleBrick_intact_doesNotRemoveBrick() {
        let col = Collector()
        let brick = makeBrick(cell: .multiHit(2))
        col.bricks = [brick]
        let coord = makeCoordinator(collector: col)

        _ = coord.handleBrick(brick, contactPoint: .zero)

        #expect(col.bricks.count == 1)
    }

    @Test func handleBrick_intact_addsSparksToScene() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        _ = coord.handleBrick(makeBrick(cell: .multiHit(2)), contactPoint: .zero)

        #expect(!col.added.isEmpty)
    }

    // MARK: - handleBrick: destroyed

    @Test func handleBrick_destroyed_returnsScore() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        let outcome = coord.handleBrick(makeBrick(), contactPoint: .zero)

        #expect(outcome.pointsScored == Theme.Layout.brickPoints)
    }

    @Test func handleBrick_destroyed_removesBrickFromArray() {
        let col = Collector()
        let brick = makeBrick()
        col.bricks = [brick]
        let coord = makeCoordinator(collector: col)

        _ = coord.handleBrick(brick, contactPoint: .zero)

        #expect(col.bricks.isEmpty)
    }

    @Test func handleBrick_destroyed_addsScorePopupToScene() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        _ = coord.handleBrick(makeBrick(), contactPoint: .zero)

        #expect(col.added.contains { $0 is ScorePopupNode })
    }

    @Test func handleBrick_destroyedWithPowerBallActive_doesNotSpawnPowerUp() {
        let col = Collector()
        let coord = makeCoordinatorWithPowerBall(collector: col)

        _ = coord.handleBrick(makeBrick(), contactPoint: .zero)

        #expect(!col.added.contains { $0 is PowerUpNode })
    }

    @Test func handleBrick_bonusBrick_alwaysSpawnsPowerUp() {
        let col = Collector()
        // powerBall active — normally suppresses drops, but bonus overrides
        let coord = makeCoordinatorWithPowerBall(collector: col)

        _ = coord.handleBrick(makeBrick(cell: .bonus), contactPoint: .zero)

        #expect(col.added.contains { $0 is PowerUpNode })
    }

    // MARK: - handlePowerUp

    @Test func handlePowerUp_extraLife_awardsLife() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        let outcome = coord.handlePowerUp(
            PowerUpNode(type: .extraLife), balls: [], gamePhase: .playing
        )

        #expect(outcome.lifeAwarded)
    }

    @Test func handlePowerUp_extraLife_addsEffectNodes() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        _ = coord.handlePowerUp(PowerUpNode(type: .extraLife), balls: [], gamePhase: .playing)

        #expect(!col.added.isEmpty)
    }

    @Test func handlePowerUp_multiBall_whilePlaying_returnsSpawn() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let ball = BallNode(radius: 8)
        ball.physicsBody?.velocity = CGVector(dx: 100, dy: 400)

        let outcome = coord.handlePowerUp(
            PowerUpNode(type: .multiBall), balls: [ball], gamePhase: .playing
        )

        #expect(outcome.extraBallSpawn != nil)
    }

    @Test func handlePowerUp_multiBall_whileWaitingToLaunch_noSpawn() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let ball = BallNode(radius: 8)
        ball.physicsBody?.velocity = CGVector(dx: 100, dy: 400)

        let outcome = coord.handlePowerUp(
            PowerUpNode(type: .multiBall), balls: [ball], gamePhase: .waitingToLaunch
        )

        #expect(outcome.extraBallSpawn == nil)
    }

    @Test func handlePowerUp_multiBall_noBalls_noSpawn() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        let outcome = coord.handlePowerUp(
            PowerUpNode(type: .multiBall), balls: [], gamePhase: .playing
        )

        #expect(outcome.extraBallSpawn == nil)
    }

    @Test func handlePowerUp_activated_returnsZeroPointsAndNoSpawn() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        let outcome = coord.handlePowerUp(
            PowerUpNode(type: .powerBall), balls: [], gamePhase: .playing
        )

        #expect(outcome.pointsScored == 0)
        #expect(!outcome.lifeAwarded)
        #expect(outcome.extraBallSpawn == nil)
    }

    @Test func handlePowerUp_activated_returnsPowerUpEffects() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        let outcome = coord.handlePowerUp(
            PowerUpNode(type: .powerBall), balls: [], gamePhase: .playing
        )

        #expect(outcome.powerUpEffects == [.activatePowerBall])
    }

    // MARK: - handleLaser

    @Test func handleLaser_withBrick_removesLaserFromParent() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let laser = LaserNode()
        let parent = SKNode()
        parent.addChild(laser)

        _ = coord.handleLaser(laser, brick: makeBrick(), contactPoint: .zero)

        #expect(laser.parent == nil)
    }

    @Test func handleLaser_withBrick_returnsScore() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)

        let outcome = coord.handleLaser(LaserNode(), brick: makeBrick(), contactPoint: .zero)

        #expect(outcome.pointsScored == Theme.Layout.brickPoints)
    }

    @Test func handleLaser_withoutBrick_removesLaserAndReturnsEmpty() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let laser = LaserNode()
        let parent = SKNode()
        parent.addChild(laser)

        let outcome = coord.handleLaser(laser, brick: nil, contactPoint: .zero)

        #expect(laser.parent == nil)
        #expect(outcome.pointsScored == 0)
    }

    // MARK: - reflectBallOffPaddle

    @Test func reflectBallOffPaddle_abovePaddle_changesVelocityUpward() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let ball = BallNode(radius: 8)
        let initial = CGVector(dx: 50, dy: -400)
        ball.physicsBody?.velocity = initial
        // contactPoint.y (10) >= paddle.position.y (0)
        coord.reflectBallOffPaddle(contactPoint: CGPoint(x: 0, y: 10), ball: ball)

        let velocity = ball.physicsBody?.velocity ?? initial
        #expect(velocity.dy > 0)
    }

    @Test func reflectBallOffPaddle_belowPaddle_leavesVelocityUnchanged() {
        let col = Collector()
        let coord = makeCoordinator(collector: col)
        let ball = BallNode(radius: 8)
        let initial = CGVector(dx: 50, dy: -400)
        ball.physicsBody?.velocity = initial
        // contactPoint.y (-5) < paddle.position.y (0) — physics glitch guard
        coord.reflectBallOffPaddle(contactPoint: CGPoint(x: 0, y: -5), ball: ball)

        let velocity = ball.physicsBody?.velocity ?? .zero
        #expect(abs(velocity.dx - initial.dx) < 0.001)
        #expect(abs(velocity.dy - initial.dy) < 0.001)
    }
}
