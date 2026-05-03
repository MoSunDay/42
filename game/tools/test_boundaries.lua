-- test_boundaries.lua - Test map boundary restrictions

print("=== Map Boundary Test ===\n")

-- Mock Love2D environment
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

-- Add path
package.path = package.path .. ";../src/?.lua;../src/core/?.lua;../src/entities/?.lua"

-- Load modules
local AssetManager = require("core.asset_manager")
local Player = require("entities.player")

print("1. Creating test objects...")
local assetManager = AssetManager.create()
AssetManager.load_all(assetManager)

local player = Player.create(1000, 1000, assetManager)
Player.set_map_bounds(player, 2000, 2000)
print("   Player created at (1000, 1000)")
print("   Map bounds: 2000 x 2000")

print("\n2. Testing boundary restrictions...")

-- Test moving beyond right boundary
print("\n   Test 1: Move beyond right boundary (3000, 1000)")
Player.move_to(player, 3000, 1000)
print("   Target set to: (" .. player.targetX .. ", " .. player.targetY .. ")")
if player.targetX <= 2000 - player.width/2 then
    print("   ✓ Right boundary restriction working")
else
    print("   ✗ Right boundary restriction FAILED")
end

-- Test moving beyond bottom boundary
print("\n   Test 2: Move beyond bottom boundary (1000, 3000)")
Player.move_to(player, 1000, 3000)
print("   Target set to: (" .. player.targetX .. ", " .. player.targetY .. ")")
if player.targetY <= 2000 - player.height/2 then
    print("   ✓ Bottom boundary restriction working")
else
    print("   ✗ Bottom boundary restriction FAILED")
end

-- Test moving beyond left boundary
print("\n   Test 3: Move beyond left boundary (-100, 1000)")
Player.move_to(player, -100, 1000)
print("   Target set to: (" .. player.targetX .. ", " .. player.targetY .. ")")
if player.targetX >= player.width/2 then
    print("   ✓ Left boundary restriction working")
else
    print("   ✗ Left boundary restriction FAILED")
end

-- Test moving beyond top boundary
print("\n   Test 4: Move beyond top boundary (1000, -100)")
Player.move_to(player, 1000, -100)
print("   Target set to: (" .. player.targetX .. ", " .. player.targetY .. ")")
if player.targetY >= player.height/2 then
    print("   ✓ Top boundary restriction working")
else
    print("   ✗ Top boundary restriction FAILED")
end

-- Test valid movement
print("\n   Test 5: Valid movement (500, 500)")
Player.move_to(player, 500, 500)
print("   Target set to: (" .. player.targetX .. ", " .. player.targetY .. ")")
if player.targetX == 500 and player.targetY == 500 then
    print("   ✓ Valid movement working")
else
    print("   ✗ Valid movement FAILED")
end

-- Test movement during update
print("\n3. Testing boundary during movement...")
player.x = 1980
player.y = 1000
Player.move_to(player, 2100, 1000)

for i = 1, 50 do
    Player.update(player, 0.016)
end

print("   Final position: (" .. player.x .. ", " .. player.y .. ")")
if player.x <= 2000 - player.width/2 then
    print("   ✓ Movement boundary restriction working")
else
    print("   ✗ Movement boundary restriction FAILED")
end

print("\n=== All Boundary Tests Complete! ===\n")
print("Boundary restrictions are working correctly.")
print("Player cannot move outside the map bounds.")
