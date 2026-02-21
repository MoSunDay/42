-- inventory_system.lua - Inventory/Backpack management
-- 30-slot backpack system for storing items

local ItemDatabase = require("src.systems.item_database")

local InventorySystem = {}
InventorySystem.__index = InventorySystem

local MAX_SLOTS = 30

function InventorySystem.new()
    local self = setmetatable({}, InventorySystem)
    
    self.maxSlots = MAX_SLOTS
    self.slots = {}
    
    for i = 1, self.maxSlots do
        self.slots[i] = nil
    end
    
    return self
end

-- Add item to inventory
-- Returns: success, slotIndex or error message
function InventorySystem:addItem(itemId)
    local itemData = ItemDatabase.getItem(itemId)
    if not itemData then
        return false, "Unknown item: " .. tostring(itemId)
    end
    
    local emptySlot = nil
    for i = 1, self.maxSlots do
        if self.slots[i] == nil then
            emptySlot = i
            break
        end
    end
    
    if not emptySlot then
        return false, "Inventory is full"
    end
    
    self.slots[emptySlot] = {
        id = itemId,
        name = itemData.name,
        type = itemData.type,
        slot = itemData.slot
    }
    
    return true, emptySlot
end

-- Remove item from slot
-- Returns: removed item or nil
function InventorySystem:removeItem(slotIndex)
    if slotIndex < 1 or slotIndex > self.maxSlots then
        return nil
    end
    
    local item = self.slots[slotIndex]
    self.slots[slotIndex] = nil
    return item
end

-- Get item at slot
function InventorySystem:getItem(slotIndex)
    if slotIndex < 1 or slotIndex > self.maxSlots then
        return nil
    end
    return self.slots[slotIndex]
end

-- Get all items (non-nil slots)
function InventorySystem:getItems()
    local items = {}
    for i = 1, self.maxSlots do
        if self.slots[i] then
            table.insert(items, {
                slot = i,
                item = self.slots[i]
            })
        end
    end
    return items
end

-- Get all slots (including empty)
function InventorySystem:getAllSlots()
    return self.slots
end

-- Get count of used slots
function InventorySystem:getUsedSlots()
    local count = 0
    for i = 1, self.maxSlots do
        if self.slots[i] then
            count = count + 1
        end
    end
    return count
end

-- Get count of free slots
function InventorySystem:getFreeSlots()
    return self.maxSlots - self:getUsedSlots()
end

-- Check if inventory is full
function InventorySystem:isFull()
    return self:getFreeSlots() == 0
end

-- Check if inventory is empty
function InventorySystem:isEmpty()
    return self:getUsedSlots() == 0
end

-- Find item by ID
-- Returns: slotIndex or nil
function InventorySystem:findItem(itemId)
    for i = 1, self.maxSlots do
        if self.slots[i] and self.slots[i].id == itemId then
            return i
        end
    end
    return nil
end

-- Find all items of a type
function InventorySystem:findItemsByType(itemType)
    local results = {}
    for i = 1, self.maxSlots do
        if self.slots[i] and self.slots[i].type == itemType then
            table.insert(results, { slot = i, item = self.slots[i] })
        end
    end
    return results
end

-- Find all items for a specific equipment slot
function InventorySystem:findEquipmentForSlot(equipSlot)
    local results = {}
    for i = 1, self.maxSlots do
        if self.slots[i] and self.slots[i].slot == equipSlot then
            table.insert(results, { slot = i, item = self.slots[i] })
        end
    end
    return results
end

-- Get all equipment items in inventory
function InventorySystem:getEquipmentItems()
    return self:findItemsByType(ItemDatabase.TYPE.EQUIPMENT)
end

-- Get all consumable items in inventory
function InventorySystem:getConsumableItems()
    return self:findItemsByType(ItemDatabase.TYPE.CONSUMABLE)
end

-- Swap two items in inventory
function InventorySystem:swapItems(slotA, slotB)
    if slotA < 1 or slotA > self.maxSlots or 
       slotB < 1 or slotB > self.maxSlots then
        return false
    end
    
    self.slots[slotA], self.slots[slotB] = self.slots[slotB], self.slots[slotA]
    return true
end

-- Clear all items
function InventorySystem:clear()
    for i = 1, self.maxSlots do
        self.slots[i] = nil
    end
end

-- Serialize for saving
function InventorySystem:serialize()
    local data = {}
    for i = 1, self.maxSlots do
        if self.slots[i] then
            data[i] = self.slots[i].id
        end
    end
    return data
end

-- Deserialize from saved data
function InventorySystem:deserialize(data)
    if not data then return end
    
    self:clear()
    
    for slotIdx, itemId in pairs(data) do
        local slotNum = tonumber(slotIdx)
        if slotNum and slotNum >= 1 and slotNum <= self.maxSlots then
            local itemData = ItemDatabase.getItem(itemId)
            if itemData then
                self.slots[slotNum] = {
                    id = itemId,
                    name = itemData.name,
                    type = itemData.type,
                    slot = itemData.slot
                }
            end
        end
    end
end

-- Get max slots
function InventorySystem:getMaxSlots()
    return self.maxSlots
end

return InventorySystem
