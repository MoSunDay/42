-- character_select_ui.lua - Character selection and creation UI
-- 角色选择和创建界面

local AvatarRenderer = require("account.avatar_renderer")
local AppearanceSystem = require("src.systems.appearance_system")
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
    
    self.buttonWidth = 200
    self.buttonHeight = 40
    
    self.characters = {}
    self.network = nil
    self.onCharacterSelectedCallback = nil
    
    return self
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

-- Generate unique character ID
function CharacterSelectUI:generateCharacterId()
    -- Use timestamp + random number for uniqueness
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return string.format("char_%d_%d", timestamp, random)
end

-- Check if character name already exists
function CharacterSelectUI:isNameTaken(name, accountManager, username)
    local account = accountManager.getAccount(username)
    if not account or not account.characters then
        return false
    end

    for _, char in ipairs(account.characters) do
        if char.characterName == name then
            return true
        end
    end

    return false
end

function CharacterSelectUI:drawSelectScreen(accountManager, username)
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Select Character", 0, 50, w, "center")

    local account = accountManager.getAccount(username)
    local characters = (account and account.characters) or {}
    
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
        love.graphics.print(char.characterName or char.name or "Unknown", w/2 - 150, y + 15)
        love.graphics.print(string.format("HP: %d/%d", char.hp, char.maxHp), w/2 - 150, y + 35)
        love.graphics.print(string.format("Gold: %d", char.gold), w/2 - 150, y + 50)
        
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print("ID: " .. (char.id or "N/A"), w/2 + 50, y + 50)
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
    love.graphics.printf("Create New Character", 0, 50, w, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Character Name:", w/2 - 200, 120)
    
    Components.drawInput(w/2 - 200, 145, 400, 35, self.nameInputActive, nil)
    
    love.graphics.setColor(1, 1, 1)
    local displayName = self.newCharName
    if self.nameInputActive and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        displayName = displayName .. "|"
    end
    love.graphics.print(displayName, w/2 - 190, 152)
    
    if self.errorMessage ~= "" then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf(self.errorMessage, 0, 190, w, "center")
    end
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Select Appearance:", w/2 - 200, 230)
    
    local gridStartX = w/2 - 250
    local gridStartY = 260
    local cellWidth = 125
    local cellHeight = 100
    
    for i, appearance in ipairs(self.appearances) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local x = gridStartX + col * cellWidth
        local y = gridStartY + row * cellHeight
        
        local isSelected = (i == self.selectedAppearanceIndex)
        
        if isSelected then
            Components.drawPanelSimple(x, y, 115, 90, 5)
            love.graphics.setColor(self.colors.selected[1], self.colors.selected[2], self.colors.selected[3], 0.3)
            love.graphics.rectangle("fill", x, y, 115, 90, 5, 5)
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
            love.graphics.rectangle("fill", x, y, 115, 90, 5, 5)
        end
        
        local preset = AppearanceSystem.getPreset(appearance.id)
        AppearanceSystem.drawAvatar(x + 57, y + 35, 20, preset)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(appearance.name, x, y + 65, 115, "center")
    end
    
    local buttonY = h - 150
    
    Components.drawButtonSimple(w/2 - 220, buttonY, self.buttonWidth, self.buttonHeight, "Create", false, false, love.graphics.getFont())
    
    local font = love.graphics.getFont()
    love.graphics.setColor(0.6, 0.3, 0.3)
    love.graphics.rectangle("fill", w/2 + 20, buttonY, self.buttonWidth, self.buttonHeight, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Cancel", w/2 + 20, buttonY + 12, self.buttonWidth, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Click name field to type, use arrow keys to select appearance", 0, h - 50, w, "center")
end

-- Draw the UI
function CharacterSelectUI:draw(accountManager, username)
    if self.mode == "select" then
        self:drawSelectScreen(accountManager, username)
    else
        self:drawCreateScreen()
    end
end

-- Handle keyboard input
function CharacterSelectUI:keypressed(key, accountManager, username)
    if self.mode == "select" then
        local account = accountManager.getAccount(username)
        local characters = (account and account.characters) or {}
        
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
        if self.nameInputActive then
            if key == "backspace" then
                self.newCharName = self.newCharName:sub(1, -2)
                self.errorMessage = ""
            elseif key == "return" then
                self.nameInputActive = false
            elseif key == "escape" then
                self.nameInputActive = false
            end
        else
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

-- Handle text input
function CharacterSelectUI:textinput(text)
    if self.mode == "create" and self.nameInputActive then
        if #self.newCharName < 20 then
            self.newCharName = self.newCharName .. text
            self.errorMessage = ""
        end
    end
end

-- Handle mouse clicks
function CharacterSelectUI:mousepressed(x, y, button, accountManager, username)
    local w, h = love.graphics.getDimensions()

    if self.mode == "select" then
        local account = accountManager.getAccount(username)
        local characters = (account and account.characters) or {}

        -- Check if clicked on a character
        local startY = 120
        for i, char in ipairs(characters) do
            local charY = startY + (i - 1) * 80
            if button == 1 and x >= w/2 - 250 and x <= w/2 + 250 and y >= charY and y <= charY + 70 then
                self.selectedCharIndex = i
                -- Double click to select
                return characters[i]
            end
        end

        local buttonY = h - 150

        -- Select button
        if button == 1 and x >= w/2 - 220 and x <= w/2 - 20 and y >= buttonY and y <= buttonY + self.buttonHeight then
            if #characters > 0 and self.selectedCharIndex <= #characters then
                return characters[self.selectedCharIndex]
            end
        end

        -- Create new button
        if button == 1 and x >= w/2 + 20 and x <= w/2 + 220 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.mode = "create"
            self.newCharName = ""
            self.errorMessage = ""
            self.nameInputActive = false
            self.selectedAppearanceIndex = 1
        end
    elseif self.mode == "create" then
        -- Name input box
        if button == 1 and x >= w/2 - 200 and x <= w/2 + 200 and y >= 145 and y <= 180 then
            self.nameInputActive = true
        else
            self.nameInputActive = false
        end

        -- Appearance selection
        local gridStartX = w/2 - 250
        local gridStartY = 260
        local cellWidth = 125
        local cellHeight = 100

        for i, appearance in ipairs(self.appearances) do
            local col = (i - 1) % 4
            local row = math.floor((i - 1) / 4)
            local cellX = gridStartX + col * cellWidth
            local cellY = gridStartY + row * cellHeight

            if button == 1 and x >= cellX and x <= cellX + 115 and y >= cellY and y <= cellY + 90 then
                self.selectedAppearanceIndex = i
            end
        end

        local buttonY = h - 150

        -- Create button
        if button == 1 and x >= w/2 - 220 and x <= w/2 - 20 and y >= buttonY and y <= buttonY + self.buttonHeight then
            return self:createCharacter(accountManager, username)
        end

        -- Cancel button
        if button == 1 and x >= w/2 + 20 and x <= w/2 + 220 and y >= buttonY and y <= buttonY + self.buttonHeight then
            self.mode = "select"
            self.newCharName = ""
            self.errorMessage = ""
        end
    end
    
    return nil
end

-- Create a new character
function CharacterSelectUI:createCharacter(accountManager, username)
    -- Validate name
    if self.newCharName == "" then
        self.errorMessage = "Name cannot be empty!"
        return nil
    end
    
    if #self.newCharName < 3 then
        self.errorMessage = "Name must be at least 3 characters!"
        return nil
    end
    
    if self:isNameTaken(self.newCharName, accountManager, username) then
        self.errorMessage = "Name already taken!"
        return nil
    end
    
    -- Create character
    local CharacterData = require("account.character_data")
    local newChar = CharacterData.createCharacter(self.newCharName)
    
    -- Set unique ID
    newChar.id = self:generateCharacterId()
    
    -- Set appearance
    local selectedAppearance = self.appearances[self.selectedAppearanceIndex]
    AppearanceSystem.setCharacterAppearance(newChar, selectedAppearance.id)
    
    -- Add to account
    local account = accountManager.getAccount(username)
    if not account then
        self.errorMessage = "Account not found!"
        return nil
    end
    if not account.characters then
        account.characters = {}
    end
    table.insert(account.characters, newChar)
    
    -- Reset UI
    self.mode = "select"
    self.newCharName = ""
    self.errorMessage = ""
    self.selectedCharIndex = #account.characters
    
    return newChar
end

return CharacterSelectUI

