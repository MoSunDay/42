# Architecture Notes

## Paradigm

All Lua modules use **pure functional style**. There are no classes, no `setmetatable`, no `__index`, and no `self` keyword. Data is passed as plain tables; functions operate on them via dot syntax (`Module.method(state, ...)`). Constructors use `.create()` returning plain tables.

## Game States

1. `login` - Account login screen
2. `character_select` - Character selection/creation
3. `exploration` - Free roam on map
4. `battle` - Turn-based combat

## Key Systems

> 详细 API 见各模块的 `docs/summary.md`

| System | Location | Summary |
|--------|----------|---------|
| Battle | `src/systems/battle/` | [summary.md](../game/src/systems/battle/docs/summary.md) |
| Party | `src/systems/party_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |
| Chat | `src/systems/chat_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |
| Collision | `src/systems/collision_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |
| Equipment | `src/systems/equipment_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |
| Companion | `src/systems/companion_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |
| Spirit Crystal | `src/systems/spirit_crystal_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |
| Audio | `src/systems/audio_system.lua` | [summary.md](../game/src/systems/docs/summary.md) |

## Map System

> 详见 [game/map/docs/summary.md](../game/map/docs/summary.md)

- **MapGenerator**: Generates terrain based on 10 themes
- **MapRegistry**: Manages map unlock progression and level ranges
- **Tiled Integration**: STI library for Tiled map format support

## NPC System

> 详见 [game/npcs/docs/summary.md](../game/npcs/docs/summary.md)

| Type | File | Purpose |
|------|------|---------|
| Boss | `npcs/bosses.lua` | Boss encounters |
| Friendly | `npcs/friendly_npcs.lua` | Quest givers, merchants |
| Monster | `npcs/monsters.lua` | Regular enemies |
| Teleporter | `npcs/teleporter.lua` | Map travel |

## UI System

> 详见 [game/src/ui/docs/summary.md](../game/src/ui/docs/summary.md)

- **Components Module**: 9-slice panels, buttons, bars, slots, dialogs
- **Theme System**: Unified color palette

## LÖVE Callbacks

```lua
love.load()      -- Initialize game
love.update(dt)  -- Game loop update
love.draw()      -- Render frame
love.keypressed(key)
love.textinput(text)
love.mousepressed(x, y, button)
love.wheelmoved(x, y)
```
