local ItemData = require("src.systems.item_data")

local ItemDatabase = {}

ItemDatabase.TYPE = {
    EQUIPMENT = "equipment",
    CONSUMABLE = "consumable"
}

ItemDatabase.SLOTS = ItemData.SLOTS

local SLOT_NAMES = {
    weapon = "Weapon",
    hat = "Hat",
    clothes = "Clothes",
    shoes = "Shoes",
    necklace = "Necklace"
}

local DATABASE = ItemData.ITEMS

function ItemDatabase.get_item(itemId)
    return DATABASE[itemId]
end

function ItemDatabase.get_equipment_by_slot(slot)
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.EQUIPMENT and item.slot == slot then
            table.insert(items, item)
        end
    end
    table.sort(items, function(a, b) return (a.price or 0) < (b.price or 0) end)
    return items
end

function ItemDatabase.getConsumables()
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.CONSUMABLE then
            table.insert(items, item)
        end
    end
    table.sort(items, function(a, b) return (a.price or 0) < (b.price or 0) end)
    return items
end

function ItemDatabase.getAllEquipment()
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.EQUIPMENT then
            table.insert(items, item)
        end
    end
    return items
end

function ItemDatabase.getSlotName(slot)
    return SLOT_NAMES[slot] or slot
end

function ItemDatabase.isEquipment(itemId)
    local item = DATABASE[itemId]
    return item and item.type == ItemDatabase.TYPE.EQUIPMENT
end

function ItemDatabase.isConsumable(itemId)
    local item = DATABASE[itemId]
    return item and item.type == ItemDatabase.TYPE.CONSUMABLE
end

function ItemDatabase.getEquipmentByTier(tier)
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.EQUIPMENT and item.tier == tier then
            table.insert(items, item)
        end
    end
    table.sort(items, function(a, b) return (a.price or 0) < (b.price or 0) end)
    return items
end

return ItemDatabase
