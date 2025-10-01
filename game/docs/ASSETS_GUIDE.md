# 游戏素材下载指南

本文档提供免费游戏素材的下载来源和使用说明。

## 推荐素材网站

### 1. OpenGameArt.org
最大的免费游戏素材社区，提供大量高质量的 2D/3D 素材。

**网址**: https://opengameart.org/

**推荐素材包**:
- [Tiny 16: Expanded Character Sprites](https://opengameart.org/content/tiny-16-expanded-character-sprites)
  - 16x16 像素角色精灵
  - 包含多个方向的行走动画
  - CC-BY 3.0 许可证

- [LPC Character Sprites](https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets)
  - 完整的角色动画集
  - 多种装备和服装
  - CC-BY-SA 3.0 / GPL 3.0

### 2. itch.io
独立游戏开发者社区，提供大量免费和付费素材。

**网址**: https://itch.io/game-assets/free/tag-top-down

**推荐素材包**:
- [Tiny Swords](https://pixelfrog-assets.itch.io/tiny-swords)
  - 完整的俯视角游戏素材包
  - 包含角色、敌人、地图瓦片
  - 免费使用

- [Sprout Lands](https://cupnooble.itch.io/sprout-lands-asset-pack)
  - 可爱的农场风格素材
  - 包含角色、动物、建筑
  - 免费版本可用

### 3. Kenney.nl
提供大量免费的游戏素材，质量高且风格统一。

**网址**: https://kenney.nl/assets

**推荐素材包**:
- [Tiny Town](https://kenney.nl/assets/tiny-town)
- [Micro Roguelike](https://kenney.nl/assets/micro-roguelike)
- [Top-Down Tanks Redux](https://kenney.nl/assets/topdown-tanks-redux)

## 快速开始 - 下载推荐素材

### 方案一：使用 Tiny 16 素材（最简单）

1. **下载素材**
   ```bash
   # 访问以下链接下载
   https://opengameart.org/content/tiny-16-expanded-character-sprites
   ```

2. **放置文件**
   - 下载 `tiny16_expaned_again.png`
   - 放置到 `game/assets/images/` 目录
   - 重命名为 `player.png`

3. **修改代码**（可选）
   - 素材会自动加载
   - 如需调整精灵大小，修改 `src/entities/player.lua` 中的 `width` 和 `height`

### 方案二：使用 Kenney 素材包（推荐）

1. **下载 Micro Roguelike 素材包**
   ```bash
   # 访问
   https://kenney.nl/assets/micro-roguelike
   # 点击 "Download" 按钮
   ```

2. **解压并放置**
   ```bash
   # 解压下载的 zip 文件
   # 将 Tilemap 文件夹中的 PNG 文件复制到 game/assets/images/
   ```

3. **使用素材**
   - `colored.png` - 包含所有彩色瓦片和角色
   - 可以使用精灵切割工具提取单个角色

### 方案三：使用 itch.io 的 Tiny Swords（最完整）

1. **访问页面**
   ```
   https://pixelfrog-assets.itch.io/tiny-swords
   ```

2. **下载免费版本**
   - 点击 "Download Now"
   - 可以选择 $0 下载免费版本

3. **放置素材**
   - 解压下载的文件
   - 将 `Factions/Knights/Troops/Warrior/` 中的精灵放到 `game/assets/images/`
   - 将地图瓦片放到相应目录

## 素材文件命名规范

为了让游戏自动加载素材，请遵循以下命名规范：

```
game/assets/images/
├── player.png          # 玩家精灵（32x32 或 16x16）
├── tileset.png         # 地图瓦片集
├── enemy_01.png        # 敌人精灵
└── ...
```

## 使用自定义素材

如果你想使用自己的素材或其他来源的素材：

1. **准备素材**
   - 玩家精灵：推荐 16x16、32x32 或 64x64 像素
   - 地图瓦片：推荐 16x16 或 32x32 像素
   - PNG 格式，支持透明背景

2. **放置文件**
   - 将文件放到 `game/assets/images/` 目录
   - 使用规范的文件名

3. **修改配置**（如需要）
   - 编辑 `src/core/asset_manager.lua`
   - 在 `loadImages()` 函数中添加新的资源加载代码

## 素材许可证说明

使用免费素材时，请注意许可证要求：

- **CC0 (Public Domain)**: 完全免费，无需署名
- **CC-BY 3.0/4.0**: 免费使用，需要署名作者
- **CC-BY-SA**: 免费使用，需要署名，衍生作品需使用相同许可证
- **OGA-BY 3.0**: OpenGameArt 专用许可证，需要署名

## 推荐工具

### 精灵编辑工具
- **Aseprite** (付费，但功能强大): https://www.aseprite.org/
- **Piskel** (免费在线工具): https://www.piskelapp.com/
- **GIMP** (免费): https://www.gimp.org/

### 地图编辑工具
- **Tiled Map Editor** (免费): https://www.mapeditor.org/

## 快速命令行下载（示例）

```bash
# 创建资源目录
mkdir -p game/assets/images
mkdir -p game/assets/fonts
mkdir -p game/assets/sounds

# 使用 curl 下载示例素材（需要替换为实际下载链接）
# cd game/assets/images
# curl -O [素材下载链接]
```

## 常见问题

**Q: 素材没有显示怎么办？**
A: 检查文件路径和文件名是否正确，确保文件格式为 PNG。

**Q: 素材太大或太小？**
A: 修改 `src/entities/player.lua` 中的 `width` 和 `height` 参数。

**Q: 如何添加动画？**
A: 需要使用精灵表（sprite sheet），并在代码中实现帧动画逻辑。

**Q: 可以使用付费素材吗？**
A: 可以，但请确保遵守素材的许可证条款。

## 贡献

如果你发现了好的免费素材资源，欢迎提交 PR 更新本文档！

