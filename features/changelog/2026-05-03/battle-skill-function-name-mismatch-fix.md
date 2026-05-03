# 游戏核心系统 camelCase/snake_case 函数名全面修正

## Context

跨系统的三轮流审查发现大量函数名命名风格不一致问题：多个系统模块定义 snake_case 函数，但 UI 和核心调用方使用 camelCase。Lua 中调用不存在的函数返回 `nil` 不报错，导致战斗、技能、装备、聊天、奖励等多个系统静默失效。通过三轮审查逐步发现并修复。

## 第一轮修复 — 战斗/技能核心（combat + skill）

### combat_utils.lua
- 添加 3 个 camelCase 别名：`take_damageMutating`, `healMutating`, `calculate_damageMutating`

### skill_panel.lua
- `getAvailableSkills`, `getLockedSkills` → `get_available_skills`, `get_locked_skills`
- `upgradeSkill`, `unlockSkill` → `upgrade_skill`, `unlock_skill`

### battle_system.lua
- `getPreferredCrystalType` → `get_preferred_crystal_type`
- `getSkill` → `get_skill`
- `getAvailableSkills` → `get_available_skills`

### skill_system.lua
- `get_skillTierName` → `get_skill_tier_name`

### companion_system.lua
- 修复 `defPercent` 计算中 `enhanceBonus.defense` 重复累加

## 第二轮修复 — 战斗流程 + 聊天 + 奖励

### game_state.lua
- `setSpiritCrystalSystem` → `set_spirit_crystal_system`
- `isActive` → `is_active`
- `getState` → `get_state`

### chat_system.lua
- 添加 6 个 camelCase 别名：`isInputting`, `startInput`, `endInput`, `addInputChar`, `removeInputChar`, `getInputText`

### spirit_crystal_system.lua
- 添加 `generateDrop` 别名

## 第三轮修复 — 装备 + 背包 + 队伍 + 存档

### unified_menu.lua（13 处）
- `getEquipped` → `get_equipped` (2处)
- `equipFromInventory` → `equip_from_inventory` (2处)
- `unequipToInventory` → `unequip_to_inventory`
- `getMaxSlots` → `get_max_slots`
- `getPartyName` → `get_party_name`
- `syncPlayerToCharacter` → `sync_player_to_character` (6处)

### equipment_ui.lua
- `EquipmentSlots.ARMOR` → `EquipmentSlots.CLOTHES`
- 补充 `HAT`、`SHOES` 槽位
- `getEquipped` → `get_equipped`

### inventory_ui.lua
- `getAllSlots` → `get_all_slots`
- `getMaxSlots` → `get_max_slots`

### party_ui.lua
- `getPartyName` → `get_party_name`

## Impact Surface

| 影响系统 | 修复前 | 修复后 |
|---------|--------|--------|
| 战斗流程 | 0 帧结束/永远逃跑 | 正常回合制 |
| 攻击/伤害 | 不生效 | 正常计算 |
| 技能 UI | 完全不可用 | 正常运作 |
| 战斗技能 | 无技能列表 | 正常显示/释放 |
| 战斗奖励 | 不掉落灵晶 | 正常生成 |
| 装备强化 | 报"未初始化" | 正常操作 |
| 装备面板 | 只显示 Weapon/Necklace，CLOTHES 写为 ARMOR | 5 槽位完整 |
| 装备操作(统一菜单) | 穿/脱失效 | 正常工作 |
| 背包容量 | 显示 0 | 正常显示 30 |
| 队伍名 | 显示 nil | 正常显示 |
| 数据存档 | 物品变动后不保存 | 正常同步 |
| 聊天输入 | 退格/发送/过滤失效 | 正常 |

## Related Files

- `game/src/core/game_state.lua` — 3 处修正
- `game/src/systems/battle/battle_system.lua` — 3 处修正
- `game/src/systems/combat_utils.lua` — 3 别名
- `game/src/systems/chat_system.lua` — 6 别名
- `game/src/systems/spirit_crystal_system.lua` — 1 别名
- `game/src/systems/skill_system.lua` — 1 处修正
- `game/src/systems/companion_system.lua` — 1 处修正
- `game/src/ui/skill_panel.lua` — 4 处修正
- `game/src/ui/unified_menu.lua` — 13 处修正
- `game/src/ui/equipment_ui.lua` — 3 处修正 + 2 槽位
- `game/src/ui/inventory_ui.lua` — 2 处修正
- `game/src/ui/party_ui.lua` — 1 处修正
