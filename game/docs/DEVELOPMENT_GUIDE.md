# 开发指南

## 目录
1. [环境搭建](#环境搭建)
2. [快速开始](#快速开始)
3. [添加新功能](#添加新功能)
4. [常见开发任务](#常见开发任务)
5. [调试技巧](#调试技巧)
6. [代码规范](#代码规范)

---

## 环境搭建

### 1. 安装LÖVE2D

#### macOS
```bash
brew install love
```

#### Windows
从 [love2d.org](https://love2d.org/) 下载安装包

#### Linux
```bash
sudo apt-get install love
```

### 2. 验证安装
```bash
love --version
```

### 3. 运行游戏
```bash
cd game
love .
```

---

## 快速开始

### 项目结构概览
```
game/
├── main.lua              # 游戏入口
├── conf.lua              # 配置文件
├── account/              # 账号系统
├── map/                  # 地图系统
├── src/
│   ├── core/            # 核心系统
│   ├── entities/        # 游戏实体
│   ├── systems/         # 游戏系统
│   └── ui/              # UI组件
├── assets/              # 资源文件
└── docs/                # 文档
```

### 游戏启动流程
```
main.lua:love.load()
    ↓
初始化AssetManager
    ↓
初始化GameState
    ↓
进入LOGIN模式
    ↓
用户登录 → CHARACTER_SELECT
    ↓
选择角色 → EXPLORATION
```

---

## 添加新功能

### 示例1: 添加新的战斗动作

#### 1. 在BattleUI中添加动作
```lua
-- src/ui/battle/battle_ui.lua
self.actions = {
    {name = "Attack", key = "attack"},
    {name = "Defend", key = "defend"},
    {name = "Skill", key = "skill"},  -- 新增
    {name = "Item", key = "item"},
    {name = "Escape", key = "escape"},
    {name = "Auto", key = "auto"}
}
```

#### 2. 在BattleSystem中处理动作
```lua
-- src/systems/battle/battle_system.lua
function BattleSystem:selectAction(action, target)
    if action == "skill" then
        -- 处理技能使用
        self:useSkill(target)
    end
    -- ... 其他动作
end
```

#### 3. 实现技能逻辑
```lua
function BattleSystem:useSkill(target)
    -- 检查MP
    if self.player.mp < 10 then
        self:addLog("Not enough MP!")
        return
    end
    
    -- 扣除MP
    self.player.mp = self.player.mp - 10
    
    -- 执行技能
    local damage = self.player.attack * 2
    target:takeDamage(damage)
    
    self:addLog("Used skill on " .. target.name .. "!")
    self.state = BATTLE_STATE.EXECUTING
end
```

---

### 示例2: 添加新地图

#### 1. 创建地图文件
```lua
-- map/maps/desert_01.lua
return {
    id = "desert_01",
    name = "Desert Oasis",
    width = 2400,
    height = 2000,
    tileSize = 64,
    backgroundColor = {0.9, 0.8, 0.5},
    
    spawnPoints = {
        {x = 1200, y = 1000, name = "Oasis Center"}
    },
    
    encounterZones = {
        {
            x = 800,
            y = 600,
            radius = 30,
            enemyTypes = {"scorpion", "snake"}
        }
    },
    
    buildings = {
        {
            x = 1000,
            y = 800,
            width = 200,
            height = 150,
            name = "Merchant Tent",
            color = {0.8, 0.6, 0.3}
        }
    }
}
```

#### 2. 加载地图
```lua
-- 在GameState中
local mapData = MapManager.loadMap("desert_01")
self.map = mapData
```

---

### 示例3: 添加新UI标签页

#### 1. 在UnifiedMenu中添加标签
```lua
-- src/ui/unified_menu.lua
self.tabs = {
    {name = "Equipment", key = "equipment"},
    {name = "Items", key = "items"},
    {name = "Party", key = "party"},
    {name = "Pet", key = "pet"},
    {name = "Skills", key = "skills"}  -- 新增
}
```

#### 2. 实现绘制方法
```lua
function UnifiedMenu:drawSkillsTab(gameState, contentY, contentHeight)
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Skills", self.x, contentY + 10, self.width, "center")
    
    -- 绘制技能列表
    local skills = gameState.player.skills or {}
    local skillY = contentY + 60
    
    for i, skill in ipairs(skills) do
        local y = skillY + (i - 1) * 60
        
        -- 技能面板
        love.graphics.setColor(self.colors.panel)
        love.graphics.rectangle("fill", self.x + 50, y, self.width - 100, 50, 5, 5)
        
        -- 技能名称
        love.graphics.setColor(self.colors.text)
        love.graphics.print(skill.name, self.x + 70, y + 10)
        
        -- MP消耗
        love.graphics.setColor(0.5, 0.7, 1)
        love.graphics.print("MP: " .. skill.mpCost, self.x + 250, y + 10)
    end
end
```

#### 3. 在draw方法中调用
```lua
function UnifiedMenu:draw(gameState)
    -- ...
    if self.tabs[self.currentTab].key == "skills" then
        self:drawSkillsTab(gameState, contentY, contentHeight)
    end
    -- ...
end
```

---

## 常见开发任务

### 任务1: 修改玩家初始属性

```lua
-- src/entities/player.lua
function Player.new(character)
    local self = setmetatable({}, Player)
    
    self.hp = character.hp or 150        -- 修改初始HP
    self.maxHp = character.maxHp or 150
    self.mp = character.mp or 50         -- 添加MP
    self.maxMp = character.maxMp or 50
    self.attack = character.attack or 15  -- 修改攻击力
    self.defense = character.defense or 8 -- 修改防御力
    
    return self
end
```

### 任务2: 添加新敌人类型

```lua
-- src/entities/enemy.lua
local ENEMY_TYPES = {
    slime = {
        name = "Slime",
        hp = 30,
        attack = 5,
        defense = 2,
        exp = 10,
        gold = 5
    },
    dragon = {  -- 新增
        name = "Dragon",
        hp = 200,
        attack = 30,
        defense = 15,
        exp = 100,
        gold = 50
    }
}
```

### 任务3: 修改战斗奖励

```lua
-- src/systems/battle/battle_system.lua
function BattleSystem:endBattle(result)
    if result == BATTLE_STATE.VICTORY then
        local totalExp = 0
        local totalGold = 0
        
        for _, enemy in ipairs(self.enemies) do
            totalExp = totalExp + enemy.exp * 2  -- 双倍经验
            totalGold = totalGold + enemy.gold * 2  -- 双倍金币
        end
        
        self.player:gainExp(totalExp)
        self.player:gainGold(totalGold)
    end
end
```

### 任务4: 添加音效

```lua
-- src/systems/audio_system.lua
function AudioSystem:playSFX(name)
    if name == "attack" then
        -- 播放攻击音效
        local sound = love.audio.newSource("assets/sounds/attack.wav", "static")
        sound:play()
    elseif name == "hit" then
        -- 播放击中音效
        local sound = love.audio.newSource("assets/sounds/hit.wav", "static")
        sound:play()
    end
end
```

### 任务5: 修改UI颜色主题

```lua
-- src/ui/unified_menu.lua
self.colors = {
    background = {0.1, 0.1, 0.15, 0.95},
    panel = {0.15, 0.15, 0.2, 0.9},
    border = {1.0, 0.5, 0.2, 0.9},  -- 改为橙色边框
    tabActive = {0.5, 0.3, 0.7, 0.9},  -- 改为紫色
    tabInactive = {0.2, 0.2, 0.25, 0.9},
    text = {1, 1, 1},
    textDim = {0.7, 0.7, 0.7}
}
```

---

## 调试技巧

### 1. 打印调试信息

```lua
-- 打印玩家位置
print(string.format("Player: (%.2f, %.2f)", player.x, player.y))

-- 打印表内容
function printTable(t, indent)
    indent = indent or 0
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(string.rep("  ", indent) .. k .. ":")
            printTable(v, indent + 1)
        else
            print(string.rep("  ", indent) .. k .. " = " .. tostring(v))
        end
    end
end
```

### 2. 绘制调试信息

```lua
-- 在render_system.lua中
function RenderSystem:drawDebugInfo()
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Player: " .. self.gameState.player.x .. ", " .. self.gameState.player.y, 10, 30)
    love.graphics.print("Mode: " .. self.gameState:getMode(), 10, 50)
end
```

### 3. 使用断言

```lua
-- 确保参数有效
function Player:takeDamage(damage)
    assert(type(damage) == "number", "Damage must be a number")
    assert(damage >= 0, "Damage must be non-negative")
    
    self.hp = self.hp - damage
end
```

### 4. 条件断点

```lua
-- 只在特定条件下打印
if self.player.hp < 10 then
    print("WARNING: Low HP!", self.player.hp)
end
```

### 5. 性能分析

```lua
-- 测量函数执行时间
local startTime = love.timer.getTime()
-- 执行代码
local endTime = love.timer.getTime()
print("Execution time:", (endTime - startTime) * 1000, "ms")
```

---

## 代码规范

### 1. 文件组织

```lua
-- 文件头注释
-- filename.lua - Brief description
-- Detailed description of the module

-- 依赖导入
local Module1 = require("path.to.module1")
local Module2 = require("path.to.module2")

-- 常量定义
local CONSTANT_VALUE = 100

-- 模块定义
local MyModule = {}
MyModule.__index = MyModule

-- 构造函数
function MyModule.new()
    local self = setmetatable({}, MyModule)
    -- 初始化
    return self
end

-- 公共方法
function MyModule:publicMethod()
    -- 实现
end

-- 私有函数（local）
local function privateFunction()
    -- 实现
end

-- 导出模块
return MyModule
```

### 2. 命名规范

```lua
-- 模块：大写开头
local BattleSystem = {}

-- 常量：全大写，下划线分隔
local MAX_HEALTH = 100
local BATTLE_STATE = {
    PLAYER_TURN = "player"
}

-- 函数：驼峰命名
function calculateDamage(attack, defense)
end

-- 变量：驼峰命名
local playerHealth = 100
local enemyCount = 3

-- 私有函数：local + 驼峰
local function updateAnimation(dt)
end
```

### 3. 注释规范

```lua
-- 单行注释：简短说明

--[[
    多行注释：
    详细说明
    复杂逻辑
]]

--- 文档注释：公共API
--- Calculate damage based on attack and defense
--- @param attack number The attack value
--- @param defense number The defense value
--- @return number The calculated damage
function calculateDamage(attack, defense)
    return math.max(1, attack - defense)
end
```

### 4. 代码格式

```lua
-- 缩进：4空格
function example()
    if condition then
        doSomething()
    end
end

-- 空格：运算符两边加空格
local result = a + b * c

-- 表定义：每个元素一行（长表）
local config = {
    width = 800,
    height = 600,
    title = "Game"
}

-- 函数调用：参数较多时分行
someFunction(
    parameter1,
    parameter2,
    parameter3
)
```

### 5. 错误处理

```lua
-- 使用pcall捕获错误
local success, result = pcall(function()
    return riskyOperation()
end)

if not success then
    print("Error:", result)
    -- 处理错误
end

-- 参数验证
function setHealth(value)
    if type(value) ~= "number" then
        error("Health must be a number")
    end
    if value < 0 then
        error("Health cannot be negative")
    end
    self.health = value
end
```

---

## 测试建议

### 1. 单元测试思路

```lua
-- 测试伤害计算
function testDamageCalculation()
    local damage = calculateDamage(10, 5)
    assert(damage == 5, "Damage calculation failed")
    
    local minDamage = calculateDamage(5, 10)
    assert(minDamage == 1, "Minimum damage should be 1")
end
```

### 2. 集成测试

- 测试完整的战斗流程
- 测试地图切换
- 测试账号登录流程

### 3. 手动测试清单

- [ ] 账号注册与登录
- [ ] 角色创建
- [ ] 地图移动
- [ ] 遇敌触发
- [ ] 战斗流程
- [ ] 装备系统
- [ ] 组队功能
- [ ] 聊天功能
- [ ] UI交互

---

## 常见问题解决

### Q: 游戏启动报错 "module not found"
**A**: 检查require路径是否正确，确保文件存在

### Q: 角色移动卡顿
**A**: 检查碰撞检测逻辑，可能是性能问题

### Q: 战斗动画不显示
**A**: 检查BattleAnimation是否正确初始化和更新

### Q: UI不响应点击
**A**: 检查输入优先级，确保UI在最上层处理输入

---

## 发布流程

### 1. 准备发布
```bash
# 清理临时文件
rm -rf .DS_Store
rm -rf *.log

# 检查代码
# 确保所有文件都在400行以内
```

### 2. 打包游戏

#### macOS
```bash
zip -r game.love game/
```

#### Windows
创建.love文件（实际上是zip文件）

### 3. 创建可执行文件

参考LÖVE2D官方文档的发布指南。

---

## 资源链接

- [LÖVE2D Wiki](https://love2d.org/wiki/Main_Page)
- [Lua参考手册](https://www.lua.org/manual/5.1/)
- [游戏开发模式](https://gameprogrammingpatterns.com/)

---

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交代码
4. 创建Pull Request
5. 等待审核

---

最后更新: 2025-10-12

