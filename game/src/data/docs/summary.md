# Data Module Summary

> Last updated: 2026-02-21 - Class & Skill databases

## Purpose
Static data definitions for classes and skills.

## Files

| File | Description |
|------|-------------|
| `class_database.lua` | 6 classes with passive bonuses and base stats |
| `skill_database.lua` | 18 skills with upgrade formulas |

## class_database.lua

### Classes

| ID | Name | Category | Passive Bonuses |
|----|------|----------|-----------------|
| `dual_blade` | 双刀流 | warrior | +15% SPD, +10% CRIT |
| `great_sword` | 巨剑士 | warrior | +20% ATK, +5% CRIT |
| `blade_master` | 侠客 | warrior | +30% MaxHP, +20% DEF |
| `sealer` | 封印师 | mage | +25% DEF, +20% MaxHP, +15% SPD |
| `healer` | 治愈师 | mage | +20% DEF, +25% MaxHP, +10% SPD |
| `elementalist` | 元素师 | mage | +25% MATK, -20% SPD |

### API

```lua
ClassDatabase.getClass(classId)           -- Get class data
ClassDatabase.getCategory(categoryId)     -- Get category (warrior/mage)
ClassDatabase.getClassesByCategory(id)    -- Get all classes in category
ClassDatabase.getBaseStats(classId)       -- Get base stats with passives applied
ClassDatabase.applyPassiveBonus(classId, stats) -- Apply passive to stats table
```

## skill_database.lua

### Skill Types

| Type | Description |
|------|-------------|
| `single` | Single target damage |
| `aoe` | Area of effect damage |
| `heal` | Restore HP |
| `seal` | Apply status effect (bind/silence/confusion) |

### Upgrade Formulas

```lua
-- Unlock costs
Tier 1: 0 (free)
Tier 2: 100 Spirit Crystals
Tier 3: 250 Spirit Crystals

-- Upgrade cost (unlimited levels)
cost = 40 × level × (1 + 0.08 × level)

-- Effect bonus
multiplier = base × (1 + 0.03 × (level - 1))
```

### API

```lua
SkillDatabase.getSkill(skillId)           -- Get skill data
SkillDatabase.getSkillsByClass(classId)   -- Get all skills for class
SkillDatabase.getUpgradeCost(level)       -- Calculate upgrade cost
SkillDatabase.getUnlockCost(tier)         -- Get unlock cost by tier
SkillDatabase.getEffectMultiplier(level)  -- Get damage/heal multiplier
SkillDatabase.getEffectiveDamage(skill, level) -- Get scaled damage
SkillDatabase.getEffectiveHealPercent(skill, level) -- Get scaled heal %
SkillDatabase.getTargetCount(skill)       -- Get min/max targets
SkillDatabase.getSkillTierName(tier)      -- Get tier name (初级/中级/高级)
```

## Related Documentation

- [CLASS_SKILL_SYSTEM.md](../../docs/CLASS_SKILL_SYSTEM.md) - Full system documentation
