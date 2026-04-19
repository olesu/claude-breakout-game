import SpriteKit
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Segmented horizontal health bar shown in the HUD on boss levels.
/// Color transitions red → orange → yellow as health decreases.
final class BossHealthBarNode: SKNode {
    private static let segmentCount = 10
    private static let segmentWidth: CGFloat = 18
    private static let segmentGap: CGFloat = 3

    private let segments: [SKShapeNode]

    override init() {
        let count = CGFloat(BossHealthBarNode.segmentCount)
        let sw = BossHealthBarNode.segmentWidth
        let sg = BossHealthBarNode.segmentGap
        let totalWidth = count * sw + (count - 1) * sg
        var segs: [SKShapeNode] = []
        for i in 0..<BossHealthBarNode.segmentCount {
            let seg = SKShapeNode(rectOf: CGSize(width: sw, height: 8), cornerRadius: 2)
            seg.position = CGPoint(x: CGFloat(i) * (sw + sg) - totalWidth / 2 + sw / 2, y: 0)
            seg.strokeColor = .clear
            segs.append(seg)
        }
        segments = segs
        super.init()
        segs.forEach { addChild($0) }
    }

    func update(health: Float) {
        let active = Int((health * Float(BossHealthBarNode.segmentCount)).rounded(.up))
        let color = barColor(for: health)
        for (i, seg) in segments.enumerated() {
            seg.isHidden = i >= active
            seg.fillColor = color
        }
    }

    private func barColor(for health: Float) -> PlatformColor {
        if health > 0.6 {
            return PlatformColor(red: 1, green: 0.15, blue: 0.1, alpha: 1)
        } else if health > 0.3 {
            return PlatformColor(red: 1, green: 0.5, blue: 0.05, alpha: 1)
        } else {
            return PlatformColor(red: 1, green: 0.85, blue: 0.05, alpha: 1)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
