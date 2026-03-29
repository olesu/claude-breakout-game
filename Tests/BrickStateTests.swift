@testable import BreakoutGame
import Testing

struct BrickStateTests {

    // MARK: - transition

    @Test func hitOnSingleHitBrickDestroys() {
        #expect(transition(.intact(hitsRemaining: 1), on: .hit) == .destroyed)
    }

    @Test func hitOnMultiHitBrickDecrementsCount() {
        #expect(transition(.intact(hitsRemaining: 3), on: .hit) == .intact(hitsRemaining: 2))
        #expect(transition(.intact(hitsRemaining: 2), on: .hit) == .intact(hitsRemaining: 1))
    }

    @Test func hitOnLastMultiHitDestroys() {
        let afterTwo = transition(.intact(hitsRemaining: 2), on: .hit)
        #expect(transition(afterTwo, on: .hit) == .destroyed)
    }

    @Test func hitOnDestroyedIsTerminal() {
        #expect(transition(.destroyed, on: .hit) == .destroyed)
    }

    // MARK: - asCell

    @Test func destroyedAsCellIsEmpty() {
        #expect(BrickState.destroyed.asCell == .empty)
    }

    @Test func intactOneAsCellIsNormal() {
        #expect(BrickState.intact(hitsRemaining: 1).asCell == .normal)
    }

    @Test func intactMultipleAsCellIsMultiHit() {
        #expect(BrickState.intact(hitsRemaining: 3).asCell == .multiHit(3))
        #expect(BrickState.intact(hitsRemaining: 2).asCell == .multiHit(2))
    }
}
