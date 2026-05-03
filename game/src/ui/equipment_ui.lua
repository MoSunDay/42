local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local SlotUtils = require("src.ui.slot_utils")
local EquipmentSystem = require("src.systems.equipment_system")

local EquipmentUI = {}

function EquipmentUI.create(assetManager)
    local state = {}
    
    state.assetManager = assetManager
    state.visible = false
    state.selectedSlot = 1
    
    state.equipColors = Theme.colors.equipment
    
    return state
end

function EquipmentUI.toggle(state)
    state.visible = not state.visible
end

function EquipmentUI.show(state)
    state.visible = true
end

function EquipmentUI.hide(state)
    state.visible = false
end

function EquipmentUI.draw(state, equipmentSystem, x, y, width, height)
    if not state.visible then
        return
    end
    
    local EquipmentSlots = require("src.systems.equipment_system").SLOTS
    
    local w, h = love.graphics.getDimensions()
    Components.drawOverlay(w, h, 0.7)
    
    Components.drawOrnatePanel(x, y, width, height, state.assetManager, {title="Equipment", corners=true, glow=true})
    
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print("Press E to close", x + width - 150, y + 20)
    
    local slotY = y + 60
    local slotHeight = 80
    local slotIndex = 1
    
    EquipmentUI.draw_equipment_slot(state, equipmentSystem, EquipmentSlots.WEAPON, "Weapon", 
        x + 20, slotY, width - 40, slotHeight, slotIndex == state.selectedSlot)
    slotY = slotY + slotHeight + 10
    slotIndex = slotIndex + 1
    
    EquipmentUI.draw_equipment_slot(state, equipmentSystem, EquipmentSlots.ARMOR, "Armor", 
        x + 20, slotY, width - 40, slotHeight, slotIndex == state.selectedSlot)
    slotY = slotY + slotHeight + 10
    slotIndex = slotIndex + 1
    
    EquipmentUI.draw_equipment_slot(state, equipmentSystem, EquipmentSlots.NECKLACE, "Necklace", 
        x + 20, slotY, width - 40, slotHeight, slotIndex == state.selectedSlot)
    
    EquipmentUI.draw_total_stats(state, equipmentSystem, x + 20, y + height - 100, width - 40)
end

function EquipmentUI.draw_equipment_slot(state, equipmentSystem, slot, slotName, x, y, width, height, isSelected)
    Components.drawOrnatePanel(x, y, width, height, state.assetManager, {
        corners = false,
        glow = isSelected,
        borderColor = isSelected and Theme.gold.bright or Theme.colors.borderDim
    })
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(slotName, x + 10, y + 10)
    
    local item = EquipmentSystem.getEquipped(equipmentSystem, slot)
    if item then
        love.graphics.setColor(SlotUtils.getSlotColor(slot))
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
        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.print("(Empty)", x + 10, y + 35)
    end
end

function EquipmentUI.draw_total_stats(state, equipmentSystem, x, y, width)
    local stats = EquipmentSystem.get_total_stats(equipmentSystem)
    
    Components.drawOrnatePanel(x, y, width, 80, state.assetManager, {corners=false, glow=false})
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print("Total Equipment Bonus", x + 10, y + 10)
    
    love.graphics.setColor(state.equipColors.weapon)
    love.graphics.print("ATK: +" .. stats.attack, x + 10, y + 35)
    
    love.graphics.setColor(state.equipColors.clothes)
    love.graphics.print("DEF: +" .. stats.defense, x + 120, y + 35)
    
    love.graphics.setColor(Theme.colors.success)
    love.graphics.print("SPD: " .. (stats.speed >= 0 and "+" or "") .. stats.speed, x + 230, y + 35)
end

function EquipmentUI.navigate_up(state)
    state.selectedSlot = math.max(1, state.selectedSlot - 1)
end

function EquipmentUI.navigate_down(state)
    state.selectedSlot = math.min(3, state.selectedSlot + 1)
end

function EquipmentUI.is_visible(state)
    return state.visible
end

return EquipmentUI
