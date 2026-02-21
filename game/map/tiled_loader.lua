-- tiled_loader.lua - Tiled Map Editor loader
-- 支持 .tmx (XML) 和 .json 格式地图文件加载
-- 支持 STI (Simple Tiled Implementation) 库

local TiledLoader = {}
TiledLoader.__index = TiledLoader

local json = require("lib.json")
local STI = nil
local stiAvailable = false

pcall(function()
    STI = require("lib.sti")
    stiAvailable = true
end)

local function parseXML(xml)
    local result = {}
    local stack = {{children = result}}
    
    for tag, attrs, content in xml:gmatch("<(%w+)([^>]-)>([^<]*)") do
        local node = {
            name = tag,
            attrs = {},
            children = {},
            content = content or ""
        }
        
        for key, value in attrs:gmatch('(%w+)=["\']([^"\']*)["\']') do
            node.attrs[key] = value
        end
        
        table.insert(stack[#stack].children, node)
        
        if not attrs:match("/>") then
            table.insert(stack, node)
        end
    end
    
    return result
end

local function decodeCSV(data)
    local tiles = {}
    for tileId in data:gmatch("([^,]+)") do
        tileId = tonumber(tileId:match("^%s*(.-)%s*$"))
        if tileId and tileId > 0 then
            table.insert(tiles, tileId)
        end
    end
    return tiles
end

local function decodeBase64(data)
    local decoded = {}
    local mapping = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local revMapping = {}
    for i = 1, #mapping do
        revMapping[mapping:sub(i, i)] = i - 1
    end
    
    data = data:gsub("[^" .. mapping .. "=]", "")
    
    for i = 1, #data, 4 do
        local chunk = data:sub(i, i + 3)
        local n = 0
        for j = 1, 4 do
            local c = chunk:sub(j, j)
            if c == "=" then
                n = n * 64
            else
                n = n * 64 + (revMapping[c] or 0)
            end
        end
        
        table.insert(decoded, n % 256)
        table.insert(decoded, math.floor(n / 256) % 256)
        table.insert(decoded, math.floor(n / 65536) % 256)
        table.insert(decoded, math.floor(n / 16777216) % 256)
    end
    
    return decoded
end

local function decompressGZIP(data)
    return data
end

local function decodeLayerData(encoding, compression, data, width, height)
    local tiles = {}
    
    if encoding == "csv" then
        tiles = decodeCSV(data)
    elseif encoding == "base64" then
        local decoded = decodeBase64(data)
        
        if compression == "gzip" or compression == "zlib" then
            decoded = decompressGZIP(decoded)
        end
        
        for i = 1, #decoded, 4 do
            local tileId = decoded[i] + decoded[i + 1] * 256 + decoded[i + 2] * 65536 + decoded[i + 3] * 16777216
            if tileId > 0 then
                table.insert(tiles, tileId)
            end
        end
    else
        for y = 0, height - 1 do
            for x = 0, width - 1 do
                tiles[y * width + x + 1] = 0
            end
        end
    end
    
    return tiles
end

local function getLayerData(layer, width, height)
    if layer.data and #layer.data > 0 then
        return layer.data
    end
    
    local encoding = layer.encoding or "csv"
    local compression = layer.compression
    local rawData = layer.rawData or ""
    
    return decodeLayerData(encoding, compression, rawData, width, height)
end

function TiledLoader.load(filepath)
    local MapData = require("map.map_data")
    
    if not love.filesystem.getInfo(filepath) then
        print("Warning: Tiled map file not found: " .. filepath)
        return nil
    end
    
    local isJson = filepath:match("%.json$") ~= nil
    
    if isJson then
        return TiledLoader.loadJSON(filepath)
    else
        return TiledLoader.loadTMX(filepath)
    end
end

function TiledLoader.loadWithSTI(filepath)
    if not stiAvailable then
        print("Warning: STI library not available, falling back to built-in loader")
        return TiledLoader.load(filepath)
    end
    
    if not love.filesystem.getInfo(filepath) then
        print("Warning: Tiled map file not found: " .. filepath)
        return nil
    end
    
    local success, stiMap = pcall(function()
        return STI(filepath)
    end)
    
    if not success or not stiMap then
        print("Warning: STI failed to load map: " .. filepath)
        return TiledLoader.load(filepath)
    end
    
    return TiledLoader.convertSTIToMapData(stiMap)
end

function TiledLoader.convertSTIToMapData(stiMap)
    local MapData = require("map.map_data")
    
    local mapInfo = {
        width = stiMap.width * stiMap.tilewidth,
        height = stiMap.height * stiMap.tileheight,
        tileSize = stiMap.tilewidth,
        layers = {},
        tilesets = stiMap.tilesets or {},
        objects = {},
        buildings = {},
        collisionMap = {},
        spawnPoints = {},
        npcs = {},
        encounterZones = {},
        teleports = {},
        season = "spring",
        stiMap = stiMap
    }
    
    if stiMap.properties then
        if stiMap.properties.season then
            mapInfo.season = stiMap.properties.season
        end
        if stiMap.properties.name then
            mapInfo.name = stiMap.properties.name
        end
    end
    
    local tilesX = stiMap.width
    local tilesY = stiMap.height
    mapInfo.collisionMap = {}
    for y = 0, tilesY - 1 do
        mapInfo.collisionMap[y] = {}
        for x = 0, tilesX - 1 do
            mapInfo.collisionMap[y][x] = 0
        end
    end
    
    for layerName, layer in pairs(stiMap.layers) do
        if layer.type == "tilelayer" and layer.data then
            mapInfo.layers[layerName] = {
                width = layer.width,
                height = layer.height,
                tiles = layer.data,
                visible = layer.visible,
                opacity = layer.opacity
            }
        elseif layer.type == "objectgroup" and layer.objects then
            for _, obj in ipairs(layer.objects) do
                TiledLoader.processTiledObject(obj, layer.name, mapInfo)
            end
        end
    end
    
    if #mapInfo.spawnPoints == 0 then
        mapInfo.spawnPoints = {{x = mapInfo.width / 2, y = mapInfo.height / 2}}
    end
    
    local map = MapData.new(mapInfo)
    map.stiMap = stiMap
    map.useSTI = true
    
    return map
end

function TiledLoader.loadTMX(filepath)
    local content, size = love.filesystem.read(filepath)
    if not content then
        print("Warning: Failed to read Tiled map file: " .. filepath)
        return nil
    end
    
    local map = TiledLoader.parseTMX(content)
    if not map then
        print("Warning: Failed to parse Tiled map: " .. filepath)
        return nil
    end
    
    return map
end

function TiledLoader.loadJSON(filepath)
    local content, size = love.filesystem.read(filepath)
    if not content then
        print("Warning: Failed to read Tiled JSON file: " .. filepath)
        return nil
    end
    
    local jsonData = json.decode(content)
    if not jsonData then
        print("Warning: Failed to parse Tiled JSON: " .. filepath)
        return nil
    end
    
    return TiledLoader.parseJSON(jsonData)
end

function TiledLoader.parseJSON(data)
    local MapData = require("map.map_data")
    
    local mapInfo = {
        width = (data.width or 32) * (data.tilewidth or 32),
        height = (data.height or 32) * (data.tileheight or 32),
        tileSize = data.tilewidth or 32,
        layers = {},
        tilesets = {},
        objects = {},
        buildings = {},
        collisionMap = {},
        spawnPoints = {},
        npcs = {},
        encounterZones = {},
        teleports = {},
        season = "spring"
    }
    
    if data.properties then
        if data.properties.season then
            mapInfo.season = data.properties.season
        end
        if data.properties.name then
            mapInfo.name = data.properties.name
        end
    end
    
    if data.tilesets then
        for _, ts in ipairs(data.tilesets) do
            table.insert(mapInfo.tilesets, {
                firstgid = ts.firstgid or 1,
                name = ts.name or "tileset",
                source = ts.image,
                image = ts.image,
                tileWidth = ts.tilewidth,
                tileHeight = ts.tileheight,
                tileCount = ts.tilecount,
                columns = ts.columns
            })
        end
    end
    
    local tilesX = data.width or 32
    local tilesY = data.height or 32
    mapInfo.collisionMap = {}
    for y = 0, tilesY - 1 do
        mapInfo.collisionMap[y] = {}
        for x = 0, tilesX - 1 do
            mapInfo.collisionMap[y][x] = 0
        end
    end
    
    if data.layers then
        for _, layer in ipairs(data.layers) do
            if layer.type == "tilelayer" then
                local tiles = {}
                if layer.data then
                    if layer.encoding == "base64" then
                        tiles = TiledLoader.decodeBase64Layer(layer.data, layer.compression, tilesX, tilesY)
                    elseif layer.encoding == "csv" then
                        tiles = layer.data
                    else
                        tiles = layer.data
                    end
                end
                
                mapInfo.layers[layer.name] = {
                    width = layer.width,
                    height = layer.height,
                    tiles = tiles,
                    visible = layer.visible ~= false,
                    opacity = layer.opacity or 1
                }
            elseif layer.type == "objectgroup" and layer.objects then
                for _, obj in ipairs(layer.objects) do
                    TiledLoader.processTiledObject(obj, layer.name, mapInfo)
                end
            end
        end
    end
    
    if #mapInfo.spawnPoints == 0 then
        mapInfo.spawnPoints = {{x = mapInfo.width / 2, y = mapInfo.height / 2}}
    end
    
    return MapData.new(mapInfo)
end

function TiledLoader.decodeBase64Layer(data, compression, width, height)
    local decoded = TiledLoader.decodeBase64(data)
    local tiles = {}
    
    for i = 1, #decoded, 4 do
        local tileId = decoded[i] + decoded[i + 1] * 256 + decoded[i + 2] * 65536 + decoded[i + 3] * 16777216
        table.insert(tiles, tileId)
    end
    
    return tiles
end

function TiledLoader.processTiledObject(obj, layerName, mapInfo)
    local objType = obj.type or "generic"
    local objX = obj.x or 0
    local objY = obj.y or 0
    local objWidth = obj.width or mapInfo.tileSize
    local objHeight = obj.height or mapInfo.tileHeight or mapInfo.tileSize
    local objName = obj.name or ""
    local tileSize = mapInfo.tileSize
    local tilesX = math.floor(mapInfo.width / tileSize)
    local tilesY = math.floor(mapInfo.height / tileSize)
    
    if layerName == "collision" or objType == "collision" then
        local tileX = math.floor(objX / tileSize)
        local tileY = math.floor(objY / tileSize)
        local tilesW = math.ceil(objWidth / tileSize)
        local tilesH = math.ceil(objHeight / tileSize)
        
        for ty = tileY, math.min(tileY + tilesH - 1, tilesY - 1) do
            for tx = tileX, math.min(tileX + tilesW - 1, tilesX - 1) do
                if mapInfo.collisionMap[ty] then
                    mapInfo.collisionMap[ty][tx] = 1
                end
            end
        end
    elseif layerName == "spawn" or objType == "spawn" then
        table.insert(mapInfo.spawnPoints, {x = objX, y = objY})
    elseif layerName == "npcs" or objType == "npc" then
        table.insert(mapInfo.npcs, {
            x = objX,
            y = objY,
            name = objName,
            properties = obj.properties
        })
    elseif layerName == "encounter" or objType == "encounter" then
        table.insert(mapInfo.encounterZones, {
            x = objX + objWidth / 2,
            y = objY + objHeight / 2,
            radius = math.min(objWidth, objHeight) / 2
        })
    elseif layerName == "teleport" or objType == "teleport" then
        table.insert(mapInfo.teleports, {
            x = objX,
            y = objY,
            width = objWidth,
            height = objHeight,
            name = objName,
            properties = obj.properties
        })
    elseif objType == "building" then
        table.insert(mapInfo.buildings, {
            x = objX,
            y = objY,
            width = objWidth,
            height = objHeight,
            color = {0.7, 0.5, 0.3},
            name = objName
        })
    else
        table.insert(mapInfo.objects, {
            type = objType,
            name = objName,
            x = objX,
            y = objY,
            width = objWidth,
            height = objHeight,
            properties = obj.properties
        })
    end
end

function TiledLoader.parseTMX(content)
    local MapData = require("map.map_data")
    
    local mapInfo = {
        width = 0,
        height = 0,
        tileSize = 32,
        layers = {},
        tilesets = {},
        objects = {},
        buildings = {},
        collisionMap = {},
        spawnPoints = {},
        npcs = {},
        encounterZones = {},
        teleports = {},
        season = "spring"
    }
    
    local mapTag = content:match('<map[^>]*>')
    if mapTag then
        mapInfo.width = tonumber(mapTag:match('width="(%d+)"')) or 32
        mapInfo.height = tonumber(mapTag:match('height="(%d+)"')) or 32
        mapInfo.tileSize = tonumber(mapTag:match('tilewidth="(%d+)"')) or 32
        mapInfo.width = mapInfo.width * mapInfo.tileSize
        mapInfo.height = mapInfo.height * mapInfo.tileSize
    end
    
    local properties = content:match('<properties>(.-)</properties>')
    if properties then
        for name, value in properties:gmatch('<property name="([^"]+)" value="([^"]+)"/>') do
            if name == "season" then
                mapInfo.season = value
            elseif name == "name" then
                mapInfo.name = value
            end
        end
    end
    
    for tileset in content:gmatch('<tileset[^>]*>(.-)</tileset>') do
        local firstgid = tonumber(tileset:match('firstgid="(%d+)"')) or 1
        local name = tileset:match('name="([^"]*)"') or "tileset"
        local source = tileset:match('source="([^"]*)"')
        
        table.insert(mapInfo.tilesets, {
            firstgid = firstgid,
            name = name,
            source = source
        })
    end
    
    local tilesX = math.floor(mapInfo.width / mapInfo.tileSize)
    local tilesY = math.floor(mapInfo.height / mapInfo.tileSize)
    mapInfo.collisionMap = {}
    for y = 0, tilesY - 1 do
        mapInfo.collisionMap[y] = {}
        for x = 0, tilesX - 1 do
            mapInfo.collisionMap[y][x] = 0
        end
    end
    
    for layer in content:gmatch('<layer[^>]*>(.-)</layer>') do
        local layerName = layer:match('name="([^"]*)"') or "unnamed"
        local layerWidth = tonumber(layer:match('width="(%d+)"')) or tilesX
        local layerHeight = tonumber(layer:match('height="(%d+)"')) or tilesY
        
        local encoding = layer:match('encoding="([^"]*)"')
        local compression = layer:match('compression="([^"]*)"')
        local rawData = layer:match('<data[^>]*>(.-)</data>')
        if rawData then
            rawData = rawData:gsub("^%s+", ""):gsub("%s+$", "")
        end
        
        local tiles = {}
        if encoding then
            tiles = decodeLayerData(encoding, compression, rawData or "", layerWidth, layerHeight)
        end
        
        mapInfo.layers[layerName] = {
            width = layerWidth,
            height = layerHeight,
            tiles = tiles,
            encoding = encoding
        }
    end
    
    for objectGroup in content:gmatch('<objectgroup[^>]*>(.-)</objectgroup>') do
        local groupName = objectGroup:match('name="([^"]*)"') or "objects"
        
        for obj in objectGroup:gmatch('<object[^>]*/>') do
            local objType = obj:match('type="([^"]*)"') or "generic"
            local objX = tonumber(obj:match('x="(%d+)"')) or 0
            local objY = tonumber(obj:match('y="(%d+)"')) or 0
            local objWidth = tonumber(obj:match('width="(%d+)"')) or mapInfo.tileSize
            local objHeight = tonumber(obj:match('height="(%d+)"')) or mapInfo.tileSize
            local objName = obj:match('name="([^"]*)"') or ""
            
            local newObj = {
                type = objType,
                name = objName,
                x = objX,
                y = objY,
                width = objWidth,
                height = objHeight
            }
            
            if groupName == "collision" or objType == "collision" then
                local tileX = math.floor(objX / mapInfo.tileSize)
                local tileY = math.floor(objY / mapInfo.tileSize)
                local tilesW = math.ceil(objWidth / mapInfo.tileSize)
                local tilesH = math.ceil(objHeight / mapInfo.tileSize)
                
                for ty = tileY, math.min(tileY + tilesH - 1, tilesY - 1) do
                    for tx = tileX, math.min(tileX + tilesW - 1, tilesX - 1) do
                        if mapInfo.collisionMap[ty] then
                            mapInfo.collisionMap[ty][tx] = 1
                        end
                    end
                end
            elseif groupName == "spawn" or objType == "spawn" then
                table.insert(mapInfo.spawnPoints, {x = objX, y = objY})
            elseif groupName == "npcs" or objType == "npc" then
                table.insert(mapInfo.npcs, {
                    x = objX,
                    y = objY,
                    name = objName
                })
            elseif groupName == "encounter" or objType == "encounter" then
                table.insert(mapInfo.encounterZones, {
                    x = objX + objWidth / 2,
                    y = objY + objHeight / 2,
                    radius = math.min(objWidth, objHeight) / 2
                })
            elseif groupName == "teleport" or objType == "teleport" then
                table.insert(mapInfo.teleports, {
                    x = objX,
                    y = objY,
                    width = objWidth,
                    height = objHeight,
                    name = objName
                })
            elseif objType == "building" then
                table.insert(mapInfo.buildings, {
                    x = objX,
                    y = objY,
                    width = objWidth,
                    height = objHeight,
                    color = {0.7, 0.5, 0.3},
                    name = objName
                })
            else
                table.insert(mapInfo.objects, newObj)
            end
        end
    end
    
    if #mapInfo.spawnPoints == 0 then
        mapInfo.spawnPoints = {{x = mapInfo.width / 2, y = mapInfo.height / 2}}
    end
    
    return MapData.new(mapInfo)
end

function TiledLoader.loadTileset(filepath)
    if not love.filesystem.getInfo(filepath) then
        print("Warning: Tileset file not found: " .. filepath)
        return nil
    end
    
    local content = love.filesystem.read(filepath)
    if not content then
        return nil
    end
    
    local tileset = {
        name = "",
        image = "",
        tileWidth = 32,
        tileHeight = 32,
        tileCount = 0,
        columns = 0,
        firstgid = 1
    }
    
    local imageTag = content:match('<image[^>]*>')
    if imageTag then
        tileset.image = imageTag:match('source="([^"]*)"') or ""
    end
    
    local tsTag = content:match('<tileset[^>]*>')
    if tsTag then
        tileset.name = tsTag:match('name="([^"]*)"') or ""
        tileset.tileWidth = tonumber(tsTag:match('tilewidth="(%d+)"')) or 32
        tileset.tileHeight = tonumber(tsTag:match('tileheight="(%d+)"')) or 32
        tileset.tileCount = tonumber(tsTag:match('tilecount="(%d+)"')) or 0
        tileset.columns = tonumber(tsTag:match('columns="(%d+)"')) or 0
    end
    
    if tileset.image ~= "" then
        local imagePath = filepath:match("(.-)[^/]+$") .. tileset.image
        local success, image = pcall(love.graphics.newImage, imagePath)
        if success then
            tileset.imageData = image
        end
    end
    
    return tileset
end

function TiledLoader.createObjectLayer(name, objects)
    return {
        name = name,
        type = "objectgroup",
        objects = objects or {},
        visible = true,
        opacity = 1
    }
end

function TiledLoader.exportToTMX(map, filepath)
    local tmx = {}
    
    table.insert(tmx, '<?xml version="1.0" encoding="UTF-8"?>')
    table.insert(tmx, string.format(
        '<map version="1.5" tiledversion="1.7.2" orientation="orthogonal" ' ..
        'renderorder="right-down" width="%d" height="%d" tilewidth="%d" tileheight="%d">',
        math.floor(map.width / map.tileSize),
        math.floor(map.height / map.tileSize),
        map.tileSize, map.tileSize
    ))
    
    table.insert(tmx, '  <properties>')
    if map.season then
        table.insert(tmx, string.format('    <property name="season" value="%s"/>', map.season))
    end
    if map.name then
        table.insert(tmx, string.format('    <property name="name" value="%s"/>', map.name))
    end
    table.insert(tmx, '  </properties>')
    
    for _, layer in pairs(map.layers or {}) do
        table.insert(tmx, string.format(
            '  <layer name="%s" width="%d" height="%d">',
            layer.name or "layer",
            math.floor(map.width / map.tileSize),
            math.floor(map.height / map.tileSize)
        ))
        table.insert(tmx, '    <data encoding="csv">')
        if layer.tiles and #layer.tiles > 0 then
            table.insert(tmx, "      " .. table.concat(layer.tiles, ","))
        end
        table.insert(tmx, '    </data>')
        table.insert(tmx, '  </layer>')
    end
    
    table.insert(tmx, '</map>')
    
    local content = table.concat(tmx, "\n")
    
    if filepath then
        love.filesystem.write(filepath, content)
    end
    
    return content
end

function TiledLoader.exportToJSON(map, filepath)
    local tilesX = math.floor(map.width / map.tileSize)
    local tilesY = math.floor(map.height / map.tileSize)
    
    local jsonData = {
        compressionlevel = -1,
        height = tilesY,
        infinite = false,
        layers = {},
        nextlayerid = 1,
        nextobjectid = 1,
        orientation = "orthogonal",
        renderorder = "right-down",
        tiledversion = "1.10.2",
        tileheight = map.tileSize,
        tilesets = {},
        tilewidth = map.tileSize,
        type = "map",
        version = "1.10",
        width = tilesX,
        properties = {}
    }
    
    if map.season then
        jsonData.properties.season = map.season
    end
    if map.name then
        jsonData.properties.name = map.name
    end
    
    local layerId = 1
    for layerName, layer in pairs(map.layers or {}) do
        table.insert(jsonData.layers, {
            id = layerId,
            name = layerName,
            type = "tilelayer",
            data = layer.tiles or {},
            width = layer.width or tilesX,
            height = layer.height or tilesY,
            opacity = layer.opacity or 1,
            visible = layer.visible ~= false,
            x = 0,
            y = 0
        })
        layerId = layerId + 1
    end
    
    local content = json.encode(jsonData)
    
    if filepath then
        love.filesystem.write(filepath, content)
    end
    
    return content
end

function TiledLoader.isSTIAvailable()
    return stiAvailable
end

function TiledLoader.getSupportedFormats()
    return {
        {ext = ".tmx", desc = "Tiled XML format"},
        {ext = ".json", desc = "Tiled JSON format (recommended)"},
        {ext = ".lua", desc = "Tiled Lua export"}
    }
end

return TiledLoader
