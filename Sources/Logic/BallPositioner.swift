import CoreGraphics

func ballRestingPosition(
    paddlePosition: CGPoint,
    paddleHalfHeight: CGFloat,
    ballRadius: CGFloat
) -> CGPoint {
    CGPoint(x: paddlePosition.x, y: paddlePosition.y + paddleHalfHeight + ballRadius)
}
