import SpriteKit

/// Drives the march, reinforcement waves, and health tracking for boss levels (10, 20, …, 90).
/// `GameScene` creates one of these when `level.isBoss && level.metadata.bossPhases > 0`,
/// wires the three callbacks, then calls `update(currentTime:phase:)` each frame.
@MainActor
final class BossCoordinator {

    // MARK: - Constants

    private static let baseMarchSpeed: CGFloat = 4
    private static let marchSpeedIncrement: CGFloat = 1
    /// Bricks reaching within this many points of the paddle top trigger a life loss.
    static let paddleZoneOffset: CGFloat = 80

    // MARK: - Callbacks

    /// Called after the formation has been reset. GameScene should call `handleBallLoss()`.
    var onLifeLost: (() -> Void)?
    /// Called with freshly created wave bricks. GameScene must add them to the scene
    /// and its `bricks` array before this returns (actions start immediately after).
    var onWaveBricksSpawned: (([BrickNode]) -> Void)?
    /// Called after each brick destruction with the current health ratio (0 = dead, 1 = full).
    var onHealthChanged: ((Float) -> Void)?

    // MARK: - State

    private let bossPhases: Int
    private let layout: BrickLayout
    private let columns: Int
    private let sceneMaxY: CGFloat
    private let paddleZoneY: CGFloat
    private let getBricks: () -> [BrickNode]

    private var marchOffset: CGFloat = 0
    private var currentMarchSpeed: CGFloat
    private var originalBrickCount: Int
    private var totalBrickCount: Int
    private var destroyedCount: Int = 0
    private var wavesSpawned: Int = 0
    private var lastUpdateTime: TimeInterval = 0
    private var isResetting = false
    private var lastPhase: GamePhase = .waitingToLaunch
    /// World-space Y of each brick when marchOffset == 0.
    private var originalPositions: [ObjectIdentifier: CGFloat] = [:]
    /// Bricks currently in their drop-entry animation; excluded from march positioning.
    private var animatingBrickIDs: Set<ObjectIdentifier> = []

    // MARK: - Init

    init(
        initialBricks: [BrickNode],
        bossPhases: Int,
        layout: BrickLayout,
        columns: Int,
        sceneMaxY: CGFloat,
        paddleZoneY: CGFloat,
        getBricks: @escaping () -> [BrickNode]
    ) {
        self.bossPhases = bossPhases
        self.layout = layout
        self.columns = columns
        self.sceneMaxY = sceneMaxY
        self.paddleZoneY = paddleZoneY
        self.getBricks = getBricks
        self.currentMarchSpeed = Self.baseMarchSpeed
        self.originalBrickCount = initialBricks.count
        self.totalBrickCount = initialBricks.count
        for brick in initialBricks {
            originalPositions[ObjectIdentifier(brick)] = brick.position.y
        }
    }

    // MARK: - Per-frame update

    func update(currentTime: TimeInterval, phase: GamePhase) {
        // Clear the reset lock the moment the ball is re-launched.
        if phase == .playing && lastPhase != .playing { isResetting = false }
        lastPhase = phase

        let delta = nextDelta(currentTime: currentTime)
        guard phase == .playing, !isResetting else { return }

        marchOffset += currentMarchSpeed * delta
        var lowestWorldY: CGFloat = .greatestFiniteMagnitude

        for brick in getBricks() {
            let id = ObjectIdentifier(brick)
            guard let origY = originalPositions[id],
                  !animatingBrickIDs.contains(id) else { continue }
            let newY = origY - marchOffset
            brick.position.y = newY
            if newY < lowestWorldY { lowestWorldY = newY }
        }

        if lowestWorldY <= paddleZoneY { triggerLifeLoss() }
    }

    // MARK: - Brick events

    func brickDestroyed() {
        destroyedCount += 1
        emitHealthUpdate()
        checkWaveSpawn()
    }
}

// MARK: - Private helpers

private extension BossCoordinator {

    func nextDelta(currentTime: TimeInterval) -> CGFloat {
        defer { lastUpdateTime = currentTime }
        guard lastUpdateTime > 0 else { return 0 }
        return min(CGFloat(currentTime - lastUpdateTime), 0.1)
    }

    func emitHealthUpdate() {
        let remaining = max(0, totalBrickCount - destroyedCount)
        onHealthChanged?(Float(remaining) / Float(max(1, totalBrickCount)))
    }

    func checkWaveSpawn() {
        guard wavesSpawned < bossPhases else { return }
        let nextThreshold = Double(wavesSpawned + 1) / Double(bossPhases + 1)
        let progress = Double(destroyedCount) / Double(max(1, originalBrickCount))
        guard progress >= nextThreshold else { return }
        spawnWave()
    }

    func spawnWave() {
        wavesSpawned += 1
        currentMarchSpeed += Self.marchSpeedIncrement

        let waveNumber = wavesSpawned   // 1-indexed
        let h = layout.size.height
        let s = layout.spacing

        // World-space Y for this wave row when marchOffset == 0 (row -(waveNumber)).
        let waveOriginalY = layout.gridOrigin.y + CGFloat(waveNumber) * (h + s) - h / 2

        let cells = waveCells(for: waveNumber)
        var newBricks: [BrickNode] = []
        for col in 0..<columns where col < cells.count && cells[col] != .empty {
            let x = brickPosition(
                column: col, row: 0,
                size: layout.size, spacing: layout.spacing, gridOrigin: layout.gridOrigin
            ).x
            let brick = BrickNode(size: layout.size, row: 0, col: col, cell: cells[col])
            brick.position = CGPoint(x: x, y: sceneMaxY + h)   // start off-screen
            newBricks.append(brick)
        }

        totalBrickCount += newBricks.count
        emitHealthUpdate()

        // GameScene adds them to the scene; actions execute only once they are in the tree.
        onWaveBricksSpawned?(newBricks)

        let targetY = waveOriginalY - marchOffset
        for (i, brick) in newBricks.enumerated() {
            let id = ObjectIdentifier(brick)
            originalPositions[id] = waveOriginalY
            animatingBrickIDs.insert(id)
            brick.run(.sequence([
                .wait(forDuration: Double(i) * 0.04),
                .moveTo(y: targetY, duration: 0.35)
            ])) { [weak self] in
                self?.animatingBrickIDs.remove(id)
            }
        }
    }

    func waveCells(for waveNumber: Int) -> [BrickCell] {
        switch waveNumber {
        case 1:
            return Array(repeating: .multiHit(2), count: columns)
        case 2:
            return Array(repeating: .multiHit(3), count: columns)
        default:
            return (0..<columns).map { i in i.isMultiple(of: 2) ? .explosive : .multiHit(3) }
        }
    }

    func triggerLifeLoss() {
        guard !isResetting else { return }
        isResetting = true
        marchOffset = 0
        animatingBrickIDs.removeAll()

        for brick in getBricks() {
            brick.removeAllActions()
            guard let origY = originalPositions[ObjectIdentifier(brick)] else { continue }
            brick.run(.moveTo(y: origY, duration: 0.4))
        }
        onLifeLost?()
    }
}
