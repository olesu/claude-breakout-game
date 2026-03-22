@testable import BreakoutGame
import Foundation
import Testing

struct FrameDeltaTests {
    @Test func firstFrameYieldsZeroDelta() {
        #expect(frameDelta(last: 0, current: 1.0) == 0)
    }

    @Test func subsequentFrameYieldsDifference() {
        #expect(frameDelta(last: 1.0, current: 1.016) == 1.016 - 1.0)
    }

    @Test func zeroLastAndZeroCurrentYieldsZero() {
        #expect(frameDelta(last: 0, current: 0) == 0)
    }

    @Test func largeTimestampsComputeCorrectly() {
        let last: TimeInterval = 10_000.0
        let current: TimeInterval = 10_000.016
        #expect(frameDelta(last: last, current: current) == current - last)
    }
}
