# 快速开始指南

## 5 分钟快速运行游戏

### 步骤 1: 安装 Love2D

**macOS:**
```bash
brew install love
```

**Windows:**
访问 https://love2d.org/ 下载安装

**Linux:**
```bash
sudo apt-get install love  # Ubuntu/Debian
sudo pacman -S love        # Arch Linux
```

### 步骤 2: 运行游戏

```bash
cd /Users/amos/42
love game
```

游戏会使用程序生成的基础图形运行。

### 步骤 3: （可选）添加真实素材

#### 方案 A: 使用下载脚本（推荐）

```bash
cd game/tools
./download_assets.sh
```

#### 方案 B: 手动下载

1. **访问 Kenney.nl**
   - 网址: https://kenney.nl/assets/micro-roguelike
   - 点击 "Download" 按钮
   - 解压 ZIP 文件

2. **复制素材**
   ```bash
   # 将 PNG 文件复制到
   cp downloaded/*.png game/assets/images/
   ```

3. **重命名文件**
   - 选择一个角色精灵重命名为 `player.png`
   - 选择地图瓦片重命名为 `tileset.png`

#### 方案 C: 使用在线素材

访问以下网站下载免费素材：

1. **OpenGameArt.org**
   - https://opengameart.org/content/tiny-16-expanded-character-sprites
   - 下载后放到 `game/assets/images/`

2. **itch.io**
   - https://itch.io/game-assets/free/tag-top-down
   - 搜索 "top-down character"
   - 下载免费素材包

3. **Kenney Assets**
   - https://kenney.nl/assets
   - 所有素材都是 CC0 许可（完全免费）

## 游戏操作

- **鼠标左键**: 点击屏幕移动角色
- **ESC**: 退出游戏

## 界面说明

- **左上角**: 玩家坐标
- **右上角**: 小地图（红点是玩家位置）
- **右下角**: FPS 显示
- **黄色标记**: 移动目标位置

## 常见问题

**Q: 游戏无法启动？**
```bash
# 检查 Love2D 是否安装
love --version

# 应该显示类似: LOVE 11.4 (Mysterious Mysteries)
```

**Q: 看不到角色？**
- 游戏默认使用程序生成的蓝色圆形作为角色
- 如果看不到，检查控制台是否有错误信息

**Q: 素材没有加载？**
- 检查文件路径: `game/assets/images/player.png`
- 确保文件名正确（小写）
- 查看控制台输出的加载信息

**Q: 如何查看控制台输出？**
```bash
# macOS/Linux
love game 2>&1 | tee game.log

# 或者修改 conf.lua 中的 t.console = true
```

## 下一步

- 阅读 `docs/ASSETS_GUIDE.md` 了解更多素材资源
- 阅读 `docs/DEVELOPMENT.md` 了解开发文档
- 查看 `README.md` 了解项目详情

## 获取帮助

如果遇到问题：

1. 检查 Love2D 版本（需要 11.4+）
2. 查看控制台错误信息
3. 阅读文档目录中的相关文档
4. 提交 Issue 描述问题

## 推荐素材包（直接下载链接）

以下是一些可以直接使用的免费素材：

1. **Kenney Micro Roguelike**
   - 下载: https://kenney.nl/media/pages/assets/micro-roguelike/micro-roguelike.zip
   - 许可: CC0 (Public Domain)

2. **Kenney Tiny Dungeon**
   - 下载: https://kenney.nl/media/pages/assets/tiny-dungeon/tiny-dungeon.zip
   - 许可: CC0 (Public Domain)

3. **Kenney Top-Down Tanks**
   - 下载: https://kenney.nl/media/pages/assets/topdown-tanks-redux/topdown-tanks-redux.zip
   - 许可: CC0 (Public Domain)

下载后解压，将 PNG 文件复制到 `game/assets/images/` 目录即可。

