---
name: game-rpg
description: Play the 42 turn-based RPG game via headless UDP client. Login, explore, battle, and manage characters.
version: 1.0.0
platforms: [macos, linux]
metadata:
  hermes:
    tags: [gaming, rpg, game-agent, automation]
    requires_toolsets: [terminal]
---

# 42 RPG Game Agent Skill

## When to Use

When the user asks you to play the game, check game status, manage characters, or perform any game-related action.

## Quick Reference

All commands use the game client CLI at `${HERMES_SKILL_DIR}/scripts/game_client.py`.

The server must be running at `127.0.0.1:9000` (UDP) before connecting.

## Procedure

### 1. Login Flow

```
# Connect and login (or register)
python ${HERMES_SKILL_DIR}/scripts/game_client.py login --user <username> --pass <password>

# If new user, register first
python ${HERMES_SKILL_DIR}/scripts/game_client.py register --user <username> --pass <password>
```

### 2. Character Management

```
# List available characters
python ${HERMES_SKILL_DIR}/scripts/game_client.py list-characters

# Create a new character (6 classes: dual_blade, great_sword, blade_master, sealer, healer, elementalist)
python ${HERMES_SKILL_DIR}/scripts/game_client.py create-character --name "Hero" --class dual_blade

# Select a character to enter the game world
python ${HERMES_SKILL_DIR}/scripts/game_client.py select-character --id <character_id>
```

### 3. Check Game State

```
# Get current state (mode, player stats, position, battle status)
python ${HERMES_SKILL_DIR}/scripts/game_client.py state
```

State returns:
- `mode`: "disconnected" | "login" | "character_select" | "exploration" | "battle"
- `player`: name, level, hp, maxHp, mp, maxMp, classId
- `position`: x, y, mapId
- `battle`: enemy list, turn info (if in battle)

### 4. Exploration

```
# Move character to coordinates
python ${HERMES_SKILL_DIR}/scripts/game_client.py move --x 500 --y 300

# Random encounters trigger automatically when walking in exploration mode
# After encounter, mode changes to "battle"
```

### 5. Battle Actions

```
# Check if in battle
python ${HERMES_SKILL_DIR}/scripts/game_client.py state

# Attack a specific enemy
python ${HERMES_SKILL_DIR}/scripts/game_client.py battle --action attack --target enemy_1

# Use a skill (skill IDs: whirlwind, heavy_strike, heal, fire_storm, etc.)
python ${HERMES_SKILL_DIR}/scripts/game_client.py battle --action skill --skill-id whirlwind

# Use skill with specific targets
python ${HERMES_SKILL_DIR}/scripts/game_client.py battle --action skill --skill-id fire_storm --targets enemy_1 enemy_2

# Defend (reduce incoming damage)
python ${HERMES_SKILL_DIR}/scripts/game_client.py battle --action defend

# Flee from battle
python ${HERMES_SKILL_DIR}/scripts/game_client.py battle --action flee
```

### 6. Auto Battle

```
# Run auto-battle with AI strategy
python ${HERMES_SKILL_DIR}/scripts/auto_battle.py --strategy balanced

# Strategies: aggressive (low heal threshold), balanced (default), defensive (high heal threshold)
python ${HERMES_SKILL_DIR}/scripts/auto_battle.py --strategy aggressive --max-turns 50
```

### 7. Save and Logout

```
# Save character progress
python ${HERMES_SKILL_DIR}/scripts/game_client.py save

# Send chat message
python ${HERMES_SKILL_DIR}/scripts/game_client.py chat --msg "Hello world"

# Logout
python ${HERMES_SKILL_DIR}/scripts/game_client.py logout
```

## Game State Machine

```
disconnected → connect → login
login → login_success → character_select
login → register_success → character_select
character_select → select_character → exploration
exploration → encounter → battle
battle → battle_end → exploration
exploration → logout → disconnected
```

## Battle AI Decision Flow

1. Check `state` - is mode "battle"?
2. Get player HP%, MP, class
3. Count alive enemies
4. Apply strategy from BATTLE_STRATEGY.md:
   - HP < 30% → Heal if healer, else Defend
   - Enemies ≥ 2 → Use AOE skill
   - MP > 50% → Use strongest available skill
   - Otherwise → Basic attack
5. Execute action
6. Repeat until mode != "battle"

## Class Quick Guide

| Class | Role | Best Against | Key Skills |
|-------|------|-------------|------------|
| Dual Blade | AOE DPS | Groups | Whirlwind, Storm Blade |
| Great Sword | Single Target | Bosses | World Slash, Mountain Breaker |
| Blade Master | AOE Tank | Groups | Heaven Blade, Sword Aura |
| Sealer | Control | Dangerous enemies | Confusion, Silence |
| Healer | Support | Sustain | Group Heal, Revival Light |
| Elementalist | AOE Magic | Groups | Thunder Strike, Fire Storm |

## Pitfalls

- The server uses UDP with RUDP reliability. Commands may timeout if server is down.
- Always check `state` before actions to verify current mode.
- Battle actions only work when mode is "battle".
- Move only works when mode is "exploration".
- The game auto-saves on certain events, but manual save is recommended after progress.
- Each login creates a new session. Previous sessions get kicked if same character is selected.

## Verification

After login, run `state` to verify:
- `connected: true`
- `mode` matches expected state
- `player` data is present (after character select)
