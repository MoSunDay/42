local NetworkManager = require("src.network.network_manager")
local constants = require("src.network.constants")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local Particles = require("src.ui.particles")

local LoginUI = {}

local MODE = {
    LOGIN = "login",
    REGISTER = "register"
}

local PANEL_H = {
    login = 380,
    register = 430,
}

function LoginUI.create(assetManager)
    return {
        assetManager = assetManager,
        is_active = true,
        mode = MODE.LOGIN,
        selectedField = "username",

        username = "",
        password = "",
        passwordDisplay = "",
        characterName = "",

        errorMessage = "",
        successMessage = "",
        errorTimer = 0,

        isConnecting = false,
        isSubmitting = false,
        network = nil,

        panelHeight = PANEL_H.login,
        targetPanelHeight = PANEL_H.login,

        particleEmitter = nil,

        titleFont = love.graphics.newFont(32),
        normalFont = love.graphics.newFont(18),
        smallFont = love.graphics.newFont(14),

        usernameFieldRect = {x = 0, y = 0, width = 0, height = 0},
        passwordFieldRect = {x = 0, y = 0, width = 0, height = 0},
        characterNameFieldRect = {x = 0, y = 0, width = 0, height = 0},
        submitButtonRect = {x = 0, y = 0, width = 0, height = 0},
        loginTabRect = {x = 0, y = 0, width = 0, height = 0},
        registerTabRect = {x = 0, y = 0, width = 0, height = 0},
    }
end

LoginUI.new = LoginUI.create

function LoginUI.set_network(state, network)
    state.network = network

    NetworkManager.on(network, constants.PacketType.LOGIN, function(data, pkt)
        state.isSubmitting = false
        if data.success then
            state.successMessage = "Success!"
            local characters = data.characters or {}
            if state.onLoginSuccess then
                state.onLoginSuccess(characters, state.username)
            end
        else
            state.errorMessage = data.error or "Login failed"
            state.errorTimer = 3.0
            state.password = ""
            state.passwordDisplay = ""
        end
    end)

    NetworkManager.on(network, constants.PacketType.ERROR, function(data, pkt)
        state.isSubmitting = false
        state.errorMessage = data.message or "Server error"
        state.errorTimer = 3.0
    end)
end

function LoginUI.on_login(state, callback)
    state.onLoginSuccess = callback
end

function LoginUI.update(state, dt)
    if state.errorTimer > 0 then
        state.errorTimer = state.errorTimer - dt
        if state.errorTimer <= 0 then
            state.errorMessage = ""
            state.successMessage = ""
        end
    end

    if state.panelHeight ~= state.targetPanelHeight then
        local diff = state.targetPanelHeight - state.panelHeight
        state.panelHeight = state.panelHeight + diff * math.min(1, dt * 10)
        if math.abs(diff) < 0.5 then
            state.panelHeight = state.targetPanelHeight
        end
    end

    if state.network then
        NetworkManager.update(state.network)
    end
end

function LoginUI.connect(state)
    if state.network and not NetworkManager.is_connected(state.network) then
        state.isConnecting = true
        NetworkManager.connect(state.network)
    end
end

function LoginUI.ensure_particles(state)
    if not state.particleEmitter then
        local w, h = love.graphics.getDimensions()
        state.particleEmitter = Particles.continuous(w / 2, h, "goldDust", 3)
    end
end

function LoginUI.draw(state)
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(Theme.colors.background)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local loginBg = state.assetManager and state.assetManager:get_ui_panel("login_panel")
    if loginBg then
        local scaleX = w / loginBg:getWidth()
        local scaleY = h / loginBg:getHeight()
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.draw(loginBg, 0, 0, 0, scaleX, scaleY)
    end

    Theme.draw_shimmer(0, 0, w, h, 0.15)

    LoginUI.ensure_particles(state)

    love.graphics.setFont(state.titleFont)
    love.graphics.setColor(Theme.gold.bright)
    love.graphics.printf("Fantasy RPG", 0, h * 0.06, w, "center")
    Theme.draw_diamond_separator(w / 2, h * 0.06 + 38, 300)

    local panelW = 420
    local panelH = state.panelHeight
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2 + 20

    LoginUI.draw_panel(state, panelX, panelY, panelW, panelH)

    Theme.draw_diamond_separator(w / 2, panelY + 48, panelW - 80)

    local tabW = panelW / 2
    state.loginTabRect = {x = panelX, y = panelY, width = tabW, height = 40}
    state.registerTabRect = {x = panelX + tabW, y = panelY, width = tabW, height = 40}

    LoginUI.draw_tab(state, "Login", state.loginTabRect, state.mode == MODE.LOGIN)
    LoginUI.draw_tab(state, "Register", state.registerTabRect, state.mode == MODE.REGISTER)

    local contentY = panelY + 60

    local fieldX = panelX + 30
    local fieldW = panelW - 60
    local fieldH = 40
    local fieldGap = 70

    state.usernameFieldRect = {x = fieldX, y = contentY, width = fieldW, height = fieldH}
    LoginUI.draw_input_field(state, "Username:", state.username, state.usernameFieldRect,
        state.selectedField == "username")

    state.passwordFieldRect = {x = fieldX, y = contentY + fieldGap, width = fieldW, height = fieldH}
    LoginUI.draw_input_field(state, "Password:", state.passwordDisplay, state.passwordFieldRect,
        state.selectedField == "password")

    if state.mode == MODE.REGISTER then
        state.characterNameFieldRect = {x = fieldX, y = contentY + fieldGap * 2, width = fieldW, height = fieldH}
        LoginUI.draw_input_field(state, "Character Name:", state.characterName, state.characterNameFieldRect,
            state.selectedField == "characterName")

        state.submitButtonRect = {x = fieldX, y = contentY + fieldGap * 3 + 20, width = fieldW, height = fieldH}
    else
        state.characterNameFieldRect = {x = 0, y = 0, width = 0, height = 0}

        state.submitButtonRect = {x = fieldX, y = contentY + fieldGap * 2 + 20, width = fieldW, height = fieldH}
    end

    local mx, my = love.mouse.getPosition()
    local submitHover = LoginUI.is_mouse_over(state, state.submitButtonRect, mx, my)
    local buttonText = state.mode == MODE.LOGIN and "Login" or "Create Account"
    local isDisabled = state.isSubmitting or state.isConnecting
    LoginUI.draw_button(state, buttonText, state.submitButtonRect, false, submitHover, isDisabled)

    local msgY = state.submitButtonRect.y + state.submitButtonRect.height + 15

    if state.errorMessage ~= "" then
        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(Theme.colors.error)
        love.graphics.printf(state.errorMessage, panelX, msgY, panelW, "center")
    elseif state.successMessage ~= "" then
        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(Theme.colors.success)
        love.graphics.printf(state.successMessage, panelX, msgY, panelW, "center")
    elseif state.isConnecting then
        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.printf("Connecting to server...", panelX, msgY, panelW, "center")
    end

    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Tab: Switch field | Enter: Submit", 0, h - 40, w, "center")
end

function LoginUI.draw_panel(state, x, y, w, h)
    Components.drawOrnatePanel(x, y, w, h, state.assetManager, {
        title = "",
        corners = true,
        glow = true,
        shimmer = true,
        font = state.titleFont,
        style = "login_panel",
    })
    Theme.draw_gold_border(x, y, w, h, 2)
    Theme.draw_corner_ornaments(x, y, w, h, 12)
end

function LoginUI.draw_tab(state, text, rect, is_active)
    Components.drawTab(rect.x, rect.y, rect.width, rect.height, text, is_active, state.assetManager, state.normalFont)

    if is_active then
        Theme.draw_gold_border(rect.x, rect.y, rect.width, rect.height, 1)
    end
end

function LoginUI.draw_input_field(state, label, text, rect, selected)
    love.graphics.setFont(state.normalFont)

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print(label, rect.x, rect.y - 22)

    Components.drawInput(rect.x, rect.y, rect.width, rect.height, selected, state.assetManager)

    if selected then
        Theme.draw_glow(rect.x, rect.y, rect.width, rect.height, Theme.colors.accentBlue, 0.08)
    end

    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(text, rect.x + 10, rect.y + 10)

    if selected then
        local cursorX = rect.x + 10 + state.normalFont:getWidth(text)
        local time = love.timer.getTime()
        if math.floor(time * 2) % 2 == 0 then
            love.graphics.setColor(Theme.colors.text)
            love.graphics.rectangle("fill", cursorX, rect.y + 8, 2, 24)
        end
    end
end

function LoginUI.draw_button(state, text, rect, disabled, hover, submitting)
    local btnState = "normal"
    if submitting then
        btnState = "pressed"
    elseif hover and not disabled then
        btnState = "hover"
    end

    Components.drawOrnateButton(rect.x, rect.y, rect.width, rect.height,
        text, btnState, state.assetManager, state.normalFont, {gemColor = Theme.gem.sapphire})

    love.graphics.setFont(state.normalFont)
    if submitting then
        love.graphics.setColor(Theme.colors.textDim)
        local _, centerTextY = rect.x, rect.y + 10
        love.graphics.printf("Please wait...", rect.x, centerTextY, rect.width, "center")
    end
end

function LoginUI.is_mouse_over(state, rect, mx, my)
    return mx >= rect.x and mx <= rect.x + rect.width and
           my >= rect.y and my <= rect.y + rect.height
end

function LoginUI.textinput(state, text)
    if state.isSubmitting then return end

    local maxLen = 20
    if state.selectedField == "username" then
        if #state.username < maxLen then
            state.username = state.username .. text
        end
    elseif state.selectedField == "password" then
        if #state.password < maxLen then
            state.password = state.password .. text
            state.passwordDisplay = state.passwordDisplay .. "*"
        end
    elseif state.selectedField == "characterName" then
        if #state.characterName < maxLen then
            state.characterName = state.characterName .. text
        end
    end
end

function LoginUI.keypressed(state, key)
    if state.isSubmitting then return nil end

    if key == "backspace" then
        if state.selectedField == "username" then
            state.username = state.username:sub(1, -2)
        elseif state.selectedField == "password" then
            state.password = state.password:sub(1, -2)
            state.passwordDisplay = state.passwordDisplay:sub(1, -2)
        elseif state.selectedField == "characterName" then
            state.characterName = state.characterName:sub(1, -2)
        end
    elseif key == "tab" then
        LoginUI.cycle_field(state)
    elseif key == "return" or key == "kpenter" then
        return LoginUI.submit(state)
    end

    return nil
end

function LoginUI.cycle_field(state)
    if state.mode == MODE.LOGIN then
        if state.selectedField == "username" then
            state.selectedField = "password"
        else
            state.selectedField = "username"
        end
    else
        if state.selectedField == "username" then
            state.selectedField = "password"
        elseif state.selectedField == "password" then
            state.selectedField = "characterName"
        else
            state.selectedField = "username"
        end
    end
end

function LoginUI.submit(state)
    state.errorMessage = ""
    state.successMessage = ""

    if state.username == "" then
        state.errorMessage = "Username is required"
        state.errorTimer = 3.0
        return nil
    end

    if state.password == "" then
        state.errorMessage = "Password is required"
        state.errorTimer = 3.0
        return nil
    end

    if #state.username < 2 then
        state.errorMessage = "Username must be at least 2 characters"
        state.errorTimer = 3.0
        return nil
    end

    if #state.password < 3 then
        state.errorMessage = "Password must be at least 3 characters"
        state.errorTimer = 3.0
        return nil
    end

    if state.mode == MODE.REGISTER then
        if state.characterName == "" then
            state.characterName = state.username
        end
        return LoginUI.attempt_register(state)
    else
        return LoginUI.attempt_login(state)
    end
end

function LoginUI.attempt_login(state)
    if not state.network or not NetworkManager.is_connected(state.network) then
        state.errorMessage = "Not connected to server"
        state.errorTimer = 3.0
        return nil
    end

    state.isSubmitting = true
    NetworkManager.login(state.network, state.username, state.password)

    return nil
end

function LoginUI.attempt_register(state)
    if not state.network or not NetworkManager.is_connected(state.network) then
        state.errorMessage = "Not connected to server"
        state.errorTimer = 3.0
        return nil
    end

    state.isSubmitting = true
    NetworkManager.register(state.network, state.username, state.password, state.characterName)

    return nil
end

function LoginUI.switch_mode(state, newMode)
    if state.mode == newMode then return end
    state.mode = newMode
    state.targetPanelHeight = PANEL_H[newMode] or PANEL_H.login
    state.errorMessage = ""
    state.successMessage = ""
    state.errorTimer = 0
    state.selectedField = "username"
end

function LoginUI.mousepressed(state, x, y, button)
    if button ~= 1 then return nil end
    if state.isSubmitting then return nil end

    if LoginUI.is_mouse_over(state, state.loginTabRect, x, y) then
        LoginUI.switch_mode(state, MODE.LOGIN)
        return nil
    end

    if LoginUI.is_mouse_over(state, state.registerTabRect, x, y) then
        LoginUI.switch_mode(state, MODE.REGISTER)
        return nil
    end

    if LoginUI.is_mouse_over(state, state.usernameFieldRect, x, y) then
        state.selectedField = "username"
        return nil
    end

    if LoginUI.is_mouse_over(state, state.passwordFieldRect, x, y) then
        state.selectedField = "password"
        return nil
    end

    if state.mode == MODE.REGISTER and LoginUI.is_mouse_over(state, state.characterNameFieldRect, x, y) then
        state.selectedField = "characterName"
        return nil
    end

    if LoginUI.is_mouse_over(state, state.submitButtonRect, x, y) then
        return LoginUI.submit(state)
    end

    return nil
end

function LoginUI.is_login_active(state)
    return state.is_active
end

return LoginUI
