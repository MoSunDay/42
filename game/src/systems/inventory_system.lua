-- inventory_system.lua - Inventory/Backpack management
-- 30-slot backpack system for storing items

local ItemDatabase = require("src.systems.item_database")

local InventorySystem = {}

local MAX_SLOTS = 30

function InventorySystem.create()
    local state = {}

    state.maxSlots = MAX_SLOTS
    state.slots = {}

    for i = 1, state.maxSlots do
        state.slots[i] = nil
    end

    return state
end

-- Add item to inventory
-- Returns: success, slotIndex or error message
function InventorySystem.add_item(state, itemId)
    local itemData = ItemDatabase.get_item(itemId)
    if not itemData then
        return false, "Unknown item: " .. tostring(itemId)
    end

    local emptySlot = nil
    for i = 1, state.maxSlots do
        if state.slots[i] == nil then
            emptySlot = i
            break
        end
    end

    if not emptySlot then
        return false, "Inventory is full"
    end

    state.slots[emptySlot] = {
        id = itemId,
        name = itemData.name,
        type = itemData.type,
        slot = itemData.slot
    }

    return true, emptySlot
end

-- Remove item from slot
-- Returns: removed item or nil
function InventorySystem.remove_item(state, slotIndex)
    if slotIndex < 1 or slotIndex > state.maxSlots then
        return nil
    end

    local item = state.slots[slotIndex]
    state.slots[slotIndex] = nil
    return item
end

-- Get item at slot
function InventorySystem.get_item(state, slotIndex)
    if slotIndex < 1 or slotIndex > state.maxSlots then
        return nil
    end
    return state.slots[slotIndex]
end

-- Get all items (non-nil slots)
function InventorySystem.get_items(state)
    local items = {}
    for i = 1, state.maxSlots do
        if state.slots[i] then
            table.insert(items, {
                slot = i,
                item = state.slots[i]
            })
        end
    end
    return items
end

-- Get all slots (including empty)
function InventorySystem.get_all_slots(state)
    return state.slots
end

-- Get count of used slots
function InventorySystem.get_used_slots(state)
    local count = 0
    for i = 1, state.maxSlots do
        if state.slots[i] then
            count = count + 1
        end
    end
    return count
end

-- Get count of free slots
function InventorySystem.get_free_slots(state)
    return state.maxSlots - InventorySystem.get_used_slots(state)
end

-- Check if inventory is full
function InventorySystem.isFull(state)
    return InventorySystem.get_free_slots(state) == 0
end

-- Check if inventory is empty
function InventorySystem.isEmpty(state)
    return InventorySystem.get_used_slots(state) == 0
end

-- Find item by ID
-- Returns: slotIndex or nil
function InventorySystem.find_item(state, itemId)
    for i = 1, state.maxSlots do
        if state.slots[i] and state.slots[i].id == itemId then
            return i
        end
    end
    return nil
end

-- Find all items of a type
function InventorySystem.find_items_by_type(state, itemType)
    local results = {}
    for i = 1, state.maxSlots do
        if state.slots[i] and state.slots[i].type == itemType then
            table.insert(results, { slot = i, item = state.slots[i] })
        end
    end
    return results
end

-- Find all items for a specific equipment slot
function InventorySystem.find_equipment_for_slot(state, equipSlot)
    local results = {}
    for i = 1, state.maxSlots do
        if state.slots[i] and state.slots[i].slot == equipSlot then
            table.insert(results, { slot = i, item = state.slots[i] })
        end
    end
    return results
end

-- Get all equipment items in inventory
function InventorySystem.get_equipment_items(state)
    return InventorySystem.find_items_by_type(state, ItemDatabase.TYPE.EQUIPMENT)
end

-- Get all consumable items in inventory
function InventorySystem.get_consumable_items(state)
    return InventorySystem.find_items_by_type(state, ItemDatabase.TYPE.CONSUMABLE)
end

-- Swap two items in inventory
function InventorySystem.swap_items(state, slotA, slotB)
    if slotA < 1 or slotA > state.maxSlots or
       slotB < 1 or slotB > state.maxSlots then
        return false
    end

    state.slots[slotA], state.slots[slotB] = state.slots[slotB], state.slots[slotA]
    return true
end

-- Clear all items
function InventorySystem.clear(state)
    for i = 1, state.maxSlots do
        state.slots[i] = nil
    end
end

-- Serialize for saving
function InventorySystem.serialize(state)
    local data = {}
    for i = 1, state.maxSlots do
        if state.slots[i] then
            data[i] = state.slots[i].id
        end
    end
    return data
end

-- Deserialize from saved data
function InventorySystem.deserialize(state, data)
    if not data then return end

    InventorySystem.clear(state)

    for slotIdx, itemId in pairs(data) do
        local slotNum = tonumber(slotIdx)
        if slotNum and slotNum >= 1 and slotNum <= state.maxSlots then
            local itemData = ItemDatabase.get_item(itemId)
            if itemData then
                state.slots[slotNum] = {
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
function InventorySystem.get_max_slots(state)
    return state.maxSlots
end

return InventorySystem
