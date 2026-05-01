# Battle System Module Summary

> Last updated: 2026-02-21 - Skill system integration

## Purpose
Turn-based combat system with AI, animations, turn timer, and skill execution.

## Files

| File | Description |
|------|-------------|
| `battle_system.lua` | Main battle controller with skill support |
| `battle_ai.lua` | Enemy and auto-battle AI |
| `battle_animation.lua` | Attack/damage animations |
| `battle_executor.lua` | Action execution (attack/skill/heal/seal) |
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
- `BattleSystem:selectSkill(skillId)` - Select skill for use
- `BattleSystem:getAvailableSkills()` - Get player's unlocked skills
- `BattleSystem.STATE` - State constants

### battle_executor.lua
- `BattleExecutor.executePlayerAttack(battleSystem, target, index)` - Basic attack
- `BattleExecutor.executePlayerSkill(battleSystem, skillId, targets, indices)` - Use skill
- `BattleExecutor.executePlayerDefend(battleSystem)` - Defend action
- `BattleExecutor.executePlayerEscape(battleSystem, state)` - Escape attempt
- `BattleExecutor.selectSkillTargets(battleSystem, skillId)` - Auto-select targets
- `BattleExecutor.executeHealSkill(battleSystem, skill, level)` - Healing skill
- `BattleExecutor.executeSealSkill(battleSystem, skill, level, targets, indices)` - Seal skill
- `BattleExecutor.executeDamageSkill(battleSystem, skill, level, targets, indices)` - Damage skill

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
| `skill` | Use skill (opens skill selection) |
| `defend` | Reduce damage taken (+25% DEF) |
| `escape` | Attempt to flee (50% chance) |

## Turn Timer
- 90 seconds per turn
- Auto-defend if timeout

## Related Documentation

- [CLASS_SKILL_SYSTEM.md](../../../docs/CLASS_SKILL_SYSTEM.md) - Skill database and mechanics
