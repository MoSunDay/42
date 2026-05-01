# Map Module Summary

> Last updated: f86d842 - Procedural map generator and registry

## Purpose
Map data loading, rendering, tilesets, particle effects, Tiled integration, and procedural generation.

## Files

| File | Description |
|------|-------------|
| `map_manager.lua` | Map loading, switching, and Tiled support |
| `map_data.lua` | Map definitions and tile data |
| `map_generator.lua` | Procedural terrain generation |
| `map_registry.lua` | Map unlock/progression system |
| `tiled_loader.lua` | Tiled map format loader (JSON/TMX/Lua) |
| `tiled_integration.lua` | Tiled integration guide and demo |
| `tileset_manager.lua` | Tileset management |
| `autotile.lua` | Auto-tiling logic (water, paths) |
| `particle_system.lua` | Particle effects |
| `maps/` | Map data files (including Tiled JSON) |
| `minimap/` | Minimap data files |

## Dungeon Maps

| ID | Type | Level | Description |
| |----|-------|--------|-------------|
| `trial_of_awakening` | tutorial | 1-3 | New player tutorial dungeon |

## Generated Maps

| ID | Theme | Season | Description |
|----|-------|--------|-------------|
| `generated_01_woods` | forest | spring | Beginner forest |
| `generated_02_desert` | desert | summer | Sandy desert |
| `generated_03_snow` | snow | winter | Frozen tundra |
| `generated_04_volcanic` | volcanic | volcanic | Fire realm |
| `generated_05_cave` | cave | cave | Underground caves |
| `generated_06_sky` | sky | sky | Floating islands |
| `generated_07_swamp` | swamp | autumn | Poison swamp |
| `generated_08_crystal` | crystal | crystal | Crystal caverns |
| `generated_09_ruins` | ruins | ruins | Ancient ruins |
| `generated_10_realm` | realm | realm | Final realm |

## Map IDs

| ID | Description |
|----|-------------|
| `town_01` | Starting town |
| `forest_01` | Forest area |
| `dungeon_01` | Dungeon interior |
| `tiled_example` | Example Tiled map (JSON format) |
| `generated_*` | Procedurally generated maps |

## Tile Layers

1. Ground (grass, road, water)
2. Objects (trees, buildings)
3. Collision (walkability)
4. Encounter (monster zones)

## Tiled Object Layers

| Layer Name | Purpose |
|------------|---------|
| `collision` | Collision zones (impassable areas) |
| `spawn` | Player spawn points |
| `npcs` | NPC configurations |
| `encounter` | Monster encounter zones |
| `teleport` | Map teleport destinations |

## Tiled Custom Properties

| Property | Type | Description |
|----------|------|-------------|
| `season` | string | Map season (spring/summer/autumn/winter) |
| `name` | string | Display name of the map |
| `difficulty` | number | Enemy difficulty level |
