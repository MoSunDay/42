# Game Client Module Summary

> Last updated: e0b0fcb - Tests, docs, and new systems

## Purpose
LÖVE 2D game client for turn-based RPG with top-down exploration and combat.

## Main Directories

| Directory | Description |
|-----------|-------------|
| `src/core/` | Core systems (game_state, camera, assets, sound loading) |
| `src/entities/` | Game entities (player, enemy with AI, map, encounters) |
| `src/systems/` | Game systems (audio, companion, spirit crystal, equipment, battle, etc.) |
| `src/ui/` | UI components |
| `src/animations/` | Animation system |
| `src/network/` | Network communication |
| `account/` | Account/login system |
| `map/` | Map data, Tiled integration, STI library |
| `npcs/` | NPC definitions |
| `assets/` | Images, fonts, sounds (24 placeholder files) |
| `lib/` | External libraries (STI for Tiled maps) |
| `tools/` | Test files and development tools |

## Key Files

| File | Description |
|------|-------------|
| `main.lua` | Entry point, LÖVE callbacks |
| `conf.lua` | LÖVE configuration (1280x720, 60fps) |

## Test Files (tools/)

| File | Coverage |
|------|----------|
| `test_battle.lua` | Enemy creation, damage, death |
| `test_game.lua` | Core module loading, player movement |
| `test_boundaries.lua` | Map boundary restrictions |
| `test_audio.lua` | Audio file loading, fallback generation |
| `test_tiled.lua` | Tiled JSON parsing, layers |
| `test_companion.lua` | Companion templates, party, leveling |
| `test_spirit_crystal.lua` | Crystal types, tiers, fusion |
| `test_equipment.lua` | Equipment slots, stats, enhancement |

## Game States

1. `login` - Account login screen
2. `character_select` - Character selection/creation
3. `exploration` - Free roam on map
4. `battle` - Turn-based combat

## New Systems (e0b0fcb)

### Companion System
- 6 companion templates (warrior, berserker, guardian, assassin, mage, paladin)
- Max 9 companions in party
- Leveling and stat growth
- Battle party formation

### Spirit Crystal System
- 5 crystal types (crimson/azure/emerald/violet/golden)
- 4 tiers (fragment/crystal/gem/core)
- Stat bonuses when equipped
- Crystal fusion for upgrades

### Audio System Enhancement
- File loading from assets/sounds/
- Procedural fallback generation
- 24 placeholder sound files
- Volume controls

### Tiled Map Integration
- STI library for full Tiled support
- JSON/TMX format parsing
- Object layers (collision, spawn, npcs, encounter)

## Architecture

- Uses module pattern with `local M = {}; M.__index = M`
- State managed by `game_state.lua`
- Camera follows player with smooth interpolation
- Tile-based collision system
- Audio with file loading + procedural fallback
