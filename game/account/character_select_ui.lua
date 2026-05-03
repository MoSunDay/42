local AvatarRenderer = require("account.avatar_renderer")
local AppearanceSystem = require("src.systems.appearance_system")
local ClassDatabase = require("src.data.class_database")
local CharacterData = require("account.character_data")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local Particles = require("src.ui.particles")

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

        particleEmitter = nil,
    }
    CharacterSelectUI.update_class_list(state)
    return state
end

CharacterSelectUI.new = CharacterSelectUI.create

function CharacterSelectUI.update_class_list(state)
    local categoryId = state.categories[state.selectedCategoryIndex].id
    state.currentClassList = ClassDatabase.get_classes_by_category(categoryId)
    state.selectedClassIndex = 1
end

function CharacterSelectUI.set_characters(state, characters)
    state.characters = characters or {}
end

function CharacterSelectUI.set_network(state, network)
    state.network = network
end

function CharacterSelectUI.on_character_selected(state, callback)
    state.onCharacterSelectedCallback = callback
end

function CharacterSelectUI.trigger_character_selected(state, character)
    if state.onCharacterSelectedCallback then
        state.onCharacterSelectedCallback(character)
    end
end

function CharacterSelectUI.generate_character_id(state)
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return string.format("char_%d_%d", timestamp, random)
end

function CharacterSelectUI.is_name_taken(state, name)
    for _, char in ipairs(state.characters) do
        if char.characterName == name then
            return true
        end
    end
    return false
end

function CharacterSelectUI.ensure_particles(state)
    if not state.particleEmitter then
        local w, h = love.graphics.getDimensions()
        state.particleEmitter = Particles.continuous(w / 2, h, "goldDust", 2)
    end
end

local function draw_background(w, h)
    love.graphics.setColor(Theme.colors.background)
    love.graphics.rectangle("fill", 0, 0, w, h)
    Theme.draw_shimmer(0, 0, w, h, 0.2)
end

local function draw_step_indicator(currentStep, w, y)
    local font = love.graphics.get_font()
    local diamondSize = 6
    local gap = 50
    local startX = w / 2 - gap

    for i = 1, 3 do
        local cx = startX + (i - 1) * gap
        local is_active = (i == currentStep)

        if is_active then
            love.graphics.setColor(Theme.gold.bright)
        else
            love.graphics.setColor(Theme.colors.textDim)
        end
        love.graphics.polygon("fill",
            cx, y - diamondSize,
            cx + diamondSize, y,
            cx, y + diamondSize,
            cx - diamondSize, y
        )

        if is_active then
            Theme.draw_glow(cx - diamondSize, y - diamondSize, diamondSize * 2, diamondSize * 2, Theme.gold.bright, 0.3)
        end

        if i < 3 then
            local lineX1 = cx + diamondSize + 4
            local lineX2 = cx + gap - diamondSize - 4
            love.graphics.setColor(is_active and Theme.gold.normal or Theme.colors.textDim)
            love.graphics.setLineWidth(1)
            love.graphics.line(lineX1, y, lineX2, y)
        end
    end

    local stepNames = {"Name", "Class", "Appearance"}
    love.graphics.setFont(font)
    for i = 1, 3 do
        local cx = startX + (i - 1) * gap
        love.graphics.setColor(i == currentStep and Theme.gold.bright or Theme.colors.textDim)
        love.graphics.printf(stepNames[i], cx - 30, y + diamondSize + 4, 60, "center")
    end
end

function CharacterSelectUI.draw_select_screen(state)
    local w, h = love.graphics.getDimensions()
    draw_background(w, h)

    love.graphics.setFont(love.graphics.get_font())
    love.graphics.setColor(Theme.gold.bright)
    love.graphics.printf("Select Character", 0, 50, w, "center")
    Theme.draw_diamond_separator(w / 2, 75, 200)

    local characters = state.characters
    local startY = 120
    for i, char in ipairs(characters) do
        local y = startY + (i - 1) * 80
        local isSelected = (i == state.selectedCharIndex)

        if isSelected then
            Components.drawOrnatePanel(w/2 - 250, y, 500, 70, state.assetManager, { corners = true, glow = true, shimmer = true })
            love.graphics.setColor(Theme.colors.accentBlue[1], Theme.colors.accentBlue[2], Theme.colors.accentBlue[3], 0.3)
            love.graphics.rectangle("fill", w/2 - 250, y, 500, 70, 5, 5)
            Theme.draw_gold_border(w/2 - 250, y, 500, 70, 2)
            Theme.draw_corner_ornaments(w/2 - 250, y, 500, 70, 8)
        else
            Components.drawOrnatePanel(w/2 - 250, y, 500, 70, state.assetManager, { corners = true, glow = false })
        end

        AvatarRenderer.draw_avatar(w/2 - 200, y + 35, 25, char)

        love.graphics.setColor(Theme.colors.text)
        love.graphics.print(char.characterName or char.name or "Unknown", w/2 - 150, y + 8)
        love.graphics.setColor(Theme.colors.accentBlue)
        love.graphics.print(CharacterData.get_class_name(char), w/2 - 150, y + 24)

        local hpPercent = char.hp and char.maxHp and char.maxHp > 0 and (char.hp / char.maxHp) or 0
        local mpPercent = char.mp and char.maxMp and char.maxMp > 0 and (char.mp / char.maxMp) or 0
        Components.drawOrnateHPBar(w/2 - 150, y + 42, 120, 10, hpPercent, nil, state.assetManager)
        Components.drawOrnateMPBar(w/2 + 10, y + 42, 80, 10, mpPercent, state.assetManager)
    end

    local buttonY = h - 150

    if #characters > 0 then
        Components.drawOrnateButton(w/2 - 220, buttonY, state.buttonWidth, state.buttonHeight, "Select", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "blue" })
    end

    Components.drawOrnateButton(w/2 + 20, buttonY, state.buttonWidth, state.buttonHeight, "Create New", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "green" })

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Use UP/DOWN to select, ENTER to confirm", 0, h - 50, w, "center")
end

function CharacterSelectUI.draw_create_screen(state)
    local w, h = love.graphics.getDimensions()
    draw_background(w, h)

    love.graphics.setColor(Theme.gold.bright)
    love.graphics.printf("Create New Character", 0, 30, w, "center")
    Theme.draw_diamond_separator(w / 2, 55, 200)

    draw_step_indicator(state.createStep, w, 70)

    if state.createStep == 1 then
        CharacterSelectUI.draw_name_step(state, w, h)
    elseif state.createStep == 2 then
        CharacterSelectUI.draw_class_step(state, w, h)
    elseif state.createStep == 3 then
        CharacterSelectUI.draw_appearance_step(state, w, h)
    end
end

function CharacterSelectUI.draw_name_step(state, w, h)
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Enter Character Name", 0, 100, w, "center")

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print("Character Name:", w/2 - 200, 150)

    Components.drawInput(w/2 - 200, 175, 400, 40, state.nameInputActive, state.assetManager)

    love.graphics.setColor(Theme.colors.text)
    local displayName = state.newCharName
    if state.nameInputActive and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        displayName = displayName .. "|"
    end
    love.graphics.print(displayName, w/2 - 190, 183)

    if state.errorMessage ~= "" then
        love.graphics.setColor(Theme.colors.error)
        love.graphics.printf(state.errorMessage, 0, 230, w, "center")
    end

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Click the input box and type your name (3-20 characters)", 0, 280, w, "center")

    local buttonY = h - 120
    Components.drawOrnateButton(w/2 - 100, buttonY, state.buttonWidth, state.buttonHeight, "Next", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "green" })
    Components.drawOrnateButton(w/2 + 110, buttonY, state.buttonWidth, state.buttonHeight, "Cancel", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "red" })
end

function CharacterSelectUI.draw_class_step(state, w, h)
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Choose Your Class", 0, 100, w, "center")

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print("Select Category:", w/2 - 300, 130)

    local catStartX = w/2 - 300
    for i, cat in ipairs(state.categories) do
        local x = catStartX + (i - 1) * 160
        local isSelected = (i == state.selectedCategoryIndex)

        if isSelected then
            Components.drawOrnatePanel(x, 150, 150, 50, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(Theme.colors.accentBlue[1], Theme.colors.accentBlue[2], Theme.colors.accentBlue[3], 0.4)
            love.graphics.rectangle("fill", x, 150, 150, 50, 5, 5)
            Theme.draw_gold_border(x, 150, 150, 50, 1)
        else
            Components.drawOrnatePanel(x, 150, 150, 50, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(Theme.colors.panel[1], Theme.colors.panel[2], Theme.colors.panel[3], 0.5)
            love.graphics.rectangle("fill", x, 150, 150, 50, 5, 5)
        end

        love.graphics.setColor(Theme.colors.text)
        love.graphics.printf(cat.name, x, 160, 150, "center")
        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.printf(cat.description, x, 178, 150, "center")
    end

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print("Select Class:", w/2 - 300, 220)

    local classStartY = 250
    for i, class in ipairs(state.currentClassList) do
        local y = classStartY + (i - 1) * 100
        local isSelected = (i == state.selectedClassIndex)

        if isSelected then
            Components.drawOrnatePanel(w/2 - 300, y, 600, 90, state.assetManager, { corners = true, glow = true })
            love.graphics.setColor(Theme.colors.accentBlue[1], Theme.colors.accentBlue[2], Theme.colors.accentBlue[3], 0.35)
            love.graphics.rectangle("fill", w/2 - 300, y, 600, 90, 8, 8)
            Theme.draw_gold_border(w/2 - 300, y, 600, 90, 2)
            Theme.draw_corner_ornaments(w/2 - 300, y, 600, 90, 6)
        else
            Components.drawOrnatePanel(w/2 - 300, y, 600, 90, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(Theme.colors.panel[1], Theme.colors.panel[2], Theme.colors.panel[3], 0.4)
            love.graphics.rectangle("fill", w/2 - 300, y, 600, 90, 8, 8)
        end

        love.graphics.setColor(Theme.colors.text)
        love.graphics.print(class.name, w/2 - 280, y + 10)

        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.print(class.description, w/2 - 280, y + 32)

        love.graphics.setColor(Theme.colors.success)
        local bonusText = CharacterSelectUI.format_passive_bonus(state, class.passiveBonus)
        love.graphics.print("被动: " .. bonusText, w/2 - 280, y + 54)

        love.graphics.setColor(Theme.colors.textDim)
        local statsText = string.format("HP:%d MP:%d ATK:%d DEF:%d SPD:%d",
            class.baseStats.hp, class.baseStats.mp, class.baseStats.attack,
            class.baseStats.defense, class.baseStats.speed)
        love.graphics.print(statsText, w/2 - 280, y + 72)
    end

    local buttonY = h - 80
    Components.drawOrnateButton(w/2 - 320, buttonY, state.buttonWidth, state.buttonHeight, "Back", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "red" })
    Components.drawOrnateButton(w/2 - 100, buttonY, state.buttonWidth, state.buttonHeight, "Next", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "green" })
end

function CharacterSelectUI.format_passive_bonus(state, bonus)
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

function CharacterSelectUI.draw_appearance_step(state, w, h)
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Select Appearance", 0, 100, w, "center")

    local selectedClass = state.currentClassList[state.selectedClassIndex]
    love.graphics.setColor(Theme.colors.accentBlue)
    love.graphics.printf(string.format("Creating: %s - %s", state.newCharName, selectedClass.name), 0, 120, w, "center")

    local gridStartX = w/2 - 280
    local gridStartY = 155
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
            love.graphics.setColor(Theme.colors.accentBlue[1], Theme.colors.accentBlue[2], Theme.colors.accentBlue[3], 0.3)
            love.graphics.rectangle("fill", x, y, 130, 100, 5, 5)
            Theme.draw_gold_border(x, y, 130, 100, 1)
            Theme.draw_corner_ornaments(x, y, 130, 100, 5)
        else
            Components.drawOrnatePanel(x, y, 130, 100, state.assetManager, { corners = true, glow = false })
            love.graphics.setColor(Theme.colors.panel[1], Theme.colors.panel[2], Theme.colors.panel[3], 0.3)
            love.graphics.rectangle("fill", x, y, 130, 100, 5, 5)
        end

        local preset = AppearanceSystem.get_preset(appearance.id)
        AppearanceSystem.draw_avatar(x + 65, y + 35, 22, preset)

        love.graphics.setColor(Theme.colors.text)
        love.graphics.printf(appearance.name, x, y + 72, 130, "center")
    end

    local buttonY = h - 80
    Components.drawOrnateButton(w/2 - 320, buttonY, state.buttonWidth, state.buttonHeight, "Back", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "red" })
    Components.drawOrnateButton(w/2 - 100, buttonY, state.buttonWidth, state.buttonHeight, "Create", "normal", state.assetManager, love.graphics.get_font(), { gemColor = "green" })
end

function CharacterSelectUI.draw(state)
    CharacterSelectUI.ensure_particles(state)
    if state.mode == "select" then
        CharacterSelectUI.draw_select_screen(state)
    else
        CharacterSelectUI.draw_create_screen(state)
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
                CharacterSelectUI.update_class_list(state)
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
            CharacterSelectUI.update_class_list(state)
        end
    elseif state.mode == "create" then
        CharacterSelectUI.handle_create_mouse_press(state, x, y, button, w, h)
    end

    return nil
end

function CharacterSelectUI.handle_create_mouse_press(state, x, y, button, w, h)
    if state.createStep == 1 then
        if button == 1 and x >= w/2 - 200 and x <= w/2 + 200 and y >= 175 and y <= 215 then
            state.nameInputActive = true
        else
            state.nameInputActive = false
        end

        local buttonY = h - 120
        if button == 1 and x >= w/2 - 100 and x <= w/2 + 100 and y >= buttonY and y <= buttonY + state.buttonHeight then
            if CharacterSelectUI.validate_name(state) then
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
            if button == 1 and x >= cx and x <= cx + 150 and y >= 150 and y <= 200 then
                state.selectedCategoryIndex = i
                CharacterSelectUI.update_class_list(state)
            end
        end

        local classStartY = 250
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
        local gridStartY = 155
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
            return CharacterSelectUI.create_character(state)
        end
    end
end

function CharacterSelectUI.validate_name(state)
    if state.newCharName == "" then
        state.errorMessage = "Name cannot be empty!"
        return false
    end

    if #state.newCharName < 3 then
        state.errorMessage = "Name must be at least 3 characters!"
        return false
    end

    if CharacterSelectUI.is_name_taken(state, state.newCharName) then
        state.errorMessage = "Name already taken!"
        return false
    end

    state.errorMessage = ""
    return true
end

function CharacterSelectUI.create_character(state)
    if not CharacterSelectUI.validate_name(state) then
        state.createStep = 1
        return nil
    end

    local selectedClass = state.currentClassList[state.selectedClassIndex]
    if not selectedClass then
        state.errorMessage = "Please select a class!"
        state.createStep = 2
        return nil
    end
    local newChar = CharacterData.create_character(state.newCharName, selectedClass.id)

    newChar.id = CharacterSelectUI.generate_character_id(state)

    local selectedAppearance = state.appearances[state.selectedAppearanceIndex]
    AppearanceSystem.set_character_appearance(newChar, selectedAppearance.id)

    table.insert(state.characters, newChar)

    state.mode = "select"
    state.newCharName = ""
    state.errorMessage = ""
    state.selectedCharIndex = #state.characters
    state.createStep = 1

    return newChar
end

return CharacterSelectUI
