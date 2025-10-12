# 新功能说明 v4.0

## 📋 概述

本次更新实现了以下主要功能：
1. **小地图功能增强** - 支持全屏地图和自动寻路
2. **组队系统** - 最多5人组队
3. **聊天系统** - 聊天框和气泡对话
4. **Battle系统重构** - 文件结构优化

---

## 🗺️ 小地图功能增强

### 功能特性

#### 1. 全屏地图
- **打开方式**：
  - 按 `TAB` 键
  - 点击右上角小地图
- **关闭方式**：
  - 按 `TAB` 键
  - 按 `ESC` 键
  - 点击地图外部区域

#### 2. 自动寻路导航
- 在全屏地图上点击任意位置
- 角色会自动移动到目标位置
- 地图上会显示导航目标标记（绿色脉冲圆圈）
- 显示从当前位置到目标的连线

#### 3. 地图显示
- 显示完整的世界地图
- 显示建筑物和地标
- 显示玩家当前位置（红色圆点）
- 显示玩家视野范围（黄色圆圈）
- 显示坐标信息

### 使用方法

```lua
-- 打开全屏地图
按 TAB 键

-- 导航到指定位置
1. 打开全屏地图
2. 点击目标位置
3. 地图自动关闭，角色开始移动
```

### 文件结构

```
game/src/ui/
├── fullscreen_map.lua    # 全屏地图UI
└── hud.lua              # HUD（包含小地图）
```

---

## 👥 组队系统

### 功能特性

#### 1. 队伍管理
- **最大人数**：5人
- **队长标识**：金色边框 + 星星标记
- **成员信息**：
  - 头像（彩色圆圈）
  - 名字
  - 等级
  - HP条
  - 在线状态

#### 2. 队伍显示
- **位置**：左侧，角色面板下方
- **显示内容**：
  - 队伍名称
  - 成员数量（当前/最大）
  - 每个成员的详细信息

#### 3. 队伍功能
- 添加成员
- 移除成员
- 设置队长
- 清空队伍
- 自定义队伍名称

### 使用方法

```lua
-- 系统会自动将当前玩家加入队伍
-- 队伍UI会显示在左侧

-- 通过代码添加成员（示例）
local partySystem = gameState:getPartySystem()
local member = PartySystem.createMemberData(
    "player2",           -- ID
    "队友名字",          -- 名字
    5,                   -- 等级
    100,                 -- HP
    100,                 -- 最大HP
    {0.8, 0.2, 0.2}     -- 头像颜色
)
partySystem:addMember(member)
```

### API 接口

```lua
-- 获取组队系统
local partySystem = gameState:getPartySystem()

-- 添加成员
partySystem:addMember(memberData)

-- 移除成员
partySystem:removeMember(memberId)

-- 设置队长
partySystem:setLeader(memberIndex)

-- 获取所有成员
local members = partySystem:getMembers()

-- 检查队伍是否已满
local isFull = partySystem:isFull()
```

### 文件结构

```
game/src/
├── systems/
│   └── party_system.lua    # 组队系统逻辑
└── ui/
    └── party_ui.lua        # 组队UI显示
```

---

## 💬 聊天系统

### 功能特性

#### 1. 聊天框
- **位置**：左下角
- **显示内容**：
  - 最近10条消息
  - 发送者名字（蓝色）
  - 消息内容
  - 输入框

#### 2. 气泡对话
- 发送消息时在角色头顶显示气泡
- 气泡持续3秒
- 最后0.5秒淡出效果
- 自动换行（最大宽度200像素）

#### 3. 输入功能
- **开始输入**：按 `ENTER` 键
- **发送消息**：按 `ENTER` 键
- **取消输入**：按 `ESC` 键
- **删除字符**：按 `BACKSPACE` 键
- **输入提示**：闪烁光标

### 使用方法

```lua
-- 发送消息
1. 按 ENTER 键激活输入框
2. 输入消息内容
3. 按 ENTER 发送
4. 消息会显示在聊天框中
5. 同时在角色头顶显示气泡

-- 取消输入
按 ESC 键
```

### API 接口

```lua
-- 获取聊天系统
local chatSystem = gameState:getChatSystem()

-- 发送消息（通过游戏状态）
gameState:sendChatMessage("你好！")

-- 添加系统消息
chatSystem:addMessage("System", "欢迎来到游戏！", {0.4, 0.8, 1.0})

-- 添加气泡对话
chatSystem:addSpeechBubble(x, y, "对话内容", 3.0, {1, 1, 1})

-- 获取最近消息
local messages = chatSystem:getRecentMessages(10)
```

### 文件结构

```
game/src/
├── systems/
│   └── chat_system.lua     # 聊天系统逻辑
└── ui/
    └── chat_ui.lua         # 聊天UI显示
```

---

## 🔧 Battle系统重构

### 改动说明

将所有battle相关文件整合到统一目录：

#### 之前的结构
```
game/src/
├── systems/
│   ├── battle_system.lua
│   ├── battle_ai.lua
│   ├── battle_animation.lua
│   ├── battle_log.lua
│   ├── battle_utils.lua
│   └── battle/
│       ├── battle_state.lua
│       ├── battle_timer.lua
│       └── battle_executor.lua
└── ui/
    ├── battle_ui.lua
    ├── battle_background.lua
    └── battle/
        ├── battle_menu.lua
        └── battle_panels.lua
```

#### 现在的结构
```
game/src/
├── systems/
│   └── battle/
│       ├── battle_system.lua      # 主系统
│       ├── battle_ai.lua          # AI逻辑
│       ├── battle_animation.lua   # 动画效果
│       ├── battle_log.lua         # 战斗日志
│       ├── battle_utils.lua       # 工具函数
│       ├── battle_state.lua       # 状态定义
│       ├── battle_timer.lua       # 计时器
│       └── battle_executor.lua    # 动作执行
└── ui/
    └── battle/
        ├── battle_ui.lua          # 主UI
        ├── battle_background.lua  # 背景
        ├── battle_menu.lua        # 菜单
        └── battle_panels.lua      # 面板
```

### 优势
- ✅ 更清晰的文件组织
- ✅ 更容易维护和扩展
- ✅ 逻辑和UI完全分离
- ✅ 所有引用已更新，功能不变

---

## 🎮 控制说明

### 探索模式
- `鼠标左键` - 移动角色 / 点击小地图打开全屏地图
- `TAB` - 打开/关闭全屏地图
- `ESC` - 关闭全屏地图
- `ENTER` - 开始聊天输入 / 发送消息
- `BACKSPACE` - 删除字符

### 战斗模式
- `WASD / 方向键` - 选择动作/敌人
- `ENTER / 空格` - 确认选择
- `ESC` - 退出游戏

---

## 📊 技术细节

### 系统集成

所有新系统都已集成到游戏核心：

```lua
-- game_state.lua
self.partySystem = PartySystem.new()
self.chatSystem = ChatSystem.new()

-- render_system.lua
self.partyUI = PartyUI.new(assetManager)
self.chatUI = ChatUI.new(assetManager)
self.fullscreenMap = FullscreenMap.new(assetManager)

-- input_system.lua
-- 处理所有输入（地图、聊天、组队）
```

### 性能优化

- 聊天气泡自动清理（超时后移除）
- 聊天历史限制（最多50条）
- 地图只在打开时渲染
- UI裁剪（scissor）防止溢出

---

## 🚀 未来扩展

### 可能的功能
1. **组队功能扩展**
   - 队伍邀请系统
   - 队伍聊天频道
   - 队伍任务共享

2. **聊天功能扩展**
   - 多个聊天频道（世界、队伍、私聊）
   - 表情符号
   - 聊天历史记录

3. **地图功能扩展**
   - 地图标记
   - 任务追踪
   - 传送点

---

## 📝 更新日志

### v4.0 (2025-10-12)
- ✅ 实现全屏地图和自动寻路
- ✅ 实现组队系统（最多5人）
- ✅ 实现聊天系统（聊天框+气泡）
- ✅ 重构battle系统文件结构
- ✅ 更新所有相关引用
- ✅ 测试通过，功能正常

---

## 🎯 总结

本次更新大幅提升了游戏的社交和导航功能：
- 玩家可以更方便地导航世界
- 支持组队协作
- 支持实时聊天交流
- 代码结构更加清晰

所有功能都已测试通过，可以正常使用！

