import AVFoundation

final class SoundCoordinator {
    private static let muteKey = "soundMuted"

    private let engine = AVAudioEngine()

    // Four independent brick-hit players, each with its own pitch unit so
    // simultaneous hits (laser, multiball) can carry different pitches.
    private let brickHitNodes: [AVAudioPlayerNode]
    private let brickPitchUnits: [AVAudioUnitTimePitch]
    private var brickPoolIndex = 0
    private var brickNodeBusy = [false, false, false, false]

    private let paddleNode = AVAudioPlayerNode()
    private let wallNode = AVAudioPlayerNode()
    private let launchNode = AVAudioPlayerNode()
    private let sfxNode = AVAudioPlayerNode()
    private let powerUpNode = AVAudioPlayerNode()

    // Audio-combo state for pitch boost (independent from scoring combo).
    private var audioComboCounter = 0
    private var audioLastHitTime: TimeInterval = 0

    private let defaults: UserDefaults

    // Cached buffers — nil if the asset is missing (graceful silent no-op).
    private var brickHitBuffer: AVAudioPCMBuffer?
    private var paddleHitBuffer: AVAudioPCMBuffer?
    private var wallHitBuffer: AVAudioPCMBuffer?
    private var launchBuffer: AVAudioPCMBuffer?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.brickHitNodes = (0..<4).map { _ in AVAudioPlayerNode() }
        self.brickPitchUnits = (0..<4).map { _ in AVAudioUnitTimePitch() }
        activateAudioSession()
        buildAudioGraph()
        do {
            try engine.start()
        } catch {
            print("SoundCoordinator: engine failed to start – \(error)")
        }
        engine.mainMixerNode.outputVolume = defaults.bool(forKey: Self.muteKey) ? 0 : 1
        loadBuffers()
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

    // MARK: - Playback

    /// Plays a brick-hit sound with pitch derived from row position,
    /// micro-variance, and a combo boost for rapid consecutive hits.
    func playBrickHit(row: Int, totalRows: Int) {
        guard let buffer = brickHitBuffer else { return }

        // Select a free player (round-robin); silent no-op if all are busy.
        let start = brickPoolIndex
        var chosen: Int?
        for offset in 0..<4 {
            let idx = (start + offset) % 4
            if !brickNodeBusy[idx] {
                chosen = idx
                break
            }
        }
        guard let idx = chosen else { return }
        brickPoolIndex = (idx + 1) % 4

        let now = Date().timeIntervalSinceReferenceDate
        updateAudioCombo(currentTime: now)

        let pitch = pitchForRow(row: row, totalRows: totalRows)
            + Float.random(in: -50...50)
            + comboBoost(counter: audioComboCounter)
        brickPitchUnits[idx].pitch = pitch

        brickNodeBusy[idx] = true
        brickHitNodes[idx].scheduleBuffer(
            buffer,
            completionCallbackType: .dataConsumed
        ) { [weak self] _ in
            self?.brickNodeBusy[idx] = false
        }
        brickHitNodes[idx].play()
    }

    /// Flat thwack — no pitch variation.
    func playPaddleHit() {
        play(buffer: paddleHitBuffer, on: paddleNode)
    }

    /// Light high tick.
    func playWallHit() {
        play(buffer: wallHitBuffer, on: wallNode)
    }

    /// Short ascending sweep played at ball launch.
    func playLaunch() {
        play(buffer: launchBuffer, on: launchNode)
    }

    // MARK: - Pitch formula (internal for testability)

    /// Row pitch: lerp from +600 cents (top row) to -600 cents (bottom row).
    func pitchForRow(row: Int, totalRows: Int) -> Float {
        guard totalRows > 1 else { return 0 }
        let t = Float(row) / Float(totalRows - 1)
        return 600 - 1200 * t
    }

    /// Combo pitch boost: each combo level adds 25 cents, capped at 8 levels (200 cents).
    func comboBoost(counter: Int) -> Float {
        Float(min(counter, 8)) * 25
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

        for idx in 0..<4 {
            engine.attach(brickHitNodes[idx])
            engine.attach(brickPitchUnits[idx])
            engine.connect(brickHitNodes[idx], to: brickPitchUnits[idx], format: nil)
            engine.connect(brickPitchUnits[idx], to: mixer, format: nil)
        }

        [paddleNode, wallNode, launchNode, sfxNode, powerUpNode].forEach {
            engine.attach($0)
            engine.connect($0, to: mixer, format: nil)
        }
    }

    private func loadBuffers() {
        brickHitBuffer = loadBuffer(named: "brick_hit")
        paddleHitBuffer = loadBuffer(named: "paddle_hit")
        wallHitBuffer = loadBuffer(named: "wall_hit")
        launchBuffer = loadBuffer(named: "ball_launch")
    }

    private func loadBuffer(named name: String) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "caf") else {
            print("SoundCoordinator: missing asset \(name).caf")
            return nil
        }
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        let frameCount = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: frameCount
        ) else { return nil }
        try? file.read(into: buffer)
        return buffer
    }

    private func play(buffer: AVAudioPCMBuffer?, on node: AVAudioPlayerNode) {
        guard let buffer else { return }
        node.scheduleBuffer(buffer, at: nil, options: .interrupts)
        node.play()
    }

    private func updateAudioCombo(currentTime: TimeInterval) {
        let hitWindow = 0.15
        let resetWindow = 0.4
        if currentTime - audioLastHitTime < hitWindow {
            audioComboCounter += 1
        } else if currentTime - audioLastHitTime > resetWindow {
            audioComboCounter = 0
        }
        audioLastHitTime = currentTime
    }
}
