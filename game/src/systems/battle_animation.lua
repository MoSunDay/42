-- battle_animation.lua - Battle animation effects
-- Handles attack animations, damage numbers, and visual effects

local BattleAnimation = {}
BattleAnimation.__index = BattleAnimation

function BattleAnimation.new()
    local self = setmetatable({}, BattleAnimation)
    
    -- Active animations
    self.animations = {}
    
    -- Damage numbers
    self.damageNumbers = {}
    
    return self
end

-- Add attack animation
function BattleAnimation:addAttackAnimation(fromX, fromY, toX, toY, callback)
    local anim = {
        type = "attack",
        fromX = fromX,
        fromY = fromY,
        toX = toX,
        toY = toY,
        progress = 0,
        duration = 0.3,
        callback = callback
    }
    table.insert(self.animations, anim)
end

-- Add damage number
function BattleAnimation:addDamageNumber(x, y, damage, isCritical)
    local dmg = {
        x = x,
        y = y,
        damage = damage,
        isCritical = isCritical or false,
        alpha = 1.0,
        offsetY = 0,
        duration = 1.5,
        timer = 0
    }
    table.insert(self.damageNumbers, dmg)
end

-- Add hit flash effect
function BattleAnimation:addHitFlash(x, y)
    local flash = {
        type = "flash",
        x = x,
        y = y,
        radius = 30,
        alpha = 1.0,
        duration = 0.2,
        timer = 0
    }
    table.insert(self.animations, flash)
end

-- Update all animations
function BattleAnimation:update(dt)
    -- Update animations
    for i = #self.animations, 1, -1 do
        local anim = self.animations[i]
        
        if anim.type == "attack" then
            anim.progress = anim.progress + dt / anim.duration
            if anim.progress >= 1 then
                if anim.callback then
                    anim.callback()
                end
                table.remove(self.animations, i)
            end
        elseif anim.type == "flash" then
            anim.timer = anim.timer + dt
            anim.alpha = 1 - (anim.timer / anim.duration)
            if anim.timer >= anim.duration then
                table.remove(self.animations, i)
            end
        end
    end
    
    -- Update damage numbers
    for i = #self.damageNumbers, 1, -1 do
        local dmg = self.damageNumbers[i]
        dmg.timer = dmg.timer + dt
        dmg.offsetY = dmg.offsetY - dt * 50  -- Float upward
        dmg.alpha = 1 - (dmg.timer / dmg.duration)
        
        if dmg.timer >= dmg.duration then
            table.remove(self.damageNumbers, i)
        end
    end
end

-- Draw all animations
function BattleAnimation:draw()
    -- Draw attack animations
    for _, anim in ipairs(self.animations) do
        if anim.type == "attack" then
            self:drawAttackLine(anim)
        elseif anim.type == "flash" then
            self:drawFlash(anim)
        end
    end
    
    -- Draw damage numbers
    for _, dmg in ipairs(self.damageNumbers) do
        self:drawDamageNumber(dmg)
    end
end

-- Draw attack line
function BattleAnimation:drawAttackLine(anim)
    local t = anim.progress
    -- Ease out cubic
    t = 1 - math.pow(1 - t, 3)
    
    local x = anim.fromX + (anim.toX - anim.fromX) * t
    local y = anim.fromY + (anim.toY - anim.fromY) * t
    
    -- Draw attack trail
    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.line(anim.fromX, anim.fromY, x, y)
    
    -- Draw attack point
    love.graphics.setColor(1, 0.5, 0, 1)
    love.graphics.circle("fill", x, y, 8)
    
    love.graphics.setLineWidth(1)
end

-- Draw hit flash
function BattleAnimation:drawFlash(flash)
    love.graphics.setColor(1, 1, 1, flash.alpha * 0.8)
    love.graphics.circle("fill", flash.x, flash.y, flash.radius)
    
    love.graphics.setColor(1, 0.5, 0, flash.alpha * 0.5)
    love.graphics.circle("line", flash.x, flash.y, flash.radius)
end

-- Draw damage number
function BattleAnimation:drawDamageNumber(dmg)
    local x = dmg.x
    local y = dmg.y + dmg.offsetY
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, dmg.alpha * 0.5)
    love.graphics.print(tostring(dmg.damage), x + 2, y + 2)
    
    -- Damage number
    if dmg.isCritical then
        love.graphics.setColor(1, 0.3, 0.3, dmg.alpha)  -- Red for critical
    else
        love.graphics.setColor(1, 1, 1, dmg.alpha)  -- White for normal
    end
    
    local scale = dmg.isCritical and 1.5 or 1.0
    love.graphics.print(tostring(dmg.damage), x, y, 0, scale, scale)
end

-- Check if animations are playing
function BattleAnimation:isPlaying()
    return #self.animations > 0 or #self.damageNumbers > 0
end

-- Clear all animations
function BattleAnimation:clear()
    self.animations = {}
    self.damageNumbers = {}
end

return BattleAnimation

