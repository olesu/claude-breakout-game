@testable import BreakoutGame
import Testing

struct PowerUpStateTests {

    // MARK: - Init

    @Test func init_activeIsNil() {
        #expect(PowerUpState().active == nil)
    }

    @Test func init_timeRemainingIsZero() {
        #expect(PowerUpState().timeRemaining == 0)
    }

    @Test func init_isActiveIsFalse() {
        #expect(PowerUpState().isActive == false)
    }

    // MARK: - collect

    @Test func collect_setsActiveType() {
        #expect(PowerUpState().collect(.powerBall).active == .powerBall)
    }

    @Test func collect_setsTimeRemainingFromTypeDuration() {
        let state = PowerUpState().collect(.powerBall)
        #expect(state.timeRemaining == Theme.Layout.powerUpDuration)
    }

    @Test func collect_isActiveBecomesTrue() {
        #expect(PowerUpState().collect(.powerBall).isActive == true)
    }

    // Cross-type replacement will need separate coverage once a second PowerUpType case exists.
    @Test func collect_whenAlreadyActive_resetsState() {
        let state = PowerUpState().collect(.powerBall).collect(.powerBall)
        #expect(state.active == .powerBall)
    }

    @Test func collect_whenAlreadyActive_resetsTimeRemaining() {
        let state = PowerUpState().collect(.powerBall).tick(delta: 3).collect(.powerBall)
        #expect(state.timeRemaining == Theme.Layout.powerUpDuration)
    }

    // MARK: - tick

    @Test func tick_whenInactive_isNoOp() {
        let state = PowerUpState().tick(delta: 1)
        #expect(state.active == nil)
        #expect(state.timeRemaining == 0)
    }

    @Test func tick_decrementsTimeRemaining() {
        let state = PowerUpState().collect(.powerBall).tick(delta: 2)
        #expect(state.timeRemaining == Theme.Layout.powerUpDuration - 2)
    }

    @Test func tick_preservesActiveWhenTimeRemains() {
        let state = PowerUpState().collect(.powerBall).tick(delta: 1)
        #expect(state.active == .powerBall)
    }

    @Test func tick_exactlyExpired_clearsActive() {
        let state = PowerUpState().collect(.powerBall).tick(delta: Theme.Layout.powerUpDuration)
        #expect(state.active == nil)
    }

    @Test func tick_pastExpiry_clearsActive() {
        let state = PowerUpState().collect(.powerBall).tick(delta: Theme.Layout.powerUpDuration + 1)
        #expect(state.active == nil)
    }

    @Test func tick_pastExpiry_timeRemainingIsZero() {
        let state = PowerUpState().collect(.powerBall).tick(delta: Theme.Layout.powerUpDuration + 1)
        #expect(state.timeRemaining == 0)
    }

    // MARK: - clear

    @Test func clear_whenActive_clearsActiveType() {
        let state = PowerUpState().collect(.powerBall).clear()
        #expect(state.active == nil)
    }

    @Test func clear_whenActive_resetsTimeRemaining() {
        let state = PowerUpState().collect(.powerBall).clear()
        #expect(state.timeRemaining == 0)
    }

    @Test func clear_whenInactive_isNoOp() {
        let state = PowerUpState().clear()
        #expect(state.active == nil)
        #expect(state.timeRemaining == 0)
    }

    // MARK: - Value semantics

    @Test func collect_originalUnchanged() {
        let original = PowerUpState()
        let collected = original.collect(.powerBall)
        #expect(original.active == nil)
        #expect(collected.active == .powerBall)
    }

    @Test func tick_originalUnchanged() {
        let collected = PowerUpState().collect(.powerBall)
        let ticked = collected.tick(delta: 1)
        #expect(collected.timeRemaining == Theme.Layout.powerUpDuration)
        #expect(ticked.timeRemaining == Theme.Layout.powerUpDuration - 1)
    }
}
