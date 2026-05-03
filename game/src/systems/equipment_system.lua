local ItemDatabase = require("src.systems.item_database")
local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")
local InventorySystem = require("src.systems.inventory_system")

local EquipmentSystem = {}

local DEF_TO_PERCENT = 5
local MAX_DEF_PERCENT = 50

local SLOT_CRYSTAL_MAP = {
    weapon = SpiritCrystalSystem.TYPES.CRIMSON,
    hat = SpiritCrystalSystem.TYPES.AZURE,
    clothes = SpiritCrystalSystem.TYPES.EMERALD,
    shoes = SpiritCrystalSystem.TYPES.GOLDEN,
    necklace = SpiritCrystalSystem.TYPES.VIOLET
}

function EquipmentSystem.create()
    local state = {}

    state.equipped = {}
    for _, slot in pairs(ItemDatabase.SLOTS) do
        state.equipped[slot] = nil
    end

    state.enhanceLevels = {
        weapon = 0,
        hat = 0,
        clothes = 0,
        shoes = 0,
        necklace = 0
    }

    state.spiritCrystalSystem = nil

    return state
end

function EquipmentSystem.set_spirit_crystal_system(state, scs)
    state.spiritCrystalSystem = scs
end

function EquipmentSystem.equip(state, itemId)
    local item = ItemDatabase.get_item(itemId)
    if not item then
        return false, nil
    end

    if item.type ~= ItemDatabase.TYPE.EQUIPMENT then
        return false, nil
    end

    local oldItem = state.equipped[item.slot]
    state.equipped[item.slot] = item

    return true, oldItem
end

function EquipmentSystem.equip_from_inventory(state, inventoryState, slotIndex)
    local invItem = InventorySystem.get_item(inventoryState, slotIndex)
    if not invItem then
        return false, "No item in slot"
    end

    if not ItemDatabase.isEquipment(invItem.id) then
        return false, "Item is not equipment"
    end

    local itemData = ItemDatabase.get_item(invItem.id)
    local oldEquipped = state.equipped[itemData.slot]

    state.equipped[itemData.slot] = itemData
    InventorySystem.remove_item(inventoryState, slotIndex)

    if oldEquipped then
        InventorySystem.add_item(inventoryState, oldEquipped.id)
    end

    return true, "Equipped " .. invItem.name
end

function EquipmentSystem.unequip_to_inventory(state, slot, inventoryState)
    local item = state.equipped[slot]
    if not item then
        return false, "No item equipped in that slot"
    end

    if InventorySystem.isFull(inventoryState) then        return false, "Inventory is full"
    end

    InventorySystem.add_item(inventoryState, item.id)
    state.equipped[slot] = nil

    return true, "Unequipped " .. item.name
end

function EquipmentSystem.unequip(state, slot)
    local item = state.equipped[slot]
    if item then
        state.equipped[slot] = nil
        return item
    end
    return nil
end

function EquipmentSystem.get_equipped(state, slot)
    return state.equipped[slot]
end

function EquipmentSystem.get_all_equipped(state)
    return state.equipped
end

function EquipmentSystem.get_enhance_level(state, slot)
    return state.enhanceLevels[slot] or 0
end

function EquipmentSystem.get_all_enhance_levels(state)
    return state.enhanceLevels
end

function EquipmentSystem.can_enhance(state, slot)
    if not state.equipped[slot] then
        return false, "该槽位没有装备"
    end

    local currentLevel = state.enhanceLevels[slot]
    if currentLevel >= SpiritCrystalSystem.MAX_ENHANCE_LEVEL then
        return false, "已达最大强化等级"
    end

    local crystalType = SLOT_CRYSTAL_MAP[slot]
    if not crystalType then
        return false, "无效的槽位"
    end

    if not state.spiritCrystalSystem then
        return false, "灵晶系统未初始化"
    end

    return SpiritCrystalSystem.can_enhance(state.spiritCrystalSystem, currentLevel)
end

function EquipmentSystem.enhance(state, slot)
    local canEnhanceResult, result = EquipmentSystem.can_enhance(state, slot)
    if not canEnhanceResult then
        return false, result
    end

    local crystalType = SLOT_CRYSTAL_MAP[slot]
    local currentLevel = state.enhanceLevels[slot]

    local success, msg = SpiritCrystalSystem.enhance(state.spiritCrystalSystem, currentLevel)
    if success then
        state.enhanceLevels[slot] = currentLevel + 1
        local bonus = EquipmentSystem.get_enhancement_bonus(state, slot)
        return true, string.format("强化成功！%s +%d",
            SpiritCrystalSystem.TYPE_NAMES[crystalType], bonus)
    end

    return false, msg
end

function EquipmentSystem.get_enhancement_bonus(state, slot)
    local level = state.enhanceLevels[slot]
    if level <= 0 then return 0 end

    local crystalType = SLOT_CRYSTAL_MAP[slot]
    return SpiritCrystalSystem.get_enhancement_bonus(crystalType, level)
end

function EquipmentSystem.get_total_stats(state)
    local stats = {
        attack = 0,
        defense = 0,
        speed = 0,
        hp = 0,
        crit = 0,
        eva = 0
    }

    for slot, item in pairs(state.equipped) do
        if item then
            stats.attack = stats.attack + (item.attack or 0)
            stats.defense = stats.defense + (item.defense or 0)
            stats.speed = stats.speed + (item.speed or 0)
            stats.hp = stats.hp + (item.hp or 0)
            stats.crit = stats.crit + (item.crit or 0)
            stats.eva = stats.eva + (item.eva or 0)
        end
    end

    for slot, level in pairs(state.enhanceLevels) do
        if level > 0 then
            local crystalType = SLOT_CRYSTAL_MAP[slot]
            local bonus = SpiritCrystalSystem.get_enhancement_bonus(crystalType, level)
            local statKey = SpiritCrystalSystem.STATS_MAP[crystalType]
            if statKey and stats[statKey] then
                stats[statKey] = stats[statKey] + bonus
            end
        end
    end

    return stats
end

function EquipmentSystem.get_defense_percent(state)
    local stats = EquipmentSystem.get_total_stats(state)
    local defPercent = math.floor(stats.defense / DEF_TO_PERCENT)
    return math.min(MAX_DEF_PERCENT, defPercent)
end

function EquipmentSystem.get_enhancement_cost(state, slot)
    local currentLevel = state.enhanceLevels[slot]
    if currentLevel >= SpiritCrystalSystem.MAX_ENHANCE_LEVEL then
        return 0
    end
    return SpiritCrystalSystem.ENHANCE_COSTS[currentLevel + 1]
end

function EquipmentSystem.get_equipment_data(itemId)
    return ItemDatabase.get_item(itemId)
end

function EquipmentSystem.get_equipment_by_slot(slot)
    return ItemDatabase.get_equipment_by_slot(slot)
end

function EquipmentSystem.serialize(state)
    local data = {
        equipped = {},
        enhanceLevels = state.enhanceLevels
    }

    for slot, item in pairs(state.equipped) do
        if item then
            data.equipped[slot] = item.id
        end
    end

    return data
end

function EquipmentSystem.deserialize(state, data)
    if not data then return end

    if data.equipped then
        for slot, itemId in pairs(data.equipped) do
            if itemId then
                EquipmentSystem.equip(state, itemId)
            end
        end
    end

    if data.enhanceLevels then
        state.enhanceLevels = data.enhanceLevels
    end
end

EquipmentSystem.SLOTS = ItemDatabase.SLOTS
EquipmentSystem.MAX_DEF_PERCENT = MAX_DEF_PERCENT
EquipmentSystem.SLOT_CRYSTAL_MAP = SLOT_CRYSTAL_MAP

return EquipmentSystem
