local Theme = require("src.ui.theme")

local BattleBackground = {}

local BG_PARTICLES = {}
local BG_PARTICLE_TIME = 0

function BattleBackground.update(dt)
    BG_PARTICLE_TIME = BG_PARTICLE_TIME + dt
    for i = #BG_PARTICLES, 1, -1 do
        local p = BG_PARTICLES[i]
        p.y = p.y - p.speed * dt
        p.life = p.life - dt
        p.alpha = math.max(0, p.life / p.maxLife)
        if p.life <= 0 then
            table.remove(BG_PARTICLES, i)
        end
    end
    if #BG_PARTICLES < 15 then
        local p = {
            x = math.random() * love.graphics.getWidth(),
            y = love.graphics.getHeight() + 10,
            speed = math.random(15, 40),
            size = math.random(1, 3),
            life = math.random(2, 5),
            maxLife = 5,
            alpha = 1
        }
        p.maxLife = p.life
        table.insert(BG_PARTICLES, p)
    end
end

function BattleBackground.draw(w, h, mapType)
    local bgColors = Theme.colors.battleBg[mapType] or Theme.colors.battleBg.forest
    
    Theme.draw_gradient(0, 0, w, h * 0.6, bgColors.gradient1, bgColors.gradient2, 12)

    love.graphics.setColor(bgColors.ground)
    love.graphics.rectangle("fill", 0, h * 0.6, w, h * 0.4)

    for _, p in ipairs(BG_PARTICLES) do
        love.graphics.setColor(1, 1, 1, p.alpha * 0.15)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
end

function BattleBackground.get_map_type(map)
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
