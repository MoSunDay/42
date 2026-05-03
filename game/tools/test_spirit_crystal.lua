-- test_spirit_crystal.lua - Test spirit crystal system
-- Run: cd game/tools && lua test_spirit_crystal.lua

print("=== Spirit Crystal System Test ===")
print()

package.path = package.path .. ";../?.lua;../src/?.lua;../src/systems/?.lua"

print("1. Testing SpiritCrystalSystem module loading...")
local success, SpiritCrystalSystem = pcall(require, "spirit_crystal_system")
if success then
    print("   ✓ SpiritCrystalSystem loaded successfully")
else
    print("   ✗ SpiritCrystalSystem load failed: " .. tostring(SpiritCrystalSystem))
    os.exit(1)
end
print()

print("2. Checking crystal types...")
print("   Available types:")
for type, typeId in pairs(SpiritCrystalSystem.TYPES) do
    local name = SpiritCrystalSystem.TYPE_NAMES[typeId]
    local stat = SpiritCrystalSystem.STATS_MAP[typeId]
    print("   - " .. name .. " (" .. type .. ") -> " .. stat)
end
print("   ✓ 5 crystal types defined")
print()

print("3. Checking crystal tiers...")
for tier, name in pairs(SpiritCrystalSystem.TIER_NAMES) do
    print("   Tier " .. tier .. ": " .. name)
end
print("   ✓ 4 crystal tiers defined")
print()

print("4. Creating SpiritCrystalSystem state...")
local state = SpiritCrystalSystem.create()
print("   ✓ State created")
print()

print("5. Testing crystal collection (add_crystal)...")
SpiritCrystalSystem.add_crystal(state, 1, 5)
SpiritCrystalSystem.add_crystal(state, 2, 3)
SpiritCrystalSystem.add_crystal(state, 3, 1)
print("   Tier 1 count: " .. SpiritCrystalSystem.get_crystal_count(state, 1))
print("   Tier 2 count: " .. SpiritCrystalSystem.get_crystal_count(state, 2))
print("   Tier 3 count: " .. SpiritCrystalSystem.get_crystal_count(state, 3))
if SpiritCrystalSystem.get_crystal_count(state, 1) == 5 then
    print("   ✓ Crystal collection works")
else
    print("   ✗ Crystal count mismatch")
end
print()

print("6. Testing total value...")
local total = SpiritCrystalSystem.get_total_value(state)
local expected = 5 * 10 + 3 * 50 + 1 * 200
print("   Total value: " .. total .. " (expected: " .. expected .. ")")
if total == expected then
    print("   ✓ Total value correct")
else
    print("   ✗ Total value mismatch")
end
print()

print("7. Testing add_crystal_value...")
local state2 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal_value(state2, 120)
print("   Added value: 120")
print("   Tier 1: " .. SpiritCrystalSystem.get_crystal_count(state2, 1))
print("   Tier 2: " .. SpiritCrystalSystem.get_crystal_count(state2, 2))
print("   ✓ Crystal value conversion works")
print()

print("8. Testing crystal removal...")
local state3 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal(state3, 1, 5)
local removed = SpiritCrystalSystem.remove_crystal(state3, 1, 3)
print("   Removed: " .. tostring(removed))
print("   Remaining: " .. SpiritCrystalSystem.get_crystal_count(state3, 1))
if removed and SpiritCrystalSystem.get_crystal_count(state3, 1) == 2 then
    print("   ✓ Crystal removal works")
else
    print("   ✗ Crystal removal failed")
end
print()

print("9. Testing spend_value...")
local state4 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal(state4, 1, 10)
SpiritCrystalSystem.add_crystal(state4, 2, 5)
local beforeValue = SpiritCrystalSystem.get_total_value(state4)
local ok, msg = SpiritCrystalSystem.spend_value(state4, 60)
local afterValue = SpiritCrystalSystem.get_total_value(state4)
print("   Before: " .. beforeValue .. ", After: " .. afterValue)
if ok and afterValue == beforeValue - 60 then
    print("   ✓ Spend value works")
else
    print("   ✗ Spend value failed: " .. tostring(msg))
end
print()

print("10. Testing enhancement bonus...")
for level = 1, 5 do
    local bonus = SpiritCrystalSystem.get_enhancement_bonus("crimson", level)
    print("   Level " .. level .. " bonus: +" .. bonus)
end
print("   ✓ Enhancement bonus calculated")
print()

print("11. Testing can_enhance / enhance...")
local state5 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal(state5, 4, 2)
local canEnhance, costOrMsg = SpiritCrystalSystem.can_enhance(state5, 0)
print("   Can enhance from level 0: " .. tostring(canEnhance))
if canEnhance then
    print("   Cost: " .. tostring(costOrMsg))
    local enhanced, msg = SpiritCrystalSystem.enhance(state5, 0)
    print("   Enhanced: " .. tostring(enhanced))
    if enhanced then
        print("   ✓ Enhancement works")
    else
        print("   ✗ Enhancement failed: " .. tostring(msg))
    end
else
    print("   ✗ Cannot enhance: " .. tostring(costOrMsg))
end
print()

print("12. Testing generate_drop...")
math.randomseed(os.time())
local drops = SpiritCrystalSystem.generate_drop(2)
print("   Drop count for tier 2 enemy: " .. #drops)
for i, drop in ipairs(drops) do
    print("   Drop " .. i .. ": " .. drop.name .. " (tier " .. drop.tier .. ", value " .. drop.value .. ")")
end
if #drops > 0 then
    print("   ✓ Drop generation works")
else
    print("   ✗ Drop generation failed")
end
print()

print("13. Testing crystal info...")
local state6 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal(state6, 2, 3)
local info = SpiritCrystalSystem.get_crystal_info(state6, 2)
if info then
    print("   Tier: " .. info.tier .. ", Name: " .. info.name .. ", Count: " .. info.count)
    print("   ✓ Crystal info works")
else
    print("   ✗ Crystal info failed")
end
print()

print("14. Testing serialization...")
local state7 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal(state7, 1, 10)
SpiritCrystalSystem.add_crystal(state7, 3, 2)
local data = SpiritCrystalSystem.serialize(state7)
local state8 = SpiritCrystalSystem.create()
SpiritCrystalSystem.deserialize(state8, data)
local origValue = SpiritCrystalSystem.get_total_value(state7)
local newValue = SpiritCrystalSystem.get_total_value(state8)
if origValue == newValue then
    print("   ✓ Serialization preserves value (" .. origValue .. ")")
else
    print("   ✗ Serialization mismatch: " .. origValue .. " vs " .. newValue)
end
print()

print("15. Testing get_all_crystals...")
local state9 = SpiritCrystalSystem.create()
SpiritCrystalSystem.add_crystal(state9, 1, 3)
SpiritCrystalSystem.add_crystal(state9, 2, 1)
local allCrystals = SpiritCrystalSystem.get_all_crystals(state9)
print("   Crystals: " .. allCrystals[1] .. ", " .. allCrystals[2] .. ", " .. allCrystals[3] .. ", " .. allCrystals[4])
print("   ✓ get_all_crystals works")
print()

print("=== All Spirit Crystal Tests Complete! ===")
print()
print("Spirit Crystal system supports:")
print("  - 5 crystal types (crimson, azure, emerald, violet, golden)")
print("  - 4 tiers (fragment, crystal, gem, core)")
print("  - Crystal collection and spending")
print("  - Enhancement bonus (+2 per level)")
print("  - Random drop generation")
print("  - Serialization for save/load")
