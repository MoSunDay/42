local ItemDatabase = require("src.systems.item_database")
local InventoryUI = require("src.ui.inventory_ui")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local SlotUtils = require("src.ui.slot_utils")
local EquipmentSystem = require("src.systems.equipment_system")
local InventorySystem = require("src.systems.inventory_system")
local Player = require("src.entities.player")
local CombatUtils = require("src.systems.combat_utils")

local UnifiedMenu = {}

function UnifiedMenu.create(assetManager)
    local state = {}
    
    state.assetManager = assetManager
    state.isOpen = false
    
    state.tabs = {
        {name = "Equipment", key = "equipment"},
        {name = "Items", key = "items"},
        {name = "Party", key = "party"},
        {name = "Pet", key = "pet"}
    }
    state.currentTab = 1
    state.hoveredTab = 0
    state.hoveredTab = nil
    
    local w, h = love.graphics.getDimensions()
    state.width = 800
    state.height = 600
    state.x = (w - state.width) / 2
    state.y = (h - state.height) / 2
    
    state.tabHeight = 40
    state.tabWidth = state.width / #state.tabs
    
    state.colors = {
        background = Theme.colors.background,
        panel = Theme.colors.panel,
        border = Theme.colors.border,
        tabActive = Theme.colors.tab.active,
        tabInactive = Theme.colors.tab.inactive,
        text = Theme.colors.text,
        textDim = Theme.colors.textDim,
        button = Theme.colors.button,
        buttonHover = Theme.colors.buttonHover,
        weapon = Theme.colors.equipment.weapon,
        hat = Theme.colors.equipment.hat,
        clothes = Theme.colors.equipment.clothes,
        shoes = Theme.colors.equipment.shoes,
        necklace = Theme.colors.equipment.necklace
    }
    
    state.font = assetManager:get_font("default")
    state.fontLarge = assetManager:get_font("large")
    
    state.inventoryUI = InventoryUI.create(assetManager)
    
    state.selectedEquipSlot = nil
    state.showEquipDialog = false
    
    state.buttonHover_equip = false
    state.buttonHover_use = false
    
    return state
end

function UnifiedMenu.toggle(state)
    state.isOpen = not state.isOpen
end

function UnifiedMenu.open(state)
    state.isOpen = true
end

function UnifiedMenu.close(state)
    state.isOpen = false
    InventoryUI.clear_selection(state.inventoryUI)
    state.selectedEquipSlot = nil
    state.showEquipDialog = false
end

function UnifiedMenu.is_menu_open(state)
    return state.isOpen
end

function UnifiedMenu.switch_tab(state, tabIndex)
    if tabIndex >= 1 and tabIndex <= #state.tabs then
        state.currentTab = tabIndex
        InventoryUI.clear_selection(state.inventoryUI)
        state.selectedEquipSlot = nil
        state.showEquipDialog = false
    end
end

function UnifiedMenu.set_tab(state, tabIndex)
    UnifiedMenu.switch_tab(state, tabIndex)
end

function UnifiedMenu.draw(state, gameState)
    if not state.isOpen then return end
    
    local w, h = love.graphics.getDimensions()
    Components.drawOverlay(w, h, 0.6)
    
    Components.drawOrnatePanel(state.x, state.y, state.width, state.height, state.assetManager, {
        title = "Menu",
        corners = true,
        glow = true,
        shimmer = true,
        font = state.fontLarge
    })
    
    UnifiedMenu.draw_tabs(state)
    
    local contentY = state.y + state.tabHeight + 10
    local contentHeight = state.height - state.tabHeight - 20
    
    if state.tabs[state.currentTab].key == "equipment" then
        UnifiedMenu.draw_equipment_tab(state, gameState, contentY, contentHeight)
    elseif state.tabs[state.currentTab].key == "items" then
        UnifiedMenu.draw_items_tab(state, gameState, contentY, contentHeight)
    elseif state.tabs[state.currentTab].key == "party" then
        UnifiedMenu.draw_party_tab(state, gameState, contentY, contentHeight)
    elseif state.tabs[state.currentTab].key == "pet" then
        UnifiedMenu.draw_pet_tab(state, gameState, contentY, contentHeight)
    end
    
    UnifiedMenu.draw_close_button(state)
end

function UnifiedMenu.draw_tabs(state)
    local mx, my = love.mouse.getPosition()
    state.hoveredTab = nil
    for i, tab in ipairs(state.tabs) do
        local tabX = state.x + (i - 1) * state.tabWidth
        local tabY = state.y + 5
        local is_active = i == state.currentTab
        local is_hovered = mx >= tabX and mx <= tabX + state.tabWidth and my >= tabY and my <= tabY + state.tabHeight

        if is_hovered then
            state.hoveredTab = i
        end

        Components.drawTab(tabX + 2, tabY, state.tabWidth - 4, state.tabHeight, tab.name, is_active, state.assetManager, state.font, is_hovered)

        if is_active then
            love.graphics.setColor(Theme.gold.normal)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", tabX + 2, tabY, state.tabWidth - 4, state.tabHeight, 5, 5)
        end

        love.graphics.setFont(state.font)
        love.graphics.setColor(is_active and Theme.gold.bright or Theme.colors.text)
        love.graphics.printf(tab.name, tabX + 2, tabY + (state.tabHeight - state.font:getHeight()) / 2, state.tabWidth - 4, "center")
    end
end

function UnifiedMenu.draw_close_button(state)
    local btnSize = 30
    local btnX = state.x + state.width - btnSize - 10
    local btnY = state.y + 10
    
    Components.drawOrnateButton(btnX, btnY, btnSize, btnSize, "X", "normal", state.assetManager, state.font)
end

function UnifiedMenu.draw_equipment_tab(state, gameState, contentY, contentHeight)
    local equipmentSystem = gameState:get_equipment_system()
    local inventorySystem = gameState:get_inventory_system()
    
    if not equipmentSystem then
        love.graphics.setColor(state.colors.textDim)
        love.graphics.printf("Equipment system not available", state.x, contentY + 100, state.width, "center")
        return
    end
    
    love.graphics.setFont(state.fontLarge)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Equipment", state.x, contentY + 10, state.width, "center")
    
    local slots = {
        {slot = ItemDatabase.SLOTS.WEAPON, name = "Weapon"},
        {slot = ItemDatabase.SLOTS.HAT, name = "Hat"},
        {slot = ItemDatabase.SLOTS.CLOTHES, name = "Clothes"},
        {slot = ItemDatabase.SLOTS.SHOES, name = "Shoes"},
        {slot = ItemDatabase.SLOTS.NECKLACE, name = "Necklace"}
    }
    
    local leftPanelX = state.x + 20
    local leftPanelWidth = 350
    local slotY = contentY + 50
    local slotHeight = 65
    
    love.graphics.setFont(state.font)
    
    Components.drawOrnatePanel(leftPanelX, slotY - 10, leftPanelWidth, #slots * (slotHeight + 5) + 20, state.assetManager, { corners = true, glow = false })
    
    for i, slotInfo in ipairs(slots) do
        local y = slotY + (i - 1) * (slotHeight + 5)
        
        UnifiedMenu.draw_equipment_slot(state, equipmentSystem, slotInfo.slot, slotInfo.name, leftPanelX + 10, y, leftPanelWidth - 20, slotHeight)
    end
    
    local statsY = slotY + #slots * (slotHeight + 5) + 20
    UnifiedMenu.draw_total_stats(state, equipmentSystem, leftPanelX, statsY, leftPanelWidth)
    
    local rightPanelX = state.x + leftPanelWidth + 40
    local rightPanelWidth = state.width - leftPanelWidth - 60
    
    Components.drawOrnatePanel(rightPanelX, contentY + 50, rightPanelWidth, contentHeight - 60, state.assetManager, { corners = true, glow = false })
    
    love.graphics.setColor(state.colors.text)
    love.graphics.print("Inventory", rightPanelX + 10, contentY + 60)
    
    local gridX = rightPanelX + 10
    local gridY = contentY + 90
    local gridWidth = rightPanelWidth - 20
    local gridHeight = contentHeight - 130
    local detailHeight = 100
    
    InventoryUI.draw(state.inventoryUI, inventorySystem, gridX, gridY + detailHeight + 10, gridWidth, gridHeight - detailHeight - 10)
    
    InventoryUI.draw_item_detail(state.inventoryUI, inventorySystem, gridX, gridY, gridWidth, detailHeight)
end

function UnifiedMenu.draw_equipment_slot(state, equipmentSystem, slot, slotName, x, y, width, height)
    local isSelected = state.selectedEquipSlot == slot
    
    Components.drawOrnatePanel(x, y, width, height, state.assetManager, {
        corners = false,
        glow = isSelected,
        borderColor = isSelected and Theme.gold.bright or Theme.colors.borderDim
    })
    
    love.graphics.setColor(state.colors.text)
    love.graphics.print(slotName, x + 10, y + 8)
    
    local item = EquipmentSystem.get_equipped(equipmentSystem, slot)
    if item then
        local slotColor = SlotUtils.getSlotColor(slot)
        love.graphics.setColor(slotColor)
        love.graphics.print(item.name, x + 10, y + 28, 0, 1.1, 1.1)
        
        love.graphics.setColor(state.colors.textDim)
        local stats = {}
        if item.attack and item.attack > 0 then table.insert(stats, "ATK+" .. item.attack) end
        if item.defense and item.defense > 0 then table.insert(stats, "DEF+" .. item.defense) end
        if item.speed and item.speed ~= 0 then table.insert(stats, "SPD" .. (item.speed > 0 and "+" or "") .. item.speed) end
        if item.hp and item.hp > 0 then table.insert(stats, "HP+" .. item.hp) end
        if item.crit and item.crit > 0 then table.insert(stats, "CRIT+" .. item.crit .. "%") end
        if item.eva and item.eva > 0 then table.insert(stats, "EVA+" .. item.eva .. "%") end
        love.graphics.print(table.concat(stats, "  "), x + 10, y + 46)
    else
        love.graphics.setColor(state.colors.textDim)
        love.graphics.print("(Empty)", x + 10, y + 35)
    end
end

function UnifiedMenu.draw_total_stats(state, equipmentSystem, x, y, width)
    local stats = EquipmentSystem.get_total_stats(equipmentSystem)
    local defPercent = EquipmentSystem.get_defense_percent(equipmentSystem)
    
    Components.drawOrnatePanel(x, y, width, 80, state.assetManager, { corners = true, glow = false })
    
    love.graphics.setColor(state.colors.text)
    love.graphics.print("Equipment Bonus:", x + 10, y + 8)
    
    local statX = x + 10
    local statY = y + 28
    
    love.graphics.setColor(state.colors.weapon)
    love.graphics.print("ATK: +" .. stats.attack, statX, statY)
    
    love.graphics.setColor(state.colors.clothes)
    love.graphics.print("DEF: +" .. stats.defense .. " (" .. defPercent .. "%)", statX + 100, statY)
    
    love.graphics.setColor(Theme.colors.stat.speed)
    love.graphics.print("SPD: " .. (stats.speed >= 0 and "+" or "") .. stats.speed, statX + 240, statY)
    
    statY = statY + 22
    
    love.graphics.setColor(Theme.colors.stat.hp)
    love.graphics.print("HP: +" .. stats.hp, statX, statY)
    
    love.graphics.setColor(Theme.colors.stat.crit)
    love.graphics.print("CRIT: +" .. stats.crit .. "%", statX + 100, statY)
    
    love.graphics.setColor(Theme.colors.stat.evasion)
    love.graphics.print("EVA: +" .. stats.eva .. "%", statX + 220, statY)
end

function UnifiedMenu.draw_items_tab(state, gameState, contentY, contentHeight)
    local inventorySystem = gameState:get_inventory_system()
    
    love.graphics.setFont(state.fontLarge)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Items", state.x, contentY + 10, state.width, "center")
    
    local inventoryInfo = string.format("Inventory: %d / %d", 
        InventorySystem.get_used_slots(inventorySystem), 
        InventorySystem.get_max_slots(inventorySystem))
    love.graphics.setFont(state.font)
    love.graphics.setColor(state.colors.textDim)
    love.graphics.print(inventoryInfo, state.x + 20, contentY + 45)
    
    local gridX = state.x + 20
    local gridY = contentY + 70
    local gridWidth = state.width - 250
    local gridHeight = contentHeight - 100
    
    Components.drawOrnatePanel(gridX, gridY, gridWidth, gridHeight, state.assetManager, { corners = true, glow = false })
    
    InventoryUI.draw(state.inventoryUI, inventorySystem, gridX, gridY + 10, gridWidth, gridHeight - 20)
    
    local detailX = gridX + gridWidth + 10
    local detailWidth = state.width - gridWidth - 40
    
    Components.drawOrnatePanel(detailX, gridY, detailWidth, gridHeight, state.assetManager, { corners = true, glow = false })
    
    InventoryUI.draw_item_detail(state.inventoryUI, inventorySystem, detailX + 10, gridY + 10, detailWidth - 20, gridHeight - 60)
    
    local selectedItem = InventoryUI.get_selected_slot(state.inventoryUI) and InventorySystem.get_item(inventorySystem, InventoryUI.get_selected_slot(state.inventoryUI))
    
    if selectedItem then
        local btnX = detailX + 10
        local btnY = gridY + gridHeight - 45
        local btnWidth = detailWidth - 20
        local btnHeight = 35
        
        if selectedItem.type == ItemDatabase.TYPE.EQUIPMENT then
            UnifiedMenu.draw_button(state, "Equip", btnX, btnY, btnWidth, btnHeight, state.buttonHover_equip)
        elseif selectedItem.type == ItemDatabase.TYPE.CONSUMABLE then
            UnifiedMenu.draw_button(state, "Use", btnX, btnY, btnWidth, btnHeight, state.buttonHover_use)
        end
    end
end

function UnifiedMenu.draw_button(state, text, x, y, width, height, isHovered)
    Components.drawOrnateButton(x, y, width, height, text, isHovered and "hover" or "normal", state.assetManager, state.font)
end

function UnifiedMenu.draw_party_tab(state, gameState, contentY, contentHeight)
    local partySystem = gameState:get_party_system()
    if not partySystem then
        love.graphics.setColor(state.colors.textDim)
        love.graphics.printf("Party system not available", state.x, contentY + 100, state.width, "center")
        return
    end
    
    love.graphics.setFont(state.fontLarge)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Party Management", state.x, contentY + 10, state.width, "center")
    
    love.graphics.setFont(state.font)
    love.graphics.print("Party Name: " .. partySystem:get_party_name(), state.x + 50, contentY + 60)
    
    local members = partySystem:get_members()
    love.graphics.print("Members: " .. #members .. "/5", state.x + 50, contentY + 85)
    
    local memberY = contentY + 120
    for i, member in ipairs(members) do
        local y = memberY + (i - 1) * 70
        
        Components.drawOrnatePanel(state.x + 50, y, state.width - 100, 60, state.assetManager, { corners = true, glow = false })
        
        if i == partySystem.leaderIndex then
            love.graphics.setColor(Theme.gold.bright)
            love.graphics.print("*", state.x + 60, y + 10)
        end
        
        love.graphics.setColor(state.colors.text)
        love.graphics.print(member.name, state.x + 90, y + 10)
        
        local hpBarX = state.x + 90
        local hpBarY = y + 35
        local hpBarW = 200
        local hpBarH = 12
        
        local hpPercent = member.hp / member.maxHp
        Components.drawOrnateHPBar(hpBarX, hpBarY, hpBarW, hpBarH, hpPercent, nil, state.assetManager)
        
        love.graphics.setColor(state.colors.text)
        love.graphics.print(member.hp .. "/" .. member.maxHp, hpBarX + hpBarW + 10, hpBarY)
    end
end

function UnifiedMenu.draw_pet_tab(state, gameState, contentY, contentHeight)
    love.graphics.setFont(state.fontLarge)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Pet Management", state.x, contentY + 10, state.width, "center")
    
    love.graphics.setFont(state.font)
    love.graphics.setColor(state.colors.textDim)
    love.graphics.printf("Pet system coming soon...", state.x, contentY + 100, state.width, "center")
    love.graphics.printf("Summon and manage your battle companions", state.x, contentY + 130, state.width, "center")
end

function UnifiedMenu.mousepressed(state, x, y, button, gameState)
    if not state.isOpen or button ~= 1 then
        return false
    end
    
    local btnSize = 30
    local btnX = state.x + state.width - btnSize - 10
    local btnY = state.y + 10
    
    if x >= btnX and x <= btnX + btnSize and y >= btnY and y <= btnY + btnSize then
        UnifiedMenu.close(state)
        return true
    end
    
    for i, tab in ipairs(state.tabs) do
        local tabX = state.x + (i - 1) * state.tabWidth
        local tabY = state.y
        
        if x >= tabX and x <= tabX + state.tabWidth and y >= tabY and y <= tabY + state.tabHeight then
            UnifiedMenu.switch_tab(state, i)
            return true
        end
    end
    
    if not gameState then return false end
    
    if state.tabs[state.currentTab].key == "equipment" then
        return UnifiedMenu.handle_equipment_click(state, gameState, x, y)
    elseif state.tabs[state.currentTab].key == "items" then
        return UnifiedMenu.handle_items_click(state, gameState, x, y)
    end
    
    return false
end

function UnifiedMenu.handle_equipment_click(state, gameState, x, y)
    local equipmentSystem = gameState:get_equipment_system()
    local inventorySystem = gameState:get_inventory_system()
    local player = gameState.player
    
    local contentY = state.y + state.tabHeight + 10
    local leftPanelX = state.x + 20
    local leftPanelWidth = 350
    local slotY = contentY + 50
    local slotHeight = 65
    
    local slots = {
        ItemDatabase.SLOTS.WEAPON,
        ItemDatabase.SLOTS.HAT,
        ItemDatabase.SLOTS.CLOTHES,
        ItemDatabase.SLOTS.SHOES,
        ItemDatabase.SLOTS.NECKLACE
    }
    
    for i, slot in ipairs(slots) do
        local slotYPos = slotY + (i - 1) * (slotHeight + 5)
        if x >= leftPanelX + 10 and x <= leftPanelX + leftPanelWidth - 10 and
           y >= slotYPos and y <= slotYPos + slotHeight then
            
            local item = EquipmentSystem.get_equipped(equipmentSystem, slot)
            if item then
                local success = EquipmentSystem.unequip_to_inventory(equipmentSystem, slot, inventorySystem)
                if success then
                    Player.update_stats_with_equipment(player)
                    gameState:sync_player_to_character()
                end
            end
            return true
        end
    end
    
    local rightPanelX = state.x + leftPanelWidth + 40
    local rightPanelWidth = state.width - leftPanelWidth - 60
    local gridX = rightPanelX + 10
    local gridY = contentY + 90 + 110
    local gridWidth = rightPanelWidth - 20
    
    local clickedSlot = InventoryUI.handle_click(state.inventoryUI, inventorySystem, x, y, gridX, gridY, gridWidth)
    if clickedSlot then
        local item = InventorySystem.get_item(inventorySystem, clickedSlot)
        if item and item.type == ItemDatabase.TYPE.EQUIPMENT then
            local success, msg = EquipmentSystem.equip_from_inventory(equipmentSystem, inventorySystem, clickedSlot)
            if success then
                Player.update_stats_with_equipment(player)
                gameState:sync_player_to_character()
                InventoryUI.clear_selection(state.inventoryUI)
            end
        end
        return true
    end
    
    return false
end

function UnifiedMenu.handle_items_click(state, gameState, x, y)
    local inventorySystem = gameState:get_inventory_system()
    local player = gameState.player
    
    local contentY = state.y + state.tabHeight + 10
    local gridX = state.x + 20
    local gridY = contentY + 70
    local gridWidth = state.width - 250
    
    local clickedSlot = InventoryUI.handle_click(state.inventoryUI, inventorySystem, x, y, gridX, gridY, gridWidth)
    if clickedSlot then
        return true
    end
    
    local detailX = gridX + gridWidth + 10
    local detailWidth = state.width - gridWidth - 40
    local gridHeight = state.height - state.tabHeight - 120
    local btnX = detailX + 10
    local btnY = gridY + gridHeight - 45
    local btnWidth = detailWidth - 20
    local btnHeight = 35
    
    if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
        local selectedSlot = InventoryUI.get_selected_slot(state.inventoryUI)
        if selectedSlot then
            local item = InventorySystem.get_item(inventorySystem, selectedSlot)
            if item then
                if item.type == ItemDatabase.TYPE.EQUIPMENT then
                    local equipmentSystem = gameState:get_equipment_system()
                    local success, msg = EquipmentSystem.equip_from_inventory(equipmentSystem, inventorySystem, selectedSlot)
                    if success then
                        Player.update_stats_with_equipment(player)
                        gameState:sync_player_to_character()
                        InventoryUI.clear_selection(state.inventoryUI)
                    end
                elseif item.type == ItemDatabase.TYPE.CONSUMABLE then
                    UnifiedMenu.use_consumable(state, gameState, selectedSlot)
                end
            end
        end
        return true
    end
    
    return false
end

function UnifiedMenu.use_consumable(state, gameState, slotIndex)
    local inventorySystem = gameState:get_inventory_system()
    local player = gameState.player
    
    local item = InventorySystem.get_item(inventorySystem, slotIndex)
    if not item then return end
    
    local itemData = ItemDatabase.get_item(item.id)
    if not itemData then return end
    
    if itemData.effect == "heal" then
        CombatUtils.healMutating(player, itemData.value)
        InventorySystem.remove_item(inventorySystem, slotIndex)
        InventoryUI.clear_selection(state.inventoryUI)
        gameState:sync_player_to_character()
    elseif itemData.effect == "full_heal" then
        player.hp = player.maxHp
        InventorySystem.remove_item(inventorySystem, slotIndex)
        InventoryUI.clear_selection(state.inventoryUI)
        gameState:sync_player_to_character()
    elseif itemData.effect == "cure_poison" then
        InventorySystem.remove_item(inventorySystem, slotIndex)
        InventoryUI.clear_selection(state.inventoryUI)
    elseif itemData.effect == "random" then
        local effects = {"heal_small", "heal_large", "damage", "nothing"}
        local effect = effects[math.random(1, #effects)]
        if effect == "heal_small" then
            CombatUtils.healMutating(player, 30)
        elseif effect == "heal_large" then
            CombatUtils.healMutating(player, 100)
        elseif effect == "damage" then
            CombatUtils.take_damageMutating(player, 20)
        end
        InventorySystem.remove_item(inventorySystem, slotIndex)
        InventoryUI.clear_selection(state.inventoryUI)
        gameState:sync_player_to_character()
    end
end

function UnifiedMenu.mousemoved(state, x, y, gameState)
    if not state.isOpen then return end
    
    state.hoveredTab = 0
    for i, tab in ipairs(state.tabs) do
        local tabX = state.x + (i - 1) * state.tabWidth
        local tabY = state.y + 5
        if x >= tabX and x <= tabX + state.tabWidth and y >= tabY and y <= tabY + state.tabHeight then
            state.hoveredTab = i
            break
        end
    end
    
    local contentY = state.y + state.tabHeight + 10
    
    if state.tabs[state.currentTab].key == "equipment" then
        local leftPanelWidth = 350
        local rightPanelX = state.x + leftPanelWidth + 40
        local rightPanelWidth = state.width - leftPanelWidth - 60
        local gridX = rightPanelX + 10
        local gridY = contentY + 90 + 110
        local gridWidth = rightPanelWidth - 20
        
        if gameState then
            InventoryUI.update_hover(state.inventoryUI, gameState:get_inventory_system(), x, y, gridX, gridY, gridWidth)
        end
    elseif state.tabs[state.currentTab].key == "items" then
        local gridX = state.x + 20
        local gridY = contentY + 70
        local gridWidth = state.width - 250
        
        if gameState then
            InventoryUI.update_hover(state.inventoryUI, gameState:get_inventory_system(), x, y, gridX, gridY, gridWidth)
        end
        
        local detailX = gridX + gridWidth + 10
        local detailWidth = state.width - gridWidth - 40
        local gridHeight = state.height - state.tabHeight - 120
        local btnX = detailX + 10
        local btnY = gridY + gridHeight - 45
        local btnWidth = detailWidth - 20
        local btnHeight = 35
        
        state.buttonHover_use = false
        state.buttonHover_equip = false
        
        local selectedSlot = InventoryUI.get_selected_slot(state.inventoryUI)
        if selectedSlot then
            local item = InventorySystem.get_item(gameState:get_inventory_system(), selectedSlot)
            if item then
                if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
                    if item.type == ItemDatabase.TYPE.EQUIPMENT then
                        state.buttonHover_equip = true
                    elseif item.type == ItemDatabase.TYPE.CONSUMABLE then
                        state.buttonHover_use = true
                    end
                end
            end
        end
    end
end

function UnifiedMenu.keypressed(state, key)
    if key == "escape" or key == "m" then
        if state.isOpen then
            UnifiedMenu.close(state)
            return true
        end
    end
    return false
end

return UnifiedMenu
