# Battle System Fixes v1.4.1

## 🐛 修复的问题

### 1. ✅ 第一个敌人死亡后无法攻击第二个敌人

**问题描述**：
- 击败第一个敌人后，无法选择或攻击第二个敌人
- 选中的目标索引没有自动调整

**修复方案**：
1. **自动目标调整**：在 `executePlayerAction()` 中添加逻辑，如果当前选中的敌人已死亡，自动选择第一个存活的敌人
2. **UI自动调整**：在 `BattleUI:draw()` 中添加逻辑，如果选中的敌人死亡，自动切换到下一个存活的敌人

**代码修改**：
```lua
-- battle_system.lua
-- 在攻击前检查目标是否存活
if target and not target:isAlive() then
    target = nil
    for i, enemy in ipairs(self.enemies) do
        if enemy:isAlive() then
            target = enemy
            targetIndex = i
            self.selectedTarget = i
            break
        end
    end
end
```

### 2. ✅ 支持鼠标点击选择敌人

**新功能**：
- 可以直接点击敌人来选择攻击目标
- 点击检测基于敌人的位置和半径（25像素）

**实现细节**：
```lua
-- input_system.lua
-- 在战斗模式下检测鼠标点击
for i, enemy in ipairs(enemies) do
    if enemy:isAlive() then
        local enemyX = w * 0.25 + (i - 1) * 120
        local enemyY = h * 0.35
        local radius = 25
        
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance <= radius then
            self.battleUI:setSelectedEnemy(i)
        end
    end
end
```

### 3. ✅ 修复回合制逻辑

**问题描述**：
- 敌人回合没有正确执行
- 玩家攻击后直接回到玩家回合，敌人没有机会攻击

**修复方案**：
1. **状态管理**：明确区分 `EXECUTING`（执行中）和 `ENEMY_TURN`（敌人回合）状态
2. **回合切换**：玩家行动完成后 → 敌人回合 → 玩家回合
3. **动画等待**：等待攻击动画完成后再切换回合

**修复的流程**：
```
玩家选择行动
  ↓
EXECUTING 状态（播放玩家攻击动画）
  ↓
动画完成 → nextTurn()
  ↓
ENEMY_TURN 状态（敌人依次攻击）
  ↓
敌人行动完成 → nextTurn()
  ↓
PLAYER_TURN 状态（玩家回合）
```

**代码修改**：
```lua
-- battle_system.lua
function BattleSystem:nextTurn()
    -- Reset defending status
    self.player.isDefending = false
    for _, enemy in ipairs(self.enemies) do
        enemy.isDefending = false
    end
    
    -- Switch to enemy turn
    if self.state == BATTLE_STATE.EXECUTING then
        self:executeEnemyTurn()
    elseif self.state == BATTLE_STATE.ENEMY_TURN then
        -- Enemy turn finished, back to player turn
        self.turn = self.turn + 1
        self.state = BATTLE_STATE.PLAYER_TURN
    end
end
```

---

## 🎮 改进的功能

### 1. 智能目标选择

**自动调整**：
- 当前选中的敌人死亡时，自动选择下一个存活的敌人
- 避免玩家手动切换目标的麻烦

**实现位置**：
- `battle_system.lua` - 攻击执行前检查
- `battle_ui.lua` - 绘制时自动调整

### 2. 鼠标交互

**点击选择**：
- 直接点击敌人图标选择目标
- 更直观的操作方式
- 点击范围：敌人中心25像素半径

**视觉反馈**：
- 选中的敌人有黄色高亮边框
- 点击后立即显示选中效果

### 3. 回合制完整性

**正确的回合流程**：
1. 玩家回合：选择行动 → 执行 → 播放动画
2. 敌人回合：所有存活敌人依次行动 → 播放动画
3. 循环直到战斗结束

**状态转换**：
```
INTRO (1.5s)
  ↓
PLAYER_TURN (等待玩家输入)
  ↓
EXECUTING (播放玩家动画)
  ↓
ENEMY_TURN (敌人依次攻击)
  ↓
PLAYER_TURN (下一回合)
```

---

## 📝 修改的文件

### 1. `src/systems/battle_system.lua`

**修改内容**：
- `executePlayerAction()` - 添加目标存活检查和自动调整
- `executeEnemyTurn()` - 修改状态为 `ENEMY_TURN`
- `nextTurn()` - 重写回合切换逻辑

**新增逻辑**：
```lua
-- 自动查找存活的敌人
if target and not target:isAlive() then
    for i, enemy in ipairs(self.enemies) do
        if enemy:isAlive() then
            target = enemy
            targetIndex = i
            break
        end
    end
end
```

### 2. `src/systems/input_system.lua`

**修改内容**：
- `mousepressed()` - 添加战斗模式下的鼠标点击处理

**新增功能**：
```lua
-- 战斗中点击敌人选择目标
if mode == "battle" then
    if button == 1 then
        -- 检测点击的敌人
        for i, enemy in ipairs(enemies) do
            if enemy:isAlive() then
                -- 距离检测
                if distance <= radius then
                    self.battleUI:setSelectedEnemy(i)
                end
            end
        end
    end
end
```

### 3. `src/ui/battle_ui.lua`

**修改内容**：
- `draw()` - 添加自动调整选中敌人的逻辑
- `navigateLeft()` / `navigateRight()` - 改进边界检查
- `setSelectedEnemy()` - 新增方法，支持鼠标点击设置

**新增方法**：
```lua
function BattleUI:setSelectedEnemy(index)
    self.selectedEnemy = index
end
```

---

## 🎯 测试验证

### 测试场景 1：多敌人战斗

**步骤**：
1. 触发战斗（遇到2-3个敌人）
2. 攻击第一个敌人直到死亡
3. 观察是否自动切换到第二个敌人
4. 继续攻击第二个敌人

**预期结果**：
- ✅ 第一个敌人死亡后，自动选中第二个敌人
- ✅ 可以正常攻击第二个敌人
- ✅ 所有敌人死亡后显示胜利

### 测试场景 2：鼠标点击选择

**步骤**：
1. 进入战斗
2. 用鼠标点击不同的敌人
3. 观察选中状态变化
4. 确认攻击后攻击正确的目标

**预期结果**：
- ✅ 点击敌人后，黄色边框移动到该敌人
- ✅ 攻击时攻击选中的敌人
- ✅ 只能点击存活的敌人

### 测试场景 3：回合制流程

**步骤**：
1. 进入战斗
2. 选择攻击
3. 观察玩家攻击动画
4. 观察敌人反击
5. 确认回到玩家回合

**预期结果**：
- ✅ 玩家攻击后播放动画
- ✅ 动画完成后敌人开始攻击
- ✅ 所有敌人攻击完成后回到玩家回合
- ✅ 回合指示器正确显示 "Your Turn" / "Enemy Turn"

---

## 🔧 技术细节

### 目标选择算法

```lua
-- 1. 检查当前目标是否存活
if target and not target:isAlive() then
    -- 2. 查找第一个存活的敌人
    for i, enemy in ipairs(self.enemies) do
        if enemy:isAlive() then
            target = enemy
            targetIndex = i
            self.selectedTarget = i
            break
        end
    end
end
```

### 鼠标点击检测

```lua
-- 计算点击位置到敌人中心的距离
local dx = x - enemyX
local dy = y - enemyY
local distance = math.sqrt(dx * dx + dy * dy)

-- 如果距离小于半径，则命中
if distance <= radius then
    -- 选中该敌人
end
```

### 回合状态机

```
State: INTRO
  Timer: 1.5s
  Next: PLAYER_TURN

State: PLAYER_TURN
  Wait: User input
  Next: EXECUTING (on action selected)

State: EXECUTING
  Wait: Animation complete
  Next: ENEMY_TURN (via nextTurn)

State: ENEMY_TURN
  Action: All enemies attack
  Wait: Animation complete + timer
  Next: PLAYER_TURN (via nextTurn)
```

---

## 📊 改进效果

### 用户体验提升

**之前**：
- ❌ 第一个敌人死后无法继续战斗
- ❌ 只能用键盘选择敌人
- ❌ 敌人不会反击

**现在**：
- ✅ 自动切换到下一个存活敌人
- ✅ 可以用鼠标点击选择敌人
- ✅ 完整的回合制战斗流程
- ✅ 敌人会在自己的回合攻击玩家

### 操作便利性

**键盘操作**：
- ←/→ 或 A/D：切换敌人
- ↑/↓ 或 W/S：切换行动
- Enter/Space：确认

**鼠标操作**：
- 点击敌人：选择目标
- 点击行动菜单：选择行动（未来可实现）

---

## 🎉 总结

### 修复的核心问题

1. **目标选择** - 敌人死亡后自动切换目标
2. **鼠标交互** - 支持点击选择敌人
3. **回合制** - 完整的玩家回合 → 敌人回合循环

### 代码质量

- ✅ 所有修改通过语法检查
- ✅ 逻辑清晰，易于维护
- ✅ 添加了详细的注释

### 游戏体验

- ✅ 战斗流程完整
- ✅ 操作更加直观
- ✅ 回合制感觉明显

---

**版本**: v1.4.1  
**日期**: 2025-10-11  
**状态**: ✅ 修复完成并测试通过  

**修改代码**: ~80行  
**新增功能**: 鼠标点击选择敌人  
**修复问题**: 3个核心战斗问题  

---

**现在战斗系统完全可用了！** 🎮⚔️

