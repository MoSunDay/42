-- test_battle.lua - Test battle system
-- Run: cd game/tools && lua test_battle.lua

package.path = package.path .. ";../src/?.lua;../src/entities/?.lua;../src/systems/?.lua"

local Enemy = require("enemy")

print("=== Battle System Test ===")
print()

-- Test 1: Create enemy
print("1. Creating enemy...")
local slime = Enemy.new("slime")
print("   Created: " .. slime.name)
print("   HP: " .. slime.hp .. "/" .. slime.maxHp)
print("   Attack: " .. slime.attack)
print("   Defense: " .. slime.defense)
print("   ✓ Enemy created")
print()

-- Test 2: Check isAlive method
print("2. Testing isAlive method...")
if slime:isAlive() then
    print("   ✓ Enemy is alive (HP: " .. slime.hp .. ")")
else
    print("   ✗ ERROR: Enemy should be alive!")
end
print()

-- Test 3: Take damage
print("3. Testing damage...")
local damage = slime:takeDamage(10)
print("   Took " .. damage .. " damage")
print("   HP: " .. slime.hp .. "/" .. slime.maxHp)
if slime:isAlive() then
    print("   ✓ Enemy still alive")
else
    print("   ✗ ERROR: Enemy should still be alive!")
end
print()

-- Test 4: Defeat enemy
print("4. Testing defeat...")
slime:takeDamage(100)
print("   HP: " .. slime.hp .. "/" .. slime.maxHp)
if not slime:isAlive() then
    print("   ✓ Enemy defeated correctly")
else
    print("   ✗ ERROR: Enemy should be dead!")
end
print()

-- Test 5: Create all enemy types
print("5. Testing all enemy types...")
local types = {"slime", "goblin", "skeleton", "orc"}
for _, type in ipairs(types) do
    local enemy = Enemy.new(type)
    if enemy:isAlive() then
        print("   ✓ " .. enemy.name .. " created (HP: " .. enemy.hp .. ")")
    else
        print("   ✗ ERROR: " .. type .. " should be alive!")
    end
end
print()

-- Test 6: Random enemy generation
print("6. Testing random enemy generation...")
for i = 1, 5 do
    local randomType = Enemy.getRandomType()
    local enemy = Enemy.new(randomType)
    print("   " .. i .. ". " .. enemy.name .. " (HP: " .. enemy.hp .. ", ATK: " .. enemy.attack .. ")")
end
print()

print("=== All Tests Complete! ===")
print()
print("If all tests passed, the battle system should work correctly.")
print("Run the game and walk around to trigger battles!")

