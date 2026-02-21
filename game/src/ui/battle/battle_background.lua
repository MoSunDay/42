local Theme = require("src.ui.theme")

local BattleBackground = {}

function BattleBackground.draw(w, h, mapType)
    local bgColors = Theme.colors.battleBg[mapType] or Theme.colors.battleBg.forest
    
    local segments = 20
    
    for i = 0, segments do
        local t = i / segments
        
        local r = bgColors.gradient1[1] + t * (bgColors.gradient2[1] - bgColors.gradient1[1])
        local g = bgColors.gradient1[2] + t * (bgColors.gradient2[2] - bgColors.gradient1[2])
        local b = bgColors.gradient1[3] + t * (bgColors.gradient2[3] - bgColors.gradient1[3])
        
        love.graphics.setColor(r, g, b, 0.95)
        
        local x1 = (i / segments) * w
        local y1 = 0
        local x2 = ((i + 1) / segments) * w
        local y2 = 0
        local x3 = 0
        local y3 = (i / segments) * h
        local x4 = 0
        local y4 = ((i + 1) / segments) * h
        
        if x1 < w then
            love.graphics.polygon("fill", x1, y1, x2, y2, w, h * (i / segments), w, h * ((i + 1) / segments))
        end
        
        if y3 < h then
            love.graphics.polygon("fill", x3, y3, x4, y4, w * (i / segments), h, w * ((i + 1) / segments), h)
        end
    end
    
    love.graphics.setColor(bgColors.ground)
    love.graphics.rectangle("fill", 0, h * 0.6, w, h * 0.4)
end

function BattleBackground.getMapType(map)
    if not map then return "forest" end
    
    local name = map.name and map.name:lower() or ""
    
    if name:find("desert") or name:find("sand") then
        return "desert"
    elseif name:find("dungeon") or name:find("cave") or name:find("crypt") then
        return "dungeon"
    elseif name:find("boss") or name:find("throne") then
        return "boss"
    elseif name:find("sky") or name:find("cloud") then
        return "sky"
    elseif name:find("volcanic") or name:find("fire") or name:find("lava") then
        return "volcanic"
    else
        return "forest"
    end
end

return BattleBackground
