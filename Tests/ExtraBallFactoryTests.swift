@testable import BreakoutGame
import CoreGraphics
import Testing

private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
    abs(a - b) < tolerance
}

struct ExtraBallFactoryTests {
    private let origin = CGPoint(x: 100, y: 200)
    private let radius: CGFloat = 8
    private let primary = CGVector(dx: 0, dy: 500)

    @Test func returnsTwoSpecs() {
        let specs = makeExtraBalls(at: origin, primaryVelocity: primary, radius: radius)
        #expect(specs.count == 2)
    }

    @Test func bothBallsPositionedAtOrigin() {
        let specs = makeExtraBalls(at: origin, primaryVelocity: primary, radius: radius)
        for spec in specs {
            #expect(spec.ball.position == origin)
        }
    }

    @Test func bothVelocitiesPreservePrimarySpeed() {
        let primarySpeed = hypot(primary.dx, primary.dy)
        let specs = makeExtraBalls(at: origin, primaryVelocity: primary, radius: radius)
        for spec in specs {
            #expect(isClose(hypot(spec.velocity.dx, spec.velocity.dy), primarySpeed))
        }
    }

    @Test func velocitiesDivergeFromEachOther() {
        let specs = makeExtraBalls(at: origin, primaryVelocity: primary, radius: radius)
        let v1 = specs[0].velocity
        let v2 = specs[1].velocity
        #expect(!isClose(v1.dx, v2.dx))
    }

    @Test func velocitiesAreSymmetricAboutPrimary() {
        // For a straight-up primary, the two velocities should have equal dy and opposite dx.
        let specs = makeExtraBalls(at: origin, primaryVelocity: primary, radius: radius)
        let v1 = specs[0].velocity
        let v2 = specs[1].velocity
        #expect(isClose(v1.dy, v2.dy))
        #expect(isClose(v1.dx, -v2.dx))
    }

    @Test func zeroPrimaryVelocity_returnsTwoZeroVelocities() {
        let specs = makeExtraBalls(at: origin, primaryVelocity: .zero, radius: radius)
        for spec in specs {
            #expect(spec.velocity == .zero)
        }
    }
}
