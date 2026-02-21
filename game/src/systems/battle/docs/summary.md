# Battle System Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Turn-based combat system with AI, animations, and turn timer.

## Files

| File | Description |
|------|-------------|
| `battle_system.lua` | Main battle controller |
| `battle_ai.lua` | Enemy and auto-battle AI |
| `battle_animation.lua` | Attack/damage animations |
| `battle_executor.lua` | Action execution logic |
| `battle_log.lua` | Battle message log |
| `battle_state.lua` | State constants |
| `battle_timer.lua` | Turn timer (90 seconds) |
| `battle_utils.lua` | Helper functions |

## Battle Flow

```
INTRO -> PLAYER_TURN -> EXECUTING -> ENEMY_TURN -> (repeat)
                              |
                              v
                         VICTORY / DEFEAT / ESCAPED
```

## Key APIs

### battle_system.lua
- `BattleSystem.new(player, audioSystem, animationManager)`
- `BattleSystem:startBattle(enemyCount)` - Start battle (1-3 enemies)
- `BattleSystem:selectAction(action, targetIndex)` - Player action
- `BattleSystem:toggleAutoBattle()` - Toggle auto mode
- `BattleSystem:getState()` - Current state
- `BattleSystem.STATE` - State constants

### battle_ai.lua
- `BattleAI.enemyAction(enemy, player)` - Enemy AI decision
- `BattleAI.autoPlayerAction(battleSystem)` - Auto-battle AI

### battle_state.lua
- `INTRO` - Battle start animation
- `PLAYER_TURN` - Waiting for player input
- `EXECUTING` - Player action animation
- `ENEMY_TURN` - Enemy action animation
- `VICTORY` / `DEFEAT` / `ESCAPED` - End states

## Player Actions

| Action | Description |
|--------|-------------|
| `attack` | Attack selected enemy |
| `defend` | Reduce damage taken (+25% DEF) |
| `escape` | Attempt to flee (50% chance) |

## Turn Timer
- 90 seconds per turn
- Auto-defend if timeout
