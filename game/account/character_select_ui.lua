local AvatarRenderer = require("account.avatar_renderer")
local AppearanceSystem = require("src.systems.appearance_system")
local ClassDatabase = require("src.data.class_database")
local CharacterData = require("account.character_data")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local Particles = require("src.ui.particles")

local CharacterSelectUI = {}
local PL = Theme.pixelLab
local C = PL.colors

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
            {id = "blue_hero", name = "Blue Hero", classId = nil},
            {id = "red_warrior", name = "Red Warrior", classId = nil},
            {id = "green_ranger", name = "Green Ranger", classId = nil},
            {id = "yellow_mage", name = "Yellow Mage", classId = nil},
            {id = "purple_assassin", name = "Purple Assassin", classId = nil},
            {id = "cyan_priest", name = "Cyan Priest", classId = nil},
            {id = "orange_knight", name = "Orange Knight", classId = nil},
            {id = "pink_dancer", name = "Pink Dancer", classId = nil},
            {id = "dual_blade", name = "Dual Blade", classId = "dual_blade"},
            {id = "great_sword", name = "Great Sword", classId = "great_sword"},
            {id = "blade_master", name = "Blade Master", classId = "blade_master"},
            {id = "sealer", name = "Sealer", classId = "sealer"},
            {id = "healer", name = "Healer", classId = "healer"},
            {id = "elementalist", name = "Elementalist", classId = "elementalist"}
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
    Theme.draw_gradient(0, 0, w, h, C.bg, C.bgPanel, 12)
end

local function draw_pixel_bar(x, y, w, h, percent, fillColor, bgColor)
    love.graphics.setColor(bgColor or C.textMuted)
    love.graphics.rectangle("fill", x, y, w, h)
    percent = math.max(0, math.min(1, percent))
    if percent > 0 then
        love.graphics.setColor(fillColor or C.neonGreen)
        love.graphics.rectangle("fill", x, y, w * percent, h)
        love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3], 0.3)
        love.graphics.rectangle("fill", x, y, w * percent, h / 2)
    end
    love.graphics.setColor(C.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h)
end

local function draw_step_indicator(state, currentStep, w, y)
    local am = state and state.assetManager
    local font = love.graphics.getFont()
    local dotSize = 7
    local gap = 60
    local startX = w / 2 - gap

    local dotActive = am and am:get_ui_asset("charSelect", "pixellab_dot_active")
    local dotInactive = am and am:get_ui_asset("charSelect", "pixellab_dot_inactive")

    for i = 1, 3 do
        local cx = startX + (i - 1) * gap
        local is_active = (i == currentStep)
        local dotAsset = is_active and dotActive or dotInactive

        if dotAsset then
            love.graphics.setColor(1, 1, 1)
            local s = dotSize / dotAsset:getWidth()
            love.graphics.draw(dotAsset, cx - dotSize, y - dotSize, 0, s, s)
        else
            local color = is_active and C.neonCyan or C.stepDotInactive
            PL.drawDot(cx, y, dotSize - 2, color)
        end

        if i < 3 then
            local lineX1 = cx + dotSize + 3
            local lineX2 = cx + gap - dotSize - 3
            PL.drawDotLine(lineX1, lineX2, y, is_active, C.neonCyan)
        end
    end

    local stepNames = {"Name", "Class", "Appearance"}
    love.graphics.setFont(font)
    for i = 1, 3 do
        local cx = startX + (i - 1) * gap
        love.graphics.setColor(i == currentStep and C.neonCyan or C.textDim)
        love.graphics.printf(stepNames[i], cx - 35, y + dotSize + 6, 70, "center")
    end
end

function CharacterSelectUI.draw_select_screen(state)
    local w, h = love.graphics.getDimensions()
    draw_background(w, h)

    love.graphics.setFont(love.graphics.newFont(28))
    love.graphics.setColor(C.neonCyan)
    love.graphics.printf("SELECT CHARACTER", 0, 40, w, "center")

    local sepAsset = state.assetManager and state.assetManager:get_ui_asset("charSelect", "pixellab_separator")
    if sepAsset then
        love.graphics.setColor(1, 1, 1)
        local sx = 280 / sepAsset:getWidth()
        love.graphics.draw(sepAsset, w / 2 - 140, 62, 0, sx, 1)
    else
        PL.drawSeparator(w / 2 - 140, w / 2 + 140, 68)
    end

    local font = love.graphics.getFont()
    local characters = state.characters
    local startY = 100
    local slotAsset = state.assetManager and state.assetManager:get_ui_asset("charSelect", "pixellab_slot")
    local slotW = 560
    local slotH = 66

    for i, char in ipairs(characters) do
        local y = startY + (i - 1) * 78
        local isSelected = (i == state.selectedCharIndex)

        local usedAsset = false
        if slotAsset then
            usedAsset = Components.draw9Slice(slotAsset, w / 2 - slotW / 2, y, slotW, slotH, 8)
        end
        if not usedAsset then
            PL.drawPanel(w / 2 - 280, y, slotW, slotH, {
                hovered = isSelected,
                innerBorder = isSelected,
            })
        end

        if isSelected then
            love.graphics.setColor(C.neonCyan[1], C.neonCyan[2], C.neonCyan[3], 0.06)
            love.graphics.rectangle("fill", w / 2 - 280, y, 4, slotH)
        end

        AvatarRenderer.draw_avatar(w / 2 - 240, y + 33, 22, char)

        love.graphics.setFont(font)
        love.graphics.setColor(C.text)
        love.graphics.print(char.characterName or char.name or "Unknown", w / 2 - 190, y + 8)
        love.graphics.setColor(C.neonCyan)
        love.graphics.print(CharacterData.get_class_name(char), w / 2 - 190, y + 24)

        local hpPercent = char.hp and char.maxHp and char.maxHp > 0 and (char.hp / char.maxHp) or 0
        local mpPercent = char.mp and char.maxMp and char.maxMp > 0 and (char.mp / char.maxMp) or 0
        draw_pixel_bar(w / 2 - 190, y + 44, 120, 8, hpPercent, C.neonGreen, C.neonPink)
        draw_pixel_bar(w / 2 + 10, y + 44, 80, 8, mpPercent, C.neonBlue, C.textMuted)
    end

    local buttonY = h - 140
    if #characters > 0 then
        local mx, my = love.mouse.getPosition()
        local selHover = mx >= w / 2 - 220 and mx <= w / 2 - 20 and my >= buttonY and my <= buttonY + 40
        PL.drawButton(w / 2 - 220, buttonY, state.buttonWidth, 40,
            "Select", "primary", font, { hover = selHover })
    end

    local mx, my = love.mouse.getPosition()
    local createHover = mx >= w / 2 + 20 and mx <= w / 2 + 220 and my >= buttonY and my <= buttonY + 40
    PL.drawButton(w / 2 + 20, buttonY, state.buttonWidth, 40,
        "Create New", "primary", font, { hover = createHover })

    love.graphics.setColor(C.textMuted)
    love.graphics.printf("UP/DOWN: Select  |  ENTER: Confirm", 0, h - 40, w, "center")
end

function CharacterSelectUI.draw_create_screen(state)
    local w, h = love.graphics.getDimensions()
    draw_background(w, h)

    love.graphics.setFont(love.graphics.newFont(26))
    love.graphics.setColor(C.neonCyan)
    love.graphics.printf("CREATE CHARACTER", 0, 25, w, "center")
    PL.drawSeparator(w / 2 - 150, w / 2 + 150, 52)

    draw_step_indicator(state, state.createStep, w, 70)

    if state.createStep == 1 then
        CharacterSelectUI.draw_name_step(state, w, h)
    elseif state.createStep == 2 then
        CharacterSelectUI.draw_class_step(state, w, h)
    elseif state.createStep == 3 then
        CharacterSelectUI.draw_appearance_step(state, w, h)
    end
end

function CharacterSelectUI.draw_name_step(state, w, h)
    local font = love.graphics.getFont()
    love.graphics.setColor(C.textDim)
    love.graphics.printf("Enter Character Name", 0, 90, w, "center")

    PL.drawPanel(w / 2 - 230, 120, 460, 120, { innerBorder = true })

    love.graphics.setColor(C.textDim)
    love.graphics.print("Character Name:", w / 2 - 200, 140)

    Theme.pixelLab.drawInput(w / 2 - 200, 165, 400, 40, state.nameInputActive)

    love.graphics.setColor(C.text)
    local displayName = state.newCharName
    if state.nameInputActive and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        displayName = displayName .. "|"
    end
    love.graphics.print(displayName, w / 2 - 190, 173)

    if state.errorMessage ~= "" then
        love.graphics.setColor(Theme.colors.error)
        love.graphics.printf(state.errorMessage, 0, 215, w, "center")
    end

    love.graphics.setColor(C.textMuted)
    love.graphics.printf("Click the input box and type your name (3-20 characters)", 0, 245, w, "center")

    local buttonY = h - 110
    local mx, my = love.mouse.getPosition()
    local nextHover = mx >= w / 2 - 100 and mx <= w / 2 + 100 and my >= buttonY and my <= buttonY + 38
    local cancelHover = mx >= w / 2 + 110 and mx <= w / 2 + 310 and my >= buttonY and my <= buttonY + 38
    PL.drawButton(w / 2 - 100, buttonY, state.buttonWidth, 38, "Next", "primary", font, { hover = nextHover })
    PL.drawButton(w / 2 + 110, buttonY, state.buttonWidth, 38, "Cancel", "danger", font, { hover = cancelHover })
end

function CharacterSelectUI.draw_class_step(state, w, h)
    local font = love.graphics.getFont()

    love.graphics.setColor(C.textDim)
    love.graphics.printf("Choose Your Class", 0, 90, w, "center")

    love.graphics.setColor(C.textDim)
    love.graphics.print("Category:", w / 2 - 280, 120)

    local catStartX = w / 2 - 280
    for i, cat in ipairs(state.categories) do
        local x = catStartX + (i - 1) * 160
        local isSelected = (i == state.selectedCategoryIndex)

        PL.drawPanel(x, 140, 150, 50, { hovered = isSelected })

        love.graphics.setColor(C.text)
        love.graphics.printf(cat.name, x, 148, 150, "center")
        love.graphics.setColor(C.textDim)
        love.graphics.printf(cat.description, x, 166, 150, "center")
    end

    love.graphics.setColor(C.textDim)
    love.graphics.print("Classes:", w / 2 - 280, 210)

    local classStartY = 235
    for i, class in ipairs(state.currentClassList) do
        local y = classStartY + (i - 1) * 98
        local isSelected = (i == state.selectedClassIndex)

        PL.drawPanel(w / 2 - 280, y, 560, 88, {
            hovered = isSelected,
            innerBorder = isSelected,
        })

        if isSelected then
            love.graphics.setColor(C.neonCyan[1], C.neonCyan[2], C.neonCyan[3], 0.06)
            love.graphics.rectangle("fill", w / 2 - 280, y, 4, 88)
        end

        love.graphics.setColor(C.text)
        love.graphics.print(class.name, w / 2 - 260, y + 8)
        love.graphics.setColor(C.textDim)
        love.graphics.print(class.description, w / 2 - 260, y + 28)

        love.graphics.setColor(C.neonGreen)
        local bonusText = CharacterSelectUI.format_passive_bonus(state, class.passiveBonus)
        love.graphics.print("Passive: " .. bonusText, w / 2 - 260, y + 48)

        love.graphics.setColor(C.textMuted)
        local statsText = string.format("HP:%d  MP:%d  ATK:%d  DEF:%d  SPD:%d",
            class.baseStats.hp, class.baseStats.mp, class.baseStats.attack,
            class.baseStats.defense, class.baseStats.speed)
        love.graphics.print(statsText, w / 2 - 260, y + 66)
    end

    local buttonY = h - 80
    local mx, my = love.mouse.getPosition()
    local backHover = mx >= w / 2 - 320 and mx <= w / 2 - 120 and my >= buttonY and my <= buttonY + 38
    local nextHover = mx >= w / 2 - 100 and mx <= w / 2 + 100 and my >= buttonY and my <= buttonY + 38
    PL.drawButton(w / 2 - 320, buttonY, state.buttonWidth, 38, "Back", "danger", font, { hover = backHover })
    PL.drawButton(w / 2 - 100, buttonY, state.buttonWidth, 38, "Next", "primary", font, { hover = nextHover })
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
    local font = love.graphics.getFont()

    love.graphics.setColor(C.textDim)
    love.graphics.printf("Select Appearance", 0, 90, w, "center")

    local selectedClass = state.currentClassList[state.selectedClassIndex]
    love.graphics.setColor(C.neonCyan)
    love.graphics.printf(string.format("Creating: %s - %s", state.newCharName, selectedClass.name), 0, 108, w, "center")

    local gridStartX = w / 2 - 280
    local gridStartY = 135
    local cellWidth = 140
    local cellHeight = 110

    for i, appearance in ipairs(state.appearances) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local x = gridStartX + col * cellWidth
        local y = gridStartY + row * cellHeight
        local isSelected = (i == state.selectedAppearanceIndex)

        PL.drawPanel(x, y, 130, 100, {
            hovered = isSelected,
            innerBorder = isSelected,
        })

        if isSelected then
            love.graphics.setColor(C.neonCyan[1], C.neonCyan[2], C.neonCyan[3], 0.06)
            love.graphics.rectangle("fill", x, y, 4, 100)
        end

        local preset = AppearanceSystem.get_preset(appearance.id)
        AppearanceSystem.draw_avatar(x + 65, y + 35, 22, preset)

        love.graphics.setColor(C.text)
        love.graphics.printf(appearance.name, x, y + 72, 130, "center")
    end

    local buttonY = h - 80
    local mx, my = love.mouse.getPosition()
    local backHover = mx >= w / 2 - 320 and mx <= w / 2 - 120 and my >= buttonY and my <= buttonY + 38
    local createHover = mx >= w / 2 - 100 and mx <= w / 2 + 100 and my >= buttonY and my <= buttonY + 38
    PL.drawButton(w / 2 - 320, buttonY, state.buttonWidth, 38, "Back", "danger", font, { hover = backHover })
    PL.drawButton(w / 2 - 100, buttonY, state.buttonWidth, 38, "Create", "primary", font, { hover = createHover })
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
    local btnH = 38

    if state.mode == "select" then
        local characters = state.characters
        local startY = 100
        for i, char in ipairs(characters) do
            local charY = startY + (i - 1) * 78
            if button == 1 and x >= w / 2 - 280 and x <= w / 2 + 280 and y >= charY and y <= charY + 66 then
                state.selectedCharIndex = i
                return characters[i]
            end
        end

        local buttonY = h - 140
        if button == 1 and x >= w / 2 - 220 and x <= w / 2 - 20 and y >= buttonY and y <= buttonY + btnH then
            if #characters > 0 and state.selectedCharIndex <= #characters then
                return characters[state.selectedCharIndex]
            end
        end

        if button == 1 and x >= w / 2 + 20 and x <= w / 2 + 220 and y >= buttonY and y <= buttonY + btnH then
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
    local btnH = 38

    if state.createStep == 1 then
        if button == 1 and x >= w / 2 - 200 and x <= w / 2 + 200 and y >= 165 and y <= 205 then
            state.nameInputActive = true
        else
            state.nameInputActive = false
        end

        local buttonY = h - 110
        if button == 1 and x >= w / 2 - 100 and x <= w / 2 + 100 and y >= buttonY and y <= buttonY + btnH then
            if CharacterSelectUI.validate_name(state) then
                state.createStep = 2
            end
        end

        if button == 1 and x >= w / 2 + 110 and x <= w / 2 + 310 and y >= buttonY and y <= buttonY + btnH then
            state.mode = "select"
            state.newCharName = ""
            state.errorMessage = ""
        end

    elseif state.createStep == 2 then
        local catStartX = w / 2 - 280
        for i, cat in ipairs(state.categories) do
            local cx = catStartX + (i - 1) * 160
            if button == 1 and x >= cx and x <= cx + 150 and y >= 140 and y <= 190 then
                state.selectedCategoryIndex = i
                CharacterSelectUI.update_class_list(state)
            end
        end

        local classStartY = 235
        for i, class in ipairs(state.currentClassList) do
            local cy = classStartY + (i - 1) * 98
            if button == 1 and x >= w / 2 - 280 and x <= w / 2 + 280 and y >= cy and y <= cy + 88 then
                state.selectedClassIndex = i
            end
        end

        local buttonY = h - 80
        if button == 1 and x >= w / 2 - 320 and x <= w / 2 - 120 and y >= buttonY and y <= buttonY + btnH then
            state.createStep = 1
        end
        if button == 1 and x >= w / 2 - 100 and x <= w / 2 + 100 and y >= buttonY and y <= buttonY + btnH then
            state.createStep = 3
        end

    elseif state.createStep == 3 then
        local gridStartX = w / 2 - 280
        local gridStartY = 135
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
        if button == 1 and x >= w / 2 - 320 and x <= w / 2 - 120 and y >= buttonY and y <= buttonY + btnH then
            state.createStep = 2
        end
        if button == 1 and x >= w / 2 - 100 and x <= w / 2 + 100 and y >= buttonY and y <= buttonY + btnH then
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
