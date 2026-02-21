-- Tiled Map Editor Integration
-- Tiled 地图编辑器集成使用指南
--
-- 支持的格式:
--   - .json (推荐) - Tiled JSON 格式
--   - .tmx - Tiled XML 格式
--   - .lua - Tiled Lua 导出
--
-- 使用方法:
--
-- 1. 在 Tiled 中创建地图，导出为 JSON 格式
-- 2. 将地图文件放到 game/map/maps/ 目录
-- 3. 使用 MapManager 加载地图:
--
--    local MapManager = require("map.map_manager")
--    
--    -- 加载 Tiled 地图 (自动检测 JSON/TMX)
--    local map = MapManager.loadMap("my_map", true)
--    
--    -- 使用 STI 库加载 (功能更完善)
--    MapManager.setUseSTI(true)
--    local map = MapManager.loadMap("my_map", true)
--
-- Tiled 对象层说明:
--   - collision: 碰撞区域
--   - spawn: 出生点
--   - npcs: NPC 配置
--   - encounter: 遭遇战区域
--   - teleport: 传送点
--
-- 地图属性 (在 Tiled 中设置):
--   - season: 季节 (spring/summer/autumn/winter)
--   - name: 地图名称

local M = {}

function M.demo()
    local MapManager = require("map.map_manager")
    
    MapManager.setDebugMode(true)
    MapManager.init()
    
    local map = MapManager.loadMap("tiled_example", true)
    
    if map then
        print("Map loaded successfully!")
        print("  Width: " .. map.width)
        print("  Height: " .. map.height)
        print("  Season: " .. map.season)
        print("  Layers: " .. #map.layers)
        print("  NPCs: " .. #map.npcs)
        print("  Spawn points: " .. #map.spawnPoints)
    else
        print("Failed to load map!")
    end
    
    return map
end

return M
