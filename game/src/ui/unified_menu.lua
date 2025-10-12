-- unified_menu.lua - Unified menu system
-- 统一菜单系统：装备、道具、组队、宠物管理

local UnifiedMenu = {}
UnifiedMenu.__index = UnifiedMenu

function UnifiedMenu.new(assetManager)
    local self = setmetatable({}, UnifiedMenu)
    
    self.assetManager = assetManager
    self.isOpen = false
    
    -- Tabs
    self.tabs = {
        {name = "Equipment", key = "equipment"},
        {name = "Items", key = "items"},
        {name = "Party", key = "party"},
        {name = "Pet", key = "pet"}
    }
    self.currentTab = 1
    
    -- UI dimensions
    local w, h = love.graphics.getDimensions()
    self.width = 800
    self.height = 600
    self.x = (w - self.width) / 2
    self.y = (h - self.height) / 2
    
    -- Tab dimensions
    self.tabHeight = 40
    self.tabWidth = self.width / #self.tabs
    
    -- Colors
    self.colors = {
        background = {0.1, 0.1, 0.15, 0.95},
        panel = {0.15, 0.15, 0.2, 0.9},
        border = {0.4, 0.7, 1.0, 0.9},
        tabActive = {0.3, 0.5, 0.7, 0.9},
        tabInactive = {0.2, 0.2, 0.25, 0.9},
        text = {1, 1, 1},
        textDim = {0.7, 0.7, 0.7}
    }
    
    -- Fonts
    self.font = assetManager:getFont("default")
    self.fontLarge = assetManager:getFont("large")
    
    return self
end

-- Toggle menu open/close
function UnifiedMenu:toggle()
    self.isOpen = not self.isOpen
end

-- Open menu
function UnifiedMenu:open()
    self.isOpen = true
end

-- Close menu
function UnifiedMenu:close()
    self.isOpen = false
end

-- Check if menu is open
function UnifiedMenu:isMenuOpen()
    return self.isOpen
end

-- Switch to tab
function UnifiedMenu:switchTab(tabIndex)
    if tabIndex >= 1 and tabIndex <= #self.tabs then
        self.currentTab = tabIndex
    end
end

-- Draw the menu
function UnifiedMenu:draw(gameState)
    if not self.isOpen then
        return
    end
    
    -- Overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Main panel background
    love.graphics.setColor(self.colors.background)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 10, 10)
    
    -- Border
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 10, 10)
    love.graphics.setLineWidth(1)
    
    -- Draw tabs
    self:drawTabs()
    
    -- Draw content based on current tab
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
    
    -- Close button
    self:drawCloseButton()
end

-- Draw tabs
function UnifiedMenu:drawTabs()
    for i, tab in ipairs(self.tabs) do
        local tabX = self.x + (i - 1) * self.tabWidth
        local tabY = self.y
        
        -- Tab background
        if i == self.currentTab then
            love.graphics.setColor(self.colors.tabActive)
        else
            love.graphics.setColor(self.colors.tabInactive)
        end
        love.graphics.rectangle("fill", tabX, tabY, self.tabWidth, self.tabHeight, 5, 5)
        
        -- Tab border
        love.graphics.setColor(self.colors.border)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", tabX, tabY, self.tabWidth, self.tabHeight, 5, 5)
        love.graphics.setLineWidth(1)
        
        -- Tab text
        love.graphics.setFont(self.font)
        love.graphics.setColor(self.colors.text)
        love.graphics.printf(tab.name, tabX, tabY + 12, self.tabWidth, "center")
    end
end

-- Draw close button
function UnifiedMenu:drawCloseButton()
    local btnSize = 30
    local btnX = self.x + self.width - btnSize - 10
    local btnY = self.y + 10
    
    -- Button background
    love.graphics.setColor(0.8, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", btnX, btnY, btnSize, btnSize, 5, 5)
    
    -- X mark
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(btnX + 8, btnY + 8, btnX + btnSize - 8, btnY + btnSize - 8)
    love.graphics.line(btnX + btnSize - 8, btnY + 8, btnX + 8, btnY + btnSize - 8)
    love.graphics.setLineWidth(1)
end

-- Draw equipment tab
function UnifiedMenu:drawEquipmentTab(gameState, contentY, contentHeight)
    local equipmentSystem = gameState:getEquipmentSystem()
    if not equipmentSystem then
        love.graphics.setColor(self.colors.textDim)
        love.graphics.printf("Equipment system not available", self.x, contentY + 100, self.width, "center")
        return
    end
    
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Equipment", self.x, contentY + 10, self.width, "center")
    
    -- Equipment slots
    local slots = {"weapon", "helmet", "armor"}
    local slotY = contentY + 60
    
    love.graphics.setFont(self.font)
    for i, slot in ipairs(slots) do
        local y = slotY + (i - 1) * 80
        
        -- Slot panel
        love.graphics.setColor(self.colors.panel)
        love.graphics.rectangle("fill", self.x + 50, y, self.width - 100, 70, 5, 5)
        
        -- Slot name
        love.graphics.setColor(self.colors.text)
        love.graphics.print(slot:upper(), self.x + 70, y + 10)
        
        -- Equipped item
        local item = equipmentSystem:getEquipped(slot)
        if item then
            love.graphics.setColor(0.3, 0.8, 0.5)
            love.graphics.print(item.name, self.x + 70, y + 35)
            
            -- Stats
            love.graphics.setColor(self.colors.textDim)
            local stats = ""
            if item.attack > 0 then stats = stats .. "ATK+" .. item.attack .. " " end
            if item.defense > 0 then stats = stats .. "DEF+" .. item.defense .. " " end
            love.graphics.print(stats, self.x + 250, y + 35)
        else
            love.graphics.setColor(self.colors.textDim)
            love.graphics.print("(Empty)", self.x + 70, y + 35)
        end
    end
    
    -- Total stats
    local stats = equipmentSystem:getTotalStats()
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Total Bonus:", self.x + 50, contentY + contentHeight - 60)
    love.graphics.print("ATK: +" .. stats.attack, self.x + 200, contentY + contentHeight - 60)
    love.graphics.print("DEF: +" .. stats.defense, self.x + 350, contentY + contentHeight - 60)
    love.graphics.print("SPD: " .. (stats.speed >= 0 and "+" or "") .. stats.speed, self.x + 500, contentY + contentHeight - 60)
end

-- Draw items tab
function UnifiedMenu:drawItemsTab(gameState, contentY, contentHeight)
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Items", self.x, contentY + 10, self.width, "center")
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.printf("Item system coming soon...", self.x, contentY + 100, self.width, "center")
    love.graphics.printf("Potions, scrolls, and other consumables", self.x, contentY + 130, self.width, "center")
end

-- Draw party tab
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
    
    -- Party info
    love.graphics.setFont(self.font)
    love.graphics.print("Party Name: " .. partySystem:getPartyName(), self.x + 50, contentY + 60)
    
    local members = partySystem:getMembers()
    love.graphics.print("Members: " .. #members .. "/5", self.x + 50, contentY + 85)
    
    -- Member list
    local memberY = contentY + 120
    for i, member in ipairs(members) do
        local y = memberY + (i - 1) * 70
        
        -- Member panel
        love.graphics.setColor(self.colors.panel)
        love.graphics.rectangle("fill", self.x + 50, y, self.width - 100, 60, 5, 5)
        
        -- Leader indicator
        if i == partySystem.leaderIndex then
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.print("★", self.x + 60, y + 10)
        end
        
        -- Member info
        love.graphics.setColor(self.colors.text)
        love.graphics.print(member.name, self.x + 90, y + 10)
        love.graphics.print("Lv." .. member.level, self.x + 250, y + 10)
        
        -- HP bar
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

-- Draw pet tab
function UnifiedMenu:drawPetTab(gameState, contentY, contentHeight)
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Pet Management", self.x, contentY + 10, self.width, "center")
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.printf("Pet system coming soon...", self.x, contentY + 100, self.width, "center")
    love.graphics.printf("Summon and manage your battle companions", self.x, contentY + 130, self.width, "center")
end

-- Handle mouse press
function UnifiedMenu:mousepressed(x, y, button)
    if not self.isOpen or button ~= 1 then
        return false
    end
    
    -- Check close button
    local btnSize = 30
    local btnX = self.x + self.width - btnSize - 10
    local btnY = self.y + 10
    
    if x >= btnX and x <= btnX + btnSize and y >= btnY and y <= btnY + btnSize then
        self:close()
        return true
    end
    
    -- Check tabs
    for i, tab in ipairs(self.tabs) do
        local tabX = self.x + (i - 1) * self.tabWidth
        local tabY = self.y
        
        if x >= tabX and x <= tabX + self.tabWidth and y >= tabY and y <= tabY + self.tabHeight then
            self:switchTab(i)
            return true
        end
    end
    
    return false
end

-- Handle key press
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

