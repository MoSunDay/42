-- equipment_system.lua - Equipment management system
-- Handles equipment slots, stats bonuses, and equipment database

local EquipmentSystem = {}
EquipmentSystem.__index = EquipmentSystem

-- Equipment slots
local EQUIPMENT_SLOTS = {
    WEAPON = "weapon",
    ARMOR = "armor",
    NECKLACE = "necklace"
}

-- Equipment database
local EQUIPMENT_DATABASE = {
    -- Weapons
    wooden_sword = {
        id = "wooden_sword",
        name = "Wooden Sword",
        slot = EQUIPMENT_SLOTS.WEAPON,
        attack = 5,
        defense = 0,
        speed = 0,
        price = 50,
        description = "A simple wooden training sword"
    },
    iron_sword = {
        id = "iron_sword",
        name = "Iron Sword",
        slot = EQUIPMENT_SLOTS.WEAPON,
        attack = 10,
        defense = 0,
        speed = 0,
        price = 150,
        description = "A sturdy iron sword"
    },
    steel_sword = {
        id = "steel_sword",
        name = "Steel Sword",
        slot = EQUIPMENT_SLOTS.WEAPON,
        attack = 18,
        defense = 0,
        speed = 1,
        price = 350,
        description = "A well-crafted steel blade"
    },
    
    -- Armor
    leather_armor = {
        id = "leather_armor",
        name = "Leather Armor",
        slot = EQUIPMENT_SLOTS.ARMOR,
        attack = 0,
        defense = 5,
        speed = 0,
        price = 80,
        description = "Light leather protection"
    },
    chain_mail = {
        id = "chain_mail",
        name = "Chain Mail",
        slot = EQUIPMENT_SLOTS.ARMOR,
        attack = 0,
        defense = 12,
        speed = -1,
        price = 200,
        description = "Heavy chain mail armor"
    },
    plate_armor = {
        id = "plate_armor",
        name = "Plate Armor",
        slot = EQUIPMENT_SLOTS.ARMOR,
        attack = 0,
        defense = 20,
        speed = -2,
        price = 500,
        description = "Full plate armor, very heavy"
    },
    
    -- Necklaces
    copper_necklace = {
        id = "copper_necklace",
        name = "Copper Necklace",
        slot = EQUIPMENT_SLOTS.NECKLACE,
        attack = 2,
        defense = 2,
        speed = 0,
        price = 100,
        description = "A simple copper necklace"
    },
    silver_necklace = {
        id = "silver_necklace",
        name = "Silver Necklace",
        slot = EQUIPMENT_SLOTS.NECKLACE,
        attack = 4,
        defense = 4,
        speed = 1,
        price = 250,
        description = "A shiny silver necklace"
    },
    gold_necklace = {
        id = "gold_necklace",
        name = "Gold Necklace",
        slot = EQUIPMENT_SLOTS.NECKLACE,
        attack = 6,
        defense = 6,
        speed = 2,
        price = 600,
        description = "A precious gold necklace"
    }
}

function EquipmentSystem.new()
    local self = setmetatable({}, EquipmentSystem)
    
    -- Equipped items
    self.equipped = {
        [EQUIPMENT_SLOTS.WEAPON] = nil,
        [EQUIPMENT_SLOTS.ARMOR] = nil,
        [EQUIPMENT_SLOTS.NECKLACE] = nil
    }
    
    return self
end

-- Equip an item
function EquipmentSystem:equip(itemId)
    local item = EQUIPMENT_DATABASE[itemId]
    if not item then
        print("Warning: Unknown equipment: " .. tostring(itemId))
        return false
    end
    
    -- Unequip current item in slot
    local oldItem = self.equipped[item.slot]
    
    -- Equip new item
    self.equipped[item.slot] = item
    
    print("Equipped: " .. item.name)
    return true, oldItem
end

-- Unequip an item from a slot
function EquipmentSystem:unequip(slot)
    local item = self.equipped[slot]
    if item then
        self.equipped[slot] = nil
        print("Unequipped: " .. item.name)
        return item
    end
    return nil
end

-- Get equipped item in a slot
function EquipmentSystem:getEquipped(slot)
    return self.equipped[slot]
end

-- Get total stat bonuses from all equipment
function EquipmentSystem:getTotalStats()
    local stats = {
        attack = 0,
        defense = 0,
        speed = 0
    }
    
    for slot, item in pairs(self.equipped) do
        if item then
            stats.attack = stats.attack + (item.attack or 0)
            stats.defense = stats.defense + (item.defense or 0)
            stats.speed = stats.speed + (item.speed or 0)
        end
    end
    
    return stats
end

-- Get equipment data by ID
function EquipmentSystem.getEquipmentData(itemId)
    return EQUIPMENT_DATABASE[itemId]
end

-- Get all equipment of a specific slot
function EquipmentSystem.getEquipmentBySlot(slot)
    local items = {}
    for id, item in pairs(EQUIPMENT_DATABASE) do
        if item.slot == slot then
            table.insert(items, item)
        end
    end
    return items
end

-- Get all equipment
function EquipmentSystem.getAllEquipment()
    return EQUIPMENT_DATABASE
end

-- Serialize equipment for saving
function EquipmentSystem:serialize()
    local data = {}
    for slot, item in pairs(self.equipped) do
        if item then
            data[slot] = item.id
        end
    end
    return data
end

-- Deserialize equipment from saved data
function EquipmentSystem:deserialize(data)
    if not data then return end
    
    for slot, itemId in pairs(data) do
        if itemId then
            self:equip(itemId)
        end
    end
end

-- Export slots constant
EquipmentSystem.SLOTS = EQUIPMENT_SLOTS

return EquipmentSystem

