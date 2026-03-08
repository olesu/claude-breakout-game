import SpriteKit

final class PaddleNode: SKSpriteNode {
    init(sceneWidth: CGFloat) {
        let width = sceneWidth * 0.2
        let height: CGFloat = 14
        super.init(texture: nil, color: .white, size: CGSize(width: width, height: height))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
