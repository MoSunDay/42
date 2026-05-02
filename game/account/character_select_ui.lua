local AvatarRenderer = require("account.avatar_renderer")
local AppearanceSystem = require("src.systems.appearance_system")
local ClassDatabase = require("src.data.class_database")
local CharacterData = require("account.character_data")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local CharacterSelectUI = {}

function CharacterSelectUI.create(assetManager)
    local state = {
        assetManager = assetManager,
        mode = "select",
        selectedCharIndex = 1,
        selectedAppearance = "blue_hero",
        
        newCharName = "",
        nameInputActive = false,
        errorMessage = "",
        
        colors = {
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
        },
        
        categories = {
            { id = "warrior", name = "战士", description = "物理输出，近战专家" },
            { id = "mage", name = "法师", description = "魔法大师，掌控元素与治愈" },
        },
        selectedCategoryIndex = 1,
        
        selectedClassIndex = 1,
        currentClassList = {},
        
        appearances = {
            {id = "blue_hero", name = "Blue Hero"},
            {id = "red_warrior", name = "Red Warrior"},
            {id = "green_ranger", name = "Green Ranger"},
            {id = "yellow_mage", name = "Yellow Mage"},
            {id = "purple_assassin", name = "Purple Assassin"},
            {id = "cyan_priest", name = "Cyan Priest"},
            {id = "orange_knight", name = "Orange Knight"},
            {id = "pink_dancer", name = "Pink Dancer"}
        },
        selectedAppearanceIndex = 1,
        
        createStep = 1,
        
        buttonWidth = 200,
        buttonHeight = 40,
        
        characters = {},
        network = nil,
        onCharacterSelectedCallback = nil,
    }
    CharacterSelectUI.updateClassList(state)
    return state
end

CharacterSelectUI.new = CharacterSelectUI.create

function CharacterSelectUI.updateClassList(state)
    local categoryId = state.categories[state.selectedCategoryIndex].id
    state.currentClassList = ClassDatabase.getClassesByCategory(categoryId)
    state.selectedClassIndex = 1
end

function CharacterSelectUI.setCharacters(state, characters)
    state.characters = characters or {}
end

function CharacterSelectUI.setNetwork(state, network)
    state.network = network
end

function CharacterSelectUI.onCharacterSelected(state, callback)
    state.onCharacterSelectedCallback = callback
end

function CharacterSelectUI.triggerCharacterSelected(state, character)
    if state.onCharacterSelectedCallback then
        state.onCharacterSelectedCallback(character)
    end
end

function CharacterSelectUI.generateCharacterId(state)
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return string.format("char_%d_%d", timestamp, random)
end

function CharacterSelectUI.isNameTaken(state, name)
    for _, char in ipairs(state.characters) do
        if char.characterName == name then
            return true
        end
    end
    return false
end

function CharacterSelectUI.drawSelectScreen(state)
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Select Character", 0, 50, w, "center")

    local characters = state.characters
    
    local startY = 120
    for i, char in ipairs(characters) do
        local y = startY + (i - 1) * 80
        local isSelected = (i == state.selectedCharIndex)
        
        if isSelected then
            Components.drawOrnatePanel(w/2 - 250, y, 500, 70, state.assetManager, { corners = true, glow = true })
            love.graphics.setColor(state.colors.selected[1], state.colors.selected[2], state.colors.selected[3], 0.3)
            love.graphics.rectangle("fill", w/2 - 250, y, 500, 70, 5, 5)
            Theme.drawGoldBorder(w/2 - 250, y, 500, 70, 2)
            Theme.drawCornerOrnaments(w/2 - 250, y, 500, 70, 8)
        else
            Components.drawOrnatePanel(w/2 - 250, y, 500, 70, state.assetManager, { corners = true, glow = false })
        end
        
        AvatarRenderer.drawAvatar(w/2 - 200, y + 35, 25, char)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(char.characterName or char.name or "Unknown", w/2 - 150, y + 10)
        love.graphics.setColor(0.7, 0.9, 1.0)
        love.graphics.print(CharacterData.getClassName(char), w/2 - 150, y + 28)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print(string.format("HP: %d/%d  MP: %d/%d", char.hp, char.maxHp, char.mp, char.maxMp), w/2 - 150, y + 46)
    end
    
    local buttonY = h - 150
    
    if #characters > 0 then
        Components.drawOrnateButton(w/2 - 220, buttonY, state.buttonWidth, state.buttonHeight, "Select", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "blue" })
    end
    
    Components.drawOrnateButton(w/2 + 20, buttonY, state.buttonWidth, state.buttonHeight, "Create New", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "green" })
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Use UP/DOWN to select, ENTER to confirm", 0, h - 50, w, "center")
end

function CharacterSelectUI.drawCreateScreen(state)
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Create New Character", 0, 30, w, "center")
    
    if state.createStep == 1 then
        CharacterSelectUI.drawNameStep(state, w, h)
    elseif state.createStep == 2 then
        CharacterSelectUI.drawClassStep(state, w, h)
    elseif state.createStep == 3 then
        CharacterSelectUI.drawAppearanceStep(state, w, h)
    end
end

function CharacterSelectUI.drawNameStep(state, w, h)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Step 1/3: Enter Character Name", 0, 80, w, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Character Name:", w/2 - 200, 150)
    
    Components.drawInput(w/2 - 200, 175, 400, 40, state.nameInputActive, state.assetManager)
    
    love.graphics.setColor(1, 1, 1)
    local displayName = state.newCharName
    if state.nameInputActive and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        displayName = displayName .. "|"
    end
    love.graphics.print(displayName, w/2 - 190, 183)
    
    if state.errorMessage ~= "" then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf(state.errorMessage, 0, 230, w, "center")
    end
    
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.printf("Click the input box and type your name (3-20 characters)", 0, 280, w, "center")
    
    local buttonY = h - 120
    Components.drawOrnateButton(w/2 - 100, buttonY, state.buttonWidth, state.buttonHeight, "Next", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "green" })
    
    Components.drawOrnateButton(w/2 + 110, buttonY, state.buttonWidth, state.buttonHeight, "Cancel", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "red" })
end

function CharacterSelectUI.drawClassStep(state, w, h)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Step 2/3: Choose Your Class", 0, 70, w, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Select Category:", w/2 - 300, 110)
    
    local catStartX = w/2 - 300
    for i, cat in ipairs(state.categories) do
        local x = catStartX + (i - 1) * 160
        local isSelected = (i == state.selectedCategoryIndex)
        
        if isSelected then
            Components.drawOrnatePanel(x, 130, 150, 50, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(state.colors.selected[1], state.colors.selected[2], state.colors.selected[3], 0.4)
            love.graphics.rectangle("fill", x, 130, 150, 50, 5, 5)
            Theme.drawGoldBorder(x, 130, 150, 50, 1)
        else
            Components.drawOrnatePanel(x, 130, 150, 50, state.assetManager, { corners = true, glow = false })
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
    for i, class in ipairs(state.currentClassList) do
        local y = classStartY + (i - 1) * 100
        local isSelected = (i == state.selectedClassIndex)
        
        if isSelected then
            Components.drawOrnatePanel(w/2 - 300, y, 600, 90, state.assetManager, { corners = true, glow = true })
            love.graphics.setColor(state.colors.selected[1], state.colors.selected[2], state.colors.selected[3], 0.35)
            love.graphics.rectangle("fill", w/2 - 300, y, 600, 90, 8, 8)
            Theme.drawGoldBorder(w/2 - 300, y, 600, 90, 2)
            Theme.drawCornerOrnaments(w/2 - 300, y, 600, 90, 6)
        else
            Components.drawOrnatePanel(w/2 - 300, y, 600, 90, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(0.2, 0.2, 0.2, 0.4)
            love.graphics.rectangle("fill", w/2 - 300, y, 600, 90, 8, 8)
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(class.name, w/2 - 280, y + 10)
        
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print(class.description, w/2 - 280, y + 32)
        
        love.graphics.setColor(0.6, 0.8, 0.6)
        local bonusText = CharacterSelectUI.formatPassiveBonus(state, class.passiveBonus)
        love.graphics.print("被动: " .. bonusText, w/2 - 280, y + 54)
        
        love.graphics.setColor(0.6, 0.6, 0.6)
        local statsText = string.format("HP:%d MP:%d ATK:%d DEF:%d SPD:%d", 
            class.baseStats.hp, class.baseStats.mp, class.baseStats.attack, 
            class.baseStats.defense, class.baseStats.speed)
        love.graphics.print(statsText, w/2 - 280, y + 72)
    end
    
    local buttonY = h - 80
    Components.drawOrnateButton(w/2 - 320, buttonY, state.buttonWidth, state.buttonHeight, "Back", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "red" })
    Components.drawOrnateButton(w/2 - 100, buttonY, state.buttonWidth, state.buttonHeight, "Next", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "green" })
end

function CharacterSelectUI.formatPassiveBonus(state, bonus)
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

function CharacterSelectUI.drawAppearanceStep(state, w, h)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Step 3/3: Select Appearance", 0, 70, w, "center")
    
    local selectedClass = state.currentClassList[state.selectedClassIndex]
    love.graphics.setColor(0.6, 0.8, 1.0)
    love.graphics.printf(string.format("Creating: %s - %s", state.newCharName, selectedClass.name), 0, 100, w, "center")
    
    local gridStartX = w/2 - 280
    local gridStartY = 140
    local cellWidth = 140
    local cellHeight = 110
    
    for i, appearance in ipairs(state.appearances) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local x = gridStartX + col * cellWidth
        local y = gridStartY + row * cellHeight
        
        local isSelected = (i == state.selectedAppearanceIndex)
        
        if isSelected then
            Components.drawOrnatePanel(x, y, 130, 100, state.assetManager, { corners = true, glow = true })
            love.graphics.setColor(state.colors.selected[1], state.colors.selected[2], state.colors.selected[3], 0.3)
            love.graphics.rectangle("fill", x, y, 130, 100, 5, 5)
            Theme.drawGoldBorder(x, y, 130, 100, 1)
            Theme.drawCornerOrnaments(x, y, 130, 100, 5)
        else
            Components.drawOrnatePanel(x, y, 130, 100, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
            love.graphics.rectangle("fill", x, y, 130, 100, 5, 5)
        end
        
        local preset = AppearanceSystem.getPreset(appearance.id)
        AppearanceSystem.drawAvatar(x + 65, y + 35, 22, preset)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(appearance.name, x, y + 72, 130, "center")
    end
    
    local buttonY = h - 80
    Components.drawOrnateButton(w/2 - 320, buttonY, state.buttonWidth, state.buttonHeight, "Back", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "red" })
    Components.drawOrnateButton(w/2 - 100, buttonY, state.buttonWidth, state.buttonHeight, "Create", "normal", state.assetManager, love.graphics.getFont(), { gemColor = "green" })
end

function CharacterSelectUI.draw(state)
    if state.mode == "select" then
        CharacterSelectUI.drawSelectScreen(state)
    else
        CharacterSelectUI.drawCreateScreen(state)
    end
end

function CharacterSelectUI.keypressed(state, key)
    if state.mode == "select" then
        local characters = state.characters
        
        if key == "up" then
            state.selectedCharIndex = math.max(1, state.selectedCharIndex - 1)
        elseif key == "down" then
            state.selectedCharIndex = math.min(#characters, state.selectedCharIndex + 1)
        elseif key == "return" then
            if #characters > 0 and state.selectedCharIndex <= #characters then
                return characters[state.selectedCharIndex]
            end
        end
    elseif state.mode == "create" then
        if state.createStep == 1 then
            if state.nameInputActive then
                if key == "backspace" then
                    state.newCharName = state.newCharName:sub(1, -2)
                    state.errorMessage = ""
                elseif key == "return" then
                    state.nameInputActive = false
                elseif key == "escape" then
                    state.nameInputActive = false
                end
            end
        elseif state.createStep == 2 then
            if key == "left" or key == "right" then
                state.selectedCategoryIndex = key == "left" and 1 or 2
                if state.selectedCategoryIndex > #state.categories then
                    state.selectedCategoryIndex = #state.categories
                end
                CharacterSelectUI.updateClassList(state)
            elseif key == "up" then
                state.selectedClassIndex = math.max(1, state.selectedClassIndex - 1)
            elseif key == "down" then
                state.selectedClassIndex = math.min(#state.currentClassList, state.selectedClassIndex + 1)
            end
        elseif state.createStep == 3 then
            if key == "left" then
                state.selectedAppearanceIndex = math.max(1, state.selectedAppearanceIndex - 1)
            elseif key == "right" then
                state.selectedAppearanceIndex = math.min(#state.appearances, state.selectedAppearanceIndex + 1)
            elseif key == "up" then
                state.selectedAppearanceIndex = math.max(1, state.selectedAppearanceIndex - 4)
            elseif key == "down" then
                state.selectedAppearanceIndex = math.min(#state.appearances, state.selectedAppearanceIndex + 4)
            end
        end
    end
    
    return nil
end

function CharacterSelectUI.textinput(state, text)
    if state.mode == "create" and state.createStep == 1 and state.nameInputActive then
        if #state.newCharName < 20 then
            state.newCharName = state.newCharName .. text
            state.errorMessage = ""
        end
    end
end

function CharacterSelectUI.mousepressed(state, x, y, button)
    local w, h = love.graphics.getDimensions()

    if state.mode == "select" then
        local characters = state.characters

        local startY = 120
        for i, char in ipairs(characters) do
            local charY = startY + (i - 1) * 80
            if button == 1 and x >= w/2 - 250 and x <= w/2 + 250 and y >= charY and y <= charY + 70 then
                state.selectedCharIndex = i
                return characters[i]
            end
        end

        local buttonY = h - 150

        if button == 1 and x >= w/2 - 220 and x <= w/2 - 20 and y >= buttonY and y <= buttonY + state.buttonHeight then
            if #characters > 0 and state.selectedCharIndex <= #characters then
                return characters[state.selectedCharIndex]
            end
        end

        if button == 1 and x >= w/2 + 20 and x <= w/2 + 220 and y >= buttonY and y <= buttonY + state.buttonHeight then
            state.mode = "create"
            state.newCharName = ""
            state.errorMessage = ""
            state.nameInputActive = false
            state.createStep = 1
            state.selectedCategoryIndex = 1
            state.selectedClassIndex = 1
            state.selectedAppearanceIndex = 1
            CharacterSelectUI.updateClassList(state)
        end
    elseif state.mode == "create" then
        CharacterSelectUI.handleCreateMousePress(state, x, y, button, w, h)
    end
    
    return nil
end

function CharacterSelectUI.handleCreateMousePress(state, x, y, button, w, h)
    if state.createStep == 1 then
        if button == 1 and x >= w/2 - 200 and x <= w/2 + 200 and y >= 175 and y <= 215 then
            state.nameInputActive = true
        else
            state.nameInputActive = false
        end
        
        local buttonY = h - 120
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + state.buttonHeight then
            if CharacterSelectUI.validateName(state) then
                state.createStep = 2
            end
        end
        
        if button == 1 and x >= w/2 + 110 and x <= w/2 + 310 and y >= buttonY and y <= buttonY + state.buttonHeight then
            state.mode = "select"
            state.newCharName = ""
            state.errorMessage = ""
        end
        
    elseif state.createStep == 2 then
        local catStartX = w/2 - 300
        for i, cat in ipairs(state.categories) do
            local cx = catStartX + (i - 1) * 160
            if button == 1 and x >= cx and x <= cx + 150 and y >= 130 and y <= 180 then
                state.selectedCategoryIndex = i
                CharacterSelectUI.updateClassList(state)
            end
        end
        
        local classStartY = 230
        for i, class in ipairs(state.currentClassList) do
            local cy = classStartY + (i - 1) * 100
            if button == 1 and x >= w/2 - 300 and x <= w/2 + 300 and y >= cy and y <= cy + 90 then
                state.selectedClassIndex = i
            end
        end
        
        local buttonY = h - 80
        if button == 1 and x >= w/2 - 320 and x <= w/2 - 120 and y >= buttonY and y <= buttonY + state.buttonHeight then
            state.createStep = 1
        end
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + state.buttonHeight then
            state.createStep = 3
        end
        
    elseif state.createStep == 3 then
        local gridStartX = w/2 - 280
        local gridStartY = 140
        local cellWidth = 140
        local cellHeight = 110

        for i, appearance in ipairs(state.appearances) do
            local col = (i - 1) % 4
            local row = math.floor((i - 1) / 4)
            local cellX = gridStartX + col * cellWidth
            local cellY = gridStartY + row * cellHeight

            if button == 1 and x >= cellX and x <= cellX + 130 and y >= cellY and y <= cellY + 100 then
                state.selectedAppearanceIndex = i
            end
        end

        local buttonY = h - 80
        if button == 1 and x >= w/2 - 320 and x <= w/2 - 120 and y >= buttonY and y <= buttonY + state.buttonHeight then
            state.createStep = 2
        end
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + state.buttonHeight then
            return CharacterSelectUI.createCharacter(state)
        end
    end
end

function CharacterSelectUI.validateName(state)
    if state.newCharName == "" then
        state.errorMessage = "Name cannot be empty!"
        return false
    end
    
    if #state.newCharName < 3 then
        state.errorMessage = "Name must be at least 3 characters!"
        return false
    end
    
    if CharacterSelectUI.isNameTaken(state, state.newCharName) then
        state.errorMessage = "Name already taken!"
        return false
    end
    
    state.errorMessage = ""
    return true
end

function CharacterSelectUI.createCharacter(state)
    if not CharacterSelectUI.validateName(state) then
        state.createStep = 1
        return nil
    end
    
    local selectedClass = state.currentClassList[state.selectedClassIndex]
    if not selectedClass then
        state.errorMessage = "Please select a class!"
        state.createStep = 2
        return nil
    end
    local newChar = CharacterData.createCharacter(state.newCharName, selectedClass.id)
    
    newChar.id = CharacterSelectUI.generateCharacterId(state)
    
    local selectedAppearance = state.appearances[state.selectedAppearanceIndex]
    AppearanceSystem.setCharacterAppearance(newChar, selectedAppearance.id)
    
    table.insert(state.characters, newChar)
    
    state.mode = "select"
    state.newCharName = ""
    state.errorMessage = ""
    state.selectedCharIndex = #state.characters
    state.createStep = 1
    
    return newChar
end

return CharacterSelectUI
