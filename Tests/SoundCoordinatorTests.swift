@testable import BreakoutGame
import AVFoundation
import Foundation
import Testing

struct SoundCoordinatorTests {
    private func makeCoordinator() throws -> SoundCoordinator {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        return SoundCoordinator(defaults: defaults)
    }

    @Test func isMutedDefaultsToFalse() throws {
        #expect(try makeCoordinator().isMuted == false)
    }

    @Test func settingMutedPersistsKey() throws {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let coordinator = SoundCoordinator(defaults: defaults)
        coordinator.isMuted = true
        #expect(defaults.bool(forKey: "soundMuted") == true)
    }

    @Test func roundTripMutedState() throws {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let coordinator1 = SoundCoordinator(defaults: defaults)
        coordinator1.isMuted = true
        let coordinator2 = SoundCoordinator(defaults: defaults)
        #expect(coordinator2.isMuted == true)
    }

    @Test func settingMuted_setsIsMutedTrue() throws {
        let coordinator = try makeCoordinator()
        coordinator.isMuted = true
        #expect(coordinator.isMuted == true)
    }

    @Test func settingUnmuted_setsIsMutedFalse() throws {
        let coordinator = try makeCoordinator()
        coordinator.isMuted = true
        coordinator.isMuted = false
        #expect(coordinator.isMuted == false)
    }

    // MARK: - pitchForRow

    @Test func pitchForRow_topRow_returnsPositive600() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.pitchForRow(row: 0, totalRows: 5) == 600)
    }

    @Test func pitchForRow_bottomRow_returnsNegative600() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.pitchForRow(row: 4, totalRows: 5) == -600)
    }

    @Test func pitchForRow_middleRow_returnsZero() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.pitchForRow(row: 2, totalRows: 5) == 0)
    }

    @Test func pitchForRow_singleRow_returnsZero() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.pitchForRow(row: 0, totalRows: 1) == 0)
    }

    // MARK: - comboBoost

    @Test func comboBoost_counterEight_returns200Cents() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.comboBoost(counter: 8) == 200)
    }

    @Test func comboBoost_counterNine_sameAsEight() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.comboBoost(counter: 9) == coordinator.comboBoost(counter: 8))
    }

    @Test func comboBoost_counterZero_returnsZero() throws {
        let coordinator = try makeCoordinator()
        #expect(coordinator.comboBoost(counter: 0) == 0)
    }
}
