# Tools Module Summary

> Last updated: e0b0fcb - Added sound generation script

## Purpose
Development utilities and asset generation.

## Files

| File | Description |
|------|-------------|
| `generate_assets.py` | Generate character/enemy sprites |
| `check_status.py` | Check server/game status |
| `download_sounds.py` | Generate placeholder sound effects |
| `generated_assets/` | Generated sprite output |

## Key Scripts

### generate_assets.py
Generates placeholder sprites for:
- Characters (8 directions, 2 animations)
- Enemies (4 directions, idle animation)
- NPCs

```bash
cd tools
python generate_assets.py
```

### download_sounds.py
Generates procedural placeholder sound effects (WAV format):
- Combat SFX (attack, hit, critical, etc.)
- UI SFX (click, hover, open, etc.)
- Character SFX (hurt, death)
- BGM loops (exploration, battle, seasonal)

```bash
python scripts/download_sounds.py
```

Output: `game/assets/sounds/` (24 files)

For production, replace with real audio from:
- https://kenney.nl/assets
- https://opengameart.org
- https://mixkit.co/free-sound-effects/game/

### check_status.py
Checks:
- Server availability
- Account count
- Character data integrity

```bash
cd tools
python check_status.py
```

## Generated Assets Structure

```
generated_assets/
└── extracted/
    ├── characters/
    │   ├── blue_hero/
    │   ├── red_warrior/
    │   └── ...
    ├── enemies/
    │   ├── slime/
    │   ├── goblin/
    │   └── ...
    └── npcs/
```

## Sound Assets Structure

```
game/assets/sounds/
├── bgm/
│   ├── exploration.wav
│   ├── battle.wav
│   ├── town.wav
│   └── seasonal/
│       ├── spring.wav
│       ├── summer.wav
│       ├── autumn.wav
│       └── winter.wav
└── sfx/
    ├── combat/
    │   ├── attack.wav
    │   ├── hit.wav
    │   └── ...
    ├── ui/
    │   ├── click.wav
    │   ├── hover.wav
    │   └── ...
    └── character/
        ├── hurt.wav
        └── death.wav
```

## Output Usage
Generated assets should be copied to `game/assets/images/` for use by the game client.
Sound files are placed directly in `game/assets/sounds/`.
