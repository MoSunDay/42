# Map Modules OOP→Functional Conversion

## Context

Map and NPC modules used OOP pattern (`setmetatable`, `__index`, `:method(self)`) while project conventions mandate pure functional style.

## Change Summary

Converted 8 files from OOP to pure functional pattern:

- `map/map_data.lua` — `MapData.new` → `MapData.create`, all `:method()` → `.method(state, ...)`
- `map/map_generator.lua` — removed dead `__index` line (was already module-pattern)
- `map/autotile.lua` — `Autotile.new` → `Autotile.create`, `self.BITMAP` → `Autotile.BITMAP` (module constant)
- `map/tileset_manager.lua` — `TilesetManager.new` → `TilesetManager.create`
- `map/particle_system.lua` — `ParticleSystem.new` → `ParticleSystem.create`
- `map/tiled_loader.lua` — removed dead `__index` line, `MapData.new()` → `MapData.create()`
- `npcs/npc_manager.lua` — `NPCManager.new` → `NPCManager.create`
- `npcs/teleporter.lua` — `Teleporter.new` → `Teleporter.create`

Updated caller `map/map_manager.lua`: all `.new()` → `.create()`, all `:method()` dispatch → `Module.method(state, ...)` for particleSystem, autotile.

## Impact Surface

- Any code calling `:method()` on instances of these 8 modules must use `Module.method(instance, ...)` instead
- Construction must use `.create()` instead of `.new()`
- Files left alone: `map_manager.lua`, `map_registry.lua` (already module-pattern); `npc_database.lua`, `monsters.lua`, `bosses.lua`, `friendly_npcs.lua` (data files)

## Related Docs

- [Code Style Guidelines](../../agents/03-code-style.md)
- [Architecture](../../agents/05-architecture.md)
