-- inventory_ui.lua - Inventory UI component
-- Displays 30-slot backpack grid with item details

local ItemDatabase = require("src.systems.item_database")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local InventoryUI = {}
InventoryUI.__index = InventoryUI

function InventoryUI.new()
    local self = setmetatable({}, InventoryUI)
    
    self.hoveredSlot = nil
    self.selectedSlot = nil
    
    self.cols = 6
    self.rows = 5
    self.slotSize = 60
    self.slotPadding = 5
    
    self.colors = Theme.colors.inventory
    self.equipColors = Theme.colors.equipment
    
    return self
end

function InventoryUI:getItemColor(item)
    if not item then
        return self.colors.slot
    end
    
    if item.type == ItemDatabase.TYPE.CONSUMABLE then
        return self.colors.consumable
    end
    
    if item.slot == ItemDatabase.SLOTS.WEAPON then
        return self.equipColors.weapon
    elseif item.slot == ItemDatabase.SLOTS.HAT then
        return self.equipColors.hat
    elseif item.slot == ItemDatabase.SLOTS.CLOTHES then
        return self.equipColors.clothes
    elseif item.slot == ItemDatabase.SLOTS.SHOES then
        return self.equipColors.shoes
    elseif item.slot == ItemDatabase.SLOTS.NECKLACE then
        return self.equipColors.necklace
    end
    
    return self.colors.equipment
end

-- Draw inventory grid
function InventoryUI:draw(inventorySystem, x, y, width, height)
    local slots = inventorySystem:getAllSlots()
    local maxSlots = inventorySystem:getMaxSlots()
    
    local gridWidth = self.cols * (self.slotSize + self.slotPadding) - self.slotPadding
    local startX = x + (width - gridWidth) / 2
    
    for row = 1, self.rows do
        for col = 1, self.cols do
            local slotIndex = (row - 1) * self.cols + col
            local slotX = startX + (col - 1) * (self.slotSize + self.slotPadding)
            local slotY = y + (row - 1) * (self.slotSize + self.slotPadding)
            
            local item = slots[slotIndex]
            local isHovered = self.hoveredSlot == slotIndex
            local isSelected = self.selectedSlot == slotIndex
            
            self:drawSlot(slotIndex, item, slotX, slotY, isHovered, isSelected)
        end
    end
end

function InventoryUI:drawSlot(slotIndex, item, x, y, isHovered, isSelected)
    Components.drawSlotSimple(x, y, self.slotSize, isHovered, isSelected)
    
    if item then
        local itemColor = self:getItemColor(item)
        love.graphics.setColor(itemColor[1], itemColor[2], itemColor[3], 0.3)
        love.graphics.rectangle("fill", x + 3, y + 3, self.slotSize - 6, self.slotSize - 6, 3, 3)
        
        love.graphics.setColor(itemColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x + 3, y + 3, self.slotSize - 6, self.slotSize - 6, 3, 3)
        love.graphics.setLineWidth(1)
        
        love.graphics.setColor(self.colors.text)
        local name = item.name or "Item"
        if #name > 8 then
            name = string.sub(name, 1, 7) .. ".."
        end
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(name)
        local textX = x + (self.slotSize - textWidth) / 2
        love.graphics.print(name, textX, y + self.slotSize - 18, 0, 0.8, 0.8)
        
        local icon = self:getItemIcon(item)
        love.graphics.setColor(self.colors.text)
        love.graphics.printf(icon, x, y + 8, self.slotSize, "center")
    else
        love.graphics.setColor(self.colors.textDim[1], self.colors.textDim[2], self.colors.textDim[3], 0.3)
        love.graphics.printf(tostring(slotIndex), x, y + (self.slotSize - 15) / 2, self.slotSize, "center")
    end
end

-- Get simple icon for item
function InventoryUI:getItemIcon(item)
    if not item then return "" end
    
    if item.type == ItemDatabase.TYPE.CONSUMABLE then
        return "P"
    end
    
    if item.slot == ItemDatabase.SLOTS.WEAPON then
        return "W"
    elseif item.slot == ItemDatabase.SLOTS.HAT then
        return "H"
    elseif item.slot == ItemDatabase.SLOTS.CLOTHES then
        return "C"
    elseif item.slot == ItemDatabase.SLOTS.SHOES then
        return "S"
    elseif item.slot == ItemDatabase.SLOTS.NECKLACE then
        return "N"
    end
    
    return "?"
end

function InventoryUI:drawItemDetail(inventorySystem, x, y, width, height)
    local item = nil
    local itemData = nil
    
    if self.selectedSlot then
        item = inventorySystem:getItem(self.selectedSlot)
    elseif self.hoveredSlot then
        item = inventorySystem:getItem(self.hoveredSlot)
    end
    
    if not item then
        love.graphics.setColor(self.colors.textDim)
        love.graphics.printf("Select an item to view details", x, y + 30, width, "center")
        return
    end
    
    itemData = ItemDatabase.getItem(item.id)
    
    Components.drawPanelSimple(x, y, width, height, 5)
    
    local textX = x + 15
    local textY = y + 15
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print(itemData.name, textX, textY, 0, 1.2, 1.2)
    textY = textY + 25
    
    love.graphics.setColor(self.colors.textDim)
    love.graphics.print(itemData.description or "", textX, textY, 0, 0.9, 0.9)
    textY = textY + 25
    
    if itemData.type == ItemDatabase.TYPE.EQUIPMENT then
        love.graphics.setColor(self.colors.equipment)
        love.graphics.print("Type: Equipment", textX, textY)
        textY = textY + 20
        
        love.graphics.setColor(self.colors.text)
        love.graphics.print("Slot: " .. ItemDatabase.getSlotName(itemData.slot), textX, textY)
        textY = textY + 25
        
        if itemData.attack and itemData.attack > 0 then
            love.graphics.setColor(self.colors.weapon)
            love.graphics.print("ATK: +" .. itemData.attack, textX, textY)
            textY = textY + 18
        end
        if itemData.defense and itemData.defense > 0 then
            love.graphics.setColor(self.colors.clothes)
            love.graphics.print("DEF: +" .. itemData.defense, textX, textY)
            textY = textY + 18
        end
        if itemData.speed and itemData.speed ~= 0 then
            love.graphics.setColor(0.8, 1.0, 0.3)
            love.graphics.print("SPD: " .. (itemData.speed > 0 and "+" or "") .. itemData.speed, textX, textY)
            textY = textY + 18
        end
        if itemData.hp and itemData.hp > 0 then
            love.graphics.setColor(0.3, 1.0, 0.3)
            love.graphics.print("HP: +" .. itemData.hp, textX, textY)
            textY = textY + 18
        end
        if itemData.crit and itemData.crit > 0 then
            love.graphics.setColor(1.0, 0.8, 0.2)
            love.graphics.print("CRIT: +" .. itemData.crit .. "%", textX, textY)
            textY = textY + 18
        end
        if itemData.eva and itemData.eva > 0 then
            love.graphics.setColor(0.5, 0.8, 1.0)
            love.graphics.print("EVA: +" .. itemData.eva .. "%", textX, textY)
            textY = textY + 18
        end
    elseif itemData.type == ItemDatabase.TYPE.CONSUMABLE then
        love.graphics.setColor(self.colors.consumable)
        love.graphics.print("Type: Consumable", textX, textY)
        textY = textY + 20
        
        love.graphics.setColor(self.colors.text)
        local effectText = self:getEffectText(itemData)
        love.graphics.print("Effect: " .. effectText, textX, textY)
        textY = textY + 25
    end
    
    if itemData.price then
        textY = y + height - 25
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.print("Price: " .. itemData.price .. " G", textX, textY)
    end
end

-- Get effect text for consumable
function InventoryUI:getEffectText(itemData)
    if itemData.effect == "heal" then
        return "Restore " .. itemData.value .. " HP"
    elseif itemData.effect == "full_heal" then
        return "Fully restore HP"
    elseif itemData.effect == "cure_poison" then
        return "Cure poison"
    elseif itemData.effect == "random" then
        return "Random effect"
    elseif itemData.effect == "temp_atk" then
        return "ATK +" .. itemData.value .. " for " .. (itemData.duration or 3) .. " turns"
    end
    return itemData.effect or "Unknown"
end

-- Check mouse position for slot hover
function InventoryUI:updateHover(inventorySystem, mouseX, mouseY, gridX, gridY, gridWidth)
    local startX = gridX + (gridWidth - self.cols * (self.slotSize + self.slotPadding) + self.slotPadding) / 2
    
    for row = 1, self.rows do
        for col = 1, self.cols do
            local slotIndex = (row - 1) * self.cols + col
            local slotX = startX + (col - 1) * (self.slotSize + self.slotPadding)
            local slotY = gridY + (row - 1) * (self.slotSize + self.slotPadding)
            
            if mouseX >= slotX and mouseX <= slotX + self.slotSize and
               mouseY >= slotY and mouseY <= slotY + self.slotSize then
                self.hoveredSlot = slotIndex
                return slotIndex
            end
        end
    end
    
    self.hoveredSlot = nil
    return nil
end

-- Handle click on inventory grid
function InventoryUI:handleClick(inventorySystem, mouseX, mouseY, gridX, gridY, gridWidth)
    local slotIndex = self:updateHover(inventorySystem, mouseX, mouseY, gridX, gridY, gridWidth)
    
    if slotIndex then
        if self.selectedSlot == slotIndex then
            self.selectedSlot = nil
        else
            self.selectedSlot = slotIndex
        end
        return slotIndex
    end
    
    return nil
end

-- Get selected slot
function InventoryUI:getSelectedSlot()
    return self.selectedSlot
end

-- Clear selection
function InventoryUI:clearSelection()
    self.selectedSlot = nil
end

-- Get grid dimensions
function InventoryUI:getGridDimensions()
    local width = self.cols * (self.slotSize + self.slotPadding) - self.slotPadding
    local height = self.rows * (self.slotSize + self.slotPadding) - self.slotPadding
    return width, height
end

return InventoryUI
