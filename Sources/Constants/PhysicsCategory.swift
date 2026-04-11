enum PhysicsCategory {
    static let ball: UInt32 = 0x1 << 0
    static let wall: UInt32 = 0x1 << 1
    static let paddle: UInt32 = 0x1 << 2
    static let brick: UInt32 = 0x1 << 3
    static let powerUp: UInt32 = 0x1 << 4
    static let laser: UInt32 = 0x1 << 5
    static let indestructibleBrick: UInt32 = 0x1 << 6
}
