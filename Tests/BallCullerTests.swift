@testable import BreakoutGame
import SpriteKit
import Testing

struct BallCullerTests {
    private let floorY: CGFloat = 0

    private func ball(y: CGFloat) -> BallNode {
        let b = BallNode(radius: 8)
        b.position = CGPoint(x: 0, y: y)
        return b
    }

    @Test func emptyArray_returnsEmpty() {
        #expect(fallenExtraBallIndices(balls: [], floorY: floorY).isEmpty)
    }

    @Test func onlyPrimaryBall_belowFloor_notIncluded() {
        // Index 0 (primary) is never culled, even when below the floor.
        let balls = [ball(y: -10)]
        #expect(fallenExtraBallIndices(balls: balls, floorY: floorY).isEmpty)
    }

    @Test func extraBallAboveFloor_notIncluded() {
        let balls = [ball(y: 100), ball(y: 50)]
        #expect(fallenExtraBallIndices(balls: balls, floorY: floorY).isEmpty)
    }

    @Test func extraBallBelowFloor_indexIncluded() {
        let balls = [ball(y: 100), ball(y: -10)]
        #expect(fallenExtraBallIndices(balls: balls, floorY: floorY) == [1])
    }

    @Test func extraBallExactlyAtFloor_notIncluded() {
        let balls = [ball(y: 100), ball(y: 0)]
        #expect(fallenExtraBallIndices(balls: balls, floorY: floorY).isEmpty)
    }

    @Test func multipleExtraBallsBelowFloor_allIncluded() {
        let balls = [ball(y: 100), ball(y: -5), ball(y: -10)]
        let result = fallenExtraBallIndices(balls: balls, floorY: floorY)
        #expect(result.sorted() == [1, 2])
    }

    @Test func indicesReturnedDescending() {
        // Descending order lets callers remove by index without shifting.
        let balls = [ball(y: 100), ball(y: -5), ball(y: -10), ball(y: -1)]
        let result = fallenExtraBallIndices(balls: balls, floorY: floorY)
        #expect(result == result.sorted(by: >))
    }

    @Test func mixedBalls_onlyFallenExtraIncluded() {
        // Index 0: primary, above — skip (primary rule)
        // Index 1: extra, above — skip
        // Index 2: extra, below — include
        // Index 3: extra, above — skip
        // Index 4: extra, below — include
        let balls = [ball(y: 100), ball(y: 50), ball(y: -5), ball(y: 30), ball(y: -1)]
        let result = fallenExtraBallIndices(balls: balls, floorY: floorY)
        #expect(result == [4, 2])
    }
}
