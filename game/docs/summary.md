# Game Client Module Summary

> Last updated: TBD (commit on first change)

## Purpose
LÖVE 2D game client for turn-based RPG with top-down exploration and combat.

## Main Directories

| Directory | Description |
|-----------|-------------|
| `src/core/` | Core systems (game_state, camera, assets) |
| `src/entities/` | Game entities (player, enemy, map) |
| `src/systems/` | Game systems (battle, party, chat, inventory) |
| `src/ui/` | UI components |
| `src/animations/` | Animation system |
| `src/network/` | Network communication |
| `account/` | Account/login system |
| `map/` | Map data and rendering |
| `npcs/` | NPC definitions |
| `assets/` | Images, fonts, sounds |

## Key Files

| File | Description |
|------|-------------|
| `main.lua` | Entry point, LÖVE callbacks |
| `conf.lua` | LÖVE configuration (1280x720, 60fps) |

## Game States

1. `login` - Account login screen
2. `character_select` - Character selection/creation
3. `exploration` - Free roam on map
4. `battle` - Turn-based combat

## Architecture

- Uses module pattern with `local M = {}; M.__index = M`
- State managed by `game_state.lua`
- Camera follows player with smooth interpolation
- Tile-based collision system
