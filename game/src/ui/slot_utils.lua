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
    [ItemDatabase.SLOTS.WEAPON] = "W",
    [ItemDatabase.SLOTS.HAT] = "H",
    [ItemDatabase.SLOTS.CLOTHES] = "C",
    [ItemDatabase.SLOTS.SHOES] = "S",
    [ItemDatabase.SLOTS.NECKLACE] = "N",
}

local function getSlotColor(slotType)
    return SLOT_COLORS[slotType] or Theme.colors.text
end

local function getSlotIcon(slotType)
    if not slotType then return "?" end
    return SLOT_ICONS[slotType] or "?"
end

local function getItemColor(item)
    if not item then return Theme.colors.inventory.slot end
    if item.type == ItemDatabase.TYPE.CONSUMABLE then
        return Theme.colors.inventory.consumable
    end
    return SLOT_COLORS[item.slot] or Theme.colors.inventory.equipment
end

return {
    getSlotColor = getSlotColor,
    getSlotIcon = getSlotIcon,
    getItemColor = getItemColor,
}
