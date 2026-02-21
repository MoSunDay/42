# Map Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Map data loading, rendering, tilesets, and particle effects.

## Files

| File | Description |
|------|-------------|
| `map_manager.lua` | Map loading and switching |
| `map_data.lua` | Map definitions and tile data |
| `tiled_loader.lua` | Tiled map format loader |
| `tileset_manager.lua` | Tileset management |
| `autotile.lua` | Auto-tiling logic (water, paths) |
| `particle_system.lua` | Particle effects |
| `maps/` | Map data files |
| `minimap/` | Minimap data files |

## Key APIs

### map_manager.lua
- `MapManager.loadMap(mapId)` - Load map by ID
- `MapManager.getCurrentMap()` - Get active map
- `MapManager.getMapList()` - Available maps

### tiled_loader.lua
- `TiledLoader.load(path)` - Load Tiled JSON/Lua map
- `TiledLoader:getTileLayer(name)` - Get layer data
- `TiledLoader:getObjectLayer(name)` - Get objects

### autotile.lua
- `Autotile.update(tileGrid)` - Calculate auto-tiles
- `Autotile.getTileType(neighbors)` - Get tile from neighbors

### particle_system.lua
- `ParticleSystem.new()` - Create system
- `ParticleSystem:emit(x, y, count)` - Emit particles
- `ParticleSystem:update(dt)` - Update particles
- `ParticleSystem:draw()` - Render particles

## Map IDs

| ID | Description |
|----|-------------|
| `town_01` | Starting town |
| `forest_01` | Forest area |
| `dungeon_01` | Dungeon interior |

## Tile Layers

1. Ground (grass, road, water)
2. Objects (trees, buildings)
3. Collision (walkability)
4. Encounter (monster zones)
