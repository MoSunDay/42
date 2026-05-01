# Class and Skill System Documentation

> Last updated: 2026-02-21 - New class/skill system with infinite leveling

## Overview

The class and skill system provides character progression through:
- **6 Classes** with unique passive bonuses and skill sets
- **18 Skills** with unlimited leveling via Spirit Crystals
- **3-Step Character Creation** flow

## Classes

### Warrior Category

| Class | Description | Passive Bonuses |
|-------|-------------|-----------------|
| **Dual Blade** | Physical AOE + single target hybrid | +15% SPD, +10% CRIT |
| **Great Sword** | Single target physical burst | +20% ATK, +5% CRIT |
| **Blade Master** | Physical AOE tank | +30% MaxHP, +20% DEF |

### Mage Category

| Class | Description | Passive Bonuses |
|-------|-------------|-----------------|
| **Sealer** | Control mage, high defense/HP/speed | +25% DEF, +20% MaxHP, +15% SPD |
| **Healer** | Healing support, high defense/HP/speed | +20% DEF, +25% MaxHP, +10% SPD |
| **Elementalist** | AOE magic, slowest but most targets | +25% MATK, -20% SPD |

## Skills

### Dual Blade Skills

| Skill | Tier | Type | Effect | Targets | MP |
|-------|------|------|--------|---------|-----|
| Whirlwind | 1 | AOE | 120% ATK | 2-3 | 15 |
| Shadow Blade | 2 | AOE | 150% ATK, +10% CRIT | 2-3 | 25 |
| Phantom Slash | 2 | Single | 200% ATK | 1 | 20 |
| Storm Blade | 3 | AOE | 180% ATK, +20% SPD buff | 2-3 | 35 |

### Great Sword Skills

| Skill | Tier | Type | Effect | Targets | MP |
|-------|------|------|--------|---------|-----|
| Heavy Strike | 1 | Single | 150% ATK | 1 | 12 |
| Mountain Breaker | 2 | Single | 220% ATK, -15% DEF | 1 | 25 |
| World Slash | 3 | Single | 350% ATK, +25% CRIT | 1 | 45 |

### Blade Master Skills

| Skill | Tier | Type | Effect | Targets | MP |
|-------|------|------|--------|---------|-----|
| Sweep | 1 | AOE | 100% ATK | 3 | 18 |
| Sword Aura | 2 | AOE | 130% ATK | 3 | 28 |
| Heaven Blade | 3 | AOE | 180% ATK, +10% DEF buff | 3 | 40 |

### Sealer Skills

| Skill | Tier | Type | Effect | Targets | MP |
|-------|------|------|--------|---------|-----|
| Bind Curse | 1 | Seal | Cannot act (1 turn) | 1 | 20 |
| Silence | 2 | Seal | Cannot use skills (2 turns) | 1 | 25 |
| Confusion | 3 | Seal | Random targeting (2 turns) | 1 | 35 |

### Healer Skills

| Skill | Tier | Type | Effect | Targets | MP |
|-------|------|------|--------|---------|-----|
| Heal | 1 | Heal | Restore 30% MaxHP | Self | 15 |
| Group Heal | 2 | Heal | Restore 20% MaxHP | All allies | 30 |
| Revival Light | 3 | Heal | Restore 50% HP + cleanse | Self | 45 |

### Elementalist Skills

| Skill | Tier | Type | Effect | Targets | MP |
|-------|------|------|--------|---------|-----|
| Fire Storm | 1 | AOE | 140% MATK, burn (2 turns) | 3-4 | 30 |
| Ice Fall | 2 | AOE | 120% MATK, -20% SPD | 3-4 | 28 |
| Thunder Strike | 3 | AOE | 160% MATK, 30% stun | 3-4 | 40 |

## Spirit Crystal Costs

### Unlock Costs

| Tier | Cost |
|------|------|
| 1 | Free (auto-unlock) |
| 2 | 100 Spirit Crystals |
| 3 | 250 Spirit Crystals |

### Upgrade Costs (Unlimited Levels)

Formula: `cost = 40 × level × (1 + 0.08 × level)`

| Current Level | Upgrade Cost |
|--------------|--------------|
| 1 → 2 | 43 |
| 5 → 6 | 280 |
| 10 → 11 | 760 |
| 20 → 21 | 2,480 |
| 50 → 51 | 10,400 |

### Effect Scaling

- Each level adds **+3%** skill effectiveness
- Formula: `multiplier = base × (1 + 0.03 × (level - 1))`

| Level | Effect Bonus |
|-------|--------------|
| 5 | +12% |
| 10 | +27% |
| 20 | +57% |
| 50 | +147% |

## Controls

| Context | Key | Action |
|----------|-----|--------|
| Exploration | `K` | Open skill panel |
| Skill Panel | `↑↓` | Select skill |
| Skill Panel | `Enter` | Unlock/Upgrade skill |
| Skill Panel | `Tab` | Switch tab (unlocked/locked) |
| Skill Panel | `ESC` | Close panel |
| Battle | Select "Skill" | Open skill selection |
| Battle Skill List | `↑↓` | Select skill |
| Battle Skill List | `Enter` | Use skill |
| Battle Skill List | `ESC` | Cancel |

## File Structure

```
src/
├── data/
│   ├── class_database.lua    # 6 classes + passive bonuses
│   └── skill_database.lua    # 18 skills + upgrade formulas
├── systems/
│   ├── skill_system.lua      # Unlock/upgrade/use logic
│   └── battle/
│       └── battle_executor.lua  # Skill execution in combat
└── ui/
    └── skill_panel.lua       # Skill management UI

account/
├── character_data.lua        # Extended: classId/mp/skills
└── character_select_ui.lua   # 3-step creation (name→class→appearance)
```

## Data Structures

### Character Data Extensions

```lua
player = {
    -- New attributes
    classId = "dual_blade",
    mp = 100,
    maxMp = 100,
    magicAttack = 10,
    
    -- Skill system
    skills = {
        { id = "whirlwind", level = 1, unlocked = true },
        { id = "shadow_blade", level = 0, unlocked = false },
        -- ...
    },
    skillCrystals = 0,  -- Currency for skill upgrades
    critBonus = 0,      -- From class passive
}
```

### Skill Data Format

```lua
{
    id = "whirlwind",
    name = "旋风斩",
    description = "旋转双刀，攻击多个敌人",
    type = "aoe",           -- single/aoe/heal/seal
    tier = 1,               -- 1/2/3
    damageMultiplier = 1.2, -- Base damage
    targets = {2, 3},       -- Min-max targets
    mpCost = 15,
    useClass = "physical",  -- physical/magic
    classId = "dual_blade",
}
```

## Integration Points

1. **Character Creation**: `character_select_ui.lua` - 3-step flow
2. **Battle System**: `battle_system.lua` + `battle_executor.lua`
3. **Save/Load**: `game_state.lua:syncPlayerToCharacter()`
4. **UI Rendering**: `render_system.lua` + `skill_panel.lua`
5. **Input Handling**: `input_system.lua`
