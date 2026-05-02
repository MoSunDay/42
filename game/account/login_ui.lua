local NetworkManager = require("src.network.network_manager")
local constants = require("src.network.constants")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local LoginUI = {}

local MODE = {
    LOGIN = "login",
    REGISTER = "register"
}

function LoginUI.create(assetManager)
    return {
        assetManager = assetManager,
        isActive = true,
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
            buttonSecondary = Theme.colors.panelLight,
            tabActive = Theme.colors.tab.active,
            tabInactive = Theme.colors.tab.inactive,
        },
        
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

function LoginUI.setNetwork(state, network)
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

function LoginUI.onLogin(state, callback)
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

function LoginUI.draw(state)
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(state.colors.background)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local loginBg = state.assetManager and state.assetManager:getUIPanel("login_panel")
    if loginBg then
        local scaleX = w / loginBg:getWidth()
        local scaleY = h / loginBg:getHeight()
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.draw(loginBg, 0, 0, 0, scaleX, scaleY)
    end
    
    love.graphics.setFont(state.titleFont)
    love.graphics.setColor(state.colors.text)
    love.graphics.printf("Fantasy RPG", 0, h * 0.08, w, "center")
    
    local panelW = 420
    local panelH = state.mode == MODE.LOGIN and 380 or 430
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2 + 20
    
    LoginUI.drawPanel(state, panelX, panelY, panelW, panelH)

    Theme.drawDiamondSeparator(w / 2, panelY + 48, panelW - 80)

    local tabW = panelW / 2
    state.loginTabRect = {x = panelX, y = panelY, width = tabW, height = 40}
    state.registerTabRect = {x = panelX + tabW, y = panelY, width = tabW, height = 40}
    
    LoginUI.drawTab(state, "Login", state.loginTabRect, state.mode == MODE.LOGIN)
    LoginUI.drawTab(state, "Register", state.registerTabRect, state.mode == MODE.REGISTER)
    
    local contentY = panelY + 60
    
    local fieldX = panelX + 30
    local fieldW = panelW - 60
    local fieldH = 40
    local fieldGap = 70
    
    state.usernameFieldRect = {x = fieldX, y = contentY, width = fieldW, height = fieldH}
    LoginUI.drawInputField(state, "Username:", state.username, state.usernameFieldRect, 
        state.selectedField == "username")
    
    state.passwordFieldRect = {x = fieldX, y = contentY + fieldGap, width = fieldW, height = fieldH}
    LoginUI.drawInputField(state, "Password:", state.passwordDisplay, state.passwordFieldRect,
        state.selectedField == "password")
    
    if state.mode == MODE.REGISTER then
        state.characterNameFieldRect = {x = fieldX, y = contentY + fieldGap * 2, width = fieldW, height = fieldH}
        LoginUI.drawInputField(state, "Character Name:", state.characterName, state.characterNameFieldRect,
            state.selectedField == "characterName")
        
        state.submitButtonRect = {x = fieldX, y = contentY + fieldGap * 3 + 20, width = fieldW, height = fieldH}
    else
        state.characterNameFieldRect = {x = 0, y = 0, width = 0, height = 0}
        
        state.submitButtonRect = {x = fieldX, y = contentY + fieldGap * 2 + 20, width = fieldW, height = fieldH}
    end
    
    local mx, my = love.mouse.getPosition()
    local submitHover = LoginUI.isMouseOver(state, state.submitButtonRect, mx, my)
    local buttonText = state.mode == MODE.LOGIN and "Login" or "Create Account"
    local isDisabled = state.isSubmitting or state.isConnecting
    LoginUI.drawButton(state, buttonText, state.submitButtonRect, false, submitHover, isDisabled)
    
    local msgY = state.submitButtonRect.y + state.submitButtonRect.height + 15
    
    if state.errorMessage ~= "" then
        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(state.colors.error)
        love.graphics.printf(state.errorMessage, panelX, msgY, panelW, "center")
    elseif state.successMessage ~= "" then
        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(state.colors.success)
        love.graphics.printf(state.successMessage, panelX, msgY, panelW, "center")
    elseif state.isConnecting then
        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(state.colors.textDim)
        love.graphics.printf("Connecting to server...", panelX, msgY, panelW, "center")
    end
    
    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(state.colors.textDim)
    love.graphics.printf("Tab: Switch field | Enter: Submit", 0, h - 40, w, "center")
end

function LoginUI.drawPanel(state, x, y, w, h)
    Components.drawOrnatePanel(x, y, w, h, state.assetManager, {
        title = "",
        corners = true,
        glow = false,
        shimmer = false,
        font = state.titleFont,
        style = "login_panel",
    })
    Theme.drawGoldBorder(x, y, w, h, 2)
    Theme.drawCornerOrnaments(x, y, w, h, 12)
end

function LoginUI.drawTab(state, text, rect, isActive)
    Components.drawTab(rect.x, rect.y, rect.width, rect.height, text, isActive, state.assetManager, state.normalFont)

    if isActive then
        love.graphics.setColor(Theme.gold.normal)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height, 0)
        love.graphics.setLineWidth(1)
    end
end

function LoginUI.drawInputField(state, label, text, rect, selected)
    love.graphics.setFont(state.normalFont)

    love.graphics.setColor(state.colors.textDim)
    love.graphics.print(label, rect.x, rect.y - 22)

    Components.drawInput(rect.x, rect.y, rect.width, rect.height, selected, state.assetManager)

    love.graphics.setColor(state.colors.text)
    love.graphics.print(text, rect.x + 10, rect.y + 10)

    if selected then
        local cursorX = rect.x + 10 + state.normalFont:getWidth(text)
        local time = love.timer.getTime()
        if math.floor(time * 2) % 2 == 0 then
            love.graphics.setColor(state.colors.text)
            love.graphics.rectangle("fill", cursorX, rect.y + 8, 2, 24)
        end
    end
end

function LoginUI.drawButton(state, text, rect, disabled, hover, submitting)
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
        love.graphics.setColor(state.colors.textDim)
        local _, centerTextY = rect.x, rect.y + 10
        love.graphics.printf("Please wait...", rect.x, centerTextY, rect.width, "center")
    end
end

function LoginUI.isMouseOver(state, rect, mx, my)
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
        LoginUI.cycleField(state)
    elseif key == "return" or key == "kpenter" then
        return LoginUI.submit(state)
    end
    
    return nil
end

function LoginUI.cycleField(state)
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
        return LoginUI.attemptRegister(state)
    else
        return LoginUI.attemptLogin(state)
    end
end

function LoginUI.attemptLogin(state)
    if not state.network or not NetworkManager.is_connected(state.network) then
        state.errorMessage = "Not connected to server"
        state.errorTimer = 3.0
        return nil
    end
    
    state.isSubmitting = true
    NetworkManager.login(state.network, state.username, state.password)
    
    return nil
end

function LoginUI.attemptRegister(state)
    if not state.network or not NetworkManager.is_connected(state.network) then
        state.errorMessage = "Not connected to server"
        state.errorTimer = 3.0
        return nil
    end
    
    state.isSubmitting = true
    NetworkManager.register(state.network, state.username, state.password, state.characterName)
    
    return nil
end

function LoginUI.switchMode(state, newMode)
    if state.mode == newMode then return end
    state.mode = newMode
    state.errorMessage = ""
    state.successMessage = ""
    state.errorTimer = 0
    
    if newMode == MODE.REGISTER then
        state.selectedField = "username"
    else
        state.selectedField = "username"
    end
end

function LoginUI.mousepressed(state, x, y, button)
    if button ~= 1 then return nil end
    if state.isSubmitting then return nil end
    
    if LoginUI.isMouseOver(state, state.loginTabRect, x, y) then
        LoginUI.switchMode(state, MODE.LOGIN)
        return nil
    end
    
    if LoginUI.isMouseOver(state, state.registerTabRect, x, y) then
        LoginUI.switchMode(state, MODE.REGISTER)
        return nil
    end
    
    if LoginUI.isMouseOver(state, state.usernameFieldRect, x, y) then
        state.selectedField = "username"
        return nil
    end
    
    if LoginUI.isMouseOver(state, state.passwordFieldRect, x, y) then
        state.selectedField = "password"
        return nil
    end
    
    if state.mode == MODE.REGISTER and LoginUI.isMouseOver(state, state.characterNameFieldRect, x, y) then
        state.selectedField = "characterName"
        return nil
    end
    
    if LoginUI.isMouseOver(state, state.submitButtonRect, x, y) then
        return LoginUI.submit(state)
    end
    
    return nil
end

function LoginUI.isLoginActive(state)
    return state.isActive
end

return LoginUI
