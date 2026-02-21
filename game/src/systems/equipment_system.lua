-- equipment_system.lua - Equipment management system
-- Handles equipment slots, stats bonuses

local ItemDatabase = require("src.systems.item_database")

local EquipmentSystem = {}
EquipmentSystem.__index = EquipmentSystem

local DEF_TO_PERCENT = 5  -- 5 DEF = 1% damage reduction
local MAX_DEF_PERCENT = 50  -- Maximum 50% damage reduction

function EquipmentSystem.new()
    local self = setmetatable({}, EquipmentSystem)
    
    self.equipped = {}
    for _, slot in pairs(ItemDatabase.SLOTS) do
        self.equipped[slot] = nil
    end
    
    return self
end

function EquipmentSystem:equip(itemId)
    local item = ItemDatabase.getItem(itemId)
    if not item then
        print("Warning: Unknown equipment: " .. tostring(itemId))
        return false, nil
    end
    
    if item.type ~= ItemDatabase.TYPE.EQUIPMENT then
        print("Warning: Item is not equipment: " .. tostring(itemId))
        return false, nil
    end
    
    local oldItem = self.equipped[item.slot]
    self.equipped[item.slot] = item
    
    print("Equipped: " .. item.name)
    return true, oldItem
end

function EquipmentSystem:equipFromInventory(inventorySystem, slotIndex)
    local invItem = inventorySystem:getItem(slotIndex)
    if not invItem then
        return false, "No item in slot"
    end
    
    if not ItemDatabase.isEquipment(invItem.id) then
        return false, "Item is not equipment"
    end
    
    local itemData = ItemDatabase.getItem(invItem.id)
    local oldEquipped = self.equipped[itemData.slot]
    
    self.equipped[itemData.slot] = itemData
    inventorySystem:removeItem(slotIndex)
    
    if oldEquipped then
        inventorySystem:addItem(oldEquipped.id)
    end
    
    return true, "Equipped " .. invItem.name
end

function EquipmentSystem:unequipToInventory(slot, inventorySystem)
    local item = self.equipped[slot]
    if not item then
        return false, "No item equipped in that slot"
    end
    
    if inventorySystem:isFull() then
        return false, "Inventory is full"
    end
    
    inventorySystem:addItem(item.id)
    self.equipped[slot] = nil
    
    return true, "Unequipped " .. item.name
end

function EquipmentSystem:unequip(slot)
    local item = self.equipped[slot]
    if item then
        self.equipped[slot] = nil
        print("Unequipped: " .. item.name)
        return item
    end
    return nil
end

function EquipmentSystem:getEquipped(slot)
    return self.equipped[slot]
end

function EquipmentSystem:getAllEquipped()
    return self.equipped
end

function EquipmentSystem:getTotalStats()
    local stats = {
        attack = 0,
        defense = 0,
        speed = 0,
        hp = 0,
        crit = 0,
        eva = 0
    }
    
    for slot, item in pairs(self.equipped) do
        if item then
            stats.attack = stats.attack + (item.attack or 0)
            stats.defense = stats.defense + (item.defense or 0)
            stats.speed = stats.speed + (item.speed or 0)
            stats.hp = stats.hp + (item.hp or 0)
            stats.crit = stats.crit + (item.crit or 0)
            stats.eva = stats.eva + (item.eva or 0)
        end
    end
    
    return stats
end

function EquipmentSystem:getDefensePercent()
    local stats = self:getTotalStats()
    local defPercent = math.floor(stats.defense / DEF_TO_PERCENT)
    return math.min(MAX_DEF_PERCENT, defPercent)
end

function EquipmentSystem.getEquipmentData(itemId)
    return ItemDatabase.getItem(itemId)
end

function EquipmentSystem.getEquipmentBySlot(slot)
    return ItemDatabase.getEquipmentBySlot(slot)
end

function EquipmentSystem:serialize()
    local data = {}
    for slot, item in pairs(self.equipped) do
        if item then
            data[slot] = item.id
        end
    end
    return data
end

function EquipmentSystem:deserialize(data)
    if not data then return end
    
    for slot, itemId in pairs(data) do
        if itemId then
            self:equip(itemId)
        end
    end
end

EquipmentSystem.SLOTS = ItemDatabase.SLOTS
EquipmentSystem.MAX_DEF_PERCENT = MAX_DEF_PERCENT

return EquipmentSystem
