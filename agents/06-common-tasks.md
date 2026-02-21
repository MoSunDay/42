# Common Tasks

## Adding a New Enemy Type

1. Edit `src/entities/enemy.lua`
2. Add to `ENEMY_DATA` table with stats
3. Set tier (1-4) for spawn weighting

## Adding a New Map

1. Create `map/maps/map_name.lua` with tile data
2. Create `map/minimap/map_name.lua` for minimap
3. Register in `map/map_manager.lua`

### Using Tiled Editor

1. Create map in Tiled Editor
2. Export as JSON to `map/maps/`
3. Add object layers: collision, spawn, npcs, encounter
4. Set properties: season, name, difficulty
5. Load with `MapManager.loadMap("map_name", true)`

## Adding a New Battle Action

1. Add action to `src/systems/battle/battle_system.lua`
2. Update UI in `src/ui/battle/battle_menu.lua`
3. Add animation in `src/systems/battle/battle_animation.lua`

## Adding a New Companion Type

1. Edit `src/systems/companion_system.lua`
2. Add template to `COMPANION_TEMPLATES` table:
   ```lua
   {
       id = "new_type",
       name = "New Type",
       description = "Description text",
       statModifiers = { hp = 1.0, attack = 1.0, defense = 1.0, speed = 1.0, crit = 1.0, eva = 1.0 }
   }
   ```
3. Run `test_companion.lua` to verify

## Adding a New Spirit Crystal Type

1. Edit `src/systems/spirit_crystal_system.lua`
2. Add type to `TYPES` and `TYPE_NAMES`
3. Add stat mapping to `STATS_MAP`
4. Add crystal data to `CRYSTAL_DATA` with 4 tiers
5. Run `test_spirit_crystal.lua` to verify

## Adding New Sound Effects

1. Place .ogg or .wav file in appropriate directory:
   - Combat: `assets/sounds/sfx/combat/`
   - UI: `assets/sounds/sfx/ui/`
   - Character: `assets/sounds/sfx/character/`
2. Add path to `SFX_PATHS` in `audio_system.lua`
3. Call with `audioSystem:playSFX("sound_name")`

## Adding New BGM

1. Place .ogg or .wav in `assets/sounds/bgm/`
2. Add path to `BGM_PATHS` in `audio_system.lua`
3. Call with `audioSystem:playBGM("theme_name")`

## Generating Placeholder Sounds

```bash
python scripts/download_sounds.py
```

This generates procedural placeholder sounds for development. Replace with real audio from:
- https://kenney.nl/assets
- https://opengameart.org
- https://mixkit.co/free-sound-effects/game/

## Adding a New Procedural Map Theme

1. Edit `map/map_generator.lua`
2. Add theme to `THEMES` table:
   ```lua
   new_theme = {
       season = "season_name",
       bgColor = {r, g, b},
       buildingColors = {{r,g,b}, ...},
       monsters = {"monster_id", ...},
       buildingTypes = {"type1", ...}
   }
   ```
3. Register in `map/map_registry.lua` with level range and unlock state

## Adding a New NPC Type

1. Choose category: `bosses.lua`, `friendly_npcs.lua`, `monsters.lua`
2. Add NPC definition with id, name, stats, dialogue
3. For special NPCs (teleporters), create dedicated file in `npcs/`

## Adding UI Components

1. Edit `src/ui/components.lua`
2. Use existing helpers: `draw9Slice`, `drawPanel`, `drawButton`
3. Reference `Theme` module for consistent colors
