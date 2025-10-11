-- pet_ui.lua - Pet UI for battle display
-- Shows pet status and renders pet in battle

local PetUI = {}
PetUI.__index = PetUI

function PetUI.new()
    local self = setmetatable({}, PetUI)
    
    self.colors = {
        panel = {0.2, 0.2, 0.25, 0.9},
        text = {1, 1, 1},
        hpBar = {0.3, 0.9, 0.4},
        hpBarBg = {0.2, 0.2, 0.25}
    }
    
    return self
end

-- Draw pet in battle (in front of player)
function PetUI:drawPet(pet, playerX, playerY, animationManager)
    if not pet then
        return
    end
    
    -- Position pet in front of player (slightly forward and to the side)
    local petX = playerX - 40
    local petY = playerY + 10
    
    -- Get animation transform
    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if animationManager and pet.animationId then
        offsetX, offsetY, rotation, scaleX, scaleY = animationManager:getTransform(pet.animationId)
    end
    
    -- Apply transform
    love.graphics.push()
    love.graphics.translate(petX + offsetX, petY + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)
    
    -- Draw pet body
    love.graphics.setColor(pet.color)
    love.graphics.circle("fill", 0, 0, pet.size)
    
    -- Draw eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", -pet.size * 0.3, -pet.size * 0.2, pet.size * 0.15)
    love.graphics.circle("fill", pet.size * 0.3, -pet.size * 0.2, pet.size * 0.15)
    
    love.graphics.pop()
    
    -- Draw HP bar above pet
    self:drawPetHPBar(pet, petX, petY - pet.size - 15)
end

-- Draw pet HP bar
function PetUI:drawPetHPBar(pet, x, y)
    local barWidth = 50
    local barHeight = 6
    
    -- Background
    love.graphics.setColor(self.colors.hpBarBg)
    love.graphics.rectangle("fill", x - barWidth/2, y, barWidth, barHeight, 2, 2)
    
    -- HP fill
    local hpPercent = pet.hp / pet.maxHp
    love.graphics.setColor(self.colors.hpBar)
    love.graphics.rectangle("fill", x - barWidth/2, y, barWidth * hpPercent, barHeight, 2, 2)
    
    -- Border
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x - barWidth/2, y, barWidth, barHeight, 2, 2)
end

-- Draw pet panel (in exploration mode)
function PetUI:drawPetPanel(pet, x, y, width, height)
    if not pet then
        return
    end
    
    -- Panel background
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Border
    love.graphics.setColor(0.4, 0.6, 1.0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    love.graphics.setLineWidth(1)
    
    -- Pet icon
    love.graphics.setColor(pet.color)
    love.graphics.circle("fill", x + 25, y + 25, 15)
    
    -- Pet name
    love.graphics.setColor(self.colors.text)
    love.graphics.print(pet.name, x + 50, y + 10)
    
    -- HP
    love.graphics.setColor(0.9, 0.3, 0.3)
    love.graphics.print("HP: " .. pet.hp .. "/" .. pet.maxHp, x + 50, y + 30)
    
    -- Stats
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("ATK:" .. pet.attack .. " DEF:" .. pet.defense, x + 10, y + 55)
end

return PetUI

