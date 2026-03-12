import CoreGraphics

func brickSize(sceneWidth: CGFloat, columns: Int, spacing: CGFloat, margin: CGFloat) -> CGSize {
    let totalWidth = sceneWidth - 2 * margin
    let brickWidth = (totalWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
    return CGSize(width: brickWidth, height: Theme.Layout.brickHeight)
}

func brickPosition(
    column: Int, row: Int, size: CGSize, spacing: CGFloat, gridOrigin: CGPoint
) -> CGPoint {
    let x = gridOrigin.x + CGFloat(column) * (size.width + spacing) + size.width / 2
    let y = gridOrigin.y - CGFloat(row) * (size.height + spacing) - size.height / 2
    return CGPoint(x: x, y: y)
}

func brickGridOrigin(sceneMinX: CGFloat, sceneMaxY: CGFloat, margin: CGFloat) -> CGPoint {
    CGPoint(x: sceneMinX + margin, y: sceneMaxY - Theme.Layout.brickTopMargin)
}
