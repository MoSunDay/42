# 游戏功能总览 v4.0

## 🎮 游戏简介

这是一个基于 LÖVE 2D 引擎开发的回合制战斗 RPG 游戏，包含完整的账号系统、角色系统、战斗系统、组队系统和聊天系统。

## ✨ 主要功能

### 1. 账号系统
- ✅ 用户注册和登录
- ✅ 多角色支持（每个账号可创建多个角色）
- ✅ 角色数据持久化
- ✅ 3个测试账号（test/123, admin/admin, player/pass）

### 2. 角色系统
- ✅ 角色创建（自定义名字和外观）
- ✅ 8种外观可选
- ✅ 角色属性（等级、HP、攻击、防御、金币）
- ✅ 角色升级系统
- ✅ 装备系统

### 3. 探索系统
- ✅ 2D 俯视角地图探索
- ✅ 点击移动
- ✅ 相机跟随
- ✅ 小地图显示
- ✅ **全屏地图（按TAB）**
- ✅ **自动寻路导航**
- ✅ 遇敌区域（明雷）

### 4. 战斗系统
- ✅ 回合制战斗
- ✅ 多敌人支持（最多3个）
- ✅ 战斗动作：攻击、防御、逃跑
- ✅ 自动战斗模式
- ✅ 90秒回合计时器
- ✅ 战斗日志
- ✅ 战斗动画和特效
- ✅ 经验和金币奖励

### 5. 组队系统 ⭐ 新功能
- ✅ 最多5人组队
- ✅ 队长标识（金色边框+星星）
- ✅ 成员信息显示（头像、名字、等级、HP）
- ✅ 在线状态显示
- ✅ 队伍管理（添加/移除成员、设置队长）

### 6. 聊天系统 ⭐ 新功能
- ✅ 聊天框（左下角）
- ✅ 消息历史（最多50条）
- ✅ 气泡对话（角色头顶）
- ✅ 实时输入
- ✅ 系统消息

### 7. UI 系统
- ✅ HUD（小地图、坐标、FPS）
- ✅ 角色信息面板
- ✅ 战斗UI
- ✅ 装备UI（按E键）
- ✅ 组队UI
- ✅ 聊天UI
- ✅ 全屏地图UI

## 🎯 控制说明

### 登录界面
- `鼠标点击` - 选择输入框
- `键盘输入` - 输入用户名/密码
- `ENTER` - 登录
- `TAB` - 切换输入框

### 角色选择
- `↑↓` - 选择角色
- `ENTER` - 确认选择
- `鼠标点击` - 选择角色/按钮/外观

### 探索模式
- `鼠标左键` - 移动角色
- `TAB` - 打开/关闭全屏地图
- `ESC` - 关闭全屏地图
- `ENTER` - 开始聊天
- `E` - 打开装备界面

### 聊天模式
- `ENTER` - 开始输入/发送消息
- `ESC` - 取消输入
- `BACKSPACE` - 删除字符

### 战斗模式
- `WASD / 方向键` - 选择动作/敌人
- `ENTER / 空格` - 确认选择
- `鼠标点击` - 选择敌人/动作

## 📦 项目结构

```
game/
├── main.lua                    # 游戏入口
├── conf.lua                    # 游戏配置
├── account/                    # 账号系统
│   ├── account_manager.lua     # 账号管理
│   ├── character_data.lua      # 角色数据
│   ├── character_select_ui.lua # 角色选择UI
│   ├── login_ui.lua           # 登录UI
│   └── avatar_renderer.lua    # 头像渲染
├── src/
│   ├── core/                  # 核心系统
│   │   ├── game_state.lua     # 游戏状态
│   │   ├── camera.lua         # 相机系统
│   │   └── asset_manager.lua  # 资源管理
│   ├── entities/              # 游戏实体
│   │   ├── player.lua         # 玩家
│   │   ├── enemy.lua          # 敌人
│   │   ├── map.lua            # 地图
│   │   └── encounter_zone.lua # 遇敌区域
│   ├── systems/               # 游戏系统
│   │   ├── battle/            # 战斗系统
│   │   │   ├── battle_system.lua
│   │   │   ├── battle_ai.lua
│   │   │   ├── battle_animation.lua
│   │   │   ├── battle_log.lua
│   │   │   ├── battle_utils.lua
│   │   │   ├── battle_state.lua
│   │   │   ├── battle_timer.lua
│   │   │   └── battle_executor.lua
│   │   ├── input_system.lua   # 输入系统
│   │   ├── render_system.lua  # 渲染系统
│   │   ├── audio_system.lua   # 音频系统
│   │   ├── equipment_system.lua # 装备系统
│   │   ├── party_system.lua   # 组队系统 ⭐
│   │   ├── chat_system.lua    # 聊天系统 ⭐
│   │   └── appearance_system.lua # 外观系统
│   ├── ui/                    # UI组件
│   │   ├── hud.lua            # HUD
│   │   ├── fullscreen_map.lua # 全屏地图 ⭐
│   │   ├── party_ui.lua       # 组队UI ⭐
│   │   ├── chat_ui.lua        # 聊天UI ⭐
│   │   ├── equipment_ui.lua   # 装备UI
│   │   └── battle/            # 战斗UI
│   │       ├── battle_ui.lua
│   │       ├── battle_menu.lua
│   │       ├── battle_panels.lua
│   │       └── battle_background.lua
│   └── animations/            # 动画系统
│       ├── animation_manager.lua
│       ├── breathing_effect.lua
│       ├── running_effect.lua
│       └── enemy_effects.lua
├── map/                       # 地图数据
│   ├── map_manager.lua
│   ├── map_data.lua
│   ├── maps/
│   │   └── town_01.lua
│   └── minimap/
│       └── town_01.lua
└── docs/                      # 文档
    ├── NEW_FEATURES_v4.0.md   # 新功能说明
    ├── CHARACTER_SELECT_FIX.md # 角色选择修复
    └── COMPLETE_FEATURES_v3.0.md # 完整功能列表
```

## 🚀 快速开始

### 1. 安装 LÖVE
```bash
# macOS
brew install love

# Windows
# 下载并安装 https://love2d.org/

# Linux
sudo apt-get install love
```

### 2. 运行游戏
```bash
cd game
love .
```

### 3. 登录测试账号
- **账号1**: test / 123 (1个角色，等级5)
- **账号2**: admin / admin (2个角色，等级10和8)
- **账号3**: player / pass (1个角色，等级1)

### 4. 开始游戏
1. 选择或创建角色
2. 进入游戏世界
3. 点击地面移动
4. 按TAB打开地图
5. 按ENTER聊天
6. 遇到敌人进入战斗

## 🎨 新功能演示

### 全屏地图和自动寻路
```
1. 按 TAB 打开全屏地图
2. 点击地图上的任意位置
3. 角色自动移动到目标位置
4. 地图显示导航路径
```

### 组队系统
```
1. 游戏自动将当前角色加入队伍
2. 队伍UI显示在左侧
3. 显示队长标识（金色边框+星星）
4. 显示所有成员信息
```

### 聊天系统
```
1. 按 ENTER 开始输入
2. 输入消息内容
3. 按 ENTER 发送
4. 消息显示在聊天框
5. 角色头顶出现气泡对话
```

## 📊 技术特性

- **引擎**: LÖVE 2D (Lua)
- **分辨率**: 1280x720
- **帧率**: 60 FPS (VSync)
- **架构**: ECS (Entity-Component-System)
- **代码规范**: 模块化设计，单一职责原则
- **文件大小**: 所有文件 < 400 行

## 🔧 开发工具

- **LÖVE 2D**: 游戏引擎
- **Lua**: 编程语言
- **Git**: 版本控制

## 📝 更新日志

### v4.0 (2025-10-12)
- ✅ 实现全屏地图和自动寻路
- ✅ 实现组队系统（最多5人）
- ✅ 实现聊天系统（聊天框+气泡）
- ✅ 重构battle系统文件结构
- ✅ 修复角色选择界面交互问题
- ✅ 修复角色显示字段名问题

### v3.0
- ✅ 装备系统
- ✅ 宠物系统
- ✅ 四季地图
- ✅ 增强音效

### v2.0
- ✅ 账号系统
- ✅ 角色系统
- ✅ 外观系统

### v1.0
- ✅ 基础战斗系统
- ✅ 地图探索
- ✅ 遇敌系统

## 🎯 未来计划

### 短期目标
- [ ] 多人联机（网络同步）
- [ ] 队伍聊天频道
- [ ] 地图标记系统
- [ ] 任务系统

### 长期目标
- [ ] 更多地图和场景
- [ ] 更多职业和技能
- [ ] PVP 战斗
- [ ] 公会系统
- [ ] 交易系统

## 🐛 已知问题

- 无

## 📞 联系方式

如有问题或建议，请提交 Issue。

## 📄 许可证

MIT License

---

**享受游戏！** 🎮✨

