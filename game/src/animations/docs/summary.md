# Animations Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Animation effects for characters and enemies.

## Files

| File | Description |
|------|-------------|
| `animation_manager.lua` | Central animation coordinator |
| `breathing_effect.lua` | Idle breathing animation |
| `running_effect.lua` | Running bob animation |
| `enemy_effects.lua` | Enemy-specific effects |

## Key APIs

### animation_manager.lua
- `AnimationManager.new()` - Create manager
- `AnimationManager:createAnimationSet(id)` - Create animation for entity
- `AnimationManager:updateEntity(id, dt, isMoving)` - Update animation
- `AnimationManager:getTransform(id)` - Get scale/offset for effect

### breathing_effect.lua
- `BreathingEffect.update(time)` - Calculate breathing scale
- Returns scaleX, scaleY for subtle idle movement

### running_effect.lua
- `RunningEffect.update(time)` - Calculate running bob
- Returns offsetY for up/down movement

### enemy_effects.lua
- `EnemyEffects.shake(intensity, time)` - Damage shake
- `EnemyEffects.flash(time)` - Hit flash effect
