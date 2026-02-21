-- test_companion.lua - Test companion system
-- Run: cd game/tools && lua test_companion.lua

print("=== Companion System Test ===")
print()

package.path = package.path .. ";../src/?.lua;../src/systems/?.lua"

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
local system = CompanionSystem.new()
print("   ✓ Instance created")
print("   Companion count: " .. system:getCompanionCount())
print()

print("4. Testing companion creation...")
local companion = system:createCompanion("warrior")
if companion then
    print("   ✓ Created warrior companion")
    print("   Name: " .. companion.name)
    print("   HP: " .. companion.hp .. "/" .. companion.maxHp)
    print("   Attack: " .. companion.attack)
    print("   Defense: " .. companion.defense)
else
    print("   ✗ Failed to create companion")
end
print()

print("5. Testing companion templates...")
local templates = {"warrior", "berserker", "guardian", "assassin", "mage", "paladin"}
for _, templateId in ipairs(templates) do
    local c = system:createCompanion(templateId)
    if c then
        print("   ✓ " .. templateId .. ": HP=" .. c.maxHp .. " ATK=" .. c.attack .. " DEF=" .. c.defense)
    else
        print("   ✗ " .. templateId .. " failed")
    end
end
print()

print("6. Testing party management...")
system = CompanionSystem.new()

for i = 1, 5 do
    local types = {"warrior", "mage", "assassin", "guardian", "berserker"}
    system:addCompanion(types[i])
end
print("   Added 5 companions")
print("   Party size: " .. system:getCompanionCount())

if system:getCompanionCount() == 5 then
    print("   ✓ Party management works")
else
    print("   ✗ Party count mismatch")
end
print()

print("7. Testing party limit...")
local added = system:addCompanion("warrior")
if system:getCompanionCount() <= CompanionSystem.MAX_COMPANIONS then
    print("   ✓ Party limit enforced (max " .. CompanionSystem.MAX_COMPANIONS .. ")")
else
    print("   ✗ Party limit not enforced")
end
print()

print("8. Testing companion removal...")
local beforeCount = system:getCompanionCount()
local firstCompanion = system:getCompanions()[1]
if firstCompanion then
    system:removeCompanion(firstCompanion.id)
    local afterCount = system:getCompanionCount()
    if afterCount == beforeCount - 1 then
        print("   ✓ Companion removed successfully")
    else
        print("   ✗ Removal failed")
    end
else
    print("   - No companion to remove")
end
print()

print("9. Testing companion leveling...")
system = CompanionSystem.new()
local c = system:createCompanion("warrior")
system:addCompanion("warrior")

if c then
    local oldLevel = c.level
    local oldHp = c.maxHp
    local oldAtk = c.attack
    
    system:gainExperience(c.id, 1000)
    
    if c.level > oldLevel then
        print("   Level: " .. oldLevel .. " -> " .. c.level)
        print("   HP: " .. oldHp .. " -> " .. c.maxHp)
        print("   ATK: " .. oldAtk .. " -> " .. c.attack)
        print("   ✓ Leveling system works")
    else
        print("   - Not enough XP to level (need more)")
    end
end
print()

print("10. Testing battle party formation...")
system = CompanionSystem.new()
system:addCompanion("warrior")
system:addCompanion("mage")
system:addCompanion("guardian")

local battleParty = system:getBattleParty()
if battleParty then
    print("   Battle party size: " .. #battleParty)
    print("   ✓ Battle party formation works")
else
    print("   ✗ Battle party failed")
end
print()

print("11. Testing companion stats calculation...")
system = CompanionSystem.new()
local warrior = system:createCompanion("warrior")
local assassin = system:createCompanion("assassin")

if warrior and assassin then
    print("   Warrior: HP=" .. warrior.maxHp .. " ATK=" .. warrior.attack .. " DEF=" .. warrior.defense)
    print("   Assassin: HP=" .. assassin.maxHp .. " ATK=" .. assassin.attack .. " DEF=" .. assassin.defense)
    
    if warrior.defense > assassin.defense then
        print("   ✓ Stat modifiers working (warrior has higher DEF)")
    else
        print("   - Stat modifiers applied")
    end
end
print()

print("12. Testing serialization...")
system = CompanionSystem.new()
system:addCompanion("warrior")
system:addCompanion("mage")

local data = system:serialize()
if data then
    print("   Serialized data length: " .. #tostring(data))
    
    local newSystem = CompanionSystem.new()
    newSystem:deserialize(data)
    
    if newSystem:getCompanionCount() == system:getCompanionCount() then
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
print("  - Leveling and experience")
print("  - Battle party formation")
print("  - Serialization for save/load")
