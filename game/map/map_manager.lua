-- map_manager.lua - Map management system
-- 地图管理系统，支持Lua、Tiled XML/JSON格式地图，支持STI库

local MapData = require("map.map_data")
local TiledLoader = require("map.tiled_loader")
local TilesetManager = require("map.tileset_manager")
local TileAnimator = require("src.systems.tile_animator")
local Autotile = require("map.autotile")
local ParticleSystem = require("map.particle_system")

local MapManager = {}

MapManager.loadedMaps = {}
MapManager.currentMap = nil
MapManager.tilesetManager = nil
MapManager.tileAnimator = nil
MapManager.autotile = nil
MapManager.particleSystem = nil
MapManager.debugMode = false
MapManager.useSTI = false

function MapManager.init()
    MapManager.tilesetManager = TilesetManager.new()
    MapManager.tileAnimator = TileAnimator.new()
    MapManager.autotile = Autotile.new()
    MapManager.particleSystem = ParticleSystem.new()
end

function MapManager.loadMap(mapId, useTiled)
    if MapManager.loadedMaps[mapId] then
        if MapManager.debugMode then
            print("[MapManager] Map '" .. mapId .. "' loaded from cache")
        end
        MapManager.currentMap = MapManager.loadedMaps[mapId]
        return MapManager.loadedMaps[mapId]
    end
    
    local map = nil
    
    if useTiled then
        if MapManager.useSTI and TiledLoader.isSTIAvailable() then
            map = MapManager.loadWithSTI(mapId)
        end
        
        if not map then
            map = MapManager.loadTiledMap(mapId)
        end
    end
    
    if not map then
        map = MapManager.loadLuaMap(mapId)
    end
    
    if map then
        MapManager.loadedMaps[mapId] = map
        MapManager.currentMap = map
        
        if MapManager.tileAnimator then
            MapManager.tileAnimator:scanMapForAnimatedTiles(map)
        end
        
        if MapManager.particleSystem and map.season then
            MapManager.particleSystem:setSeason(map.season)
        end
        
        if MapManager.debugMode then
            print("[MapManager] Map '" .. mapId .. "' loaded successfully")
        end
        
        return map
    end
    
    return nil
end

function MapManager.loadLuaMap(mapId)
    local success, mapConfig = pcall(require, "map.maps." .. mapId)
    
    if not success then
        if MapManager.debugMode then
            print("[MapManager] Error loading Lua map '" .. mapId .. "': " .. tostring(mapConfig))
        end
        return nil
    end
    
    return MapData.new(mapConfig)
end

function MapManager.loadTiledMap(mapId)
    local jsonPath = "map/maps/" .. mapId .. ".json"
    local tmxPath = "map/maps/" .. mapId .. ".tmx"
    local map = nil
    
    if love.filesystem.getInfo(jsonPath) then
        map = TiledLoader.load(jsonPath)
        if map and MapManager.debugMode then
            print("[MapManager] Loaded JSON map: " .. jsonPath)
        end
    end
    
    if not map and love.filesystem.getInfo(tmxPath) then
        map = TiledLoader.load(tmxPath)
        if map and MapManager.debugMode then
            print("[MapManager] Loaded TMX map: " .. tmxPath)
        end
    end
    
    if not map then
        if MapManager.debugMode then
            print("[MapManager] Tiled map not found: " .. mapId .. " (tried .json and .tmx)")
        end
        return nil
    end
    
    if map and MapManager.autotile then
        if map.layers then
            for layerName, layer in pairs(map.layers) do
                if layer.tiles and #layer.tiles > 0 then
                    local width = math.floor(map.width / map.tileSize)
                    local height = math.floor(map.height / map.tileSize)
                    layer.tiles = MapManager.autotile:processMap(layer.tiles, width, height)
                end
            end
        end
    end
    
    return map
end

function MapManager.loadWithSTI(mapId)
    local jsonPath = "map/maps/" .. mapId .. ".json"
    local tmxPath = "map/maps/" .. mapId .. ".tmx"
    
    if love.filesystem.getInfo(jsonPath) then
        local map = TiledLoader.loadWithSTI(jsonPath)
        if map and MapManager.debugMode then
            print("[MapManager] Loaded with STI: " .. jsonPath)
        end
        return map
    end
    
    if love.filesystem.getInfo(tmxPath) then
        local map = TiledLoader.loadWithSTI(tmxPath)
        if map and MapManager.debugMode then
            print("[MapManager] Loaded with STI: " .. tmxPath)
        end
        return map
    end
    
    return nil
end

function MapManager.setUseSTI(enabled)
    MapManager.useSTI = enabled and TiledLoader.isSTIAvailable()
    if MapManager.debugMode then
        print("[MapManager] STI mode: " .. tostring(MapManager.useSTI))
    end
end

function MapManager.getMinimap(mapId)
    local success, minimapData = pcall(require, "map.minimap." .. mapId)
    
    if not success then
        return nil
    end
    
    return minimapData
end

function MapManager.getCurrentMap()
    return MapManager.currentMap
end

function MapManager.unloadMap(mapId)
    MapManager.loadedMaps[mapId] = nil
    if MapManager.debugMode then
        print("[MapManager] Map '" .. mapId .. "' unloaded")
    end
end

function MapManager.clearAll()
    MapManager.loadedMaps = {}
    MapManager.currentMap = nil
    if MapManager.debugMode then
        print("[MapManager] All maps cleared")
    end
end

function MapManager.setDebugMode(enabled)
    MapManager.debugMode = enabled
end

function MapManager.update(dt, camera, screenWidth)
    if MapManager.tileAnimator then
        MapManager.tileAnimator:update(dt)
    end
    
    if MapManager.particleSystem and camera and MapManager.currentMap then
        MapManager.particleSystem:update(dt)
        MapManager.particleSystem:emitFromTop(
            screenWidth or 1280,
            camera.x,
            camera.y,
            MapManager.currentMap.width,
            MapManager.currentMap.height
        )
    end
end

function MapManager.drawParticles(camera)
    if MapManager.particleSystem then
        MapManager.particleSystem:draw(camera)
    end
end

function MapManager.getTilesetManager()
    if not MapManager.tilesetManager then
        MapManager.tilesetManager = TilesetManager.new()
    end
    return MapManager.tilesetManager
end

function MapManager.getTileAnimator()
    if not MapManager.tileAnimator then
        MapManager.tileAnimator = TileAnimator.new()
    end
    return MapManager.tileAnimator
end

function MapManager.getAutotile()
    if not MapManager.autotile then
        MapManager.autotile = Autotile.new()
    end
    return MapManager.autotile
end

function MapManager.getParticleSystem()
    if not MapManager.particleSystem then
        MapManager.particleSystem = ParticleSystem.new()
    end
    return MapManager.particleSystem
end

function MapManager.setParticlesEnabled(enabled)
    if MapManager.particleSystem then
        MapManager.particleSystem:setEnabled(enabled)
    end
end

function MapManager.exportToTiled(mapId, outputPath, format)
    local map = MapManager.loadedMaps[mapId]
    if not map then
        return false
    end
    
    format = format or "json"
    
    if format == "json" then
        local content = TiledLoader.exportToJSON(map, outputPath)
        return content ~= nil
    else
        local content = TiledLoader.exportToTMX(map, outputPath)
        return content ~= nil
    end
end

function MapManager.getSupportedFormats()
    return TiledLoader.getSupportedFormats()
end

function MapManager.isSTIAvailable()
    return TiledLoader.isSTIAvailable()
end

function MapManager.getMapInfo(mapId)
    local map = MapManager.loadedMaps[mapId] or MapManager.currentMap
    if not map then
        return nil
    end
    
    return {
        id = map.id,
        name = map.name,
        width = map.width,
        height = map.height,
        tileSize = map.tileSize,
        season = map.season,
        objectCount = map.objects and #map.objects or 0,
        buildingCount = map.buildings and #map.buildings or 0,
        npcCount = map.npcs and #map.npcs or 0,
        spawnPointCount = map.spawnPoints and #map.spawnPoints or 0
    }
end

return MapManager
