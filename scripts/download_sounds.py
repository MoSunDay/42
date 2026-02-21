#!/usr/bin/env python3
"""
Sound Effect Placeholder Generator

Generates procedural placeholder sound effects for development.

Usage:
    python scripts/download_sounds.py

For production, replace with real audio from:
    - https://kenney.nl/assets
    - https://opengameart.org
    - https://mixkit.co/free-sound-effects/game/
"""

import struct
import math
import wave
import os
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent / "game" / "assets" / "sounds"

SAMPLE_RATE = 44100

SFX_CONFIG = {
    "sfx/combat": {
        "attack.ogg": {"freq": 440, "duration": 0.1, "type": "sine"},
        "hit.ogg": {"freq": 220, "duration": 0.08, "type": "sine"},
        "critical.ogg": {"freq": 880, "duration": 0.15, "type": "square"},
        "block.ogg": {"freq": 330, "duration": 0.1, "type": "triangle"},
        "dodge.ogg": {"freq": 550, "duration": 0.08, "type": "noise"},
        "skill.ogg": {"freq": 660, "duration": 0.2, "type": "sweep_up"},
        "victory.ogg": {"freq": 523, "duration": 0.3, "type": "major_chord"},
        "defeat.ogg": {"freq": 165, "duration": 0.5, "type": "minor_chord"},
    },
    "sfx/ui": {
        "click.ogg": {"freq": 600, "duration": 0.05, "type": "sine"},
        "hover.ogg": {"freq": 800, "duration": 0.03, "type": "sine"},
        "open.ogg": {"freq": 500, "duration": 0.1, "type": "sweep_up"},
        "close.ogg": {"freq": 400, "duration": 0.08, "type": "sweep_down"},
        "pickup.ogg": {"freq": 700, "duration": 0.1, "type": "sweep_up"},
        "equip.ogg": {"freq": 450, "duration": 0.15, "type": "triangle"},
        "levelup.ogg": {"freq": 880, "duration": 0.4, "type": "arpeggio_up"},
    },
    "sfx/character": {
        "hurt.ogg": {"freq": 200, "duration": 0.15, "type": "noise"},
        "death.ogg": {"freq": 150, "duration": 0.5, "type": "sweep_down"},
    },
}

BGM_CONFIG = {
    "bgm": {
        "exploration.ogg": {"duration": 4.0, "mode": "exploration"},
        "battle.ogg": {"duration": 4.0, "mode": "battle"},
        "town.ogg": {"duration": 4.0, "mode": "town"},
    },
    "bgm/seasonal": {
        "spring.ogg": {"duration": 4.0, "mode": "spring"},
        "summer.ogg": {"duration": 4.0, "mode": "summer"},
        "autumn.ogg": {"duration": 4.0, "mode": "autumn"},
        "winter.ogg": {"duration": 4.0, "mode": "winter"},
    },
}

SCALES = {
    "c_major": [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25],
    "a_minor": [220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00, 440.00],
    "pentatonic": [261.63, 293.66, 329.63, 392.00, 440.00],
    "battle": [220.00, 233.08, 261.63, 277.18, 311.13, 329.63, 369.99, 392.00],
}


def generate_envelope(samples, attack=0.1, decay=0.1, sustain=0.7, release=0.2):
    total = samples
    attack_samples = int(total * attack)
    decay_samples = int(total * decay)
    release_samples = int(total * release)
    sustain_samples = total - attack_samples - decay_samples - release_samples

    envelope = []
    for i in range(attack_samples):
        envelope.append(i / attack_samples)
    for i in range(decay_samples):
        envelope.append(1.0 - (1.0 - sustain) * (i / decay_samples))
    for i in range(sustain_samples):
        envelope.append(sustain)
    for i in range(release_samples):
        envelope.append(sustain * (1 - i / release_samples))

    return envelope


def generate_sine(freq, duration, sample_rate=SAMPLE_RATE):
    samples = int(sample_rate * duration)
    data = []
    envelope = generate_envelope(samples)
    for i in range(samples):
        t = i / sample_rate
        value = (
            math.sin(2 * math.pi * freq * t) * envelope[min(i, len(envelope) - 1)] * 0.3
        )
        data.append(int(value * 32767))
    return data


def generate_square(freq, duration, sample_rate=SAMPLE_RATE):
    samples = int(sample_rate * duration)
    data = []
    envelope = generate_envelope(samples)
    for i in range(samples):
        t = i / sample_rate
        value = (
            (1 if math.sin(2 * math.pi * freq * t) > 0 else -1)
            * envelope[min(i, len(envelope) - 1)]
            * 0.2
        )
        data.append(int(value * 32767))
    return data


def generate_triangle(freq, duration, sample_rate=SAMPLE_RATE):
    samples = int(sample_rate * duration)
    data = []
    envelope = generate_envelope(samples)
    for i in range(samples):
        t = i / sample_rate
        period = 1 / freq
        phase = (t % period) / period
        value = 4 * abs(phase - 0.5) - 1
        value = value * envelope[min(i, len(envelope) - 1)] * 0.3
        data.append(int(value * 32767))
    return data


def generate_noise(duration, freq_hint, sample_rate=SAMPLE_RATE):
    import random

    samples = int(sample_rate * duration)
    data = []
    envelope = generate_envelope(samples)

    filter_factor = freq_hint / sample_rate
    last = 0

    for i in range(samples):
        raw = random.uniform(-1, 1)
        filtered = last + filter_factor * (raw - last)
        last = filtered
        value = filtered * envelope[min(i, len(envelope) - 1)] * 0.3
        data.append(int(value * 32767))
    return data


def generate_sweep(start_freq, end_freq, duration, sample_rate=SAMPLE_RATE):
    samples = int(sample_rate * duration)
    data = []
    envelope = generate_envelope(samples)
    for i in range(samples):
        t = i / sample_rate
        progress = i / samples
        freq = start_freq + (end_freq - start_freq) * progress
        value = (
            math.sin(2 * math.pi * freq * t) * envelope[min(i, len(envelope) - 1)] * 0.3
        )
        data.append(int(value * 32767))
    return data


def generate_sweep_up(freq, duration):
    return generate_sweep(freq * 0.5, freq * 1.5, duration)


def generate_sweep_down(freq, duration):
    return generate_sweep(freq * 1.5, freq * 0.5, duration)


def generate_major_chord(root, duration):
    samples = int(SAMPLE_RATE * duration)
    data = []
    envelope = generate_envelope(samples)
    freqs = [root, root * 1.26, root * 1.5]
    for i in range(samples):
        t = i / SAMPLE_RATE
        value = sum(math.sin(2 * math.pi * f * t) for f in freqs) / 3
        value = value * envelope[min(i, len(envelope) - 1)] * 0.3
        data.append(int(value * 32767))
    return data


def generate_minor_chord(root, duration):
    samples = int(SAMPLE_RATE * duration)
    data = []
    envelope = generate_envelope(samples)
    freqs = [root, root * 1.19, root * 1.5]
    for i in range(samples):
        t = i / SAMPLE_RATE
        value = sum(math.sin(2 * math.pi * f * t) for f in freqs) / 3
        value = value * envelope[min(i, len(envelope) - 1)] * 0.3
        data.append(int(value * 32767))
    return data


def generate_arpeggio_up(root, duration):
    samples = int(SAMPLE_RATE * duration)
    data = []
    notes = [root, root * 1.26, root * 1.5, root * 2]
    note_duration = duration / len(notes)

    for note_idx, freq in enumerate(notes):
        note_samples = int(SAMPLE_RATE * note_duration)
        start = note_idx * note_samples
        for i in range(note_samples):
            t = i / SAMPLE_RATE
            progress = i / note_samples
            env = math.exp(-progress * 3)
            value = math.sin(2 * math.pi * freq * t) * env * 0.3
            data.append(int(value * 32767))
    return data


def generate_sfx(config):
    sfx_type = config["type"]
    freq = config["freq"]
    duration = config["duration"]

    if sfx_type == "sine":
        return generate_sine(freq, duration)
    elif sfx_type == "square":
        return generate_square(freq, duration)
    elif sfx_type == "triangle":
        return generate_triangle(freq, duration)
    elif sfx_type == "noise":
        return generate_noise(duration, freq)
    elif sfx_type == "sweep_up":
        return generate_sweep_up(freq, duration)
    elif sfx_type == "sweep_down":
        return generate_sweep_down(freq, duration)
    elif sfx_type == "major_chord":
        return generate_major_chord(freq, duration)
    elif sfx_type == "minor_chord":
        return generate_minor_chord(freq, duration)
    elif sfx_type == "arpeggio_up":
        return generate_arpeggio_up(freq, duration)
    else:
        return generate_sine(freq, duration)


def generate_bgm(config):
    duration = config["duration"]
    mode = config["mode"]
    samples = int(SAMPLE_RATE * duration)
    data = []

    if mode in ["exploration", "spring", "summer"]:
        scale = SCALES["c_major"]
    elif mode == "battle":
        scale = SCALES["battle"]
    elif mode == "autumn":
        scale = SCALES["pentatonic"]
    elif mode in ["winter", "town"]:
        scale = SCALES["a_minor"]
    else:
        scale = SCALES["c_major"]

    progression = [[1, 3, 5], [6, 1, 3], [4, 6, 1], [5, 7, 2]]

    for i in range(samples):
        t = i / SAMPLE_RATE
        chord_idx = int((t / duration) * len(progression))
        if chord_idx >= len(progression):
            chord_idx = len(progression) - 1
        chord = progression[chord_idx]

        idx1 = (chord[0] - 1) % len(scale)
        idx2 = (chord[1] - 1) % len(scale)
        idx3 = (chord[2] - 1) % len(scale)

        melody = scale[idx1]
        harmony1 = scale[idx2]
        harmony2 = scale[idx3]
        bass = melody / 2

        note_time = t % 1.0
        if note_time < 0.05:
            env = note_time / 0.05
        elif note_time < 0.15:
            env = 1.0 - (note_time - 0.05) / 0.1 * 0.3
        elif note_time < 0.8:
            env = 0.7
        else:
            env = 0.7 * (1 - (note_time - 0.8) / 0.2)

        value = (
            (
                math.sin(2 * math.pi * melody * t)
                + math.sin(2 * math.pi * harmony1 * t) * 0.5
                + math.sin(2 * math.pi * harmony2 * t) * 0.3
                + math.sin(2 * math.pi * bass * t) * 0.4
            )
            * env
            * 0.08
        )

        data.append(int(max(-1, min(1, value)) * 32767))

    return data


def write_wav(filepath, data):
    with wave.open(str(filepath), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(struct.pack("<" + "h" * len(data), *data))


def create_readme():
    readme_path = BASE_DIR / "README.md"
    content = """# Sound Assets

Procedurally generated placeholder sounds for development.

## Directory Structure

```
sounds/
├── bgm/                    # Background music
│   ├── exploration.ogg
│   ├── battle.ogg
│   ├── town.ogg
│   └── seasonal/
│       ├── spring.ogg
│       ├── summer.ogg
│       ├── autumn.ogg
│       └── winter.ogg
└── sfx/                    # Sound effects
    ├── combat/
    │   ├── attack.ogg
    │   ├── hit.ogg
    │   ├── critical.ogg
    │   ├── block.ogg
    │   ├── dodge.ogg
    │   ├── skill.ogg
    │   ├── victory.ogg
    │   └── defeat.ogg
    ├── ui/
    │   ├── click.ogg
    │   ├── hover.ogg
    │   ├── open.ogg
    │   ├── close.ogg
    │   ├── pickup.ogg
    │   ├── equip.ogg
    │   └── levelup.ogg
    └── character/
        ├── hurt.ogg
        └── death.ogg
```

## Replacing Placeholders

For production, download real audio from:

1. **Kenney.nl** - https://kenney.nl/assets
   - High quality CC0 game audio packs
   
2. **OpenGameArt.org** - https://opengameart.org/art-search?keys=sfx
   
3. **Mixkit** - https://mixkit.co/free-sound-effects/game/

## Format Requirements

- **Format**: OGG Vorbis (.ogg) preferred
- **Sample Rate**: 44100 Hz
- **Channels**: Mono for SFX, Stereo for BGM

Regenerate placeholders:
```bash
python scripts/download_sounds.py
```
"""
    readme_path.write_text(content)
    print(f"  Created: {readme_path}")


def main():
    print("=" * 50)
    print("Sound Effect Placeholder Generator")
    print("=" * 50)

    total = 0

    print("\nGenerating SFX...")
    for category, sounds in SFX_CONFIG.items():
        cat_path = BASE_DIR / category
        cat_path.mkdir(parents=True, exist_ok=True)

        for filename, config in sounds.items():
            filepath = cat_path / filename
            data = generate_sfx(config)
            write_wav(filepath.with_suffix(".wav"), data)
            total += 1
            print(f"  Generated: {category}/{filename}")

    print("\nGenerating BGM...")
    for category, tracks in BGM_CONFIG.items():
        cat_path = BASE_DIR / category
        cat_path.mkdir(parents=True, exist_ok=True)

        for filename, config in tracks.items():
            filepath = cat_path / filename
            data = generate_bgm(config)
            write_wav(filepath.with_suffix(".wav"), data)
            total += 1
            print(f"  Generated: {category}/{filename}")

    create_readme()

    print("\n" + "=" * 50)
    print(f"Generated {total} placeholder sounds (WAV format)")
    print("=" * 50)
    print("\nTo convert to OGG, install ffmpeg and run:")
    print(
        "  find game/assets/sounds -name '*.wav' -exec sh -c 'ffmpeg -y -i \"$1\" \"${1%.wav}.ogg\"' _ {} \\;"
    )
    print("\nOr use the game's built-in procedural audio as fallback.")


if __name__ == "__main__":
    main()
