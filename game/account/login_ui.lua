local NetworkManager = require("src.network.network_manager")
local constants = require("src.network.constants")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local Particles = require("src.ui.particles")

local LoginUI = {}
local PL = Theme.pixelLab
local C = PL.colors

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

    Theme.draw_gradient(0, 0, w, h, C.bg, C.bgPanel, 12)

    LoginUI.ensure_particles(state)

    love.graphics.setFont(state.titleFont)
    love.graphics.setColor(C.neonCyan)
    love.graphics.printf("PIXEL RPG", 0, h * 0.05, w, "center")

    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(C.textDim)
    love.graphics.printf("AI-Generated Pixel Art Adventure", 0, h * 0.05 + 38, w, "center")

    local panelW = 420
    local panelH = state.panelHeight
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2 + 10

    LoginUI.draw_panel(state, panelX, panelY, panelW, panelH)

    PL.drawSeparator(panelX + 20, panelX + panelW - 20, panelY + 44)

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
    local buttonText = state.mode == MODE.LOGIN and "Sign In" or "Create Account"
    local isDisabled = state.isSubmitting or state.isConnecting
    local btnState = isDisabled and "disabled" or "primary"

    PL.drawButton(
        state.submitButtonRect.x, state.submitButtonRect.y,
        state.submitButtonRect.width, state.submitButtonRect.height,
        buttonText, btnState, state.normalFont,
        { hover = submitHover and not isDisabled }
    )

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
        love.graphics.setColor(C.textDim)
        love.graphics.printf("Connecting to server...", panelX, msgY, panelW, "center")
    end

    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(C.textMuted)
    love.graphics.printf("Tab: Switch  |  Enter: Submit", 0, h - 30, w, "center")
end

function LoginUI.draw_panel(state, x, y, w, h)
    local pixellabPanel = state.assetManager and state.assetManager:get_ui_panel("pixellab_panel")
    if pixellabPanel and Components.draw9Slice(pixellabPanel, x, y, w, h, 16) then
        return true
    end
    PL.drawPanel(x, y, w, h, { innerBorder = true })
    return false
end

function LoginUI.draw_tab(state, text, rect, is_active)
    local assetName = is_active and "pixellab_active" or "pixellab_inactive"
    local tabAsset = state.assetManager and state.assetManager:get_ui_asset("tabs", assetName)

    if tabAsset then
        love.graphics.setColor(1, 1, 1)
        local sx = rect.width / tabAsset:getWidth()
        local sy = rect.height / tabAsset:getHeight()
        love.graphics.draw(tabAsset, rect.x, rect.y, 0, sx, sy)
    else
        if is_active then
            love.graphics.setColor(C.bgCard)
            love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height)
            love.graphics.setColor(C.neonCyan)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(C.neonCyan)
            love.graphics.rectangle("fill", rect.x + rect.width * 0.2, rect.y + rect.height - 2, rect.width * 0.6, 3)
        else
            love.graphics.setColor(C.bgInput)
            love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height)
        end
    end

    love.graphics.setFont(state.normalFont)
    love.graphics.setColor(is_active and C.text or C.textDim)
    love.graphics.printf(text, rect.x, rect.y + 10, rect.width, "center")
end

function LoginUI.draw_input_field(state, label, text, rect, selected)
    local inputAsset = state.assetManager and state.assetManager:get_ui_asset("input", "pixellab_input")

    love.graphics.setFont(state.normalFont)
    love.graphics.setColor(C.textDim)
    love.graphics.print(label, rect.x, rect.y - 22)

    if inputAsset then
        love.graphics.setColor(1, 1, 1)
        local sx = rect.width / inputAsset:getWidth()
        local sy = rect.height / inputAsset:getHeight()
        love.graphics.draw(inputAsset, rect.x, rect.y, 0, sx, sy)
    else
        PL.drawInput(rect.x, rect.y, rect.width, rect.height, selected)
    end

    love.graphics.setColor(C.text)
    love.graphics.print(text, rect.x + 10, rect.y + 10)

    if selected then
        local cursorX = rect.x + 10 + state.normalFont:getWidth(text)
        local time = love.timer.getTime()
        if math.floor(time * 2) % 2 == 0 then
            love.graphics.setColor(C.neonCyan)
            love.graphics.rectangle("fill", cursorX, rect.y + 10, 2, 20)
        end
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
