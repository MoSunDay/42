# 技术细节文档

## 目录
1. [架构设计](#架构设计)
2. [核心系统详解](#核心系统详解)
3. [数据流](#数据流)
4. [状态管理](#状态管理)
5. [性能优化](#性能优化)
6. [常见问题](#常见问题)

---

## 架构设计

### MVC-like 架构

```
┌─────────────────────────────────────────┐
│              main.lua                    │
│         (游戏入口，LÖVE回调)              │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────▼─────────┐
        │   GameState       │
        │  (核心状态管理)    │
        └─────────┬─────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼───┐   ┌────▼────┐   ┌───▼────┐
│Systems│   │Entities │   │   UI   │
│(逻辑) │   │(数据)   │   │(视图)  │
└───────┘   └─────────┘   └────────┘
```

### 系统分层

1. **Core Layer（核心层）**
   - `game_state.lua` - 游戏状态机
   - `camera.lua` - 相机系统

2. **System Layer（系统层）**
   - `battle_system.lua` - 战斗逻辑
   - `input_system.lua` - 输入处理
   - `render_system.lua` - 渲染管理
   - `equipment_system.lua` - 装备管理
   - `party_system.lua` - 组队管理
   - `chat_system.lua` - 聊天管理

3. **Entity Layer（实体层）**
   - `player.lua` - 玩家实体
   - `enemy.lua` - 敌人实体
   - `encounter_zone.lua` - 遇敌区域

4. **UI Layer（UI层）**
   - `hud.lua` - HUD显示
   - `battle_ui.lua` - 战斗界面
   - `unified_menu.lua` - 统一菜单

---

## 核心系统详解

### 1. 游戏状态机 (GameState)

#### 状态定义
```lua
GAME_MODE = {
    LOGIN = "login",              -- 登录界面
    CHARACTER_SELECT = "character_select",  -- 角色选择
    EXPLORATION = "exploration",  -- 探索模式
    BATTLE = "battle"            -- 战斗模式
}
```

#### 状态转换流程
```
LOGIN → CHARACTER_SELECT → EXPLORATION ⇄ BATTLE
```

#### 关键方法
- `initializeWorld(character)` - 初始化游戏世界
- `update(dt)` - 更新游戏逻辑
- `switchMode(mode)` - 切换游戏模式
- `startBattle()` - 进入战斗
- `endBattle()` - 结束战斗

---

### 2. 战斗系统 (BattleSystem)

#### 战斗状态机
```lua
BATTLE_STATE = {
    INTRO = "intro",          -- 战斗开场
    PLAYER_TURN = "player",   -- 玩家回合
    EXECUTING = "executing",  -- 执行动作
    ENEMY_TURN = "enemy",     -- 敌人回合
    VICTORY = "victory",      -- 胜利
    DEFEAT = "defeat",        -- 失败
    ESCAPED = "escaped"       -- 逃跑
}
```

#### 战斗流程
```
INTRO (2秒)
    ↓
PLAYER_TURN (等待玩家选择)
    ↓
EXECUTING (执行动作动画)
    ↓
ENEMY_TURN (敌人行动)
    ↓
检查胜负 → 继续 or 结束
```

#### 回合计时器
- 每回合90秒
- 超时自动执行防御
- 显示倒计时条

#### 自动战斗
- 开启：点击 "Auto Battle"
- 取消：点击 "Cancel Auto"
- 逻辑：优先攻击HP最低的敌人

---

### 3. 地图系统 (MapManager)

#### 地图数据结构
```lua
{
    id = "town_01",
    name = "Newbie Village",
    width = 3200,
    height = 2400,
    tileSize = 64,
    backgroundColor = {0.3, 0.6, 0.35},
    spawnPoints = {
        {x = 1600, y = 1200, name = "Main Spawn"}
    },
    encounterZones = {
        {x = 800, y = 600, radius = 30, enemyTypes = {"slime"}}
    },
    buildings = {
        {x = 1000, y = 800, width = 200, height = 150, name = "Inn"}
    }
}
```

#### 地图加载流程
1. `MapManager.loadMap(mapId)` - 加载地图配置
2. `MapData.new(config)` - 创建地图实例
3. 初始化遇敌区域
4. 设置玩家出生点

#### 碰撞检测
- 使用瓦片坐标系统
- `isCollision(x, y)` 检查碰撞
- 支持建筑物碰撞

---

### 4. 相机系统 (Camera)

#### 功能
- 跟随玩家移动
- 平滑插值（lerp）
- 边界限制
- 坐标转换

#### 关键方法
```lua
camera:follow(x, y, dt)           -- 跟随目标
camera:toWorld(screenX, screenY)  -- 屏幕坐标→世界坐标
camera:toScreen(worldX, worldY)   -- 世界坐标→屏幕坐标
camera:apply()                    -- 应用变换
camera:reset()                    -- 重置变换
```

---

### 5. 输入系统 (InputSystem)

#### 输入优先级
```
1. 统一菜单（最高优先级）
2. 聊天输入
3. 全屏地图
4. 战斗输入
5. 探索移动（最低优先级）
```

#### 输入处理流程
```lua
function InputSystem:keypressed(key)
    -- 1. 检查统一菜单
    if unifiedMenu:isMenuOpen() then
        if unifiedMenu:keypressed(key) then
            return  -- 菜单处理了输入
        end
    end
    
    -- 2. 检查聊天输入
    if chatSystem:isInputting() then
        -- 处理聊天输入
        return
    end
    
    -- 3. 其他输入处理
    -- ...
end
```

---

### 6. 渲染系统 (RenderSystem)

#### 渲染顺序
```
1. 地图背景
2. 遇敌区域（明雷怪物）
3. 玩家角色
4. HUD（小地图、坐标）
5. 角色面板
6. 组队UI
7. 聊天UI
8. 全屏地图（如果打开）
9. 统一菜单（如果打开）
```

#### 相机变换
```lua
-- 世界空间渲染
camera:apply()
    -- 绘制地图
    -- 绘制实体
camera:reset()

-- 屏幕空间渲染
    -- 绘制UI
```

---

## 数据流

### 玩家移动数据流
```
用户输入 (WASD)
    ↓
InputSystem:update(dt)
    ↓
Player:move(dx, dy)
    ↓
检查碰撞 (Map:isCollision)
    ↓
更新玩家位置
    ↓
Camera:follow(player.x, player.y)
    ↓
RenderSystem:draw()
```

### 战斗数据流
```
玩家选择动作
    ↓
BattleSystem:selectAction(action, target)
    ↓
BattleExecutor:executePlayerAttack(target)
    ↓
BattleAnimation:addAttackAnimation()
    ↓
计算伤害
    ↓
更新敌人HP
    ↓
检查胜负
    ↓
切换到敌人回合
```

---

## 状态管理

### 游戏状态持久化

#### 保存的数据
- 账号信息（用户名、密码）
- 角色数据（名字、等级、HP、金币、装备）
- 装备数据
- 地图位置

#### 数据存储
```lua
-- 账号数据存储在内存中
AccountManager.accounts = {
    ["username"] = {
        password = "hashed_password",
        characters = {
            {characterName = "Hero", hp = 100, ...}
        }
    }
}
```

### 战斗状态管理

#### 战斗数据
```lua
BattleSystem = {
    state = BATTLE_STATE.PLAYER_TURN,
    turn = 1,
    enemies = {...},
    player = {...},
    selectedAction = nil,
    selectedTarget = nil,
    autoBattle = false,
    timer = BattleTimer.new(90.0)
}
```

---

## 性能优化

### 1. 渲染优化

#### 相机裁剪
```lua
-- 只渲染相机视野内的实体
if isInCameraView(entity) then
    entity:draw()
end
```

#### 批量绘制
- 合并相同纹理的绘制调用
- 使用SpriteBatch

### 2. 内存优化

#### 对象池
```lua
-- 伤害数字对象池
local damageNumberPool = {}

function getDamageNumber()
    return table.remove(damageNumberPool) or DamageNumber.new()
end

function recycleDamageNumber(number)
    table.insert(damageNumberPool, number)
end
```

#### 资源缓存
```lua
-- AssetManager缓存所有资源
AssetManager.fonts = {}
AssetManager.images = {}
AssetManager.sounds = {}
```

### 3. 逻辑优化

#### 避免频繁的表创建
```lua
-- 不好的做法
function update(dt)
    local temp = {x = 0, y = 0}  -- 每帧创建新表
end

-- 好的做法
local temp = {x = 0, y = 0}  -- 复用表
function update(dt)
    temp.x = 0
    temp.y = 0
end
```

---

## 常见问题

### Q1: 如何添加新地图？

1. 在 `map/maps/` 创建新文件，如 `forest_01.lua`
2. 定义地图配置：
```lua
return {
    id = "forest_01",
    name = "Dark Forest",
    width = 2000,
    height = 2000,
    -- ... 其他配置
}
```
3. 使用 `MapManager.loadMap("forest_01")` 加载

### Q2: 如何添加新敌人？

1. 在敌人数据中添加新类型
2. 配置敌人属性（HP、攻击、防御）
3. 在地图的 `encounterZones` 中引用

### Q3: 如何修改战斗回合时间？

修改 `battle_system.lua` 中的计时器初始化：
```lua
self.timer = BattleTimer.new(90.0)  -- 改为其他秒数
```

### Q4: 如何添加新的UI标签页？

1. 在 `unified_menu.lua` 的 `tabs` 中添加：
```lua
{name = "Skills", key = "skills"}
```
2. 添加对应的绘制方法：
```lua
function UnifiedMenu:drawSkillsTab(gameState, contentY, contentHeight)
    -- 绘制技能页面
end
```

### Q5: 如何调试战斗系统？

在 `battle_system.lua` 中添加调试输出：
```lua
function BattleSystem:update(dt)
    print("State:", self.state, "Turn:", self.turn)
    -- ...
end
```

---

## 扩展建议

### 1. 添加技能系统
- 创建 `skill_system.lua`
- 定义技能数据结构
- 在战斗中集成技能使用

### 2. 添加任务系统
- 创建 `quest_system.lua`
- 定义任务数据结构
- 添加任务追踪UI

### 3. 添加商店系统
- 创建 `shop_system.lua`
- 定义商品数据
- 添加购买/出售UI

### 4. 添加存档系统
- 使用 `love.filesystem` 保存数据
- 实现存档/读档功能
- 支持多个存档槽

---

## 调试技巧

### 1. 使用print调试
```lua
print(string.format("Player pos: (%.2f, %.2f)", player.x, player.y))
```

### 2. 绘制调试信息
```lua
love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
```

### 3. 使用断言
```lua
assert(player.hp > 0, "Player HP must be positive")
```

### 4. 日志系统
创建简单的日志系统记录关键事件。

---

## 最佳实践

### 1. 代码组织
- 每个系统一个文件
- 相关功能分组
- 保持文件小于400行

### 2. 命名规范
- 模块：大写开头（`BattleSystem`）
- 函数：驼峰命名（`calculateDamage`）
- 常量：全大写（`BATTLE_STATE`）

### 3. 注释
- 文件头注释说明用途
- 复杂逻辑添加注释
- 公共API添加文档注释

### 4. 错误处理
```lua
local success, result = pcall(function()
    -- 可能出错的代码
end)

if not success then
    print("Error:", result)
end
```

---

## 参考资源

- [LÖVE2D官方文档](https://love2d.org/wiki/Main_Page)
- [Lua 5.1参考手册](https://www.lua.org/manual/5.1/)
- [游戏编程模式](https://gameprogrammingpatterns.com/)

---

## 更新日志

- 2025-10-12: 创建技术细节文档
- 包含架构设计、系统详解、性能优化等内容

