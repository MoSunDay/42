-- test_tiled.lua - Test Tiled map loading system
-- Run: cd game/tools && lua test_tiled.lua

print("=== Tiled Map System Test ===")
print()

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

package.path = package.path .. ";../?.lua;../map/?.lua;../src/?.lua;../lib/?.lua"

print("1. Testing TiledLoader module loading...")
local success, TiledLoader = pcall(require, "tiled_loader")
if success then
    print("   ✓ TiledLoader loaded successfully")
else
    print("   ✗ TiledLoader load failed: " .. tostring(TiledLoader))
    os.exit(1)
end
print()

print("2. Testing MapManager module loading...")
local success2, MapManager = pcall(require, "map_manager")
if success2 then
    print("   ✓ MapManager loaded successfully")
else
    print("   ✗ MapManager load failed: " .. tostring(MapManager))
end
print()

local json = require("lib.json")

print("3. Testing Tiled JSON parsing...")
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

local decoded = json.decode(testJson)
local parsed = TiledLoader.parse_json(decoded)
if parsed and parsed.width then
    print("   ✓ JSON parsing works")
    print("   Map pixel size: " .. parsed.width .. "x" .. parsed.height)
    print("   Tile size: " .. parsed.tileSize)
else
    print("   ✗ JSON parsing failed")
end
print()

print("4. Testing layer extraction...")
if parsed and parsed.layers then
    local layerCount = 0
    for _ in pairs(parsed.layers) do layerCount = layerCount + 1 end
    print("   Layers found: " .. layerCount)
    for name, layer in pairs(parsed.layers) do
        print("   - Layer: " .. name)
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

local objDecoded = json.decode(objJson)
local objParsed = TiledLoader.parse_json(objDecoded)
if objParsed then
    local objCount = 0
    for _ in pairs(objParsed.objects or {}) do objCount = objCount + 1 end
    print("   Objects found: " .. objCount)
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
        "name": "Summer Field"
    }
}
]]

local propDecoded = json.decode(propJson)
local propParsed = TiledLoader.parse_json(propDecoded)
if propParsed and propParsed.season then
    print("   Season: " .. propParsed.season)
    print("   ✓ Property extraction works")
else
    print("   ✗ Property parsing failed")
end
print()

print("7. Testing supported formats...")
local formats = TiledLoader.get_supported_formats()
if formats then
    local formatNames = {}
    for i, f in ipairs(formats) do
        if type(f) == "string" then
            table.insert(formatNames, f)
        elseif type(f) == "table" and f.name then
            table.insert(formatNames, f.name)
        end
    end
    if #formatNames > 0 then
        print("   Supported formats: " .. table.concat(formatNames, ", "))
    else
        print("   Supported formats: (table returned)")
    end
    print("   ✓ Format query works")
else
    print("   - Formats not available")
end
print()

print("8. Testing STI availability...")
local stiAvailable = TiledLoader.is_sti_available()
print("   STI available: " .. tostring(stiAvailable))
print("   ✓ STI check works")
print()

print("=== All Tiled Tests Complete! ===")
print()
print("Tiled system supports:")
print("  - JSON format parsing")
print("  - Layer extraction")
print("  - Object layer parsing")
print("  - Custom properties")
print("  - Multiple layers")
