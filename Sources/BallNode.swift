import SpriteKit

final class BallNode: SKShapeNode {
    init(radius: CGFloat) {
        super.init()
        let diameter = radius * 2
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: diameter, height: diameter), transform: nil)
        fillColor = Theme.Color.primary
        strokeColor = .clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
}
