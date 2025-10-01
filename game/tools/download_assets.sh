#!/bin/bash
# download_assets.sh - 下载免费游戏素材

echo "开始下载游戏素材..."

# 创建临时目录
TEMP_DIR="temp_assets"
mkdir -p "$TEMP_DIR"

# 目标目录
ASSETS_DIR="../assets/images"
mkdir -p "$ASSETS_DIR"

echo ""
echo "=== 下载 Kenney 素材包 ==="

# 下载 Kenney Micro Roguelike 素材
echo "下载 Micro Roguelike 素材..."
curl -L "https://kenney.nl/content/3-assets/11-micro-roguelike/microroguelike.zip" -o "$TEMP_DIR/microroguelike.zip"

if [ -f "$TEMP_DIR/microroguelike.zip" ]; then
    echo "解压素材..."
    unzip -q "$TEMP_DIR/microroguelike.zip" -d "$TEMP_DIR/microroguelike"
    
    # 复制有用的文件
    if [ -d "$TEMP_DIR/microroguelike" ]; then
        find "$TEMP_DIR/microroguelike" -name "*.png" -exec cp {} "$ASSETS_DIR/" \;
        echo "✓ Micro Roguelike 素材下载完成"
    fi
else
    echo "✗ 下载失败，请手动下载: https://kenney.nl/assets/micro-roguelike"
fi

echo ""
echo "=== 下载 Tiny Dungeon 素材 ==="

# 下载 Tiny Dungeon 素材
echo "下载 Tiny Dungeon 素材..."
curl -L "https://kenney.nl/content/3-assets/12-tiny-dungeon/tinydungeon.zip" -o "$TEMP_DIR/tinydungeon.zip"

if [ -f "$TEMP_DIR/tinydungeon.zip" ]; then
    echo "解压素材..."
    unzip -q "$TEMP_DIR/tinydungeon.zip" -d "$TEMP_DIR/tinydungeon"
    
    if [ -d "$TEMP_DIR/tinydungeon" ]; then
        find "$TEMP_DIR/tinydungeon" -name "*.png" -exec cp {} "$ASSETS_DIR/" \;
        echo "✓ Tiny Dungeon 素材下载完成"
    fi
else
    echo "✗ 下载失败，请手动下载: https://kenney.nl/assets/tiny-dungeon"
fi

echo ""
echo "=== 清理临时文件 ==="
rm -rf "$TEMP_DIR"

echo ""
echo "素材下载完成！"
echo "文件位置: $ASSETS_DIR"
echo ""
echo "提示："
echo "1. 如果下载失败，请访问以下网站手动下载："
echo "   - https://kenney.nl/assets"
echo "   - https://opengameart.org/"
echo "   - https://itch.io/game-assets/free"
echo ""
echo "2. 将下载的 PNG 文件放到 game/assets/images/ 目录"
echo ""
echo "3. 重命名文件以匹配游戏需求："
echo "   - player.png (玩家精灵)"
echo "   - tileset.png (地图瓦片)"
echo ""

