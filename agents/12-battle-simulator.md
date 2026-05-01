# 12. 战斗模拟器 (Battle Simulator)

## 概述

战斗模拟器是一个独立的模块，用于在无UI环境下模拟战斗，用于：
- 技能数值平衡调试
- 职业强度对比测试
- 战斗机制验证

## 位置

`game/src/systems/battle_simulator/`

## 模块结构

```
battle_simulator/
├── init.lua              # 主入口，BattleSimulator 类
├── sim_unit.lua          # 模拟战斗单位（玩家职业/敌人）
├── sim_entity.lua        # 通用战斗实体
├── skill_database.lua    # 技能数据库（18个技能）
├── simulated_combatant.lua # 战斗者实体
└── simulation_engine.lua   # 模拟引擎
```

## 使用方法

### 基本用法

```lua
local BattleSimulator = require("src.systems.battle_simulator")

local sim = BattleSimulator.new()

sim:addUnitToTeamA("dual_blade", 1, "测试角色")
sim:addUnitToTeamB("orc_warrior", 1, "兽人战士")

local result = sim:run()
print("Winner:", result.winner)
print("Turns:", result.turns)
```

### 批量测试

```lua
local sim = BattleSimulator.new()
sim:addUnitToTeamA("healer", 5)
sim:addUnitToTeamB("vampire_lord", 3)

local results = sim:runMultiple(100)
print(string.format("胜率: %.1f%%", results.teamAWins / results.iterations * 100))
print(string.format("平均回合: %.1f", results.totalTurns / results.iterations))
```

### 职业对比测试

```lua
local ClassDatabase = require("src.data.class_database")
local BattleSimulator = require("src.systems.battle_simulator")

for classId, class in pairs(ClassDatabase.CLASSES) do
    local sim = BattleSimulator.new()
    sim:addUnitToTeamA(classId, 5)
    sim:addUnitToTeamB("demon", 3)
    
    local results = sim:runMultiple(50)
    print(string.format("%s vs Demon: %.1f%% 胜率",
        class.name, results.teamAWins / results.iterations * 100))
end
```

## 配置选项

```lua
sim.config.maxTurns = 100      -- 最大回合数
sim.config.logDetail = "none"  -- "none" | "normal" | "verbose"
```

## 技能数据库

18个技能已定义在 `skill_database.lua`:

| 职业 | 技能 |
|------|------|
| 双刀流 | 旋风斩、影刃、幻影斩、暴风剑 |
| 巨剑士 | 重击、破山击、天地斩 |
| 侠客 | 横扫、剑气、天剑 |
| 封印师 | 束缚咒、沉默、混乱 |
| 治愈师 | 治愈、群体治愈、复活之光 |
| 元素师 | 烈焰风暴、冰陨、雷击 |

## 技能效果公式

```lua
effect = baseEffect * statMod * levelBonus * variance

statMod = 1 + (attack or magicAttack) / 100
levelBonus = 1 + effectBonusPerLevel * (level - 1)
variance = 0.9 ~ 1.1
```

## API 参考

### BattleSimulator

| 方法 | 说明 |
|------|------|
| `new()` | 创建模拟器实例 |
| `addUnitToTeamA(classId, level, name)` | 添加玩家单位 |
| `addUnitToTeamB(enemyType, level, name)` | 添加敌人单位 |
| `run()` | 运行单次战斗 |
| `runMultiple(n)` | 运行n次战斗，返回统计 |
| `reset()` | 重置模拟器状态 |

### SimUnit

| 方法 | 说明 |
|------|------|
| `fromClass(classId, level, name)` | 从职业创建 |
| `fromEnemy(enemyType, level, name)` | 从敌人类型创建 |
| `fromStats(stats, name)` | 从自定义属性创建 |
| `takeDamage(damage)` | 受伤 |
| `heal(amount)` | 治疗 |
| `calculateDamage()` | 计算伤害 |

## 数值调试建议

1. **DPS测试**: 统计每回合平均伤害
2. **生存测试**: 统计受到的总伤害
3. **技能使用率**: 查看哪些技能被频繁/少用
4. **平衡目标**: 同级别职业 vs 同级别敌人，胜率 50-70%
