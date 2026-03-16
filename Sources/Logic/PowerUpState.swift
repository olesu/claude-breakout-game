import Foundation

struct PowerUpState {
    let active: PowerUpType?
    let timeRemaining: TimeInterval

    init() {
        active = nil
        timeRemaining = 0
    }

    private init(active: PowerUpType?, timeRemaining: TimeInterval) {
        self.active = active
        self.timeRemaining = timeRemaining
    }

    var isActive: Bool { active != nil }

    func collect(_ type: PowerUpType) -> PowerUpState {
        // Types with no duration are instant effects; handled by the coordinator directly.
        guard let duration = type.duration else { return self }
        return PowerUpState(active: type, timeRemaining: duration)
    }

    func tick(delta: TimeInterval) -> PowerUpState {
        guard isActive else { return self }
        let remaining = timeRemaining - delta
        guard remaining > 0 else { return PowerUpState() }
        return PowerUpState(active: active, timeRemaining: remaining)
    }

    func clear() -> PowerUpState {
        PowerUpState()
    }
}
