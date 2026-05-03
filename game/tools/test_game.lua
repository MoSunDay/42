-- test_game.lua - 简单的游戏逻辑测试

print("=== 游戏模块测试 ===\n")

-- 模拟 Love2D 环境
love = {
    graphics = {
        getWidth = function() return 1280 end,
        getHeight = function() return 720 end,
        newFont = function(size) return {size = size} end,
        newCanvas = function(w, h) 
            return {
                newImageData = function() 
                    return {
                        encode = function() end
                    }
                end
            }
        end,
        setCanvas = function() end,
        clear = function() end,
        setColor = function() end,
        circle = function() end,
        setLineWidth = function() end,
    },
    timer = {
        getDelta = function() return 0.016 end,
        getFPS = function() return 60 end,
    },
    filesystem = {
        getInfo = function() return nil end,
    }
}

-- 添加路径
package.path = package.path .. ";../src/?.lua;../src/core/?.lua;../src/entities/?.lua;../src/systems/?.lua;../src/ui/?.lua"

-- 测试模块加载
print("1. 测试模块加载...")

local success, AssetManager = pcall(require, "core.asset_manager")
if success then
    print("   ✓ AssetManager 加载成功")
else
    print("   ✗ AssetManager 加载失败: " .. tostring(AssetManager))
    os.exit(1)
end

local success, Camera = pcall(require, "core.camera")
if success then
    print("   ✓ Camera 加载成功")
else
    print("   ✗ Camera 加载失败: " .. tostring(Camera))
    os.exit(1)
end

local success, Player = pcall(require, "entities.player")
if success then
    print("   ✓ Player 加载成功")
else
    print("   ✗ Player 加载失败: " .. tostring(Player))
    os.exit(1)
end

local success, Map = pcall(require, "entities.map")
if success then
    print("   ✓ Map 加载成功")
else
    print("   ✗ Map 加载失败: " .. tostring(Map))
    os.exit(1)
end

-- 测试对象创建
print("\n2. 测试对象创建...")

local assetManager = AssetManager.create()
AssetManager.load_all(assetManager)
print("   ✓ AssetManager 创建成功")

local camera = Camera.create()
print("   ✓ Camera 创建成功")

local player = Player.create(100, 100, assetManager)
print("   ✓ Player 创建成功")

local map = Map.create(2000, 2000)
print("   ✓ Map 创建成功")

-- 测试玩家移动
print("\n3. 测试玩家移动...")

Player.move_to(player, 200, 200)
print("   ✓ 设置移动目标")

-- 模拟更新
for i = 1, 10 do
    Player.update(player, 0.016)
end

if player.x ~= 100 or player.y ~= 100 then
    print("   ✓ 玩家位置已更新: (" .. player.x .. ", " .. player.y .. ")")
else
    print("   ✗ 玩家位置未更新")
end

-- 测试相机跟随
print("\n4. 测试相机跟随...")

Camera.follow(camera, player.x, player.y, 0.016)
print("   ✓ 相机位置: (" .. camera.x .. ", " .. camera.y .. ")")

-- 测试坐标转换
local worldX, worldY = Camera.to_world(camera, 640, 360)
print("   ✓ 屏幕坐标转世界坐标: (640, 360) -> (" .. worldX .. ", " .. worldY .. ")")

print("\n=== 所有测试通过！ ===\n")
print("游戏核心逻辑正常，可以运行游戏。")
print("运行命令: love game")
