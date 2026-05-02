Commit: 99b2fb0

# Entities OOP → Pure Functional Conversion

## Context

Global coding rules mandate pure functional style (no classes, no `setmetatable`, no `self`). The entity modules still used OOP patterns with metatables and colon-syntax methods.

## Change Summary

Converted 4 entity modules from OOP to pure functional style:

- `game/src/entities/player.lua` — `.new` → `.create`, removed metatable, all `self:` → dot syntax with `state` param; internal cross-calls (`self:initSpriteAnimator()` → `Player.initSpriteAnimator(state)`, etc.)
- `game/src/entities/enemy.lua` — same conversion; `self:getHPPercent()` in `decideAction` → `Enemy.getHPPercent(state)`; static methods (`getRandomType`, `getAllTypes`, etc.) unchanged
- `game/src/entities/encounter_zone.lua` — same conversion; `self:getColorForType(...)` in constructor → `EncounterZone.getColorForType(state.enemyType)`
- `game/src/entities/map.lua` — same conversion; `self:generateTownLayout()` in constructor → `Map.generateTownLayout(state)`

Updated `agents/03-code-style.md` Lua module pattern section to reflect functional style.

## Impact Surface

- All callers of these 4 modules must switch from colon syntax (`player:moveTo(x,y)`) to dot syntax (`Player.moveTo(player, x,y)`)
- `Enemy.new(...)` → `Enemy.create(...)` for all callers
- `Player.new(...)` → `Player.create(...)` for all callers
- `EncounterZone.new(...)` → `EncounterZone.create(...)`
- `Map.new(...)` → `Map.create(...)`

## Notes

- CombatUtils calls already used `self` as first arg; now pass `state` directly
- External objects (SpriteAnimator, CollisionSystem, AssetManager) still use their own method call conventions; AnimationManager now converted separately (see animations-functional-conversion)
