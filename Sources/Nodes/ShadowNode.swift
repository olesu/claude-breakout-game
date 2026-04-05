import SpriteKit

enum ShadowNode {
    /// Flat tinted rectangle — attach to a `BrickNode` child.
    /// Bricks are static, so a plain shape avoids per-frame Core Image filter evaluation.
    static func makeBrickShadow(size: CGSize, color: PlatformColor) -> SKShapeNode {
        let node = SKShapeNode(rectOf: size)
        node.fillColor = color
        node.strokeColor = .clear
        node.alpha = Theme.Layout.brickShadowAlpha
        node.position = CGPoint(
            x: Theme.Layout.shadowOffset.dx,
            y: Theme.Layout.shadowOffset.dy
        )
        node.zPosition = -2
        node.isUserInteractionEnabled = false
        return node
    }

    /// Flat pill ellipse — attach as first child of `PaddleNode`.
    /// Inherits `xScale` from the paddle, so wide-paddle animation widens it automatically.
    static func makePaddleShadow(size: CGSize) -> SKShapeNode {
        let w = size.width
        let h = size.height
        let path = CGPath(
            roundedRect: CGRect(x: -w / 2, y: -h / 2, width: w, height: h),
            cornerWidth: h / 2,
            cornerHeight: h / 2,
            transform: nil
        )
        let node = SKShapeNode(path: path)
        node.fillColor = .black
        node.strokeColor = .clear
        node.alpha = Theme.Layout.shadowAlpha
        node.position = CGPoint(
            x: Theme.Layout.shadowOffset.dx,
            y: Theme.Layout.shadowOffset.dy
        )
        node.zPosition = -1
        node.isUserInteractionEnabled = false
        return node
    }

    /// Flat ellipse — attach to `BallNode`, replaces the blurred `SKEffectNode` shadow.
    static func makeBallShadow(radius: CGFloat) -> SKShapeNode {
        let node = SKShapeNode(
            path: CGPath(
                ellipseIn: CGRect(
                    x: -radius * 1.6,
                    y: -radius * 0.5,
                    width: radius * 3.2,
                    height: radius
                ),
                transform: nil
            )
        )
        node.fillColor = .black
        node.strokeColor = .clear
        node.alpha = Theme.Layout.shadowAlpha
        node.position = CGPoint(
            x: Theme.Layout.shadowOffset.dx,
            y: Theme.Layout.shadowOffset.dy
        )
        node.zPosition = -1
        node.isUserInteractionEnabled = false
        return node
    }
}
