local ItemDatabase = require("src.systems.item_database")
local InventorySystem = require("src.systems.inventory_system")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local SlotUtils = require("src.ui.slot_utils")

local InventoryUI = {}

function InventoryUI.create(assetManager)
    local state = {}
    
    state.assetManager = assetManager
    
    state.hoveredSlot = nil
    state.selectedSlot = nil
    
    state.cols = 6
    state.rows = 5
    state.slotSize = 60
    state.slotPadding = 5
    
    state.colors = Theme.colors.inventory
    state.equipColors = Theme.colors.equipment
    
    return state
end

function InventoryUI.draw(state, inventorySystem, x, y, width, height)
    local slots = InventorySystem.getAllSlots(inventorySystem)
    local maxSlots = InventorySystem.getMaxSlots(inventorySystem)
    
    local gridWidth = state.cols * (state.slotSize + state.slotPadding) - state.slotPadding
    local startX = x + (width - gridWidth) / 2
    
    for row = 1, state.rows do
        for col = 1, state.cols do
            local slotIndex = (row - 1) * state.cols + col
            local slotX = startX + (col - 1) * (state.slotSize + state.slotPadding)
            local slotY = y + (row - 1) * (state.slotSize + state.slotPadding)
            
            local item = slots[slotIndex]
            local isHovered = state.hoveredSlot == slotIndex
            local isSelected = state.selectedSlot == slotIndex
            
            InventoryUI.draw_slot(state, slotIndex, item, slotX, slotY, isHovered, isSelected)
        end
    end
end

function InventoryUI.draw_slot(state, slotIndex, item, x, y, isHovered, isSelected)
    local slotState = isSelected and "selected" or (isHovered and "hover" or "normal")
    Components.draw_slot(x, y, state.slotSize, slotState, state.assetManager)
    
    if item then
        local itemColor = SlotUtils.get_itemColor(item)
        love.graphics.setColor(itemColor[1], itemColor[2], itemColor[3], 0.3)
        love.graphics.rectangle("fill", x + 3, y + 3, state.slotSize - 6, state.slotSize - 6, 3, 3)
        
        love.graphics.setColor(itemColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x + 3, y + 3, state.slotSize - 6, state.slotSize - 6, 3, 3)
        love.graphics.setLineWidth(1)
        
        love.graphics.setColor(state.colors.text)
        local name = item.name or "Item"
        if #name > 8 then
            name = string.sub(name, 1, 7) .. ".."
        end
        local font = love.graphics.get_font()
        local textWidth = font:getWidth(name)
        local textX = x + (state.slotSize - textWidth) / 2
        love.graphics.print(name, textX, y + state.slotSize - 18, 0, 0.8, 0.8)
        
        local icon = item.type == ItemDatabase.TYPE.CONSUMABLE and "P" or SlotUtils.getSlotIcon(item.slot)
        love.graphics.setColor(state.colors.text)
        love.graphics.printf(icon, x, y + 8, state.slotSize, "center")
    else
        love.graphics.setColor(state.colors.textDim[1], state.colors.textDim[2], state.colors.textDim[3], 0.3)
        love.graphics.printf(tostring(slotIndex), x, y + (state.slotSize - 15) / 2, state.slotSize, "center")
    end
end

function InventoryUI.draw_item_detail(state, inventorySystem, x, y, width, height)
    local item = nil
    local itemData = nil
    
    if state.selectedSlot then
        item = InventorySystem.get_item(inventorySystem, state.selectedSlot)
    elseif state.hoveredSlot then
        item = InventorySystem.get_item(inventorySystem, state.hoveredSlot)
    end
    
    if not item then
        love.graphics.setColor(state.colors.textDim)
        love.graphics.printf("Select an item to view details", x, y + 30, width, "center")
        return
    end
    
    itemData = ItemDatabase.get_item(item.id)
    
    Components.drawOrnatePanel(x, y, width, height, state.assetManager, {title = nil, corners = true, glow = true, shimmer = false})
    
    local textX = x + 15
    local textY = y + 15
    
    love.graphics.setColor(state.colors.text)
    love.graphics.print(itemData.name, textX, textY, 0, 1.2, 1.2)
    textY = textY + 25
    
    love.graphics.setColor(state.colors.textDim)
    love.graphics.print(itemData.description or "", textX, textY, 0, 0.9, 0.9)
    textY = textY + 25
    
    if itemData.type == ItemDatabase.TYPE.EQUIPMENT then
        love.graphics.setColor(state.colors.equipment)
        love.graphics.print("Type: Equipment", textX, textY)
        textY = textY + 20
        
        love.graphics.setColor(state.colors.text)
        love.graphics.print("Slot: " .. ItemDatabase.getSlotName(itemData.slot), textX, textY)
        textY = textY + 25
        
        if itemData.attack and itemData.attack > 0 then
            love.graphics.setColor(state.colors.weapon)
            love.graphics.print("ATK: +" .. itemData.attack, textX, textY)
            textY = textY + 18
        end
        if itemData.defense and itemData.defense > 0 then
            love.graphics.setColor(state.colors.clothes)
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
        love.graphics.setColor(state.colors.consumable)
        love.graphics.print("Type: Consumable", textX, textY)
        textY = textY + 20
        
        love.graphics.setColor(state.colors.text)
        local effectText = InventoryUI.get_effect_text(state, itemData)
        love.graphics.print("Effect: " .. effectText, textX, textY)
        textY = textY + 25
    end
    
    if itemData.price then
        textY = y + height - 25
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.print("灵晶值: " .. itemData.price, textX, textY)
    end
end

function InventoryUI.get_effect_text(state, itemData)
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

function InventoryUI.update_hover(state, inventorySystem, mouseX, mouseY, gridX, gridY, gridWidth)
    local startX = gridX + (gridWidth - state.cols * (state.slotSize + state.slotPadding) + state.slotPadding) / 2
    
    for row = 1, state.rows do
        for col = 1, state.cols do
            local slotIndex = (row - 1) * state.cols + col
            local slotX = startX + (col - 1) * (state.slotSize + state.slotPadding)
            local slotY = gridY + (row - 1) * (state.slotSize + state.slotPadding)
            
            if mouseX >= slotX and mouseX <= slotX + state.slotSize and
               mouseY >= slotY and mouseY <= slotY + state.slotSize then
                state.hoveredSlot = slotIndex
                return slotIndex
            end
        end
    end
    
    state.hoveredSlot = nil
    return nil
end

function InventoryUI.handle_click(state, inventorySystem, mouseX, mouseY, gridX, gridY, gridWidth)
    local slotIndex = InventoryUI.update_hover(state, inventorySystem, mouseX, mouseY, gridX, gridY, gridWidth)
    
    if slotIndex then
        if state.selectedSlot == slotIndex then
            state.selectedSlot = nil
        else
            state.selectedSlot = slotIndex
        end
        return slotIndex
    end
    
    return nil
end

function InventoryUI.get_selected_slot(state)
    return state.selectedSlot
end

function InventoryUI.clear_selection(state)
    state.selectedSlot = nil
end

function InventoryUI.get_grid_dimensions(state)
    local width = state.cols * (state.slotSize + state.slotPadding) - state.slotPadding
    local height = state.rows * (state.slotSize + state.slotPadding) - state.slotPadding
    return width, height
end

return InventoryUI
