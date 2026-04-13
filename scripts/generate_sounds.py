#!/usr/bin/env python3
"""Generate synthetic .caf sound assets for BreakoutGame.

Writes 16-bit PCM 44100 Hz mono .caf files to Sources/Sounds/:
  brick_hit.caf           — short transient click
  paddle_hit.caf          — slightly heavier thwack
  wall_hit.caf            — light high tick
  ball_launch.caf         — short ascending sweep
  ball_loss.caf           — short descending tone
  game_over.caf           — dramatic descending arpeggio
  level_complete.caf      — ascending bright chime
  powerup_collect.caf     — quick collect chime
  powerup_activate.caf    — neutral activation sting (base pitch)
  powerup_laser_charge.caf — electronic charge-up
  powerup_expire.caf      — short drooping tone

Run from the repo root:
    python3 scripts/generate_sounds.py

Requires only the Python standard library (no numpy/scipy).
Uses afconvert (macOS) to write the final .caf container.
"""

import math
import os
import struct
import subprocess
import tempfile

SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "Sources", "Sounds")


def sine(freq: float, t: float) -> float:
    return math.sin(2 * math.pi * freq * t)


def write_wav(path: str, samples: list[float]) -> None:
    """Write a 16-bit signed PCM WAV file (mono, 44100 Hz)."""
    n = len(samples)
    data_bytes = n * 2  # 2 bytes per sample
    with open(path, "wb") as f:
        # RIFF header
        f.write(b"RIFF")
        f.write(struct.pack("<I", 36 + data_bytes))
        f.write(b"WAVE")
        # fmt chunk
        f.write(b"fmt ")
        f.write(struct.pack("<I", 16))        # chunk size
        f.write(struct.pack("<H", 1))         # PCM
        f.write(struct.pack("<H", 1))         # mono
        f.write(struct.pack("<I", SAMPLE_RATE))
        f.write(struct.pack("<I", SAMPLE_RATE * 2))  # byte rate
        f.write(struct.pack("<H", 2))         # block align
        f.write(struct.pack("<H", 16))        # bits per sample
        # data chunk
        f.write(b"data")
        f.write(struct.pack("<I", data_bytes))
        for s in samples:
            clamped = max(-1.0, min(1.0, s))
            f.write(struct.pack("<h", int(clamped * 32767)))


def wav_to_caf(wav_path: str, caf_path: str) -> None:
    """Convert WAV to .caf via afconvert."""
    subprocess.run(
        [
            "afconvert",
            "-f", "caff",
            "-d", "LEI16",
            wav_path,
            caf_path,
        ],
        check=True,
    )


def envelope(t: float, attack: float, decay: float, sustain: float,
             release: float, duration: float) -> float:
    """Simple ADSR envelope."""
    if t < attack:
        return t / attack
    t -= attack
    if t < decay:
        return 1.0 - (1.0 - sustain) * (t / decay)
    t -= decay
    sustain_len = duration - attack - decay - release
    if t < sustain_len:
        return sustain
    t -= sustain_len
    if t < release:
        return sustain * (1.0 - t / release)
    return 0.0


# ---------------------------------------------------------------------------
# brick_hit — short transient click (noise burst + 1 kHz tone, 80 ms)
# ---------------------------------------------------------------------------
def make_brick_hit() -> list[float]:
    import random
    duration = 0.08
    n = int(SAMPLE_RATE * duration)
    rng = random.Random(42)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.001, 0.015, 0.0, 0.064, duration)
        noise = rng.uniform(-1.0, 1.0) * 0.4
        tone = sine(1200.0, t) * 0.6
        samples.append((noise + tone) * env)
    return samples


# ---------------------------------------------------------------------------
# paddle_hit — heavier thwack (noise burst + 400 Hz, 120 ms)
# ---------------------------------------------------------------------------
def make_paddle_hit() -> list[float]:
    import random
    duration = 0.12
    n = int(SAMPLE_RATE * duration)
    rng = random.Random(7)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.002, 0.025, 0.0, 0.093, duration)
        noise = rng.uniform(-1.0, 1.0) * 0.5
        tone = sine(400.0, t) * 0.5
        samples.append((noise + tone) * env)
    return samples


# ---------------------------------------------------------------------------
# wall_hit — light high tick (noise + 2.4 kHz, 50 ms)
# ---------------------------------------------------------------------------
def make_wall_hit() -> list[float]:
    import random
    duration = 0.05
    n = int(SAMPLE_RATE * duration)
    rng = random.Random(13)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.001, 0.010, 0.0, 0.039, duration)
        noise = rng.uniform(-1.0, 1.0) * 0.3
        tone = sine(2400.0, t) * 0.7
        samples.append((noise + tone) * env)
    return samples


# ---------------------------------------------------------------------------
# ball_launch — ascending sweep 300 → 1200 Hz, 200 ms
# ---------------------------------------------------------------------------
def make_ball_launch() -> list[float]:
    duration = 0.20
    n = int(SAMPLE_RATE * duration)
    samples = []
    phase = 0.0
    f_start, f_end = 300.0, 1200.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.005, 0.040, 0.4, 0.10, duration)
        freq = f_start + (f_end - f_start) * (t / duration)
        phase += 2 * math.pi * freq / SAMPLE_RATE
        samples.append(math.sin(phase) * env * 0.8)
    return samples


# ---------------------------------------------------------------------------
# ball_loss — short descending tone (falling feel, 200 ms)
# ---------------------------------------------------------------------------
def make_ball_loss() -> list[float]:
    duration = 0.20
    n = int(SAMPLE_RATE * duration)
    samples = []
    phase = 0.0
    f_start, f_end = 600.0, 150.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.005, 0.020, 0.3, 0.08, duration)
        freq = f_start + (f_end - f_start) * (t / duration)
        phase += 2 * math.pi * freq / SAMPLE_RATE
        samples.append(math.sin(phase) * env * 0.7)
    return samples


# ---------------------------------------------------------------------------
# game_over — dramatic descending arpeggio (600 ms)
# Three notes stepping down: 500 Hz → 350 Hz → 200 Hz, each ~180 ms
# ---------------------------------------------------------------------------
def make_game_over() -> list[float]:
    import random
    total = 0.60
    freqs = [500.0, 350.0, 200.0]
    note_dur = total / len(freqs)
    n_total = int(SAMPLE_RATE * total)
    samples = [0.0] * n_total
    rng = random.Random(99)
    for idx, freq in enumerate(freqs):
        start = int(idx * note_dur * SAMPLE_RATE)
        n = int(note_dur * SAMPLE_RATE)
        phase = 0.0
        for i in range(n):
            t = i / SAMPLE_RATE
            env = envelope(t, 0.005, 0.040, 0.4, 0.10, note_dur)
            noise = rng.uniform(-1.0, 1.0) * 0.15
            phase += 2 * math.pi * freq / SAMPLE_RATE
            val = (math.sin(phase) * 0.7 + noise) * env * 0.8
            pos = start + i
            if pos < n_total:
                samples[pos] += val
    return samples


# ---------------------------------------------------------------------------
# level_complete — ascending bright chime (500 ms)
# Three notes stepping up: 400 Hz → 600 Hz → 800 Hz, each ~150 ms
# ---------------------------------------------------------------------------
def make_level_complete() -> list[float]:
    total = 0.50
    freqs = [400.0, 600.0, 800.0]
    note_dur = total / len(freqs)
    n_total = int(SAMPLE_RATE * total)
    samples = [0.0] * n_total
    for idx, freq in enumerate(freqs):
        start = int(idx * note_dur * SAMPLE_RATE)
        n = int(note_dur * SAMPLE_RATE)
        phase = 0.0
        for i in range(n):
            t = i / SAMPLE_RATE
            env = envelope(t, 0.003, 0.020, 0.5, 0.08, note_dur)
            phase += 2 * math.pi * freq / SAMPLE_RATE
            val = math.sin(phase) * env * 0.8
            pos = start + i
            if pos < n_total:
                samples[pos] += val
    return samples


# ---------------------------------------------------------------------------
# powerup_collect — quick bright chime (150 ms)
# ---------------------------------------------------------------------------
def make_powerup_collect() -> list[float]:
    duration = 0.15
    n = int(SAMPLE_RATE * duration)
    samples = []
    phase = 0.0
    f_start, f_end = 800.0, 1600.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.003, 0.015, 0.3, 0.06, duration)
        freq = f_start + (f_end - f_start) * (t / duration)
        phase += 2 * math.pi * freq / SAMPLE_RATE
        samples.append(math.sin(phase) * env * 0.7)
    return samples


# ---------------------------------------------------------------------------
# powerup_activate — neutral activation sting, base pitch (200 ms)
# Short punchy tone, mid frequency; pitch-shifted per power-up type at runtime.
# ---------------------------------------------------------------------------
def make_powerup_activate() -> list[float]:
    import random
    duration = 0.20
    n = int(SAMPLE_RATE * duration)
    rng = random.Random(55)
    samples = []
    phase = 0.0
    freq = 500.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.005, 0.030, 0.4, 0.10, duration)
        noise = rng.uniform(-1.0, 1.0) * 0.2
        phase += 2 * math.pi * freq / SAMPLE_RATE
        samples.append((math.sin(phase) * 0.7 + noise) * env * 0.8)
    return samples


# ---------------------------------------------------------------------------
# powerup_laser_charge — electronic charge-up (250 ms), rising buzz
# ---------------------------------------------------------------------------
def make_powerup_laser_charge() -> list[float]:
    duration = 0.25
    n = int(SAMPLE_RATE * duration)
    samples = []
    phase = 0.0
    f_start, f_end = 200.0, 2000.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.010, 0.020, 0.6, 0.05, duration)
        freq = f_start + (f_end - f_start) * (t / duration) ** 2
        phase += 2 * math.pi * freq / SAMPLE_RATE
        # Add odd harmonics for a buzzy electronic character
        val = (math.sin(phase) * 0.5 + math.sin(3 * phase) * 0.3 +
               math.sin(5 * phase) * 0.15) * env * 0.6
        samples.append(val)
    return samples


# ---------------------------------------------------------------------------
# powerup_expire — short drooping tone (150 ms)
# ---------------------------------------------------------------------------
def make_powerup_expire() -> list[float]:
    duration = 0.15
    n = int(SAMPLE_RATE * duration)
    samples = []
    phase = 0.0
    f_start, f_end = 700.0, 300.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope(t, 0.003, 0.015, 0.3, 0.06, duration)
        freq = f_start + (f_end - f_start) * (t / duration)
        phase += 2 * math.pi * freq / SAMPLE_RATE
        samples.append(math.sin(phase) * env * 0.65)
    return samples


def generate(name: str, samples: list[float]) -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    caf_path = os.path.join(OUTPUT_DIR, f"{name}.caf")
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        tmp_path = tmp.name
    try:
        write_wav(tmp_path, samples)
        wav_to_caf(tmp_path, caf_path)
        print(f"  wrote {caf_path}")
    finally:
        os.unlink(tmp_path)


if __name__ == "__main__":
    print("Generating sound assets…")
    generate("brick_hit", make_brick_hit())
    generate("paddle_hit", make_paddle_hit())
    generate("wall_hit", make_wall_hit())
    generate("ball_launch", make_ball_launch())
    generate("ball_loss", make_ball_loss())
    generate("game_over", make_game_over())
    generate("level_complete", make_level_complete())
    generate("powerup_collect", make_powerup_collect())
    generate("powerup_activate", make_powerup_activate())
    generate("powerup_laser_charge", make_powerup_laser_charge())
    generate("powerup_expire", make_powerup_expire())
    print("Done.")
