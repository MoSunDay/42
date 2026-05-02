Commit: HEAD

# Full OOP → Pure Functional Refactoring

## Context

Global coding rules mandate pure functional style: no classes, no `setmetatable`, no `__index`, no `self`, no colon syntax. The codebase previously used OOP patterns throughout all Lua modules. This changelog entry covers the cumulative conversion of all remaining modules and the supporting refactoring (new files, deleted files, documentation updates).

## Change Summary

### Converted Modules (OOP → Functional)

Every Lua module was converted from metatable-based OOP to plain-table functional style:

- **Core**: `game_state.lua`, `asset_manager.lua`
- **Entities**: `player.lua`, `enemy.lua`, `encounter_zone.lua`, `map.lua`
- **Animations**: `animation_manager.lua`
- **Systems**: `battle_system`, `party_system`, `chat_system`, `companion_system`, `collision_system`, `equipment_system`, `inventory_system`, `spirit_crystal_system`, `audio_system`, `skill_system`, `pet_system`, `dungeon_system`, `tutorial_system`, `input_system`, `render_system`, `sprite_animator`, `tile_animator`
- **UI**: `components.lua`, `hud.lua`, `skill_panel.lua`, `party_ui.lua`, `chat_ui.lua`, `inventory_ui.lua`, `equipment_ui.lua`, `map_renderer.lua`, `unified_menu.lua`, `button_ui.lua`, `fullscreen_map.lua`, `theme.lua`, `particles.lua`, `animation.lua`, `tutorial_panel.lua`, `pet_ui.lua`
- **Map**: `map_manager.lua`, `map_generator.lua`, `map_registry.lua`, `autotile.lua`, `tiled_loader.lua`, `tileset_manager.lua`, `particle_system.lua`
- **NPCs**: `npc_manager.lua`, `npc_database.lua`, `bosses.lua`, `friendly_npcs.lua`, `monsters.lua`, `teleporter.lua`
- **Account**: `login_ui.lua`, `character_select_ui.lua`

### New Files Created

| File | Purpose |
|------|---------|
| `game/src/systems/combat_utils.lua` | Shared combat calculation functions extracted from battle system |
| `game/src/ui/slot_utils.lua` | Slot/grid helper functions extracted from UI components |
| `game/src/entities/enemy_data.lua` | Enemy stat and loot data tables separated from enemy logic |
| `game/src/systems/item_data.lua` | Item definition data tables separated from item logic |
| `game/src/systems/battle_simulator/sim_combatant.lua` | Functional combatant for battle simulator |
| `game/map/map_themes.lua` | Theme color/asset definitions extracted from map generator |
| `game/map/map_object_renderer.lua` | Object layer rendering extracted from map manager |
| `server/handlers/common.py` | Shared Python handler utilities |

### Files Deleted

| File | Reason |
|------|--------|
| `game/src/systems/battle_simulator/sim_entity.lua` | Replaced by `sim_combatant.lua` |
| `game/src/systems/battle_simulator/sim_unit.lua` | Merged into `sim_combatant.lua` |
| `game/src/systems/battle_simulator/simulated_combatant.lua` | Replaced by `sim_combatant.lua` |
| `game/map/tiled_integration.lua` | Superseded by `tiled_loader.lua` + `map_object_renderer.lua` |

### Documentation Updated

- `agents/03-code-style.md` — Lua module pattern rewritten for functional style
- `agents/04-project-structure.md` — Added/removed files to match current tree
- `agents/05-architecture.md` — Added paradigm note (pure functional, no OOP)

## Pattern Applied (Every Module)

```lua
-- Before (OOP):
local Module = {}
Module.__index = Module
function Module.new(param)
    return setmetatable({ prop = param }, Module)
end
function Module:method(arg)
    return self.prop + arg
end

-- After (Functional):
local Module = {}
function Module.create(param)
    return { prop = param }
end
function Module.method(state, arg)
    return state.prop + arg
end
```

## Impact Surface

- **All callers** must use dot syntax: `Module.method(obj, ...)` instead of `obj:method(...)`
- **All constructors** renamed from `.new()` to `.create()`
- **No metatables** anywhere — all data tables are plain Lua tables
- **Data/logic separation**: data tables (`enemy_data.lua`, `item_data.lua`, `map_themes.lua`) hold pure data; modules operate on them functionally
