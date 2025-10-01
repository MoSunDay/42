# Top-Down Combat Game - MVP v1.1

## Project Overview

A top-down combat game developed with Lua Love2D game engine. This is the MVP version featuring a knight character in a town environment.

## Completed Features

- ✅ **Mouse Click Movement** - Click anywhere to move the character
- ✅ **Map Boundary Restrictions** - Player cannot move outside the map (NEW in v1.1)
- ✅ **Position Display** - Real-time coordinate display (top-left)
- ✅ **Minimap** - Shows player position and town layout (top-right)
- ✅ **Knight Character** - Swordsman sprite integrated (NEW in v1.1)
- ✅ **Town Map** - City environment with roads and grass (NEW in v1.1)
- ✅ **Camera Follow System** - Smooth camera tracking
- ✅ **Modular Architecture** - Clean code structure, easy to extend

## 项目结构

```
game/
├── main.lua                    # 游戏主入口
├── conf.lua                    # Love2D 配置文件
├── src/                        # 源代码目录
│   ├── core/                   # 核心系统
│   │   ├── game_state.lua      # 游戏状态管理
│   │   ├── asset_manager.lua   # 资源管理器
│   │   └── camera.lua          # 相机系统
│   ├── entities/               # 游戏实体
│   │   ├── player.lua          # 玩家实体
│   │   └── map.lua             # 地图实体
│   ├── systems/                # 游戏系统
│   │   ├── input_system.lua    # 输入系统
│   │   └── render_system.lua   # 渲染系统
│   └── ui/                     # 用户界面
│       └── hud.lua             # HUD界面
├── assets/                     # 资源目录
│   ├── images/                 # 图片资源
│   │   ├── player.png          # 玩家精灵（可选）
│   │   └── tileset.png         # 地图瓦片（可选）
│   ├── fonts/                  # 字体资源
│   └── sounds/                 # 音效资源
└── docs/                       # 文档目录
    └── ASSETS_GUIDE.md         # 素材下载指南
```

## 技术特点

- **模块化设计** - 每个模块职责单一，代码行数控制在 400 行以内
- **ECS 架构思想** - 实体-系统分离，易于扩展
- **资源管理** - 统一的资源加载和管理
- **可扩展性** - 预留了音效、动画等扩展接口

## 运行方法

### 前置要求

安装 Love2D 游戏引擎（11.4 或更高版本）：

**macOS:**
```bash
brew install love
```

**Windows:**
从 [https://love2d.org/](https://love2d.org/) 下载安装

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install love

# Arch Linux
sudo pacman -S love
```

### 运行游戏

在项目根目录执行：

```bash
cd game
love .
```

或者直接：

```bash
love game
```

## 操作说明

- **鼠标左键点击**: 控制角色移动到目标位置
- **ESC**: 退出游戏

## Game Interface

- **Top-Left**: Player position panel
- **Top-Right**: Minimap (red dot = player position, shows town roads)
- **Bottom-Right**: FPS display
- **Main View**:
  - Gray stone roads in grid pattern
  - Green grass areas between roads
  - Knight character sprite (or blue circle if sprite not loaded)
  - Yellow marker shows movement target
  - Yellow line shows movement path

## Assets

The game includes:
- **Knight sprite** (knight.png) - Swordsman character
- **Town tileset** (town.png) - City environment
- **Fallback**: Procedurally generated graphics if assets not found

For more assets, see `docs/ASSETS_GUIDE.md`.

## What's New in v1.1

- ✅ Map boundary restrictions
- ✅ Knight character sprite
- ✅ Town/city map environment
- ✅ Fixed encoding issues (all English)
- ✅ Enhanced minimap with road display

## Next Steps

- [ ] Animate knight sprite (walking animation)
- [ ] Add buildings to town
- [ ] Implement enemy AI system
- [ ] Add combat system
- [ ] Add skill system
- [ ] Add sound effects and music
- [ ] Performance optimization

## 开发规范

- 每个文件代码行数不超过 400 行
- 使用模块化函数式编程
- 遵循 Lua 代码规范
- 注释清晰，便于维护

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

