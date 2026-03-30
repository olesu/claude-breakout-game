@testable import BreakoutGame
import Testing
import Foundation

struct BrickCellTests {

    // MARK: - initialState

    @Test func emptyInitialStateIsDestroyed() {
        #expect(BrickCell.empty.initialState == .destroyed)
    }

    @Test func normalInitialStateIsIntactOne() {
        #expect(BrickCell.normal.initialState == .intact(hitsRemaining: 1))
    }

    @Test func multiHitInitialStateMatchesCount() {
        #expect(BrickCell.multiHit(3).initialState == .intact(hitsRemaining: 3))
        #expect(BrickCell.multiHit(2).initialState == .intact(hitsRemaining: 2))
    }

    // MARK: - Equatable

    @Test func equalitySameCases() {
        #expect(BrickCell.normal == .normal)
        #expect(BrickCell.empty == .empty)
        #expect(BrickCell.multiHit(2) == .multiHit(2))
    }

    @Test func inequalityDifferentCases() {
        #expect(BrickCell.normal != .empty)
        #expect(BrickCell.multiHit(2) != .multiHit(3))
        #expect(BrickCell.normal != .multiHit(1))
    }

    @Test func indestructibleInitialStateIsIntactOne() {
        #expect(BrickCell.indestructible.initialState == .intact(hitsRemaining: 1))
    }

    // MARK: - Codable

    @Test func codableRoundTripEmpty() throws {
        let data = try JSONEncoder().encode(BrickCell.empty)
        #expect(try JSONDecoder().decode(BrickCell.self, from: data) == .empty)
    }

    @Test func codableRoundTripNormal() throws {
        let data = try JSONEncoder().encode(BrickCell.normal)
        #expect(try JSONDecoder().decode(BrickCell.self, from: data) == .normal)
    }

    @Test func codableRoundTripMultiHit() throws {
        let data = try JSONEncoder().encode(BrickCell.multiHit(3))
        #expect(try JSONDecoder().decode(BrickCell.self, from: data) == .multiHit(3))
    }

    @Test func codableRoundTripIndestructible() throws {
        let data = try JSONEncoder().encode(BrickCell.indestructible)
        #expect(try JSONDecoder().decode(BrickCell.self, from: data) == .indestructible)
    }

    // MARK: - Equatable (indestructible)

    @Test func equalityIndestructible() {
        #expect(BrickCell.indestructible == .indestructible)
        #expect(BrickCell.indestructible != .normal)
        #expect(BrickCell.indestructible != .empty)
    }
}
