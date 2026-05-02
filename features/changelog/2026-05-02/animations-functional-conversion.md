Commit: 99b2fb0

# Animations OOP → Pure Functional Conversion

## Context

Global coding rules mandate pure functional style (no classes, no `setmetatable`, no `self`). The animation modules still used OOP patterns with metatables and colon-syntax methods.

## Change Summary

Converted 4 animation modules from OOP to pure functional style:

- `game/src/animations/animation_manager.lua` — `.new` → `.create`, removed `__index`/`setmetatable`, `self:` → dot syntax with `state` param; internal calls to `BreathingEffect`/`RunningEffect` now use `Module.fn(instance, ...)` form
- `game/src/animations/breathing_effect.lua` — same conversion; returns plain table with fields
- `game/src/animations/running_effect.lua` — same conversion; returns plain table with fields
- `game/src/animations/enemy_effects.lua` — `.new` → `.create`, `self.activeEffects` → `state.activeEffects`; static methods (`getEffectData`, `getMovementOffset`) unchanged

Updated 7 caller files to replace `instance:method(args)` with `AnimationManager.method(instance, args)`:
- `game/src/core/game_state.lua` — `AnimationManager.new()` → `.create()`
- `game/src/entities/player.lua` — 2 call sites
- `game/src/ui/battle/battle_ui.lua` — 2 call sites, added import
- `game/src/systems/pet_system.lua` — 3 call sites, added import
- `game/src/ui/pet_ui.lua` — 1 call site, added import
- `game/npcs/npc_manager.lua` — 5 call sites, added import
- `game/src/systems/battle/battle_system.lua` — 1 call site, added import

## Impact Surface

- All callers must use `AnimationManager.method(state, ...)` instead of `instance:method(...)`
- `AnimationManager.new()` → `AnimationManager.create()`
- `EnemyEffects.new()` → `EnemyEffects.create()`

## Notes

- `BreathingEffect` and `RunningEffect` have no external callers outside `animation_manager.lua`
- `EnemyEffects.create()` has no known external callers yet
