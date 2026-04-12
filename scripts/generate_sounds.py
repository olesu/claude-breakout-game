#!/usr/bin/env python3
"""Generate synthetic .caf sound assets for BreakoutGame.

Writes four 16-bit PCM 44100 Hz mono .caf files to Sources/Sounds/:
  brick_hit.caf   — short transient click
  paddle_hit.caf  — slightly heavier thwack
  wall_hit.caf    — light high tick
  ball_launch.caf — short ascending sweep

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
    print("Done.")
