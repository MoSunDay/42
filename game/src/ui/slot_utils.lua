local ItemDatabase = require("src.systems.item_database")
local Theme = require("src.ui.theme")

local SLOT_COLORS = {
    [ItemDatabase.SLOTS.WEAPON] = Theme.colors.equipment.weapon,
    [ItemDatabase.SLOTS.HAT] = Theme.colors.equipment.hat,
    [ItemDatabase.SLOTS.CLOTHES] = Theme.colors.equipment.clothes,
    [ItemDatabase.SLOTS.SHOES] = Theme.colors.equipment.shoes,
    [ItemDatabase.SLOTS.NECKLACE] = Theme.colors.equipment.necklace,
}

local SLOT_ICONS = {
    [ItemDatabase.SLOTS.WEAPON] = "weapon",
    [ItemDatabase.SLOTS.HAT] = "hat",
    [ItemDatabase.SLOTS.CLOTHES] = "clothes",
    [ItemDatabase.SLOTS.SHOES] = "shoes",
    [ItemDatabase.SLOTS.NECKLACE] = "necklace",
}

local SLOT_FALLBACK = {
    [ItemDatabase.SLOTS.WEAPON] = "W",
    [ItemDatabase.SLOTS.HAT] = "H",
    [ItemDatabase.SLOTS.CLOTHES] = "C",
    [ItemDatabase.SLOTS.SHOES] = "S",
    [ItemDatabase.SLOTS.NECKLACE] = "N",
}

local function getSlotColor(slotType)
    return SLOT_COLORS[slotType] or Theme.colors.text
end

local function getSlotIconName(slotType)
    if not slotType then return nil end
    return SLOT_ICONS[slotType]
end

local function getSlotIcon(slotType)
    if not slotType then return "?" end
    return SLOT_FALLBACK[slotType] or "?"
end

local function get_itemIconName(item)
    if not item then return nil end
    if item.type == ItemDatabase.TYPE.CONSUMABLE then
        if item.effect == "heal" or item.effect == "full_heal" then
            return "hp_potion"
        end
        return "item"
    end
    return SLOT_ICONS[item.slot]
end

local function get_itemColor(item)
    if not item then return Theme.colors.inventory.slot end
    if item.type == ItemDatabase.TYPE.CONSUMABLE then
        return Theme.colors.inventory.consumable
    end
    return SLOT_COLORS[item.slot] or Theme.colors.inventory.equipment
end

return {
    getSlotColor = getSlotColor,
    getSlotIcon = getSlotIcon,
    getSlotIconName = getSlotIconName,
    get_itemColor = get_itemColor,
    get_itemIconName = get_itemIconName,
}
