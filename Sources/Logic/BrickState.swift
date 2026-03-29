enum BrickState: Equatable {
    case intact(hitsRemaining: Int)
    case destroyed
}

enum BrickEvent {
    case hit
}

func transition(_ state: BrickState, on event: BrickEvent) -> BrickState {
    switch (state, event) {
    case (.intact(let n), .hit) where n > 1:
        return .intact(hitsRemaining: n - 1)
    case (.intact, .hit):
        return .destroyed
    case (.destroyed, _):
        return .destroyed
    }
}

extension BrickState {
    var asCell: BrickCell {
        switch self {
        case .intact(let n) where n == 1: return .normal
        case .intact(let n): return .multiHit(n)
        case .destroyed: return .empty
        }
    }
}
