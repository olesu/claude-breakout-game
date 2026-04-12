import AVFoundation

final class SoundCoordinator {
    private static let muteKey = "soundMuted"

    private let engine = AVAudioEngine()
    private let brickHitNodes: [AVAudioPlayerNode]
    private let timePitchUnit = AVAudioUnitTimePitch()
    private let paddleNode = AVAudioPlayerNode()
    private let wallNode = AVAudioPlayerNode()
    private let launchNode = AVAudioPlayerNode()
    private let sfxNode = AVAudioPlayerNode()
    private let powerUpNode = AVAudioPlayerNode()
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.brickHitNodes = (0..<4).map { _ in AVAudioPlayerNode() }
        activateAudioSession()
        buildAudioGraph()
        do {
            try engine.start()
        } catch {
            print("SoundCoordinator: engine failed to start – \(error)")
        }
        engine.mainMixerNode.outputVolume = defaults.bool(forKey: Self.muteKey) ? 0 : 1
    }

    var isMuted: Bool {
        get { defaults.bool(forKey: Self.muteKey) }
        set {
            defaults.set(newValue, forKey: Self.muteKey)
            engine.mainMixerNode.outputVolume = newValue ? 0 : 1
        }
    }

    func stopEngine() {
        engine.stop()
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif
    }

    // MARK: - Private

    private func activateAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient)
        try? session.setActive(true)
        #endif
    }

    private func buildAudioGraph() {
        let mixer = engine.mainMixerNode
        brickHitNodes.forEach { engine.attach($0) }
        engine.attach(timePitchUnit)
        [paddleNode, wallNode, launchNode, sfxNode, powerUpNode].forEach { engine.attach($0) }

        // Pitch variation applied to brick hits only; other events connect directly.
        brickHitNodes.forEach { engine.connect($0, to: timePitchUnit, format: nil) }
        engine.connect(timePitchUnit, to: mixer, format: nil)

        [paddleNode, wallNode, launchNode, sfxNode, powerUpNode].forEach {
            engine.connect($0, to: mixer, format: nil)
        }
    }
}
