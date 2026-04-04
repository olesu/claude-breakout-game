import Testing
import SpriteKit
@testable import BreakoutGame

@Suite("PaddleNode") struct PaddleNodeTests {
    @Test("init does not crash and physics body is set")
    func initDoesNotCrash() {
        let paddle = PaddleNode(sceneWidth: 390)
        #expect(paddle.physicsBody != nil)
    }

    @Test("wide paddle state toggle does not crash")
    func widePaddleToggle() {
        let paddle = PaddleNode(sceneWidth: 390)
        paddle.activateWidePaddle()
        paddle.deactivateWidePaddle()
    }

    @Test("init adds all seven overlay layers")
    func initAddsOverlayChildren() {
        let paddle = PaddleNode(sceneWidth: 390)
        // dropShadow + body + bottomEdgeShade + bloom + groove + specular + topShine
        #expect(paddle.children.count == 7)
    }
}
