-- map_manager.lua - Map management system
-- 地图管理系统

local MapData = require("map.map_data")

local MapManager = {}

-- Loaded maps cache
MapManager.loadedMaps = {}
MapManager.currentMap = nil

-- Load a map by ID
function MapManager.loadMap(mapId)
    -- Check cache first
    if MapManager.loadedMaps[mapId] then
        print("Map '" .. mapId .. "' loaded from cache")
        MapManager.currentMap = MapManager.loadedMaps[mapId]
        return MapManager.loadedMaps[mapId]
    end
    
    -- Load map data
    local success, mapConfig = pcall(require, "map.maps." .. mapId)
    
    if not success then
        print("Error loading map '" .. mapId .. "': " .. tostring(mapConfig))
        return nil
    end
    
    -- Create map data
    local map = MapData.new(mapConfig)
    
    -- Cache it
    MapManager.loadedMaps[mapId] = map
    MapManager.currentMap = map
    
    print("Map '" .. mapId .. "' loaded successfully")
    return map
end

-- Get minimap data
function MapManager.getMinimap(mapId)
    local success, minimapData = pcall(require, "map.minimap." .. mapId)
    
    if not success then
        print("No minimap data for '" .. mapId .. "'")
        return nil
    end
    
    return minimapData
end

-- Get current map
function MapManager.getCurrentMap()
    return MapManager.currentMap
end

-- Unload a map
function MapManager.unloadMap(mapId)
    MapManager.loadedMaps[mapId] = nil
    print("Map '" .. mapId .. "' unloaded")
end

-- Clear all maps
function MapManager.clearAll()
    MapManager.loadedMaps = {}
    MapManager.currentMap = nil
    print("All maps cleared")
end

return MapManager

