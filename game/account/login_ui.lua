-- login_ui.lua - Login UI
-- 登录界面

local LoginUI = {}
LoginUI.__index = LoginUI

function LoginUI.new()
    local self = setmetatable({}, LoginUI)
    
    -- UI state
    self.isActive = true
    self.selectedField = "username"  -- "username" or "password"
    
    -- Input fields
    self.username = ""
    self.password = ""
    self.passwordDisplay = ""  -- Masked password
    
    -- Error message
    self.errorMessage = ""
    self.errorTimer = 0
    
    -- Colors
    self.colors = {
        background = {0.1, 0.1, 0.15},
        panel = {0.2, 0.2, 0.25},
        border = {0.4, 0.4, 0.5},
        text = {1, 1, 1},
        textDim = {0.6, 0.6, 0.7},
        selected = {0.3, 0.5, 1.0},
        error = {1.0, 0.3, 0.3},
        success = {0.3, 1.0, 0.3},
    }
    
    -- Fonts
    self.titleFont = love.graphics.newFont(32)
    self.normalFont = love.graphics.newFont(18)
    self.smallFont = love.graphics.newFont(14)

    -- UI element positions (will be calculated in draw)
    self.usernameFieldRect = {x = 0, y = 0, width = 0, height = 0}
    self.passwordFieldRect = {x = 0, y = 0, width = 0, height = 0}
    self.loginButtonRect = {x = 0, y = 0, width = 0, height = 0}
    self.registerButtonRect = {x = 0, y = 0, width = 0, height = 0}

    return self
end

-- Update
function LoginUI:update(dt)
    if self.errorTimer > 0 then
        self.errorTimer = self.errorTimer - dt
        if self.errorTimer <= 0 then
            self.errorMessage = ""
        end
    end
end

-- Draw
function LoginUI:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background
    love.graphics.setColor(self.colors.background)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Title
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Fantasy RPG", 0, h * 0.15, w, "center")
    
    -- Subtitle
    love.graphics.setFont(self.normalFont)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.printf("Login to Continue", 0, h * 0.15 + 50, w, "center")
    
    -- Login panel
    local panelW = 400
    local panelH = 350
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 10, 10)
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 10, 10)
    
    -- Username field
    self.usernameFieldRect = {x = panelX + 30, y = panelY + 60, width = panelW - 60, height = 40}
    self:drawInputField("Username:", self.username, self.usernameFieldRect.x, self.usernameFieldRect.y,
        self.usernameFieldRect.width, self.selectedField == "username")

    -- Password field
    self.passwordFieldRect = {x = panelX + 30, y = panelY + 150, width = panelW - 60, height = 40}
    self:drawInputField("Password:", self.passwordDisplay, self.passwordFieldRect.x, self.passwordFieldRect.y,
        self.passwordFieldRect.width, self.selectedField == "password")

    -- Login button
    self.loginButtonRect = {x = panelX + 30, y = panelY + 240, width = 160, height = 40}
    local mx, my = love.mouse.getPosition()
    local loginHover = self:isMouseOver(self.loginButtonRect, mx, my)
    self:drawButton("Login", self.loginButtonRect.x, self.loginButtonRect.y,
        self.loginButtonRect.width, self.loginButtonRect.height, false, loginHover)

    -- Register button (placeholder)
    self.registerButtonRect = {x = panelX + 210, y = panelY + 240, width = 160, height = 40}
    local registerHover = self:isMouseOver(self.registerButtonRect, mx, my)
    self:drawButton("Register", self.registerButtonRect.x, self.registerButtonRect.y,
        self.registerButtonRect.width, self.registerButtonRect.height, true, registerHover)
    
    -- Error message
    if self.errorMessage ~= "" then
        love.graphics.setFont(self.smallFont)
        love.graphics.setColor(self.colors.error)
        love.graphics.printf(self.errorMessage, panelX, panelY + 300, panelW, "center")
    end
    
    -- Instructions
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(self.colors.textDim)
    love.graphics.printf("Tab: Switch field | Enter: Login", 0, h - 60, w, "center")
    love.graphics.printf("Default accounts: test/123, admin/admin, player/pass", 0, h - 40, w, "center")
end

-- Draw input field
function LoginUI:drawInputField(label, text, x, y, width, selected)
    love.graphics.setFont(self.normalFont)
    
    -- Label
    love.graphics.setColor(self.colors.textDim)
    love.graphics.print(label, x, y - 25)
    
    -- Field background
    if selected then
        love.graphics.setColor(self.colors.selected[1] * 0.3, self.colors.selected[2] * 0.3, self.colors.selected[3] * 0.3)
    else
        love.graphics.setColor(0.15, 0.15, 0.2)
    end
    love.graphics.rectangle("fill", x, y, width, 40, 5, 5)
    
    -- Field border
    if selected then
        love.graphics.setColor(self.colors.selected)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(self.colors.border)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", x, y, width, 40, 5, 5)
    
    -- Text
    love.graphics.setColor(self.colors.text)
    love.graphics.print(text, x + 10, y + 10)
    
    -- Cursor
    if selected then
        local cursorX = x + 10 + self.normalFont:getWidth(text)
        local time = love.timer.getTime()
        if math.floor(time * 2) % 2 == 0 then
            love.graphics.setColor(self.colors.text)
            love.graphics.rectangle("fill", cursorX, y + 8, 2, 24)
        end
    end
end

-- Draw button
function LoginUI:drawButton(text, x, y, width, height, disabled, hover)
    -- Background
    if disabled then
        love.graphics.setColor(0.3, 0.3, 0.35)
    elseif hover then
        love.graphics.setColor(0.4, 0.6, 1.0)
    else
        love.graphics.setColor(0.3, 0.5, 0.8)
    end
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)

    -- Border
    if hover and not disabled then
        love.graphics.setColor(0.5, 0.7, 1.0)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(self.colors.border)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", x, y, width, height, 5, 5)

    -- Text
    love.graphics.setFont(self.normalFont)
    if disabled then
        love.graphics.setColor(self.colors.textDim)
    else
        love.graphics.setColor(self.colors.text)
    end
    love.graphics.printf(text, x, y + 10, width, "center")
end

-- Handle text input
function LoginUI:textinput(text)
    if self.selectedField == "username" then
        if #self.username < 20 then
            self.username = self.username .. text
        end
    elseif self.selectedField == "password" then
        if #self.password < 20 then
            self.password = self.password .. text
            self.passwordDisplay = self.passwordDisplay .. "*"
        end
    end
end

-- Handle key press
function LoginUI:keypressed(key)
    if key == "backspace" then
        if self.selectedField == "username" then
            self.username = self.username:sub(1, -2)
        elseif self.selectedField == "password" then
            self.password = self.password:sub(1, -2)
            self.passwordDisplay = self.passwordDisplay:sub(1, -2)
        end
    elseif key == "tab" then
        -- Switch field
        if self.selectedField == "username" then
            self.selectedField = "password"
        else
            self.selectedField = "username"
        end
    elseif key == "return" or key == "kpenter" then
        -- Attempt login
        return self:attemptLogin()
    end
    
    return nil
end

-- Attempt login
function LoginUI:attemptLogin()
    local AccountManager = require("account.account_manager")

    local success, result = AccountManager.login(self.username, self.password)

    if success then
        print("Login successful!")
        self.isActive = false
        return success, result  -- Return success and username
    else
        -- Show error
        self.errorMessage = result
        self.errorTimer = 3.0
        
        -- Clear password
        self.password = ""
        self.passwordDisplay = ""
        
        return false, nil
    end
end

-- Check if active
function LoginUI:isLoginActive()
    return self.isActive
end

-- Check if mouse is over a rectangle
function LoginUI:isMouseOver(rect, mx, my)
    return mx >= rect.x and mx <= rect.x + rect.width and
           my >= rect.y and my <= rect.y + rect.height
end

-- Handle mouse click
function LoginUI:mousepressed(x, y, button)
    if button ~= 1 then  -- Only left click
        return nil
    end

    -- Check username field click
    if self:isMouseOver(self.usernameFieldRect, x, y) then
        self.selectedField = "username"
        return nil
    end

    -- Check password field click
    if self:isMouseOver(self.passwordFieldRect, x, y) then
        self.selectedField = "password"
        return nil
    end

    -- Check login button click
    if self:isMouseOver(self.loginButtonRect, x, y) then
        return self:attemptLogin()
    end

    -- Register button is disabled for now

    return nil
end

return LoginUI

