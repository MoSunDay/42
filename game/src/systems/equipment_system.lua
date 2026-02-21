local ItemDatabase = require("src.systems.item_database")
local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")

local EquipmentSystem = {}
EquipmentSystem.__index = EquipmentSystem

local DEF_TO_PERCENT = 5
local MAX_DEF_PERCENT = 50

local SLOT_CRYSTAL_MAP = {
    weapon = SpiritCrystalSystem.TYPES.CRIMSON,
    hat = SpiritCrystalSystem.TYPES.AZURE,
    clothes = SpiritCrystalSystem.TYPES.AZURE,
    shoes = SpiritCrystalSystem.TYPES.GOLDEN,
    necklace = SpiritCrystalSystem.TYPES.VIOLET
}

function EquipmentSystem.new()
    local self = setmetatable({}, EquipmentSystem)
    
    self.equipped = {}
    for _, slot in pairs(ItemDatabase.SLOTS) do
        self.equipped[slot] = nil
    end
    
    self.enhanceLevels = {
        weapon = 0,
        hat = 0,
        clothes = 0,
        shoes = 0,
        necklace = 0
    }
    
    self.spiritCrystalSystem = nil
    
    return self
end

function EquipmentSystem:setSpiritCrystalSystem(scs)
    self.spiritCrystalSystem = scs
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

function EquipmentSystem:getEnhanceLevel(slot)
    return self.enhanceLevels[slot] or 0
end

function EquipmentSystem:getAllEnhanceLevels()
    return self.enhanceLevels
end

function EquipmentSystem:canEnhance(slot)
    if not self.equipped[slot] then
        return false, "该槽位没有装备"
    end
    
    local currentLevel = self.enhanceLevels[slot]
    if currentLevel >= SpiritCrystalSystem.MAX_ENHANCE_LEVEL then
        return false, "已达最大强化等级"
    end
    
    local crystalType = SLOT_CRYSTAL_MAP[slot]
    if not crystalType then
        return false, "无效的槽位"
    end
    
    if not self.spiritCrystalSystem then
        return false, "灵晶系统未初始化"
    end
    
    return self.spiritCrystalSystem:canEnhance(crystalType, currentLevel)
end

function EquipmentSystem:enhance(slot)
    local canEnhance, result = self:canEnhance(slot)
    if not canEnhance then
        return false, result
    end
    
    local crystalType = SLOT_CRYSTAL_MAP[slot]
    local currentLevel = self.enhanceLevels[slot]
    
    local success, msg = self.spiritCrystalSystem:enhance(crystalType, currentLevel)
    if success then
        self.enhanceLevels[slot] = currentLevel + 1
        local bonus = self:getEnhancementBonus(slot)
        return true, string.format("强化成功！%s +%d", 
            SpiritCrystalSystem.TYPE_NAMES[crystalType], bonus)
    end
    
    return false, msg
end

function EquipmentSystem:getEnhancementBonus(slot)
    local level = self.enhanceLevels[slot]
    if level <= 0 then return 0 end
    
    local crystalType = SLOT_CRYSTAL_MAP[slot]
    return SpiritCrystalSystem.getEnhancementBonus(crystalType, level)
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
    
    for slot, level in pairs(self.enhanceLevels) do
        if level > 0 then
            local crystalType = SLOT_CRYSTAL_MAP[slot]
            local bonus = SpiritCrystalSystem.getEnhancementBonus(crystalType, level)
            local statKey = SpiritCrystalSystem.STATS_MAP[crystalType]
            if statKey and stats[statKey] then
                stats[statKey] = stats[statKey] + bonus
            end
        end
    end
    
    return stats
end

function EquipmentSystem:getDefensePercent()
    local stats = self:getTotalStats()
    local defPercent = math.floor(stats.defense / DEF_TO_PERCENT)
    return math.min(MAX_DEF_PERCENT, defPercent)
end

function EquipmentSystem:getEnhancementCost(slot)
    local currentLevel = self.enhanceLevels[slot]
    if currentLevel >= SpiritCrystalSystem.MAX_ENHANCE_LEVEL then
        return 0
    end
    return SpiritCrystalSystem.ENHANCE_COSTS[currentLevel + 1]
end

function EquipmentSystem.getEquipmentData(itemId)
    return ItemDatabase.getItem(itemId)
end

function EquipmentSystem.getEquipmentBySlot(slot)
    return ItemDatabase.getEquipmentBySlot(slot)
end

function EquipmentSystem:serialize()
    local data = {
        equipped = {},
        enhanceLevels = self.enhanceLevels
    }
    
    for slot, item in pairs(self.equipped) do
        if item then
            data.equipped[slot] = item.id
        end
    end
    
    return data
end

function EquipmentSystem:deserialize(data)
    if not data then return end
    
    if data.equipped then
        for slot, itemId in pairs(data.equipped) do
            if itemId then
                self:equip(itemId)
            end
        end
    end
    
    if data.enhanceLevels then
        self.enhanceLevels = data.enhanceLevels
    end
end

EquipmentSystem.SLOTS = ItemDatabase.SLOTS
EquipmentSystem.MAX_DEF_PERCENT = MAX_DEF_PERCENT
EquipmentSystem.SLOT_CRYSTAL_MAP = SLOT_CRYSTAL_MAP

return EquipmentSystem
