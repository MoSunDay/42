# Sound Assets

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
