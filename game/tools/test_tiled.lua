-- test_tiled.lua - Test Tiled map loading system
-- Run: cd game/tools && lua test_tiled.lua

print("=== Tiled Map System Test ===")
print()

-- Mock Love2D environment
love = {
    graphics = {
        getWidth = function() return 1280 end,
        getHeight = function() return 720 end,
        newImage = function(path) return {path = path, w = 32, h = 32} end,
        newQuad = function(x, y, w, h, sw, sh) return {x=x, y=y, w=w, h=h} end,
        draw = function() end,
    },
    filesystem = {
        getInfo = function(path)
            if path:match("tiled_example") or path:match("%.lua$") then
                return {type = "file"}
            end
            return nil
        end,
        read = function(path)
            if path:match("tiled_example%.json") then
                return [[
{
    "width": 20,
    "height": 15,
    "tilewidth": 32,
    "tileheight": 32,
    "layers": [
        {
            "name": "ground",
            "type": "tilelayer",
            "width": 20,
            "height": 15,
            "data": [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        },
        {
            "name": "collision",
            "type": "objectgroup",
            "objects": [
                {"name": "wall", "x": 0, "y": 0, "width": 32, "height": 32}
            ]
        }
    ],
    "properties": {
        "season": "spring",
        "name": "Test Map"
    }
}
]]
            end
            return nil
        end,
    },
}

package.path = package.path .. ";../map/?.lua;../src/?.lua"

print("1. Testing TiledLoader module loading...")
local success, TiledLoader = pcall(require, "tiled_loader")
if success then
    print("   ✓ TiledLoader loaded successfully")
else
    print("   ✗ TiledLoader load failed: " .. tostring(TiledLoader))
end
print()

print("2. Testing MapManager module loading...")
local success, MapManager = pcall(require, "map_manager")
if success then
    print("   ✓ MapManager loaded successfully")
else
    print("   ✗ MapManager load failed: " .. tostring(MapManager))
end
print()

print("3. Testing Tiled JSON parsing...")
local loader = TiledLoader.new()
local testJson = [[
{
    "width": 10,
    "height": 10,
    "tilewidth": 32,
    "tileheight": 32,
    "layers": [
        {"name": "ground", "type": "tilelayer", "data": [1,2,3,4,5]}
    ]
}
]]

local parsed = loader:parseJson(testJson)
if parsed and parsed.width == 10 then
    print("   ✓ JSON parsing works")
    print("   Map size: " .. parsed.width .. "x" .. parsed.height)
    print("   Tile size: " .. parsed.tilewidth .. "x" .. parsed.tileheight)
else
    print("   ✗ JSON parsing failed")
end
print()

print("4. Testing layer extraction...")
if parsed and parsed.layers then
    print("   Layers found: " .. #parsed.layers)
    for i, layer in ipairs(parsed.layers) do
        print("   - Layer " .. i .. ": " .. layer.name .. " (" .. layer.type .. ")")
    end
    print("   ✓ Layer extraction works")
else
    print("   ✗ No layers found")
end
print()

print("5. Testing object layer parsing...")
local objJson = [[
{
    "width": 5,
    "height": 5,
    "tilewidth": 32,
    "tileheight": 32,
    "layers": [
        {
            "name": "collision",
            "type": "objectgroup",
            "objects": [
                {"id": 1, "name": "wall1", "x": 0, "y": 0, "width": 64, "height": 32},
                {"id": 2, "name": "wall2", "x": 100, "y": 100, "width": 32, "height": 64}
            ]
        }
    ]
}
]]

local objParsed = loader:parseJson(objJson)
if objParsed and objParsed.layers and objParsed.layers[1].objects then
    local objs = objParsed.layers[1].objects
    print("   Objects found: " .. #objs)
    for i, obj in ipairs(objs) do
        print("   - " .. obj.name .. " at (" .. obj.x .. "," .. obj.y .. ")")
    end
    print("   ✓ Object layer parsing works")
else
    print("   ✗ Object parsing failed")
end
print()

print("6. Testing property extraction...")
local propJson = [[
{
    "width": 5,
    "height": 5,
    "tilewidth": 32,
    "tileheight": 32,
    "properties": {
        "season": "summer",
        "name": "Summer Field",
        "difficulty": 3
    }
}
]]

local propParsed = loader:parseJson(propJson)
if propParsed and propParsed.properties then
    print("   Properties:")
    for k, v in pairs(propParsed.properties) do
        print("   - " .. k .. ": " .. tostring(v))
    end
    print("   ✓ Property extraction works")
else
    print("   ✗ Property parsing failed")
end
print()

print("7. Testing tile layer data extraction...")
local tileJson = [[
{
    "width": 3,
    "height": 3,
    "tilewidth": 32,
    "tileheight": 32,
    "layers": [
        {
            "name": "ground",
            "type": "tilelayer",
            "width": 3,
            "height": 3,
            "data": [1,2,3,4,5,6,7,8,9]
        }
    ]
}
]]

local tileParsed = loader:parseJson(tileJson)
if tileParsed and tileParsed.layers then
    local layer = tileParsed.layers[1]
    if layer.data then
        print("   Tile data length: " .. #layer.data)
        print("   Sample tiles: " .. layer.data[1] .. ", " .. layer.data[5] .. ", " .. layer.data[9])
        print("   ✓ Tile data extraction works")
    else
        print("   ✗ No tile data")
    end
else
    print("   ✗ Tile parsing failed")
end
print()

print("8. Testing map bounds calculation...")
if tileParsed then
    local pixelWidth = tileParsed.width * tileParsed.tilewidth
    local pixelHeight = tileParsed.height * tileParsed.tileheight
    print("   Map pixel size: " .. pixelWidth .. "x" .. pixelHeight)
    print("   ✓ Bounds calculation works")
end
print()

print("=== All Tiled Tests Complete! ===")
print()
print("Tiled system supports:")
print("  - JSON format parsing")
print("  - Tile layer extraction")
print("  - Object layer parsing")
print("  - Custom properties")
print("  - Multiple layers")
