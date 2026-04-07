@testable import BreakoutGame
import SpriteKit
import Testing

@Suite("ContactClassifier")
struct ContactClassifierTests {

    // MARK: - Helpers

    private func makeBrick() -> BrickNode {
        BrickNode(size: CGSize(width: 40, height: 15), row: 0, col: 0, cell: .normal)
    }

    private func makeWall() -> WallNode {
        WallNode(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 100, y: 0))
    }

    // MARK: - .brick

    @Test func brick_nodeA_returnsBrickEvent() {
        let brick = makeBrick()
        let result = classifyContact(nodeA: brick, nodeB: nil, contactPoint: .zero)
        guard case .brick(let b, _) = result else {
            Issue.record("Expected .brick, got \(result)")
            return
        }
        #expect(b === brick)
    }

    @Test func brick_nodeB_returnsBrickEvent() {
        let brick = makeBrick()
        let result = classifyContact(nodeA: nil, nodeB: brick, contactPoint: .zero)
        guard case .brick(let b, _) = result else {
            Issue.record("Expected .brick, got \(result)")
            return
        }
        #expect(b === brick)
    }

    @Test func brick_forwardsContactPoint() {
        let point = CGPoint(x: 12, y: 34)
        let result = classifyContact(nodeA: makeBrick(), nodeB: nil, contactPoint: point)
        guard case .brick(_, let cp) = result else {
            Issue.record("Expected .brick, got \(result)")
            return
        }
        #expect(cp == point)
    }

    @Test func brick_withoutPhysicsBody_returnsUnknown() {
        let brick = BrickNode(size: CGSize(width: 40, height: 15), row: 0, col: 0, cell: .normal)
        brick.physicsBody = nil
        let result = classifyContact(nodeA: brick, nodeB: nil, contactPoint: .zero)
        guard case .unknown = result else {
            Issue.record("Expected .unknown when brick has no physicsBody, got \(result)")
            return
        }
    }

    // MARK: - .powerUp

    @Test func powerUp_returnsCorrectNode() {
        let node = PowerUpNode(type: .extraLife)
        let result = classifyContact(nodeA: node, nodeB: nil, contactPoint: .zero)
        guard case .powerUp(let p) = result else {
            Issue.record("Expected .powerUp, got \(result)")
            return
        }
        #expect(p === node)
    }

    @Test func powerUp_nodeB_returnsCorrectNode() {
        let node = PowerUpNode(type: .multiBall)
        let result = classifyContact(nodeA: nil, nodeB: node, contactPoint: .zero)
        guard case .powerUp(let p) = result else {
            Issue.record("Expected .powerUp, got \(result)")
            return
        }
        #expect(p === node)
    }

    // MARK: - .paddleHit

    @Test func paddleHit_withBall_includesBall() {
        let paddle = PaddleNode(sceneWidth: 400)
        let ball = BallNode(radius: 8)
        let result = classifyContact(nodeA: paddle, nodeB: ball, contactPoint: .zero)
        guard case .paddleHit(let b, _) = result else {
            Issue.record("Expected .paddleHit, got \(result)")
            return
        }
        #expect(b === ball)
    }

    @Test func paddleHit_withoutBall_returnsNilBall() {
        let paddle = PaddleNode(sceneWidth: 400)
        let result = classifyContact(nodeA: paddle, nodeB: nil, contactPoint: .zero)
        guard case .paddleHit(let b, _) = result else {
            Issue.record("Expected .paddleHit, got \(result)")
            return
        }
        #expect(b == nil)
    }

    @Test func paddleHit_forwardsContactPoint() {
        let point = CGPoint(x: 5, y: 10)
        let paddle = PaddleNode(sceneWidth: 400)
        let result = classifyContact(nodeA: paddle, nodeB: nil, contactPoint: point)
        guard case .paddleHit(_, let cp) = result else {
            Issue.record("Expected .paddleHit, got \(result)")
            return
        }
        #expect(cp == point)
    }

    // MARK: - .wallHit

    @Test func wallHit_returnsCorrectWall() {
        let wall = makeWall()
        let result = classifyContact(nodeA: wall, nodeB: nil, contactPoint: .zero)
        guard case .wallHit(let w) = result else {
            Issue.record("Expected .wallHit, got \(result)")
            return
        }
        #expect(w === wall)
    }

    @Test func wallHit_nodeB_returnsCorrectWall() {
        let wall = makeWall()
        let result = classifyContact(nodeA: nil, nodeB: wall, contactPoint: .zero)
        guard case .wallHit(let w) = result else {
            Issue.record("Expected .wallHit, got \(result)")
            return
        }
        #expect(w === wall)
    }

    // MARK: - .laser

    @Test func laser_withBrick_returnsBothNodes() {
        let laser = LaserNode()
        let brick = makeBrick()
        let result = classifyContact(nodeA: laser, nodeB: brick, contactPoint: .zero)
        guard case .laser(let l, let b, _) = result else {
            Issue.record("Expected .laser, got \(result)")
            return
        }
        #expect(l === laser)
        #expect(b === brick)
    }

    @Test func laser_withoutBrick_returnsNilBrick() {
        let laser = LaserNode()
        let result = classifyContact(nodeA: laser, nodeB: nil, contactPoint: .zero)
        guard case .laser(let l, let b, _) = result else {
            Issue.record("Expected .laser, got \(result)")
            return
        }
        #expect(l === laser)
        #expect(b == nil)
    }

    @Test func laser_takesOverBrick_returnedAsLaserNotBrick() {
        // Laser + Brick should produce .laser, not .brick — laser is checked first
        let laser = LaserNode()
        let brick = makeBrick()
        let result = classifyContact(nodeA: brick, nodeB: laser, contactPoint: .zero)
        guard case .laser = result else {
            Issue.record("Expected .laser (not .brick), got \(result)")
            return
        }
    }

    @Test func laser_forwardsContactPoint() {
        let point = CGPoint(x: 7, y: 8)
        let result = classifyContact(nodeA: LaserNode(), nodeB: nil, contactPoint: point)
        guard case .laser(_, _, let cp) = result else {
            Issue.record("Expected .laser, got \(result)")
            return
        }
        #expect(cp == point)
    }

    // MARK: - .unknown

    @Test func unknown_unrecognisedPair_returnsUnknown() {
        let result = classifyContact(nodeA: SKNode(), nodeB: SKNode(), contactPoint: .zero)
        guard case .unknown = result else {
            Issue.record("Expected .unknown, got \(result)")
            return
        }
    }

    @Test func unknown_bothNil_returnsUnknown() {
        let result = classifyContact(nodeA: nil, nodeB: nil, contactPoint: .zero)
        guard case .unknown = result else {
            Issue.record("Expected .unknown, got \(result)")
            return
        }
    }
}
