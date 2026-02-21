-- equipment_ui.lua - Equipment UI panel
-- Displays equipment slots and allows equipping/unequipping items

local Theme = require("src.ui.theme")

local EquipmentUI = {}
EquipmentUI.__index = EquipmentUI

function EquipmentUI.new()
    local self = setmetatable({}, EquipmentUI)
    
    self.visible = false
    self.selectedSlot = 1
    
    self.colors = Theme.colors.equipmentUI
    self.equipColors = Theme.colors.equipment
    
    return self
end

-- Toggle visibility
function EquipmentUI:toggle()
    self.visible = not self.visible
end

-- Show UI
function EquipmentUI:show()
    self.visible = true
end

-- Hide UI
function EquipmentUI:hide()
    self.visible = false
end

-- Draw equipment UI
function EquipmentUI:draw(equipmentSystem, x, y, width, height)
    if not self.visible then
        return
    end
    
    local EquipmentSlots = require("src.systems.equipment_system").SLOTS
    
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(Theme.colors.map.overlay)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, width, height, 10, 10)
    
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, width, height, 10, 10)
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Equipment", x + 20, y + 15, 0, 1.5, 1.5)
    
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print("Press E to close", x + width - 150, y + 20)
    
    -- Equipment slots
    local slotY = y + 60
    local slotHeight = 80
    local slotIndex = 1
    
    -- Weapon slot
    self:drawEquipmentSlot(equipmentSystem, EquipmentSlots.WEAPON, "Weapon", 
        x + 20, slotY, width - 40, slotHeight, slotIndex == self.selectedSlot)
    slotY = slotY + slotHeight + 10
    slotIndex = slotIndex + 1
    
    -- Armor slot
    self:drawEquipmentSlot(equipmentSystem, EquipmentSlots.ARMOR, "Armor", 
        x + 20, slotY, width - 40, slotHeight, slotIndex == self.selectedSlot)
    slotY = slotY + slotHeight + 10
    slotIndex = slotIndex + 1
    
    -- Necklace slot
    self:drawEquipmentSlot(equipmentSystem, EquipmentSlots.NECKLACE, "Necklace", 
        x + 20, slotY, width - 40, slotHeight, slotIndex == self.selectedSlot)
    
    -- Total stats
    self:drawTotalStats(equipmentSystem, x + 20, y + height - 100, width - 40)
end

function EquipmentUI:drawEquipmentSlot(equipmentSystem, slot, slotName, x, y, width, height, isSelected)
    if isSelected then
        love.graphics.setColor(self.colors.selected)
    else
        love.graphics.setColor(self.colors.background)
    end
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    love.graphics.setColor(Theme.colors.borderDim)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print(slotName, x + 10, y + 10)
    
    local item = equipmentSystem:getEquipped(slot)
    if item then
        love.graphics.setColor(self:getSlotColor(slot))
        love.graphics.print(item.name, x + 10, y + 30, 0, 1.2, 1.2)
        
        love.graphics.setColor(Theme.colors.textDim)
        local statsText = ""
        if item.attack > 0 then
            statsText = statsText .. "ATK +" .. item.attack .. "  "
        end
        if item.defense > 0 then
            statsText = statsText .. "DEF +" .. item.defense .. "  "
        end
        if item.speed ~= 0 then
            statsText = statsText .. "SPD " .. (item.speed > 0 and "+" or "") .. item.speed
        end
        love.graphics.print(statsText, x + 10, y + 55)
    else
        love.graphics.setColor(self.colors.empty)
        love.graphics.print("(Empty)", x + 10, y + 35)
    end
end

function EquipmentUI:drawTotalStats(equipmentSystem, x, y, width)
    local stats = equipmentSystem:getTotalStats()
    
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, width, 80, 5, 5)
    
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, 80, 5, 5)
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Total Equipment Bonus", x + 10, y + 10)
    
    love.graphics.setColor(self.equipColors.weapon)
    love.graphics.print("ATK: +" .. stats.attack, x + 10, y + 35)
    
    love.graphics.setColor(self.equipColors.clothes)
    love.graphics.print("DEF: +" .. stats.defense, x + 120, y + 35)
    
    love.graphics.setColor(Theme.colors.success)
    love.graphics.print("SPD: " .. (stats.speed >= 0 and "+" or "") .. stats.speed, x + 230, y + 35)
end

function EquipmentUI:getSlotColor(slot)
    local EquipmentSlots = require("src.systems.equipment_system").SLOTS
    
    if slot == EquipmentSlots.WEAPON then
        return self.equipColors.weapon
    elseif slot == EquipmentSlots.ARMOR then
        return self.equipColors.clothes
    elseif slot == EquipmentSlots.NECKLACE then
        return self.equipColors.necklace
    end
    
    return self.colors.text
end

-- Navigate up
function EquipmentUI:navigateUp()
    self.selectedSlot = math.max(1, self.selectedSlot - 1)
end

-- Navigate down
function EquipmentUI:navigateDown()
    self.selectedSlot = math.min(3, self.selectedSlot + 1)
end

-- Check if visible
function EquipmentUI:isVisible()
    return self.visible
end

return EquipmentUI

