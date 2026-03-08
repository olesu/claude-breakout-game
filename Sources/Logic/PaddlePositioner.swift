import CoreGraphics

func clampedPaddleX(touchX: CGFloat, sceneWidth: CGFloat, halfPaddleWidth: CGFloat) -> CGFloat {
    let minX = halfPaddleWidth
    let maxX = sceneWidth - halfPaddleWidth
    return min(max(touchX, minX), maxX)
}
