import SpriteKit

/// Describes what happened during a single boss coordinator tick or brick destruction event.
struct BossTickResult {
    /// The formation reached the paddle zone; the player should lose a life.
    var lifeLost: Bool = false
    /// Freshly created wave bricks that must be added to the scene and the bricks array.
    var waveBricks: [BrickNode] = []
    /// Updated health ratio (0 = all gone, 1 = full); present whenever the count changed.
    var healthRatio: Float?
}

/// Drives the march, reinforcement waves, and health tracking for boss levels (10, 20, …, 90).
/// `GameScene` creates one of these when `level.isBoss && level.metadata.bossPhases > 0`,
/// then calls `update(currentTime:phase:bricks:)` each frame and acts on the returned result.
@MainActor
final class BossCoordinator {

    // MARK: - Constants

    private static let baseMarchSpeed: CGFloat = 4
    private static let marchSpeedIncrement: CGFloat = 1
    /// Bricks reaching within this many points of the paddle top trigger a life loss.
    static let paddleZoneOffset: CGFloat = 80

    // MARK: - State

    private let bossPhases: Int
    private let layout: BrickLayout
    private let columns: Int
    private let sceneMaxY: CGFloat
    private let paddleZoneY: CGFloat

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
        paddleZoneY: CGFloat
    ) {
        self.bossPhases = bossPhases
        self.layout = layout
        self.columns = columns
        self.sceneMaxY = sceneMaxY
        self.paddleZoneY = paddleZoneY
        self.currentMarchSpeed = Self.baseMarchSpeed
        self.originalBrickCount = initialBricks.count
        self.totalBrickCount = initialBricks.count
        for brick in initialBricks {
            originalPositions[ObjectIdentifier(brick)] = brick.position.y
        }
    }

    // MARK: - Per-frame update

    func update(
        currentTime: TimeInterval,
        phase: GamePhase,
        bricks: [BrickNode]
    ) -> BossTickResult {
        var result = BossTickResult()

        // Clear the reset lock the moment the ball is re-launched.
        if phase == .playing && lastPhase != .playing { isResetting = false }
        lastPhase = phase

        let delta = nextDelta(currentTime: currentTime)
        guard phase == .playing, !isResetting else { return result }

        marchOffset += currentMarchSpeed * delta
        var lowestWorldY: CGFloat = .greatestFiniteMagnitude

        for brick in bricks {
            let id = ObjectIdentifier(brick)
            guard let origY = originalPositions[id],
                  !animatingBrickIDs.contains(id) else { continue }
            let newY = origY - marchOffset
            brick.position.y = newY
            if newY < lowestWorldY { lowestWorldY = newY }
        }

        if lowestWorldY <= paddleZoneY { triggerLifeLoss(bricks: bricks, result: &result) }
        return result
    }

    // MARK: - Brick events

    func brickDestroyed() -> BossTickResult {
        destroyedCount += 1
        var result = BossTickResult()
        result.healthRatio = currentHealthRatio()
        checkWaveSpawn(result: &result)
        return result
    }
}

// MARK: - Private helpers

private extension BossCoordinator {

    func nextDelta(currentTime: TimeInterval) -> CGFloat {
        defer { lastUpdateTime = currentTime }
        guard lastUpdateTime > 0 else { return 0 }
        return min(CGFloat(currentTime - lastUpdateTime), 0.1)
    }

    func currentHealthRatio() -> Float {
        let remaining = max(0, totalBrickCount - destroyedCount)
        return Float(remaining) / Float(max(1, totalBrickCount))
    }

    func checkWaveSpawn(result: inout BossTickResult) {
        guard wavesSpawned < bossPhases else { return }
        let nextThreshold = Double(wavesSpawned + 1) / Double(bossPhases + 1)
        let progress = Double(destroyedCount) / Double(max(1, originalBrickCount))
        guard progress >= nextThreshold else { return }
        spawnWave(result: &result)
    }

    func spawnWave(result: inout BossTickResult) {
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
        result.waveBricks = newBricks
        result.healthRatio = currentHealthRatio()

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

    func triggerLifeLoss(bricks: [BrickNode], result: inout BossTickResult) {
        isResetting = true
        marchOffset = 0
        animatingBrickIDs.removeAll()

        for brick in bricks {
            brick.removeAllActions()
            guard let origY = originalPositions[ObjectIdentifier(brick)] else { continue }
            brick.run(.moveTo(y: origY, duration: 0.4))
        }
        result.lifeLost = true
    }
}

// MARK: - Factory

/// Builds a `BossCoordinator` from scene geometry, computing the brick layout internally.
@MainActor
func makeBossCoordinator(
    phases: Int, cols: Int, frame: CGRect, bricks: [BrickNode]
) -> BossCoordinator {
    let spacing = Theme.Layout.brickSpacing
    let margin = Theme.Layout.brickSideMargin
    let layout = BrickLayout(
        size: brickSize(sceneWidth: frame.width, columns: cols, spacing: spacing, margin: margin),
        spacing: spacing,
        gridOrigin: brickGridOrigin(sceneMinX: frame.minX, sceneMaxY: frame.maxY, margin: margin)
    )
    let paddleZoneY = frame.minY
        + Theme.Layout.paddleOffsetY
        + Theme.Layout.paddleHeight / 2
        + BossCoordinator.paddleZoneOffset
    return BossCoordinator(
        initialBricks: bricks, bossPhases: phases,
        layout: layout, columns: cols, sceneMaxY: frame.maxY, paddleZoneY: paddleZoneY
    )
}
