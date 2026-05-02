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
    
    state.font = assetManager:getFont("default")
    state.fontLarge = assetManager:getFont("large")
    
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
    InventoryUI.clearSelection(state.inventoryUI)
    state.selectedEquipSlot = nil
    state.showEquipDialog = false
end

function UnifiedMenu.isMenuOpen(state)
    return state.isOpen
end

function UnifiedMenu.switchTab(state, tabIndex)
    if tabIndex >= 1 and tabIndex <= #state.tabs then
        state.currentTab = tabIndex
        InventoryUI.clearSelection(state.inventoryUI)
        state.selectedEquipSlot = nil
        state.showEquipDialog = false
    end
end

function UnifiedMenu.setTab(state, tabIndex)
    UnifiedMenu.switchTab(state, tabIndex)
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
    
    UnifiedMenu.drawTabs(state)
    
    local contentY = state.y + state.tabHeight + 10
    local contentHeight = state.height - state.tabHeight - 20
    
    if state.tabs[state.currentTab].key == "equipment" then
        UnifiedMenu.drawEquipmentTab(state, gameState, contentY, contentHeight)
    elseif state.tabs[state.currentTab].key == "items" then
        UnifiedMenu.drawItemsTab(state, gameState, contentY, contentHeight)
    elseif state.tabs[state.currentTab].key == "party" then
        UnifiedMenu.drawPartyTab(state, gameState, contentY, contentHeight)
    elseif state.tabs[state.currentTab].key == "pet" then
        UnifiedMenu.drawPetTab(state, gameState, contentY, contentHeight)
    end
    
    UnifiedMenu.drawCloseButton(state)
end

function UnifiedMenu.drawTabs(state)
    for i, tab in ipairs(state.tabs) do
        local tabX = state.x + (i - 1) * state.tabWidth
        local tabY = state.y + 5
        local isActive = i == state.currentTab

        Components.drawTab(tabX + 2, tabY, state.tabWidth - 4, state.tabHeight, tab.name, isActive, state.assetManager, state.font)

        if isActive then
            love.graphics.setColor(Theme.gold.normal)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", tabX + 2, tabY, state.tabWidth - 4, state.tabHeight, 5, 5)
        end

        love.graphics.setFont(state.font)
        love.graphics.setColor(isActive and Theme.gold.bright or Theme.colors.text)
        love.graphics.printf(tab.name, tabX + 2, tabY + (state.tabHeight - state.font:getHeight()) / 2, state.tabWidth - 4, "center")
    end
end

function UnifiedMenu.drawCloseButton(state)
    local btnSize = 30
    local btnX = state.x + state.width - btnSize - 10
    local btnY = state.y + 10
    
    Components.drawOrnateButton(btnX, btnY, btnSize, btnSize, "X", "normal", state.assetManager, state.font)
end

function UnifiedMenu.drawEquipmentTab(state, gameState, contentY, contentHeight)
    local equipmentSystem = gameState:getEquipmentSystem()
    local inventorySystem = gameState:getInventorySystem()
    
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
        
        UnifiedMenu.drawEquipmentSlot(state, equipmentSystem, slotInfo.slot, slotInfo.name, leftPanelX + 10, y, leftPanelWidth - 20, slotHeight)
    end
    
    local statsY = slotY + #slots * (slotHeight + 5) + 20
    UnifiedMenu.drawTotalStats(state, equipmentSystem, leftPanelX, statsY, leftPanelWidth)
    
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
    
    InventoryUI.drawItemDetail(state.inventoryUI, inventorySystem, gridX, gridY, gridWidth, detailHeight)
end

function UnifiedMenu.drawEquipmentSlot(state, equipmentSystem, slot, slotName, x, y, width, height)
    local isSelected = state.selectedEquipSlot == slot
    
    Components.drawOrnatePanel(x, y, width, height, state.assetManager, {
        corners = false,
        glow = isSelected,
        borderColor = isSelected and Theme.gold.bright or Theme.colors.borderDim
    })
    
    love.graphics.setColor(state.colors.text)
    love.graphics.print(slotName, x + 10, y + 8)
    
    local item = EquipmentSystem.getEquipped(equipmentSystem, slot)
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

function UnifiedMenu.drawTotalStats(state, equipmentSystem, x, y, width)
    local stats = EquipmentSystem.getTotalStats(equipmentSystem)
    local defPercent = EquipmentSystem.getDefensePercent(equipmentSystem)
    
    Components.drawOrnatePanel(x, y, width, 80, state.assetManager, { corners = true, glow = false })
    
    love.graphics.setColor(state.colors.text)
    love.graphics.print("Equipment Bonus:", x + 10, y + 8)
    
    local statX = x + 10
    local statY = y + 28
    
    love.graphics.setColor(state.colors.weapon)
    love.graphics.print("ATK: +" .. stats.attack, statX, statY)
    
    love.graphics.setColor(state.colors.clothes)
    love.graphics.print("DEF: +" .. stats.defense .. " (" .. defPercent .. "%)", statX + 100, statY)
    
    love.graphics.setColor(0.8, 1.0, 0.3)
    love.graphics.print("SPD: " .. (stats.speed >= 0 and "+" or "") .. stats.speed, statX + 240, statY)
    
    statY = statY + 22
    
    love.graphics.setColor(0.3, 1.0, 0.3)
    love.graphics.print("HP: +" .. stats.hp, statX, statY)
    
    love.graphics.setColor(1.0, 0.8, 0.2)
    love.graphics.print("CRIT: +" .. stats.crit .. "%", statX + 100, statY)
    
    love.graphics.setColor(0.5, 0.8, 1.0)
    love.graphics.print("EVA: +" .. stats.eva .. "%", statX + 220, statY)
end

function UnifiedMenu.drawItemsTab(state, gameState, contentY, contentHeight)
    local inventorySystem = gameState:getInventorySystem()
    
    love.graphics.setFont(state.fontLarge)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Items", state.x, contentY + 10, state.width, "center")
    
    local inventoryInfo = string.format("Inventory: %d / %d", 
        InventorySystem.getUsedSlots(inventorySystem), 
        InventorySystem.getMaxSlots(inventorySystem))
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
    
    InventoryUI.drawItemDetail(state.inventoryUI, inventorySystem, detailX + 10, gridY + 10, detailWidth - 20, gridHeight - 60)
    
    local selectedItem = InventoryUI.getSelectedSlot(state.inventoryUI) and InventorySystem.getItem(inventorySystem, InventoryUI.getSelectedSlot(state.inventoryUI))
    
    if selectedItem then
        local btnX = detailX + 10
        local btnY = gridY + gridHeight - 45
        local btnWidth = detailWidth - 20
        local btnHeight = 35
        
        if selectedItem.type == ItemDatabase.TYPE.EQUIPMENT then
            UnifiedMenu.drawButton(state, "Equip", btnX, btnY, btnWidth, btnHeight, state.buttonHover_equip)
        elseif selectedItem.type == ItemDatabase.TYPE.CONSUMABLE then
            UnifiedMenu.drawButton(state, "Use", btnX, btnY, btnWidth, btnHeight, state.buttonHover_use)
        end
    end
end

function UnifiedMenu.drawButton(state, text, x, y, width, height, isHovered)
    Components.drawOrnateButton(x, y, width, height, text, isHovered and "hover" or "normal", state.assetManager, state.font)
end

function UnifiedMenu.drawPartyTab(state, gameState, contentY, contentHeight)
    local partySystem = gameState:getPartySystem()
    if not partySystem then
        love.graphics.setColor(state.colors.textDim)
        love.graphics.printf("Party system not available", state.x, contentY + 100, state.width, "center")
        return
    end
    
    love.graphics.setFont(state.fontLarge)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Party Management", state.x, contentY + 10, state.width, "center")
    
    love.graphics.setFont(state.font)
    love.graphics.print("Party Name: " .. partySystem:getPartyName(), state.x + 50, contentY + 60)
    
    local members = partySystem:getMembers()
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

function UnifiedMenu.drawPetTab(state, gameState, contentY, contentHeight)
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
            UnifiedMenu.switchTab(state, i)
            return true
        end
    end
    
    if not gameState then return false end
    
    if state.tabs[state.currentTab].key == "equipment" then
        return UnifiedMenu.handleEquipmentClick(state, gameState, x, y)
    elseif state.tabs[state.currentTab].key == "items" then
        return UnifiedMenu.handleItemsClick(state, gameState, x, y)
    end
    
    return false
end

function UnifiedMenu.handleEquipmentClick(state, gameState, x, y)
    local equipmentSystem = gameState:getEquipmentSystem()
    local inventorySystem = gameState:getInventorySystem()
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
            
            local item = EquipmentSystem.getEquipped(equipmentSystem, slot)
            if item then
                local success = EquipmentSystem.unequipToInventory(equipmentSystem, slot, inventorySystem)
                if success then
                    Player.updateStatsWithEquipment(player)
                    gameState:syncPlayerToCharacter()
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
    
    local clickedSlot = InventoryUI.handleClick(state.inventoryUI, inventorySystem, x, y, gridX, gridY, gridWidth)
    if clickedSlot then
        local item = InventorySystem.getItem(inventorySystem, clickedSlot)
        if item and item.type == ItemDatabase.TYPE.EQUIPMENT then
            local success, msg = EquipmentSystem.equipFromInventory(equipmentSystem, inventorySystem, clickedSlot)
            if success then
                Player.updateStatsWithEquipment(player)
                gameState:syncPlayerToCharacter()
                InventoryUI.clearSelection(state.inventoryUI)
            end
        end
        return true
    end
    
    return false
end

function UnifiedMenu.handleItemsClick(state, gameState, x, y)
    local inventorySystem = gameState:getInventorySystem()
    local player = gameState.player
    
    local contentY = state.y + state.tabHeight + 10
    local gridX = state.x + 20
    local gridY = contentY + 70
    local gridWidth = state.width - 250
    
    local clickedSlot = InventoryUI.handleClick(state.inventoryUI, inventorySystem, x, y, gridX, gridY, gridWidth)
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
        local selectedSlot = InventoryUI.getSelectedSlot(state.inventoryUI)
        if selectedSlot then
            local item = InventorySystem.getItem(inventorySystem, selectedSlot)
            if item then
                if item.type == ItemDatabase.TYPE.EQUIPMENT then
                    local equipmentSystem = gameState:getEquipmentSystem()
                    local success, msg = EquipmentSystem.equipFromInventory(equipmentSystem, inventorySystem, selectedSlot)
                    if success then
                        Player.updateStatsWithEquipment(player)
                        gameState:syncPlayerToCharacter()
                        InventoryUI.clearSelection(state.inventoryUI)
                    end
                elseif item.type == ItemDatabase.TYPE.CONSUMABLE then
                    UnifiedMenu.useConsumable(state, gameState, selectedSlot)
                end
            end
        end
        return true
    end
    
    return false
end

function UnifiedMenu.useConsumable(state, gameState, slotIndex)
    local inventorySystem = gameState:getInventorySystem()
    local player = gameState.player
    
    local item = InventorySystem.getItem(inventorySystem, slotIndex)
    if not item then return end
    
    local itemData = ItemDatabase.getItem(item.id)
    if not itemData then return end
    
    if itemData.effect == "heal" then
        CombatUtils.healMutating(player, itemData.value)
        InventorySystem.removeItem(inventorySystem, slotIndex)
        InventoryUI.clearSelection(state.inventoryUI)
        gameState:syncPlayerToCharacter()
    elseif itemData.effect == "full_heal" then
        player.hp = player.maxHp
        InventorySystem.removeItem(inventorySystem, slotIndex)
        InventoryUI.clearSelection(state.inventoryUI)
        gameState:syncPlayerToCharacter()
    elseif itemData.effect == "cure_poison" then
        InventorySystem.removeItem(inventorySystem, slotIndex)
        InventoryUI.clearSelection(state.inventoryUI)
    elseif itemData.effect == "random" then
        local effects = {"heal_small", "heal_large", "damage", "nothing"}
        local effect = effects[math.random(1, #effects)]
        if effect == "heal_small" then
            CombatUtils.healMutating(player, 30)
        elseif effect == "heal_large" then
            CombatUtils.healMutating(player, 100)
        elseif effect == "damage" then
            CombatUtils.takeDamageMutating(player, 20)
        end
        InventorySystem.removeItem(inventorySystem, slotIndex)
        InventoryUI.clearSelection(state.inventoryUI)
        gameState:syncPlayerToCharacter()
    end
end

function UnifiedMenu.mousemoved(state, x, y, gameState)
    if not state.isOpen then return end
    
    local contentY = state.y + state.tabHeight + 10
    
    if state.tabs[state.currentTab].key == "equipment" then
        local leftPanelWidth = 350
        local rightPanelX = state.x + leftPanelWidth + 40
        local rightPanelWidth = state.width - leftPanelWidth - 60
        local gridX = rightPanelX + 10
        local gridY = contentY + 90 + 110
        local gridWidth = rightPanelWidth - 20
        
        if gameState then
            InventoryUI.updateHover(state.inventoryUI, gameState:getInventorySystem(), x, y, gridX, gridY, gridWidth)
        end
    elseif state.tabs[state.currentTab].key == "items" then
        local gridX = state.x + 20
        local gridY = contentY + 70
        local gridWidth = state.width - 250
        
        if gameState then
            InventoryUI.updateHover(state.inventoryUI, gameState:getInventorySystem(), x, y, gridX, gridY, gridWidth)
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
        
        local selectedSlot = InventoryUI.getSelectedSlot(state.inventoryUI)
        if selectedSlot then
            local item = InventorySystem.getItem(gameState:getInventorySystem(), selectedSlot)
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
