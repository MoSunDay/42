-- unified_menu.lua - Unified menu system
-- 统一菜单系统：装备、道具、组队、宠物管理

local ItemDatabase = require("src.systems.item_database")
local InventoryUI = require("src.ui.inventory_ui")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local UnifiedMenu = {}
UnifiedMenu.__index = UnifiedMenu

function UnifiedMenu.new(assetManager)
    local self = setmetatable({}, UnifiedMenu)
    
    self.assetManager = assetManager
    self.isOpen = false
    
    self.tabs = {
        {name = "Equipment", key = "equipment"},
        {name = "Items", key = "items"},
        {name = "Party", key = "party"},
        {name = "Pet", key = "pet"}
    }
    self.currentTab = 1
    
    local w, h = love.graphics.getDimensions()
    self.width = 800
    self.height = 600
    self.x = (w - self.width) / 2
    self.y = (h - self.height) / 2
    
    self.tabHeight = 40
    self.tabWidth = self.width / #self.tabs
    
    self.colors = {
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
    
    self.font = assetManager:getFont("default")
    self.fontLarge = assetManager:getFont("large")
    
    self.inventoryUI = InventoryUI.new()
    
    self.selectedEquipSlot = nil
    self.showEquipDialog = false
    
    self.buttonHover_equip = false
    self.buttonHover_use = false
    
    return self
end

function UnifiedMenu:toggle()
    self.isOpen = not self.isOpen
end

function UnifiedMenu:open()
    self.isOpen = true
end

function UnifiedMenu:close()
    self.isOpen = false
    self.inventoryUI:clearSelection()
    self.selectedEquipSlot = nil
    self.showEquipDialog = false
end

function UnifiedMenu:isMenuOpen()
    return self.isOpen
end

function UnifiedMenu:switchTab(tabIndex)
    if tabIndex >= 1 and tabIndex <= #self.tabs then
        self.currentTab = tabIndex
        self.inventoryUI:clearSelection()
        self.selectedEquipSlot = nil
        self.showEquipDialog = false
    end
end

function UnifiedMenu:setTab(tabIndex)
    self:switchTab(tabIndex)
end

function UnifiedMenu:draw(gameState)
    if not self.isOpen then
        return
    end
    
    Components.drawOverlay(love.graphics.getWidth(), love.graphics.getHeight(), 0.5)
    
    Components.drawPanelSimple(self.x, self.y, self.width, self.height, 10)
    
    self:drawTabs()
    
    local contentY = self.y + self.tabHeight + 10
    local contentHeight = self.height - self.tabHeight - 20
    
    if self.tabs[self.currentTab].key == "equipment" then
        self:drawEquipmentTab(gameState, contentY, contentHeight)
    elseif self.tabs[self.currentTab].key == "items" then
        self:drawItemsTab(gameState, contentY, contentHeight)
    elseif self.tabs[self.currentTab].key == "party" then
        self:drawPartyTab(gameState, contentY, contentHeight)
    elseif self.tabs[self.currentTab].key == "pet" then
        self:drawPetTab(gameState, contentY, contentHeight)
    end
    
    self:drawCloseButton()
end

function UnifiedMenu:drawTabs()
    for i, tab in ipairs(self.tabs) do
        local tabX = self.x + (i - 1) * self.tabWidth
        local tabY = self.y
        
        Components.drawTab(tabX, tabY, self.tabWidth, self.tabHeight, tab.name, i == self.currentTab, self.assetManager, self.font)
    end
end

function UnifiedMenu:drawCloseButton()
    local btnSize = 30
    local btnX = self.x + self.width - btnSize - 10
    local btnY = self.y + 10
    
    love.graphics.setColor(0.8, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", btnX, btnY, btnSize, btnSize, 5, 5)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(btnX + 8, btnY + 8, btnX + btnSize - 8, btnY + btnSize - 8)
    love.graphics.line(btnX + btnSize - 8, btnY + 8, btnX + 8, btnY + btnSize - 8)
    love.graphics.setLineWidth(1)
end

function UnifiedMenu:drawEquipmentTab(gameState, contentY, contentHeight)
    local equipmentSystem = gameState:getEquipmentSystem()
    local inventorySystem = gameState:getInventorySystem()
    
    if not equipmentSystem then
        love.graphics.setColor(self.colors.textDim)
        love.graphics.printf("Equipment system not available", self.x, contentY + 100, self.width, "center")
        return
    end
    
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Equipment", self.x, contentY + 10, self.width, "center")
    
    local slots = {
        {slot = ItemDatabase.SLOTS.WEAPON, name = "Weapon"},
        {slot = ItemDatabase.SLOTS.HAT, name = "Hat"},
        {slot = ItemDatabase.SLOTS.CLOTHES, name = "Clothes"},
        {slot = ItemDatabase.SLOTS.SHOES, name = "Shoes"},
        {slot = ItemDatabase.SLOTS.NECKLACE, name = "Necklace"}
    }
    
    local leftPanelX = self.x + 20
    local leftPanelWidth = 350
    local slotY = contentY + 50
    local slotHeight = 65
    
    love.graphics.setFont(self.font)
    
    Components.drawPanelSimple(leftPanelX, slotY - 10, leftPanelWidth, #slots * (slotHeight + 5) + 20, 5)
    
    for i, slotInfo in ipairs(slots) do
        local y = slotY + (i - 1) * (slotHeight + 5)
        
        self:drawEquipmentSlot(equipmentSystem, slotInfo.slot, slotInfo.name, leftPanelX + 10, y, leftPanelWidth - 20, slotHeight)
    end
    
    local statsY = slotY + #slots * (slotHeight + 5) + 20
    self:drawTotalStats(equipmentSystem, leftPanelX, statsY, leftPanelWidth)
    
    local rightPanelX = self.x + leftPanelWidth + 40
    local rightPanelWidth = self.width - leftPanelWidth - 60
    
    Components.drawPanelSimple(rightPanelX, contentY + 50, rightPanelWidth, contentHeight - 60, 5)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Inventory", rightPanelX + 10, contentY + 60)
    
    local gridX = rightPanelX + 10
    local gridY = contentY + 90
    local gridWidth = rightPanelWidth - 20
    local gridHeight = contentHeight - 130
    local detailHeight = 100
    
    self.inventoryUI:draw(inventorySystem, gridX, gridY + detailHeight + 10, gridWidth, gridHeight - detailHeight - 10)
    
    self.inventoryUI:drawItemDetail(inventorySystem, gridX, gridY, gridWidth, detailHeight)
end

function UnifiedMenu:drawEquipmentSlot(equipmentSystem, slot, slotName, x, y, width, height)
    local isSelected = self.selectedEquipSlot == slot
    
    if isSelected then
        love.graphics.setColor(self.colors.tabActive)
    else
        love.graphics.setColor(self.colors.background)
    end
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(isSelected and 2 or 1)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print(slotName, x + 10, y + 8)
    
    local item = equipmentSystem:getEquipped(slot)
    if item then
        local slotColor = self:getSlotColor(slot)
        love.graphics.setColor(slotColor)
        love.graphics.print(item.name, x + 10, y + 28, 0, 1.1, 1.1)
        
        love.graphics.setColor(self.colors.textDim)
        local stats = {}
        if item.attack and item.attack > 0 then table.insert(stats, "ATK+" .. item.attack) end
        if item.defense and item.defense > 0 then table.insert(stats, "DEF+" .. item.defense) end
        if item.speed and item.speed ~= 0 then table.insert(stats, "SPD" .. (item.speed > 0 and "+" or "") .. item.speed) end
        if item.hp and item.hp > 0 then table.insert(stats, "HP+" .. item.hp) end
        if item.crit and item.crit > 0 then table.insert(stats, "CRIT+" .. item.crit .. "%") end
        if item.eva and item.eva > 0 then table.insert(stats, "EVA+" .. item.eva .. "%") end
        love.graphics.print(table.concat(stats, "  "), x + 10, y + 46)
    else
        love.graphics.setColor(self.colors.textDim)
        love.graphics.print("(Empty)", x + 10, y + 35)
    end
end

function UnifiedMenu:drawTotalStats(equipmentSystem, x, y, width)
    local stats = equipmentSystem:getTotalStats()
    local defPercent = equipmentSystem:getDefensePercent()
    
    Components.drawPanelSimple(x, y, width, 80, 5)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Equipment Bonus:", x + 10, y + 8)
    
    local statX = x + 10
    local statY = y + 28
    
    love.graphics.setColor(self.colors.weapon)
    love.graphics.print("ATK: +" .. stats.attack, statX, statY)
    
    love.graphics.setColor(self.colors.clothes)
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

function UnifiedMenu:getSlotColor(slot)
    if slot == ItemDatabase.SLOTS.WEAPON then
        return self.colors.weapon
    elseif slot == ItemDatabase.SLOTS.HAT then
        return self.colors.hat
    elseif slot == ItemDatabase.SLOTS.CLOTHES then
        return self.colors.clothes
    elseif slot == ItemDatabase.SLOTS.SHOES then
        return self.colors.shoes
    elseif slot == ItemDatabase.SLOTS.NECKLACE then
        return self.colors.necklace
    end
    return self.colors.text
end

function UnifiedMenu:drawItemsTab(gameState, contentY, contentHeight)
    local inventorySystem = gameState:getInventorySystem()
    
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Items", self.x, contentY + 10, self.width, "center")
    
    local inventoryInfo = string.format("Inventory: %d / %d", 
        inventorySystem:getUsedSlots(), 
        inventorySystem:getMaxSlots())
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.print(inventoryInfo, self.x + 20, contentY + 45)
    
    local gridX = self.x + 20
    local gridY = contentY + 70
    local gridWidth = self.width - 250
    local gridHeight = contentHeight - 100
    
    Components.drawPanelSimple(gridX, gridY, gridWidth, gridHeight, 5)
    
    self.inventoryUI:draw(inventorySystem, gridX, gridY + 10, gridWidth, gridHeight - 20)
    
    local detailX = gridX + gridWidth + 10
    local detailWidth = self.width - gridWidth - 40
    
    Components.drawPanelSimple(detailX, gridY, detailWidth, gridHeight, 5)
    
    self.inventoryUI:drawItemDetail(inventorySystem, detailX + 10, gridY + 10, detailWidth - 20, gridHeight - 60)
    
    local selectedItem = self.inventoryUI:getSelectedSlot() and inventorySystem:getItem(self.inventoryUI:getSelectedSlot())
    
    if selectedItem then
        local btnX = detailX + 10
        local btnY = gridY + gridHeight - 45
        local btnWidth = detailWidth - 20
        local btnHeight = 35
        
        if selectedItem.type == ItemDatabase.TYPE.EQUIPMENT then
            self:drawButton("Equip", btnX, btnY, btnWidth, btnHeight, self.buttonHover_equip)
        elseif selectedItem.type == ItemDatabase.TYPE.CONSUMABLE then
            self:drawButton("Use", btnX, btnY, btnWidth, btnHeight, self.buttonHover_use)
        end
    end
end

function UnifiedMenu:drawButton(text, x, y, width, height, isHovered)
    Components.drawButtonSimple(x, y, width, height, text, isHovered, false, self.font)
end

function UnifiedMenu:drawPartyTab(gameState, contentY, contentHeight)
    local partySystem = gameState:getPartySystem()
    if not partySystem then
        love.graphics.setColor(self.colors.textDim)
        love.graphics.printf("Party system not available", self.x, contentY + 100, self.width, "center")
        return
    end
    
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Party Management", self.x, contentY + 10, self.width, "center")
    
    love.graphics.setFont(self.font)
    love.graphics.print("Party Name: " .. partySystem:getPartyName(), self.x + 50, contentY + 60)
    
    local members = partySystem:getMembers()
    love.graphics.print("Members: " .. #members .. "/5", self.x + 50, contentY + 85)
    
    local memberY = contentY + 120
    for i, member in ipairs(members) do
        local y = memberY + (i - 1) * 70
        
        love.graphics.setColor(self.colors.panel)
        love.graphics.rectangle("fill", self.x + 50, y, self.width - 100, 60, 5, 5)
        
        if i == partySystem.leaderIndex then
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.print("*", self.x + 60, y + 10)
        end
        
        love.graphics.setColor(self.colors.text)
        love.graphics.print(member.name, self.x + 90, y + 10)
        
        local hpBarX = self.x + 90
        local hpBarY = y + 35
        local hpBarW = 200
        local hpBarH = 12
        
        love.graphics.setColor(0.2, 0.2, 0.25)
        love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarW, hpBarH, 3, 3)
        
        local hpPercent = member.hp / member.maxHp
        love.graphics.setColor(0.2, 0.8, 0.3)
        love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarW * hpPercent, hpBarH, 3, 3)
        
        love.graphics.setColor(self.colors.text)
        love.graphics.print(member.hp .. "/" .. member.maxHp, hpBarX + hpBarW + 10, hpBarY)
    end
end

function UnifiedMenu:drawPetTab(gameState, contentY, contentHeight)
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Pet Management", self.x, contentY + 10, self.width, "center")
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.printf("Pet system coming soon...", self.x, contentY + 100, self.width, "center")
    love.graphics.printf("Summon and manage your battle companions", self.x, contentY + 130, self.width, "center")
end

function UnifiedMenu:mousepressed(x, y, button, gameState)
    if not self.isOpen or button ~= 1 then
        return false
    end
    
    local btnSize = 30
    local btnX = self.x + self.width - btnSize - 10
    local btnY = self.y + 10
    
    if x >= btnX and x <= btnX + btnSize and y >= btnY and y <= btnY + btnSize then
        self:close()
        return true
    end
    
    for i, tab in ipairs(self.tabs) do
        local tabX = self.x + (i - 1) * self.tabWidth
        local tabY = self.y
        
        if x >= tabX and x <= tabX + self.tabWidth and y >= tabY and y <= tabY + self.tabHeight then
            self:switchTab(i)
            return true
        end
    end
    
    if not gameState then return false end
    
    if self.tabs[self.currentTab].key == "equipment" then
        return self:handleEquipmentClick(gameState, x, y)
    elseif self.tabs[self.currentTab].key == "items" then
        return self:handleItemsClick(gameState, x, y)
    end
    
    return false
end

function UnifiedMenu:handleEquipmentClick(gameState, x, y)
    local equipmentSystem = gameState:getEquipmentSystem()
    local inventorySystem = gameState:getInventorySystem()
    local player = gameState.player
    
    local contentY = self.y + self.tabHeight + 10
    local leftPanelX = self.x + 20
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
            
            local item = equipmentSystem:getEquipped(slot)
            if item then
                local success = equipmentSystem:unequipToInventory(slot, inventorySystem)
                if success then
                    player:updateStatsWithEquipment()
                    gameState:syncPlayerToCharacter()
                end
            end
            return true
        end
    end
    
    local rightPanelX = self.x + leftPanelWidth + 40
    local rightPanelWidth = self.width - leftPanelWidth - 60
    local gridX = rightPanelX + 10
    local gridY = contentY + 90 + 110
    local gridWidth = rightPanelWidth - 20
    
    local clickedSlot = self.inventoryUI:handleClick(inventorySystem, x, y, gridX, gridY, gridWidth)
    if clickedSlot then
        local item = inventorySystem:getItem(clickedSlot)
        if item and item.type == ItemDatabase.TYPE.EQUIPMENT then
            local success, msg = equipmentSystem:equipFromInventory(inventorySystem, clickedSlot)
            if success then
                player:updateStatsWithEquipment()
                gameState:syncPlayerToCharacter()
                self.inventoryUI:clearSelection()
            end
        end
        return true
    end
    
    return false
end

function UnifiedMenu:handleItemsClick(gameState, x, y)
    local inventorySystem = gameState:getInventorySystem()
    local player = gameState.player
    
    local contentY = self.y + self.tabHeight + 10
    local gridX = self.x + 20
    local gridY = contentY + 70
    local gridWidth = self.width - 250
    
    local clickedSlot = self.inventoryUI:handleClick(inventorySystem, x, y, gridX, gridY, gridWidth)
    if clickedSlot then
        return true
    end
    
    local detailX = gridX + gridWidth + 10
    local detailWidth = self.width - gridWidth - 40
    local gridHeight = self.height - self.tabHeight - 120
    local btnX = detailX + 10
    local btnY = gridY + gridHeight - 45
    local btnWidth = detailWidth - 20
    local btnHeight = 35
    
    if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
        local selectedSlot = self.inventoryUI:getSelectedSlot()
        if selectedSlot then
            local item = inventorySystem:getItem(selectedSlot)
            if item then
                if item.type == ItemDatabase.TYPE.EQUIPMENT then
                    local equipmentSystem = gameState:getEquipmentSystem()
                    local success, msg = equipmentSystem:equipFromInventory(inventorySystem, selectedSlot)
                    if success then
                        player:updateStatsWithEquipment()
                        gameState:syncPlayerToCharacter()
                        self.inventoryUI:clearSelection()
                    end
                elseif item.type == ItemDatabase.TYPE.CONSUMABLE then
                    self:useConsumable(gameState, selectedSlot)
                end
            end
        end
        return true
    end
    
    return false
end

function UnifiedMenu:useConsumable(gameState, slotIndex)
    local inventorySystem = gameState:getInventorySystem()
    local player = gameState.player
    
    local item = inventorySystem:getItem(slotIndex)
    if not item then return end
    
    local itemData = ItemDatabase.getItem(item.id)
    if not itemData then return end
    
    if itemData.effect == "heal" then
        player:heal(itemData.value)
        inventorySystem:removeItem(slotIndex)
        self.inventoryUI:clearSelection()
        gameState:syncPlayerToCharacter()
    elseif itemData.effect == "full_heal" then
        player.hp = player.maxHp
        inventorySystem:removeItem(slotIndex)
        self.inventoryUI:clearSelection()
        gameState:syncPlayerToCharacter()
    elseif itemData.effect == "cure_poison" then
        inventorySystem:removeItem(slotIndex)
        self.inventoryUI:clearSelection()
    elseif itemData.effect == "random" then
        local effects = {"heal_small", "heal_large", "damage", "nothing"}
        local effect = effects[math.random(1, #effects)]
        if effect == "heal_small" then
            player:heal(30)
        elseif effect == "heal_large" then
            player:heal(100)
        elseif effect == "damage" then
            player:takeDamage(20)
        end
        inventorySystem:removeItem(slotIndex)
        self.inventoryUI:clearSelection()
        gameState:syncPlayerToCharacter()
    end
end

function UnifiedMenu:mousemoved(x, y, gameState)
    if not self.isOpen then return end
    
    local contentY = self.y + self.tabHeight + 10
    
    if self.tabs[self.currentTab].key == "equipment" then
        local leftPanelWidth = 350
        local rightPanelX = self.x + leftPanelWidth + 40
        local rightPanelWidth = self.width - leftPanelWidth - 60
        local gridX = rightPanelX + 10
        local gridY = contentY + 90 + 110
        local gridWidth = rightPanelWidth - 20
        
        if gameState then
            self.inventoryUI:updateHover(gameState:getInventorySystem(), x, y, gridX, gridY, gridWidth)
        end
    elseif self.tabs[self.currentTab].key == "items" then
        local gridX = self.x + 20
        local gridY = contentY + 70
        local gridWidth = self.width - 250
        
        if gameState then
            self.inventoryUI:updateHover(gameState:getInventorySystem(), x, y, gridX, gridY, gridWidth)
        end
        
        local detailX = gridX + gridWidth + 10
        local detailWidth = self.width - gridWidth - 40
        local gridHeight = self.height - self.tabHeight - 120
        local btnX = detailX + 10
        local btnY = gridY + gridHeight - 45
        local btnWidth = detailWidth - 20
        local btnHeight = 35
        
        self.buttonHover_use = false
        self.buttonHover_equip = false
        
        local selectedSlot = self.inventoryUI:getSelectedSlot()
        if selectedSlot then
            local item = gameState:getInventorySystem():getItem(selectedSlot)
            if item then
                if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
                    if item.type == ItemDatabase.TYPE.EQUIPMENT then
                        self.buttonHover_equip = true
                    elseif item.type == ItemDatabase.TYPE.CONSUMABLE then
                        self.buttonHover_use = true
                    end
                end
            end
        end
    end
end

function UnifiedMenu:keypressed(key)
    if key == "escape" or key == "m" then
        if self.isOpen then
            self:close()
            return true
        end
    end
    return false
end

return UnifiedMenu
