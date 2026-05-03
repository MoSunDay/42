local PlaceholderAssets = {}

local Theme = require("src.ui.theme")

local PALETTE = {
    bg = {0.102, 0.102, 0.180},
    panel = {0.086, 0.129, 0.243},
    border = {0.271, 0.714, 0.820},
    gold = {0.850, 0.720, 0.300},
    goldBright = {0.950, 0.850, 0.400},
    text = {0.910, 0.910, 0.910},
    textDim = {0.500, 0.500, 0.500},
    accent = {0.914, 0.271, 0.376},
    hp = {0.200, 0.800, 0.300},
    mp = {0.302, 0.502, 0.902},
}

local CHARACTER_COLORS = {
    red_warrior = {0.753, 0.153, 0.173},
    green_ranger = {0.086, 0.627, 0.518},
    yellow_mage = {0.953, 0.773, 0.059},
    purple_assassin = {0.608, 0.200, 0.800},
    cyan_priest = {0.200, 0.800, 0.800},
    orange_knight = {0.902, 0.500, 0.102},
    pink_dancer = {1.000, 0.412, 0.706},
    hero = {0.200, 0.600, 1.000},
}

local NPC_COLORS = {
    village_chief = {0.900, 0.850, 0.700},
    spring_guardian = {0.300, 0.800, 0.400},
    summer_merchant = {0.902, 0.700, 0.200},
    autumn_innkeeper = {0.800, 0.400, 0.200},
    winter_priest = {0.700, 0.800, 0.950},
}

local function save_canvas(canvas, path)
    local data = canvas:newImageData()
    data:encode("png", path)
end

local function draw_face(cx, cy, size, color, hasHat)
    love.graphics.setColor(color)
    love.graphics.circle("fill", cx, cy, size)

    love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", cx, cy, size)

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", cx - size * 0.3, cy - size * 0.15, size * 0.15)
    love.graphics.circle("fill", cx + size * 0.3, cy - size * 0.15, size * 0.15)

    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", cx - size * 0.25, cy - size * 0.15, size * 0.08)
    love.graphics.circle("fill", cx + size * 0.25, cy - size * 0.15, size * 0.08)

    if hasHat then
        love.graphics.setColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)
        love.graphics.polygon("fill",
            cx - size * 0.6, cy - size * 0.8,
            cx, cy - size * 1.5,
            cx + size * 0.6, cy - size * 0.8
        )
    end
end

function PlaceholderAssets.generate_characters()
    local size = 48
    for id, color in pairs(CHARACTER_COLORS) do
        local dirPath = "assets/images/characters/" .. id .. "/rotations"
        love.filesystem.createDirectory(dirPath)

        for _, dir in ipairs({"south", "north", "east", "west",
                              "south-west", "south-east", "north-west", "north-east"}) do
            local canvas = love.graphics.newCanvas(size, size)
            love.graphics.setCanvas(canvas)
            love.graphics.clear(0, 0, 0, 0)

            local cx, cy = size / 2, size / 2 + 4
            local bodyR = 14

            love.graphics.setColor(color[1] * 0.6, color[2] * 0.6, color[3] * 0.6)
            love.graphics.ellipse("fill", cx, cy + 10, bodyR * 0.6, bodyR * 0.3)

            love.graphics.setColor(color)
            love.graphics.ellipse("fill", cx, cy - 2, bodyR * 0.5, bodyR * 0.7)

            local headY = cy - bodyR - 4
            local headR = 8
            local faceOffX = 0
            if dir == "west" or dir == "south-west" or dir == "north-west" then faceOffX = -2 end
            if dir == "east" or dir == "south-east" or dir == "north-east" then faceOffX = 2 end

            love.graphics.setColor(0.95, 0.85, 0.75)
            love.graphics.circle("fill", cx + faceOffX, headY, headR)

            if dir ~= "north" and dir ~= "north-west" and dir ~= "north-east" then
                love.graphics.setColor(0, 0, 0)
                love.graphics.circle("fill", cx + faceOffX - 3, headY - 1, 1.5)
                love.graphics.circle("fill", cx + faceOffX + 3, headY - 1, 1.5)
            end

            love.graphics.setColor(color)
            love.graphics.circle("line", cx + faceOffX, headY, headR + 1)

            love.graphics.setCanvas()
            save_canvas(canvas, dirPath .. "/" .. dir .. ".png")
        end
    end
end

function PlaceholderAssets.generate_npcs()
    local size = 48
    for id, color in pairs(NPC_COLORS) do
        local dirPath = "assets/images/characters/npcs/" .. id .. "/rotations"
        love.filesystem.createDirectory(dirPath)

        for _, dir in ipairs({"south", "north", "east", "west"}) do
            local canvas = love.graphics.newCanvas(size, size)
            love.graphics.setCanvas(canvas)
            love.graphics.clear(0, 0, 0, 0)

            local cx, cy = size / 2, size / 2 + 4

            love.graphics.setColor(color[1] * 0.6, color[2] * 0.6, color[3] * 0.6)
            love.graphics.ellipse("fill", cx, cy + 10, 10, 5)

            love.graphics.setColor(color)
            love.graphics.ellipse("fill", cx, cy - 2, 8, 12)

            local headY = cy - 16
            local faceOffX = 0
            if dir == "west" then faceOffX = -2 end
            if dir == "east" then faceOffX = 2 end

            love.graphics.setColor(0.95, 0.85, 0.75)
            love.graphics.circle("fill", cx + faceOffX, headY, 7)

            if dir ~= "north" then
                love.graphics.setColor(0, 0, 0)
                love.graphics.circle("fill", cx + faceOffX - 2, headY - 1, 1.2)
                love.graphics.circle("fill", cx + faceOffX + 2, headY - 1, 1.2)
            end

            love.graphics.setColor(color)
            love.graphics.circle("line", cx + faceOffX, headY, 8)

            love.graphics.setCanvas()
            save_canvas(canvas, dirPath .. "/" .. dir .. ".png")
        end
    end
end

function PlaceholderAssets.generate_portraits()
    local allIds = {}
    for id, _ in pairs(CHARACTER_COLORS) do table.insert(allIds, id) end
    for id, _ in pairs(NPC_COLORS) do table.insert(allIds, id) end
    local baseIds = {"warrior", "mage", "archer", "rogue", "cleric", "knight", "wizard", "ranger"}
    for _, id in ipairs(baseIds) do table.insert(allIds, id) end

    for _, id in ipairs(allIds) do
        local color = CHARACTER_COLORS[id] or NPC_COLORS[id] or {0.5, 0.5, 0.5}

        local largeCanvas = love.graphics.newCanvas(64, 64)
        love.graphics.setCanvas(largeCanvas)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(color)
        love.graphics.circle("fill", 32, 32, 24)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 24, 26, 4)
        love.graphics.circle("fill", 40, 26, 4)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", 25, 26, 2)
        love.graphics.circle("fill", 41, 26, 2)
        love.graphics.setColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", 32, 32, 25)
        love.graphics.setCanvas()
        love.filesystem.createDirectory("assets/images/portraits/large")
        save_canvas(largeCanvas, "assets/images/portraits/large/" .. id .. ".png")

        local smallCanvas = love.graphics.newCanvas(32, 32)
        love.graphics.setCanvas(smallCanvas)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(color)
        love.graphics.circle("fill", 16, 16, 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 12, 14, 2)
        love.graphics.circle("fill", 20, 14, 2)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", 12, 14, 1)
        love.graphics.circle("fill", 20, 14, 1)
        love.graphics.setColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)
        love.graphics.setLineWidth(1.5)
        love.graphics.circle("line", 16, 16, 13)
        love.graphics.setCanvas()
        love.graphics.setLineWidth(1)
        love.filesystem.createDirectory("assets/images/portraits/small")
        save_canvas(smallCanvas, "assets/images/portraits/small/" .. id .. ".png")
    end
end

function PlaceholderAssets.generate_ui_elements()
    local elements = {
        {dir = "login", file = "login_bg", w = 1280, h = 720,
            draw = function()
                love.graphics.setColor(PALETTE.bg)
                love.graphics.rectangle("fill", 0, 0, 1280, 720)
                Theme.draw_gradient(0, 0, 1280, 360, PALETTE.bg, PALETTE.panel, 12)
                Theme.draw_corner_ornaments(40, 40, 1200, 640, 20)
            end},
        {dir = "login", file = "title_decoration", w = 400, h = 80,
            draw = function()
                Theme.draw_diamond_separator(200, 40, 160)
                Theme.draw_gold_border(10, 10, 380, 60, 2)
            end},
        {dir = "character_select", file = "char_slot_bg", w = 180, h = 240,
            draw = function()
                love.graphics.setColor(PALETTE.panel)
                love.graphics.rectangle("fill", 0, 0, 180, 240, 8)
                Theme.draw_gold_border(2, 2, 176, 236, 2)
                Theme.draw_corner_ornaments(6, 6, 168, 228, 10)
            end},
        {dir = "character_select", file = "char_slot_selected", w = 180, h = 240,
            draw = function()
                love.graphics.setColor(PALETTE.panel)
                love.graphics.rectangle("fill", 0, 0, 180, 240, 8)
                love.graphics.setColor(PALETTE.border)
                love.graphics.rectangle("fill", 0, 0, 180, 240, 8)
                love.graphics.setColor(PALETTE.panel)
                love.graphics.rectangle("fill", 3, 3, 174, 234, 6)
                Theme.draw_gold_border(1, 1, 178, 238, 3)
            end},
        {dir = "chat", file = "chat_bg", w = 350, h = 150,
            draw = function()
                love.graphics.setColor(PALETTE.bg[1], PALETTE.bg[2], PALETTE.bg[3], 0.85)
                love.graphics.rectangle("fill", 0, 0, 350, 150, 6)
                Theme.draw_gold_border(1, 1, 348, 148, 1)
            end},
        {dir = "chat", file = "chat_input_bg", w = 330, h = 30,
            draw = function()
                love.graphics.setColor(PALETTE.panel)
                love.graphics.rectangle("fill", 0, 0, 330, 30, 4)
                love.graphics.setColor(PALETTE.border)
                love.graphics.setLineWidth(1)
                love.graphics.rectangle("line", 0, 0, 330, 30, 4)
            end},
        {dir = "menu", file = "menu_bg", w = 200, h = 250,
            draw = function()
                love.graphics.setColor(PALETTE.panel)
                love.graphics.rectangle("fill", 0, 0, 200, 250, 8)
                Theme.draw_gold_border(2, 2, 196, 246, 2)
                Theme.draw_corner_ornaments(6, 6, 188, 238, 10)
            end},
        {dir = "menu", file = "menu_item_bg", w = 180, h = 40,
            draw = function()
                love.graphics.setColor(PALETTE.panel)
                love.graphics.rectangle("fill", 0, 0, 180, 40, 4)
                love.graphics.setColor(PALETTE.border[1], PALETTE.border[2], PALETTE.border[3], 0.3)
                love.graphics.setLineWidth(1)
                love.graphics.rectangle("line", 0, 0, 180, 40, 4)
            end},
    }

    for _, elem in ipairs(elements) do
        love.filesystem.createDirectory("assets/images/ui/" .. elem.dir)
        local canvas = love.graphics.newCanvas(elem.w, elem.h)
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0, 0, 0, 0)
        elem.draw()
        love.graphics.setCanvas()
        save_canvas(canvas, "assets/images/ui/" .. elem.dir .. "/" .. elem.file .. ".png")
    end
end

function PlaceholderAssets.generate_all()
    PlaceholderAssets.generate_characters()
    PlaceholderAssets.generate_npcs()
    PlaceholderAssets.generate_portraits()
    PlaceholderAssets.generate_ui_elements()
end

return PlaceholderAssets
