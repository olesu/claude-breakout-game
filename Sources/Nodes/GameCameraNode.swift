import SpriteKit

final class GameCameraNode: SKCameraNode {
    private let restPosition: CGPoint

    init(position: CGPoint) {
        self.restPosition = position
        super.init()
        self.position = position
    }

    func shake(duration: TimeInterval = 0.4, magnitude: CGFloat = 12) {
        let count = 6
        let step = duration / Double(count)
        var actions: [SKAction] = []
        for i in 0..<count {
            let sign: CGFloat = i % 2 == 0 ? 1 : -1
            let decay = magnitude * (1 - CGFloat(i) / CGFloat(count))
            actions.append(.move(
                to: CGPoint(
                    x: restPosition.x + sign * decay,
                    y: restPosition.y + sign * decay * 0.5
                ),
                duration: step
            ))
        }
        actions.append(.move(to: restPosition, duration: step))
        run(.sequence(actions), withKey: "shake")
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
