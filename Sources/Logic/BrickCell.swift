enum BrickCell: Equatable {
    case empty
    case normal
    case multiHit(Int)

    var initialState: BrickState {
        switch self {
        case .empty: return .destroyed
        case .normal: return .intact(hitsRemaining: 1)
        case .multiHit(let n):
            precondition(n >= 2, "multiHit requires at least 2 hits")
            return .intact(hitsRemaining: n)
        }
    }
}

extension BrickCell: Codable {
    private enum CodingKeys: String, CodingKey { case type, hits }
    private enum TypeKey: String, Codable { case empty, normal, multiHit }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .empty:
            try container.encode(TypeKey.empty, forKey: .type)
        case .normal:
            try container.encode(TypeKey.normal, forKey: .type)
        case .multiHit(let n):
            try container.encode(TypeKey.multiHit, forKey: .type)
            try container.encode(n, forKey: .hits)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(TypeKey.self, forKey: .type) {
        case .empty: self = .empty
        case .normal: self = .normal
        case .multiHit:
            self = .multiHit(try container.decode(Int.self, forKey: .hits))
        }
    }
}
