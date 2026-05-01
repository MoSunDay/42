local AvatarRenderer = require("account.avatar_renderer")
local AppearanceSystem = require("src.systems.appearance_system")
local ClassDatabase = require("src.data.class_database")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local CharacterSelectUI = {}
CharacterSelectUI.__index = CharacterSelectUI

function CharacterSelectUI.new()
    local self = setmetatable({}, CharacterSelectUI)
    
    self.mode = "select"
    self.selectedCharIndex = 1
    self.selectedAppearance = "blue_hero"
    
    self.newCharName = ""
    self.nameInputActive = false
    self.errorMessage = ""
    
    self.colors = {
        background = Theme.colors.background,
        panel = Theme.colors.panel,
        border = Theme.colors.border,
        text = Theme.colors.text,
        textDim = Theme.colors.textDim,
        selected = Theme.colors.accentBlue,
        error = Theme.colors.error,
        success = Theme.colors.success,
        buttonPrimary = Theme.colors.button,
        buttonDanger = Theme.colors.error,
    }
    
    self.categories = {
        { id = "warrior", name = "战士", description = "物理输出，近战专家" },
        { id = "mage", name = "法师", description = "魔法大师，掌控元素与治愈" },
    }
    self.selectedCategoryIndex = 1
    
    self.selectedClassIndex = 1
    self.currentClassList = {}
    self:updateClassList()
    
    self.appearances = {
        {id = "blue_hero", name = "Blue Hero"},
        {id = "red_warrior", name = "Red Warrior"},
        {id = "green_ranger", name = "Green Ranger"},
        {id = "yellow_mage", name = "Yellow Mage"},
        {id = "purple_assassin", name = "Purple Assassin"},
        {id = "cyan_priest", name = "Cyan Priest"},
        {id = "orange_knight", name = "Orange Knight"},
        {id = "pink_dancer", name = "Pink Dancer"}
    }
    self.selectedAppearanceIndex = 1
    
    self.createStep = 1
    
    self.buttonWidth = 200
    self.buttonHeight = 40
    
    self.characters = {}
    self.network = nil
    self.onCharacterSelectedCallback = nil
    
    return self
end

function CharacterSelectUI:updateClassList()
    local categoryId = self.categories[self.selectedCategoryIndex].id
    self.currentClassList = ClassDatabase.getClassesByCategory(categoryId)
    self.selectedClassIndex = 1
end

function CharacterSelectUI:setCharacters(characters)
    self.characters = characters or {}
end

function CharacterSelectUI:setNetwork(network)
    self.network = network
end

function CharacterSelectUI:onCharacterSelected(callback)
    self.onCharacterSelectedCallback = callback
end

function CharacterSelectUI:triggerCharacterSelected(character)
    if self.onCharacterSelectedCallback then
        self.onCharacterSelectedCallback(character)
    end
end

function CharacterSelectUI:generateCharacterId()
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return string.format("char_%d_%d", timestamp, random)
end

function CharacterSelectUI:isNameTaken(name)
    for _, char in ipairs(self.characters) do
        if char.characterName == name then
            return true
        end
    end
    return false
end

function CharacterSelectUI:drawSelectScreen()
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Select Character", 0, 50, w, "center")

    local characters = self.characters
    
    local startY = 120
    for i, char in ipairs(characters) do
        local y = startY + (i - 1) * 80
        local isSelected = (i == self.selectedCharIndex)
        
        if isSelected then
            Components.drawPanelSimple(w/2 - 250, y, 500, 70, 5)
            love.graphics.setColor(self.colors.selected[1], self.colors.selected[2], self.colors.selected[3], 0.3)
            love.graphics.rectangle("fill", w/2 - 250, y, 500, 70, 5, 5)
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
            love.graphics.rectangle("fill", w/2 - 250, y, 500, 70, 5, 5)
        end
        
        AvatarRenderer.drawAvatar(w/2 - 200, y + 35, 25, char)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(char.characterName or char.name or "Unknown", w/2 - 150, y + 10)
        love.graphics.setColor(0.7, 0.9, 1.0)
        love.graphics.print(char:getClassName(), w/2 - 150, y + 28)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print(string.format("HP: %d/%d  MP: %d/%d", char.hp, char.maxHp, char.mp, char.maxMp), w/2 - 150, y + 46)
    end
    
    local buttonY = h - 150
    
    if #characters > 0 then
        Components.drawButtonSimple(w/2 - 220, buttonY, self.buttonWidth, self.buttonHeight, "Select", false, false, love.graphics.getFont())
    end
    
    Components.drawButtonSimple(w/2 + 20, buttonY, self.buttonWidth, self.buttonHeight, "Create New", false, false, love.graphics.getFont())
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Use UP/DOWN to select, ENTER to confirm", 0, h - 50, w, "center")
end

function CharacterSelectUI:drawCreateScreen()
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Create New Character", 0, 30, w, "center")
    
    if self.createStep == 1 then
        self:drawNameStep(w, h)
    elseif self.createStep == 2 then
        self:drawClassStep(w, h)
    elseif self.createStep == 3 then
        self:drawAppearanceStep(w, h)
    end
end

function CharacterSelectUI:drawNameStep(w, h)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Step 1/3: Enter Character Name", 0, 80, w, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Character Name:", w/2 - 200, 150)
    
    Components.drawInput(w/2 - 200, 175, 400, 40, self.nameInputActive, nil)
    
    love.graphics.setColor(1, 1, 1)
    local displayName = self.newCharName
    if self.nameInputActive and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        displayName = displayName .. "|"
    end
    love.graphics.print(displayName, w/2 - 190, 183)
    
    if self.errorMessage ~= "" then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf(self.errorMessage, 0, 230, w, "center")
    end
    
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.printf("Click the input box and type your name (3-20 characters)", 0, 280, w, "center")
    
    local buttonY = h - 120
    Components.drawButtonSimple(w/2 - 100, buttonY, self.buttonWidth, self.buttonHeight, "Next", false, false, love.graphics.getFont())
    
    love.graphics.setColor(0.6, 0.3, 0.3)
    love.graphics.rectangle("fill", w/2 + 110, buttonY, self.buttonWidth, self.buttonHeight, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Cancel", w/2 + 110, buttonY + 12, self.buttonWidth, "center")
end

function CharacterSelectUI:drawClassStep(w, h)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Step 2/3: Choose Your Class", 0, 70, w, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Select Category:", w/2 - 300, 110)
    
    local catStartX = w/2 - 300
    for i, cat in ipairs(self.categories) do
        local x = catStartX + (i - 1) * 160
        local isSelected = (i == self.selectedCategoryIndex)
        
        if isSelected then
            love.graphics.setColor(self.colors.selected[1], self.colors.selected[2], self.colors.selected[3], 0.4)
            love.graphics.rectangle("fill", x, 130, 150, 50, 5, 5)
        else
            love.graphics.setColor(0.25, 0.25, 0.25, 0.5)
            love.graphics.rectangle("fill", x, 130, 150, 50, 5, 5)
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(cat.name, x, 140, 150, "center")
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf(cat.description, x, 158, 150, "center")
    end
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Select Class:", w/2 - 300, 200)
    
    local classStartY = 230
    for i, class in ipairs(self.currentClassList) do
        local y = classStartY + (i - 1) * 100
        local isSelected = (i == self.selectedClassIndex)
        
        if isSelected then
            love.graphics.setColor(self.colors.selected[1], self.colors.selected[2], self.colors.selected[3], 0.35)
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 0.4)
        end
        love.graphics.rectangle("fill", w/2 - 300, y, 600, 90, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(class.name, w/2 - 280, y + 10)
        
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print(class.description, w/2 - 280, y + 32)
        
        love.graphics.setColor(0.6, 0.8, 0.6)
        local bonusText = self:formatPassiveBonus(class.passiveBonus)
        love.graphics.print("被动: " .. bonusText, w/2 - 280, y + 54)
        
        love.graphics.setColor(0.6, 0.6, 0.6)
        local statsText = string.format("HP:%d MP:%d ATK:%d DEF:%d SPD:%d", 
            class.baseStats.hp, class.baseStats.mp, class.baseStats.attack, 
            class.baseStats.defense, class.baseStats.speed)
        love.graphics.print(statsText, w/2 - 280, y + 72)
    end
    
    local buttonY = h - 80
    Components.drawButtonSimple(w/2 - 320, buttonY, self.buttonWidth, self.buttonHeight, "Back", false, false, love.graphics.getFont())
    Components.drawButtonSimple(w/2 - 100, buttonY, self.buttonWidth, self.buttonHeight, "Next", false, false, love.graphics.getFont())
end

function CharacterSelectUI:formatPassiveBonus(bonus)
    local parts = {}
    if bonus.maxHpPercent then table.insert(parts, string.format("HP+%d%%", bonus.maxHpPercent * 100)) end
    if bonus.attackPercent then table.insert(parts, string.format("ATK+%d%%", bonus.attackPercent * 100)) end
    if bonus.defensePercent then table.insert(parts, string.format("DEF+%d%%", bonus.defensePercent * 100)) end
    if bonus.speedPercent then
        local val = bonus.speedPercent * 100
        if val > 0 then
            table.insert(parts, string.format("SPD+%d%%", val))
        else
            table.insert(parts, string.format("SPD%d%%", val))
        end
    end
    if bonus.magicAttackPercent then table.insert(parts, string.format("MATK+%d%%", bonus.magicAttackPercent * 100)) end
    if bonus.critPercent then table.insert(parts, string.format("CRIT+%d%%", bonus.critPercent * 100)) end
    return table.concat(parts, ", ")
end

function CharacterSelectUI:drawAppearanceStep(w, h)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Step 3/3: Select Appearance", 0, 70, w, "center")
    
    local selectedClass = self.currentClassList[self.selectedClassIndex]
    love.graphics.setColor(0.6, 0.8, 1.0)
    love.graphics.printf(string.format("Creating: %s - %s", self.newCharName, selectedClass.name), 0, 100, w, "center")
    
    local gridStartX = w/2 - 280
    local gridStartY = 140
    local cellWidth = 140
    local cellHeight = 110
    
    for i, appearance in ipairs(self.appearances) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local x = gridStartX + col * cellWidth
        local y = gridStartY + row * cellHeight
        
        local isSelected = (i == self.selectedAppearanceIndex)
        
        if isSelected then
            Components.drawPanelSimple(x, y, 130, 100, 5)
            love.graphics.setColor(self.colors.selected[1], self.colors.selected[2], self.colors.selected[3], 0.3)
            love.graphics.rectangle("fill", x, y, 130, 100, 5, 5)
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
            love.graphics.rectangle("fill", x, y, 130, 100, 5, 5)
        end
        
        local preset = AppearanceSystem.getPreset(appearance.id)
        AppearanceSystem.drawAvatar(x + 65, y + 35, 22, preset)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(appearance.name, x, y + 72, 130, "center")
    end
    
    local buttonY = h - 80
    Components.drawButtonSimple(w/2 - 320, buttonY, self.buttonWidth, self.buttonHeight, "Back", false, false, love.graphics.getFont())
    Components.drawButtonSimple(w/2 - 100, buttonY, self.buttonWidth, self.buttonHeight, "Create", false, false, love.graphics.getFont())
end

function CharacterSelectUI:draw()
    if self.mode == "select" then
        self:drawSelectScreen()
    else
        self:drawCreateScreen()
    end
end

function CharacterSelectUI:keypressed(key)
    if self.mode == "select" then
        local characters = self.characters
        
        if key == "up" then
            self.selectedCharIndex = math.max(1, self.selectedCharIndex - 1)
        elseif key == "down" then
            self.selectedCharIndex = math.min(#characters, self.selectedCharIndex + 1)
        elseif key == "return" then
            if #characters > 0 and self.selectedCharIndex <= #characters then
                return characters[self.selectedCharIndex]
            end
        end
    elseif self.mode == "create" then
        if self.createStep == 1 then
            if self.nameInputActive then
                if key == "backspace" then
                    self.newCharName = self.newCharName:sub(1, -2)
                    self.errorMessage = ""
                elseif key == "return" then
                    self.nameInputActive = false
                elseif key == "escape" then
                    self.nameInputActive = false
                end
            end
        elseif self.createStep == 2 then
            if key == "left" or key == "right" then
                self.selectedCategoryIndex = key == "left" and 1 or 2
                if self.selectedCategoryIndex > #self.categories then
                    self.selectedCategoryIndex = #self.categories
                end
                self:updateClassList()
            elseif key == "up" then
                self.selectedClassIndex = math.max(1, self.selectedClassIndex - 1)
            elseif key == "down" then
                self.selectedClassIndex = math.min(#self.currentClassList, self.selectedClassIndex + 1)
            end
        elseif self.createStep == 3 then
            if key == "left" then
                self.selectedAppearanceIndex = math.max(1, self.selectedAppearanceIndex - 1)
            elseif key == "right" then
                self.selectedAppearanceIndex = math.min(#self.appearances, self.selectedAppearanceIndex + 1)
            elseif key == "up" then
                self.selectedAppearanceIndex = math.max(1, self.selectedAppearanceIndex - 4)
            elseif key == "down" then
                self.selectedAppearanceIndex = math.min(#self.appearances, self.selectedAppearanceIndex + 4)
            end
        end
    end
    
    return nil
end

function CharacterSelectUI:textinput(text)
    if self.mode == "create" and self.createStep == 1 and self.nameInputActive then
        if #self.newCharName < 20 then
            self.newCharName = self.newCharName .. text
            self.errorMessage = ""
        end
    end
end

function CharacterSelectUI:mousepressed(x, y, button)
    local w, h = love.graphics.getDimensions()

    if self.mode == "select" then
        local characters = self.characters

        local startY = 120
        for i, char in ipairs(characters) do
            local charY = startY + (i - 1) * 80
            if button == 1 and x >= w/2 - 250 and x <= w/2 + 250 and y >= charY and y <= charY + 70 then
                self.selectedCharIndex = i
                return characters[i]
            end
        end

        local buttonY = h - 150

        if button == 1 and x >= w/2 - 220 and x <= w/2 - 20 and y >= buttonY and y <= buttonY + self.buttonHeight then
            if #characters > 0 and self.selectedCharIndex <= #characters then
                return characters[self.selectedCharIndex]
            end
        end

        if button == 1 and x >= w/2 + 20 and x <= w/2 + 220 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.mode = "create"
            self.newCharName = ""
            self.errorMessage = ""
            self.nameInputActive = false
            self.createStep = 1
            self.selectedCategoryIndex = 1
            self.selectedClassIndex = 1
            self.selectedAppearanceIndex = 1
            self:updateClassList()
        end
    elseif self.mode == "create" then
        self:handleCreateMousePress(x, y, button, w, h)
    end
    
    return nil
end

function CharacterSelectUI:handleCreateMousePress(x, y, button, w, h)
    if self.createStep == 1 then
        if button == 1 and x >= w/2 - 200 and x <= w/2 + 200 and y >= 175 and y <= 215 then
            self.nameInputActive = true
        else
            self.nameInputActive = false
        end
        
        local buttonY = h - 120
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + self.buttonHeight then
            if self:validateName() then
                self.createStep = 2
            end
        end
        
        if button == 1 and x >= w/2 + 110 and x <= w/2 + 310 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.mode = "select"
            self.newCharName = ""
            self.errorMessage = ""
        end
        
    elseif self.createStep == 2 then
        local catStartX = w/2 - 300
        for i, cat in ipairs(self.categories) do
            local cx = catStartX + (i - 1) * 160
            if button == 1 and x >= cx and x <= cx + 150 and y >= 130 and y <= 180 then
                self.selectedCategoryIndex = i
                self:updateClassList()
            end
        end
        
        local classStartY = 230
        for i, class in ipairs(self.currentClassList) do
            local cy = classStartY + (i - 1) * 100
            if button == 1 and x >= w/2 - 300 and x <= w/2 + 300 and y >= cy and y <= cy + 90 then
                self.selectedClassIndex = i
            end
        end
        
        local buttonY = h - 80
        if button == 1 and x >= w/2 - 320 and x <= w/2 - 120 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.createStep = 1
        end
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.createStep = 3
        end
        
    elseif self.createStep == 3 then
        local gridStartX = w/2 - 280
        local gridStartY = 140
        local cellWidth = 140
        local cellHeight = 110

        for i, appearance in ipairs(self.appearances) do
            local col = (i - 1) % 4
            local row = math.floor((i - 1) / 4)
            local cellX = gridStartX + col * cellWidth
            local cellY = gridStartY + row * cellHeight

            if button == 1 and x >= cellX and x <= cellX + 130 and y >= cellY and y <= cellY + 100 then
                self.selectedAppearanceIndex = i
            end
        end

        local buttonY = h - 80
        if button == 1 and x >= w/2 - 320 and x <= w/2 - 120 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.createStep = 2
        end
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + self.buttonHeight then
            return self:createCharacter()
        end
    end
end

function CharacterSelectUI:validateName()
    if self.newCharName == "" then
        self.errorMessage = "Name cannot be empty!"
        return false
    end
    
    if #self.newCharName < 3 then
        self.errorMessage = "Name must be at least 3 characters!"
        return false
    end
    
    if self:isNameTaken(self.newCharName) then
        self.errorMessage = "Name already taken!"
        return false
    end
    
    self.errorMessage = ""
    return true
end

function CharacterSelectUI:createCharacter()
    if not self:validateName() then
        self.createStep = 1
        return nil
    end
    
    local CharacterData = require("account.character_data")
    local selectedClass = self.currentClassList[self.selectedClassIndex]
    if not selectedClass then
        self.errorMessage = "Please select a class!"
        self.createStep = 2
        return nil
    end
    local newChar = CharacterData.createCharacter(self.newCharName, selectedClass.id)
    
    newChar.id = self:generateCharacterId()
    
    local selectedAppearance = self.appearances[self.selectedAppearanceIndex]
    AppearanceSystem.setCharacterAppearance(newChar, selectedAppearance.id)
    
    table.insert(self.characters, newChar)
    
    self.mode = "select"
    self.newCharName = ""
    self.errorMessage = ""
    self.selectedCharIndex = #self.characters
    self.createStep = 1
    
    return newChar
end

return CharacterSelectUI
