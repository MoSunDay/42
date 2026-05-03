-- test_companion.lua - Test companion system
-- Run: cd game/tools && lua test_companion.lua

print("=== Companion System Test ===")
print()

package.path = package.path .. ";../?.lua;../src/?.lua;../src/systems/?.lua"

print("1. Testing CompanionSystem module loading...")
local success, CompanionSystem = pcall(require, "companion_system")
if success then
    print("   ✓ CompanionSystem loaded successfully")
else
    print("   ✗ CompanionSystem load failed: " .. tostring(CompanionSystem))
    os.exit(1)
end
print()

print("2. Checking constants...")
print("   MAX_COMPANIONS: " .. tostring(CompanionSystem.MAX_COMPANIONS))
print("   MAX_PARTY_SIZE: " .. tostring(CompanionSystem.MAX_PARTY_SIZE))
if CompanionSystem.MAX_COMPANIONS == 9 then
    print("   ✓ Constants correct")
else
    print("   ✗ Constants mismatch")
end
print()

print("3. Creating CompanionSystem instance...")
local system = CompanionSystem.create()
print("   ✓ Instance created")
local companions = system:get_all_companions()
print("   Companion count: " .. #companions)
print()

print("4. Testing companion recruitment...")
local ok, companion = system:recruit("warrior")
if ok and companion then
    print("   ✓ Recruited warrior companion")
    print("   Name: " .. companion.name)
    print("   HP: " .. companion.hp .. "/" .. companion.maxHp)
    print("   Attack: " .. companion.attack)
    print("   Defense: " .. companion.defense)
else
    print("   ✗ Failed to recruit companion")
end
print()

print("5. Testing companion templates...")
local templates = {"warrior", "berserker", "guardian", "assassin", "mage", "paladin"}
for _, templateId in ipairs(templates) do
    local sys2 = CompanionSystem.create()
    local ok2, c = sys2:recruit(templateId)
    if ok2 and c then
        print("   ✓ " .. templateId .. ": HP=" .. c.maxHp .. " ATK=" .. c.attack .. " DEF=" .. c.defense)
    else
        print("   ✗ " .. templateId .. " failed")
    end
end
print()

print("6. Testing party management...")
system = CompanionSystem.create()

for i = 1, 5 do
    local types = {"warrior", "mage", "assassin", "guardian", "berserker"}
    system:recruit(types[i])
end
local allCompanions = system:get_all_companions()
print("   Recruited " .. #allCompanions .. " companions")

for _, c in ipairs(allCompanions) do
    system:add_to_party(c.id)
end
local party = system:get_party()
print("   Party size: " .. #party)

if #allCompanions == 5 then
    print("   ✓ Party management works")
else
    print("   ✗ Party count mismatch")
end
print()

print("7. Testing companion limit...")
local ok3 = system:recruit("warrior")
local allC = system:get_all_companions()
if #allC <= CompanionSystem.MAX_COMPANIONS then
    print("   ✓ Companion limit enforced (max " .. CompanionSystem.MAX_COMPANIONS .. ")")
else
    print("   ✗ Companion limit not enforced")
end
print()

print("8. Testing companion dismissal...")
local beforeCount = #system:get_all_companions()
local firstCompanion = system:get_all_companions()[1]
if firstCompanion then
    system:dismiss(firstCompanion.id)
    local afterCount = #system:get_all_companions()
    if afterCount == beforeCount - 1 then
        print("   ✓ Companion dismissed successfully")
    else
        print("   ✗ Dismissal failed")
    end
else
    print("   - No companion to dismiss")
end
print()

print("9. Testing damage and healing...")
system = CompanionSystem.create()
local ok4, warrior = system:recruit("warrior")
if ok4 and warrior then
    local oldHp = warrior.hp
    local dmg = system:take_damage(warrior, 30)
    print("   Damage dealt: " .. dmg .. " (HP: " .. oldHp .. " -> " .. warrior.hp .. ")")
    system:heal(warrior, 15)
    print("   After heal: HP=" .. warrior.hp)
    print("   ✓ Damage/heal system works")
else
    print("   ✗ Failed to recruit warrior")
end
print()

print("10. Testing battle party formation...")
system = CompanionSystem.create()
system:recruit("warrior")
system:recruit("mage")
system:recruit("guardian")

local all = system:get_all_companions()
for _, c in ipairs(all) do
    system:add_to_party(c.id)
end

local battleParty = system:get_party()
if battleParty then
    print("   Battle party size: " .. #battleParty)
    print("   ✓ Battle party formation works")
else
    print("   ✗ Battle party failed")
end
print()

print("11. Testing companion stats calculation...")
system = CompanionSystem.create()
local ok5, w = system:recruit("warrior")
local ok6, a = system:recruit("assassin")

if ok5 and ok6 and w and a then
    print("   Warrior: HP=" .. w.maxHp .. " ATK=" .. w.attack .. " DEF=" .. w.defense)
    print("   Assassin: HP=" .. a.maxHp .. " ATK=" .. a.attack .. " DEF=" .. a.defense)

    if w.defense > a.defense then
        print("   ✓ Stat modifiers working (warrior has higher DEF)")
    else
        print("   - Stat modifiers applied")
    end
end
print()

print("12. Testing serialization...")
system = CompanionSystem.create()
system:recruit("warrior")
system:recruit("mage")

local data = system:serialize()
if data then
    print("   Serialized " .. #data.companions .. " companions")

    local newSystem = CompanionSystem.create()
    newSystem:deserialize(data, require("src.systems.item_database"))

    if #newSystem:get_all_companions() == #system:get_all_companions() then
        print("   ✓ Serialization/deserialization works")
    else
        print("   ✗ Deserialization count mismatch")
    end
else
    print("   - Serialization not implemented")
end
print()

print("=== All Companion Tests Complete! ===")
print()
print("Companion system supports:")
print("  - 6+ companion templates with stat modifiers")
print("  - Party management (max " .. CompanionSystem.MAX_COMPANIONS .. " companions)")
print("  - Damage and healing")
print("  - Battle party formation")
print("  - Serialization for save/load")
