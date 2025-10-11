-- battle_background.lua - Battle background rendering
-- Diagonal gradient background for battle scenes

local BattleBackground = {}

-- Draw diagonal gradient background (bottom-left to top-right)
function BattleBackground.draw(w, h)
    -- Draw using triangular strips for diagonal gradient
    -- Bottom-left is darker, top-right is lighter
    
    local segments = 20  -- Number of gradient segments
    
    for i = 0, segments do
        local t = i / segments
        
        -- Color interpolation from dark (bottom-left) to light (top-right)
        local r = 0.1 + t * 0.15  -- 0.1 to 0.25
        local g = 0.1 + t * 0.15  -- 0.1 to 0.25
        local b = 0.15 + t * 0.15 -- 0.15 to 0.3
        
        love.graphics.setColor(r, g, b, 0.95)
        
        -- Draw diagonal strips
        local x1 = (i / segments) * w
        local y1 = 0
        local x2 = ((i + 1) / segments) * w
        local y2 = 0
        local x3 = 0
        local y3 = (i / segments) * h
        local x4 = 0
        local y4 = ((i + 1) / segments) * h
        
        -- Top triangle
        if x1 < w then
            love.graphics.polygon("fill", x1, y1, x2, y2, w, h * (i / segments), w, h * ((i + 1) / segments))
        end
        
        -- Bottom triangle
        if y3 < h then
            love.graphics.polygon("fill", x3, y3, x4, y4, w * (i / segments), h, w * ((i + 1) / segments), h)
        end
    end
    
    -- Draw battle ground overlay
    love.graphics.setColor(0.3, 0.25, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, h * 0.6, w, h * 0.4)
end

return BattleBackground

