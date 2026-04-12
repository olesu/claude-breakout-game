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
}
