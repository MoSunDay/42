# Tools Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Development utilities and asset generation.

## Files

| File | Description |
|------|-------------|
| `generate_assets.py` | Generate character/enemy sprites |
| `check_status.py` | Check server/game status |
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

## Output Usage
Generated assets should be copied to `game/assets/images/` for use by the game client.
