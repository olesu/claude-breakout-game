import SpriteKit

/// Returns the top safe-area inset to use when laying out scene content.
func topSafeAreaInset(for view: SKView) -> CGFloat {
    #if os(iOS)
    view.safeAreaInsets.top
    #else
    28  // clears the auto-hiding macOS menu bar in fullscreen
    #endif
}
