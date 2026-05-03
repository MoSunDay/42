# 战斗逻辑深化修复 + LÖVE 启动引导

## Context

第四轮深度审查发现 5 类逻辑级 Bug，涉及战斗状态机、AI、属性计算和运行时崩溃。同时修复 `love .` 从项目根目录无法启动的问题。

## LÖVE 启动引导

- 创建 `main.lua`（根目录）：调整 `package.path` 为 `game/` 子目录，委托加载 `game/main.lua`
- 创建 `conf.lua`（根目录）：委托 `game/conf.lua` 配置
- 修复后 `love .` 从项目根目录启动不再报 "No code to run"

## Bug 1: 装备强化运行时崩溃

`equipment_system.lua:141,153` 向 `SpiritCrystalSystem.can_enhance(state, currentLevel)` 传入了 `crystalType`（字符串）作为 `currentLevel` 参数，导致 `"crimson" + 1` 的算术运算崩溃。

修复：移除多余的 `crystalType` 参数。

## Bug 2: 装备属性重算丢失职业被动 HP 加成

`player.lua:344` `update_stats_with_equipment` 中 `maxHp = baseHp + equipHp`，但 `baseHp` 始终为 100（Player.create 初始化）。侠客 +30% HP、治愈师 +25% HP 等被动每次更换装备即被清零。

修复：`game_state.lua` 初始化时写入 `state.player.baseHp = character.maxHp`，确保被动加成纳入 baseHp。

## Bug 3: 技能控制效果完全无效

`battle_system.lua` 的 `next_turn` 仅清除 `isDefending`。DoT、debuff、stun、seal、selfBuff 等 8 种控制/辅助效果施加后从未被处理，`battle_ai` 也不检查状态。

修复：
- 新增 `process_status_effects` 函数：DoT 伤害 tick、debuff/buff 持续衰减、stun/seal 解除
- `battle_ai.enemy_action` 检查 `stunned`/`sealed` 时跳过行动

## Bug 4: 玩家死亡后剩余敌人继续攻击

首个敌人击杀玩家后，animation callback 仅记录日志，`end_battle` 等到 `next_turn` 才执行，剩余敌人仍依次攻击已死亡玩家。

修复：`battle_executor.lua:117` 在玩家死亡回调中直接调用 `end_battle(state, DEFEAT)`。

## Bug 5: get_hp_percent 除零 Crash 风险

`player.lua:313` 和 `enemy.lua:101` 直接 `state.hp / state.maxHp`，`maxHp = 0` 时返回 NaN。`CombatUtils` 中已有守卫但 Entity 层遗漏。

修复：添加 `maxHp <= 0` 前置守卫。

## 影响范围

| 影响 | 修复前 | 修复后 |
|------|--------|--------|
| 装备强化 | 点击强化 → Lua 崩溃 | 正常执行 |
| 职业 HP 被动 | 换装备后清零 | 始终生效 |
| 毒雾/暗影侵蚀 | DoT 施放即遗忘 | 每回合 tick 伤害 |
| 束缚/沉默/混乱 | 封印无效 | 敌人被封印时防御/跳过 |
| 眩晕 | 眩晕无效 | 敌人眩晕回合防御 |
| 疾风步/雷铠 | buff 施加即忘 | 持续生效至过期 |
| 玩家死亡 | 继续挨打 | 立即结束战斗 |
| `love .` | No code to run | 正常启动 |
