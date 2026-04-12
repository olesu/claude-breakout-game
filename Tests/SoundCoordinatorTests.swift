@testable import BreakoutGame
import AVFoundation
import Foundation
import Testing

@MainActor
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

    // MARK: - updateAudioCombo

    @Test func updateAudioCombo_rapidHits_incrementsCounter() throws {
        let coordinator = try makeCoordinator()
        coordinator.updateAudioCombo(currentTime: 0.0)
        coordinator.updateAudioCombo(currentTime: 0.1)  // within 0.15 s window
        #expect(coordinator.audioComboCounter == 1)
    }

    @Test func updateAudioCombo_slowHit_resetsCounter() throws {
        let coordinator = try makeCoordinator()
        coordinator.updateAudioCombo(currentTime: 0.0)
        coordinator.updateAudioCombo(currentTime: 0.1)  // increment
        coordinator.updateAudioCombo(currentTime: 0.5)  // > 0.15 s → reset
        #expect(coordinator.audioComboCounter == 0)
    }

    @Test func updateAudioCombo_hitsAtWindowBoundary_resets() throws {
        let coordinator = try makeCoordinator()
        coordinator.updateAudioCombo(currentTime: 0.0)
        coordinator.updateAudioCombo(currentTime: 0.15) // exactly at limit → reset
        #expect(coordinator.audioComboCounter == 0)
    }

    @Test func updateAudioCombo_multipleRapidHits_accumulatesCounter() throws {
        let coordinator = try makeCoordinator()
        coordinator.updateAudioCombo(currentTime: 0.00)
        coordinator.updateAudioCombo(currentTime: 0.05)
        coordinator.updateAudioCombo(currentTime: 0.10)
        coordinator.updateAudioCombo(currentTime: 0.14)
        #expect(coordinator.audioComboCounter == 3)
    }
}
