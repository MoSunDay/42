-- equipment_ui.lua - Equipment UI panel
-- Displays equipment slots and allows equipping/unequipping items

local EquipmentUI = {}
EquipmentUI.__index = EquipmentUI

function EquipmentUI.new()
    local self = setmetatable({}, EquipmentUI)
    
    self.visible = false
    self.selectedSlot = 1
    
    -- UI colors
    self.colors = {
        background = {0.1, 0.1, 0.15, 0.95},
        panel = {0.2, 0.2, 0.25, 0.9},
        text = {1, 1, 1},
        selected = {0.4, 0.6, 1.0, 0.5},
        empty = {0.3, 0.3, 0.35},
        weapon = {1.0, 0.5, 0.3},
        armor = {0.5, 0.7, 1.0},
        necklace = {1.0, 0.8, 0.2}
    }
    
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
    
    -- Background overlay
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Panel background
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, width, height, 10, 10)
    
    -- Panel border
    love.graphics.setColor(0.4, 0.6, 1.0)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, width, height, 10, 10)
    love.graphics.setLineWidth(1)
    
    -- Title
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Equipment", x + 20, y + 15, 0, 1.5, 1.5)
    
    -- Close hint
    love.graphics.setColor(0.7, 0.7, 0.7)
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

-- Draw a single equipment slot
function EquipmentUI:drawEquipmentSlot(equipmentSystem, slot, slotName, x, y, width, height, isSelected)
    -- Slot background
    if isSelected then
        love.graphics.setColor(self.colors.selected)
    else
        love.graphics.setColor(self.colors.background)
    end
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Slot border
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    love.graphics.setLineWidth(1)
    
    -- Slot name
    love.graphics.setColor(self.colors.text)
    love.graphics.print(slotName, x + 10, y + 10)
    
    -- Equipped item
    local item = equipmentSystem:getEquipped(slot)
    if item then
        -- Item name
        love.graphics.setColor(self:getSlotColor(slot))
        love.graphics.print(item.name, x + 10, y + 30, 0, 1.2, 1.2)
        
        -- Item stats
        love.graphics.setColor(0.8, 0.8, 0.8)
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
        -- Empty slot
        love.graphics.setColor(self.colors.empty)
        love.graphics.print("(Empty)", x + 10, y + 35)
    end
end

-- Draw total stats from equipment
function EquipmentUI:drawTotalStats(equipmentSystem, x, y, width)
    local stats = equipmentSystem:getTotalStats()
    
    -- Background
    love.graphics.setColor(0.15, 0.15, 0.2, 0.9)
    love.graphics.rectangle("fill", x, y, width, 80, 5, 5)
    
    -- Border
    love.graphics.setColor(0.4, 0.6, 1.0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, 80, 5, 5)
    love.graphics.setLineWidth(1)
    
    -- Title
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Total Equipment Bonus", x + 10, y + 10)
    
    -- Stats
    love.graphics.setColor(1.0, 0.5, 0.3)
    love.graphics.print("ATK: +" .. stats.attack, x + 10, y + 35)
    
    love.graphics.setColor(0.5, 0.7, 1.0)
    love.graphics.print("DEF: +" .. stats.defense, x + 120, y + 35)
    
    love.graphics.setColor(0.8, 1.0, 0.3)
    love.graphics.print("SPD: " .. (stats.speed >= 0 and "+" or "") .. stats.speed, x + 230, y + 35)
end

-- Get color for equipment slot
function EquipmentUI:getSlotColor(slot)
    local EquipmentSlots = require("src.systems.equipment_system").SLOTS
    
    if slot == EquipmentSlots.WEAPON then
        return self.colors.weapon
    elseif slot == EquipmentSlots.ARMOR then
        return self.colors.armor
    elseif slot == EquipmentSlots.NECKLACE then
        return self.colors.necklace
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

