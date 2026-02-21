-- login_ui.lua - Login/Register UI
-- 登录/注册界面

local NetworkManager = require("src.network.network_manager")
local constants = require("src.network.constants")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local LoginUI = {}
LoginUI.__index = LoginUI

local MODE = {
    LOGIN = "login",
    REGISTER = "register"
}

function LoginUI.new()
    local self = setmetatable({}, LoginUI)
    
    self.isActive = true
    self.mode = MODE.LOGIN
    self.selectedField = "username"
    
    self.username = ""
    self.password = ""
    self.passwordDisplay = ""
    self.characterName = ""
    
    self.errorMessage = ""
    self.successMessage = ""
    self.errorTimer = 0
    
    self.isConnecting = false
    self.isSubmitting = false
    self.network = nil
    
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
        buttonSecondary = Theme.colors.panelLight,
        tabActive = Theme.colors.tab.active,
        tabInactive = Theme.colors.tab.inactive,
    }
    
    self.titleFont = love.graphics.newFont(32)
    self.normalFont = love.graphics.newFont(18)
    self.smallFont = love.graphics.newFont(14)
    
    self.usernameFieldRect = {x = 0, y = 0, width = 0, height = 0}
    self.passwordFieldRect = {x = 0, y = 0, width = 0, height = 0}
    self.characterNameFieldRect = {x = 0, y = 0, width = 0, height = 0}
    self.submitButtonRect = {x = 0, y = 0, width = 0, height = 0}
    self.loginTabRect = {x = 0, y = 0, width = 0, height = 0}
    self.registerTabRect = {x = 0, y = 0, width = 0, height = 0}
    
    return self
end

function LoginUI:setNetwork(network)
    self.network = network
    
    self.network:on(constants.PacketType.LOGIN, function(data, pkt)
        self.isSubmitting = false
        if data.success then
            self.successMessage = "Success!"
            local characters = data.characters or {}
            if self.onLoginSuccess then
                self.onLoginSuccess(characters, self.username)
            end
        else
            self.errorMessage = data.error or "Login failed"
            self.errorTimer = 3.0
            self.password = ""
            self.passwordDisplay = ""
        end
    end)
    
    self.network:on(constants.PacketType.ERROR, function(data, pkt)
        self.isSubmitting = false
        self.errorMessage = data.message or "Server error"
        self.errorTimer = 3.0
    end)
end

function LoginUI:onLogin(callback)
    self.onLoginSuccess = callback
end

function LoginUI:update(dt)
    if self.errorTimer > 0 then
        self.errorTimer = self.errorTimer - dt
        if self.errorTimer <= 0 then
            self.errorMessage = ""
            self.successMessage = ""
        end
    end
    
    if self.network then
        self.network:update()
    end
end

function LoginUI:connect()
    if self.network and not self.network:is_connected() then
        self.isConnecting = true
        self.network:connect()
    end
end

function LoginUI:draw()
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(self.colors.background)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Fantasy RPG", 0, h * 0.08, w, "center")
    
    local panelW = 420
    local panelH = self.mode == MODE.LOGIN and 380 or 430
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2 + 20
    
    self:drawPanel(panelX, panelY, panelW, panelH)
    
    local tabW = panelW / 2
    self.loginTabRect = {x = panelX, y = panelY, width = tabW, height = 40}
    self.registerTabRect = {x = panelX + tabW, y = panelY, width = tabW, height = 40}
    
    self:drawTab("Login", self.loginTabRect, self.mode == MODE.LOGIN)
    self:drawTab("Register", self.registerTabRect, self.mode == MODE.REGISTER)
    
    local contentY = panelY + 60
    
    local fieldX = panelX + 30
    local fieldW = panelW - 60
    local fieldH = 40
    local fieldGap = 70
    
    self.usernameFieldRect = {x = fieldX, y = contentY, width = fieldW, height = fieldH}
    self:drawInputField("Username:", self.username, self.usernameFieldRect, 
        self.selectedField == "username")
    
    self.passwordFieldRect = {x = fieldX, y = contentY + fieldGap, width = fieldW, height = fieldH}
    self:drawInputField("Password:", self.passwordDisplay, self.passwordFieldRect,
        self.selectedField == "password")
    
    if self.mode == MODE.REGISTER then
        self.characterNameFieldRect = {x = fieldX, y = contentY + fieldGap * 2, width = fieldW, height = fieldH}
        self:drawInputField("Character Name:", self.characterName, self.characterNameFieldRect,
            self.selectedField == "characterName")
        
        self.submitButtonRect = {x = fieldX, y = contentY + fieldGap * 3 + 20, width = fieldW, height = fieldH}
    else
        self.characterNameFieldRect = {x = 0, y = 0, width = 0, height = 0}
        
        self.submitButtonRect = {x = fieldX, y = contentY + fieldGap * 2 + 20, width = fieldW, height = fieldH}
    end
    
    local mx, my = love.mouse.getPosition()
    local submitHover = self:isMouseOver(self.submitButtonRect, mx, my)
    local buttonText = self.mode == MODE.LOGIN and "Login" or "Create Account"
    local isDisabled = self.isSubmitting or self.isConnecting
    self:drawButton(buttonText, self.submitButtonRect, false, submitHover, isDisabled)
    
    local msgY = self.submitButtonRect.y + self.submitButtonRect.height + 15
    
    if self.errorMessage ~= "" then
        love.graphics.setFont(self.smallFont)
        love.graphics.setColor(self.colors.error)
        love.graphics.printf(self.errorMessage, panelX, msgY, panelW, "center")
    elseif self.successMessage ~= "" then
        love.graphics.setFont(self.smallFont)
        love.graphics.setColor(self.colors.success)
        love.graphics.printf(self.successMessage, panelX, msgY, panelW, "center")
    elseif self.isConnecting then
        love.graphics.setFont(self.smallFont)
        love.graphics.setColor(self.colors.textDim)
        love.graphics.printf("Connecting to server...", panelX, msgY, panelW, "center")
    end
    
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.printf("Tab: Switch field | Enter: Submit", 0, h - 40, w, "center")
end

function LoginUI:drawPanel(x, y, w, h)
    Components.drawPanelSimple(x, y, w, h, 10)
end

function LoginUI:drawTab(text, rect, isActive)
    if isActive then
        love.graphics.setColor(self.colors.tabActive)
    else
        love.graphics.setColor(self.colors.tabInactive)
    end
    love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height)
    
    Components.drawBorder(rect.x, rect.y, rect.width, rect.height, 0, isActive)
    
    love.graphics.setFont(self.normalFont)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf(text, rect.x, rect.y + 10, rect.width, "center")
end

function LoginUI:drawInputField(label, text, rect, selected)
    love.graphics.setFont(self.normalFont)
    
    love.graphics.setColor(self.colors.textDim)
    love.graphics.print(label, rect.x, rect.y - 22)
    
    if selected then
        love.graphics.setColor(Theme.colors.input.backgroundActive)
    else
        love.graphics.setColor(Theme.colors.input.background)
    end
    love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height, 5, 5)
    
    Components.drawBorder(rect.x, rect.y, rect.width, rect.height, 5, selected)
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print(text, rect.x + 10, rect.y + 10)
    
    if selected then
        local cursorX = rect.x + 10 + self.normalFont:getWidth(text)
        local time = love.timer.getTime()
        if math.floor(time * 2) % 2 == 0 then
            love.graphics.setColor(self.colors.text)
            love.graphics.rectangle("fill", cursorX, rect.y + 8, 2, 24)
        end
    end
end

function LoginUI:drawButton(text, rect, disabled, hover, submitting)
    local state = "normal"
    if submitting then
        state = "pressed"
    elseif hover and not disabled then
        state = "hover"
    end
    
    Components.drawButtonSimple(rect.x, rect.y, rect.width, rect.height, 
        nil, not submitting and hover, submitting, self.normalFont)
    
    love.graphics.setFont(self.normalFont)
    if submitting then
        love.graphics.setColor(self.colors.textDim)
        text = "Please wait..."
    else
        love.graphics.setColor(self.colors.text)
    end
    love.graphics.printf(text, rect.x, rect.y + 10, rect.width, "center")
end

function LoginUI:isMouseOver(rect, mx, my)
    return mx >= rect.x and mx <= rect.x + rect.width and
           my >= rect.y and my <= rect.y + rect.height
end

function LoginUI:textinput(text)
    if self.isSubmitting then return end
    
    local maxLen = 20
    if self.selectedField == "username" then
        if #self.username < maxLen then
            self.username = self.username .. text
        end
    elseif self.selectedField == "password" then
        if #self.password < maxLen then
            self.password = self.password .. text
            self.passwordDisplay = self.passwordDisplay .. "*"
        end
    elseif self.selectedField == "characterName" then
        if #self.characterName < maxLen then
            self.characterName = self.characterName .. text
        end
    end
end

function LoginUI:keypressed(key)
    if self.isSubmitting then return nil end
    
    if key == "backspace" then
        if self.selectedField == "username" then
            self.username = self.username:sub(1, -2)
        elseif self.selectedField == "password" then
            self.password = self.password:sub(1, -2)
            self.passwordDisplay = self.passwordDisplay:sub(1, -2)
        elseif self.selectedField == "characterName" then
            self.characterName = self.characterName:sub(1, -2)
        end
    elseif key == "tab" then
        self:cycleField()
    elseif key == "return" or key == "kpenter" then
        return self:submit()
    end
    
    return nil
end

function LoginUI:cycleField()
    if self.mode == MODE.LOGIN then
        if self.selectedField == "username" then
            self.selectedField = "password"
        else
            self.selectedField = "username"
        end
    else
        if self.selectedField == "username" then
            self.selectedField = "password"
        elseif self.selectedField == "password" then
            self.selectedField = "characterName"
        else
            self.selectedField = "username"
        end
    end
end

function LoginUI:submit()
    self.errorMessage = ""
    self.successMessage = ""
    
    if self.username == "" then
        self.errorMessage = "Username is required"
        self.errorTimer = 3.0
        return nil
    end
    
    if self.password == "" then
        self.errorMessage = "Password is required"
        self.errorTimer = 3.0
        return nil
    end
    
    if #self.username < 2 then
        self.errorMessage = "Username must be at least 2 characters"
        self.errorTimer = 3.0
        return nil
    end
    
    if #self.password < 3 then
        self.errorMessage = "Password must be at least 3 characters"
        self.errorTimer = 3.0
        return nil
    end
    
    if self.mode == MODE.REGISTER then
        if self.characterName == "" then
            self.characterName = self.username
        end
        return self:attemptRegister()
    else
        return self:attemptLogin()
    end
end

function LoginUI:attemptLogin()
    if not self.network or not self.network:is_connected() then
        self.errorMessage = "Not connected to server"
        self.errorTimer = 3.0
        return nil
    end
    
    self.isSubmitting = true
    self.network:login(self.username, self.password)
    
    return nil
end

function LoginUI:attemptRegister()
    if not self.network or not self.network:is_connected() then
        self.errorMessage = "Not connected to server"
        self.errorTimer = 3.0
        return nil
    end
    
    self.isSubmitting = true
    self.network:register(self.username, self.password, self.characterName)
    
    return nil
end

function LoginUI:switchMode(newMode)
    if self.mode == newMode then return end
    self.mode = newMode
    self.errorMessage = ""
    self.successMessage = ""
    self.errorTimer = 0
    
    if newMode == MODE.REGISTER then
        self.selectedField = "username"
    else
        self.selectedField = "username"
    end
end

function LoginUI:mousepressed(x, y, button)
    if button ~= 1 then return nil end
    if self.isSubmitting then return nil end
    
    if self:isMouseOver(self.loginTabRect, x, y) then
        self:switchMode(MODE.LOGIN)
        return nil
    end
    
    if self:isMouseOver(self.registerTabRect, x, y) then
        self:switchMode(MODE.REGISTER)
        return nil
    end
    
    if self:isMouseOver(self.usernameFieldRect, x, y) then
        self.selectedField = "username"
        return nil
    end
    
    if self:isMouseOver(self.passwordFieldRect, x, y) then
        self.selectedField = "password"
        return nil
    end
    
    if self.mode == MODE.REGISTER and self:isMouseOver(self.characterNameFieldRect, x, y) then
        self.selectedField = "characterName"
        return nil
    end
    
    if self:isMouseOver(self.submitButtonRect, x, y) then
        return self:submit()
    end
    
    return nil
end

function LoginUI:isLoginActive()
    return self.isActive
end

return LoginUI
