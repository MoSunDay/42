-- map_generator.lua - Procedural Map Generator
-- 程序化地图生成器

local MapGenerator = {}

local THEMES = {
    forest = {
        season = "spring",
        bgColor = {0.25, 0.55, 0.25},
        buildingColors = {
            {0.6, 0.5, 0.3}, {0.5, 0.6, 0.4}, {0.7, 0.6, 0.4},
            {0.4, 0.5, 0.3}, {0.8, 0.7, 0.5}
        },
        monsters = {"slime", "wolf", "goblin"},
        buildingTypes = {"hut", "cabin", "treehouse", "shrine"}
    },
    desert = {
        season = "desert",
        bgColor = {0.85, 0.75, 0.50},
        buildingColors = {
            {0.9, 0.8, 0.6}, {0.8, 0.7, 0.5}, {0.7, 0.6, 0.4},
            {0.95, 0.85, 0.65}
        },
        monsters = {"scorpion", "sandworm", "mummy"},
        buildingTypes = {"tent", "ruins", "oasis", "pyramid"}
    },
    snow = {
        season = "winter",
        bgColor = {0.85, 0.90, 0.95},
        buildingColors = {
            {0.7, 0.8, 0.9}, {0.8, 0.85, 0.9}, {0.6, 0.7, 0.8},
            {0.9, 0.9, 0.95}
        },
        monsters = {"icewolf", "yeti", "frostgiant"},
        buildingTypes = {"igloo", "cabin", "tower", "shrine"}
    },
    volcanic = {
        season = "volcanic",
        bgColor = {0.25, 0.15, 0.12},
        buildingColors = {
            {0.4, 0.3, 0.2}, {0.5, 0.3, 0.2}, {0.3, 0.25, 0.2},
            {0.6, 0.4, 0.3}
        },
        monsters = {"firebat", "lava elemental", "demon"},
        buildingTypes = {"forge", "ruins", "tower", "shrine"}
    },
    cave = {
        season = "underwater",
        bgColor = {0.15, 0.25, 0.35},
        buildingColors = {
            {0.4, 0.45, 0.5}, {0.5, 0.5, 0.55}, {0.3, 0.35, 0.4},
            {0.45, 0.5, 0.55}
        },
        monsters = {"bat", "spider", "rockgolem"},
        buildingTypes = {"camp", "ruins", "mineshaft", "shrine"}
    },
    sky = {
        season = "sky",
        bgColor = {0.90, 0.92, 0.98},
        buildingColors = {
            {0.95, 0.95, 1.0}, {0.9, 0.9, 0.95}, {0.85, 0.88, 0.95},
            {1.0, 0.98, 0.95}
        },
        monsters = {"harpy", "cloudspirit", "angel"},
        buildingTypes = {"temple", "pagoda", "garden", "shrine"}
    },
    swamp = {
        season = "autumn",
        bgColor = {0.35, 0.45, 0.35},
        buildingColors = {
            {0.5, 0.45, 0.35}, {0.4, 0.5, 0.4}, {0.45, 0.4, 0.35},
            {0.55, 0.5, 0.4}
        },
        monsters = {"swampcreature", "mosquito", "troll"},
        buildingTypes = {"hut", "dock", "ruins", "shrine"}
    },
    crystal = {
        season = "underwater",
        bgColor = {0.2, 0.3, 0.5},
        buildingColors = {
            {0.6, 0.7, 0.9}, {0.5, 0.6, 0.8}, {0.7, 0.75, 0.9},
            {0.55, 0.65, 0.85}
        },
        monsters = {"crystalgolem", "elemental", "shadow"},
        buildingTypes = {"crystal", "ruins", "tower", "shrine"}
    },
    ruins = {
        season = "summer",
        bgColor = {0.5, 0.48, 0.45},
        buildingColors = {
            {0.6, 0.55, 0.5}, {0.5, 0.5, 0.45}, {0.55, 0.52, 0.48},
            {0.65, 0.6, 0.55}
        },
        monsters = {"skeleton", "ghost", "cursewarrior"},
        buildingTypes = {"ruins", "pillar", "temple", "tomb"}
    },
    mystical = {
        season = "sky",
        bgColor = {0.15, 0.1, 0.25},
        buildingColors = {
            {0.6, 0.5, 0.8}, {0.5, 0.6, 0.7}, {0.7, 0.5, 0.6},
            {0.4, 0.6, 0.8}
        },
        monsters = {"voidcreature", "phantom", "eldritch"},
        buildingTypes = {"portal", "obelisk", "temple", "shrine"}
    }
}

local BUILDING_TEMPLATES = {
    hut = {width = 100, height = 100},
    cabin = {width = 140, height = 120},
    treehouse = {width = 120, height = 140},
    shrine = {width = 80, height = 80},
    temple = {width = 200, height = 180},
    pagoda = {width = 150, height = 200},
    tower = {width = 80, height = 160},
    ruins = {width = 160, height = 140},
    shop = {width = 120, height = 100},
    inn = {width = 180, height = 140},
    tent = {width = 80, height = 80},
    igloo = {width = 100, height = 80},
    forge = {width = 140, height = 120},
    crystal = {width = 100, height = 120},
    portal = {width = 120, height = 120},
    obelisk = {width = 60, height = 180},
    pillar = {width = 40, height = 40},
    garden = {width = 200, height = 200},
    pyramid = {width = 200, height = 200},
    oasis = {width = 150, height = 150},
    camp = {width = 100, height = 100},
    mineshaft = {width = 80, height = 120},
    dock = {width = 120, height = 80},
    tomb = {width = 140, height = 160}
}

local function randomInRange(min, max)
    return math.random() * (max - min) + min
end

local function checkOverlap(x, y, w, h, existing, padding)
    padding = padding or 50
    for _, obj in ipairs(existing) do
        if not (x + w + padding < obj.x or x > obj.x + obj.width + padding or
                y + h + padding < obj.y or y > obj.y + obj.height + padding) then
            return true
        end
    end
    return false
end

local function generateBuildings(theme, mapWidth, mapHeight, count)
    local buildings = {}
    local themeData = THEMES[theme]
    local bTypes = themeData.buildingTypes
    local bColors = themeData.buildingColors

    for i = 1, count do
        local bType = bTypes[math.random(#bTypes)]
        local template = BUILDING_TEMPLATES[bType] or {width = 100, height = 100}
        local color = bColors[math.random(#bColors)]

        local x, y, attempts = 0, 0, 0
        local maxAttempts = 50

        repeat
            x = math.random(150, mapWidth - template.width - 150)
            y = math.random(150, mapHeight - template.height - 150)
            attempts = attempts + 1
        until not checkOverlap(x, y, template.width, template.height, buildings, 80) or attempts >= maxAttempts

        if attempts < maxAttempts then
            table.insert(buildings, {
                type = bType,
                x = x,
                y = y,
                width = template.width,
                height = template.height,
                color = color,
                name = bType:gsub("^%l", string.upper) .. " " .. i
            })
        end
    end

    return buildings
end

local function generateEncounterZones(theme, mapWidth, mapHeight, count, level)
    local zones = {}
    local themeData = THEMES[theme]
    local monsters = themeData.monsters

    for i = 1, count do
        local x = math.random(200, mapWidth - 200)
        local y = math.random(200, mapHeight - 200)
        local radius = math.random(80, 150)

        table.insert(zones, {
            x = x,
            y = y,
            radius = radius,
            type = theme,
            level = level,
            monsters = monsters
        })
    end

    return zones
end

local function generateSpawnPoints(mapWidth, mapHeight, count)
    local spawns = {}

    table.insert(spawns, {
        x = mapWidth / 2,
        y = mapHeight / 2,
        name = "Center Spawn"
    })

    for i = 2, count do
        local angle = (i - 1) * (2 * math.pi / (count - 1))
        local dist = math.min(mapWidth, mapHeight) * 0.3
        table.insert(spawns, {
            x = mapWidth / 2 + math.cos(angle) * dist,
            y = mapHeight / 2 + math.sin(angle) * dist,
            name = "Spawn Point " .. i
        })
    end

    return spawns
end

local function generateCollisionMap(mapWidth, mapHeight, tileSize)
    local tilesX = math.floor(mapWidth / tileSize)
    local tilesY = math.floor(mapHeight / tileSize)
    local collisionMap = {}

    for y = 0, tilesY - 1 do
        collisionMap[y] = {}
        for x = 0, tilesX - 1 do
            if x == 0 or x == tilesX - 1 or y == 0 or y == tilesY - 1 then
                collisionMap[y][x] = 1
            else
                collisionMap[y][x] = 0
            end
        end
    end

    return collisionMap
end

function MapGenerator.generate(config)
    local theme = config.theme or "forest"
    local themeData = THEMES[theme]
    if not themeData then
        themeData = THEMES.forest
    end

    local minTiles = config.minTiles or 30
    local maxTiles = config.maxTiles or 60
    local tilesX = math.random(minTiles, maxTiles)
    local tilesY = math.random(minTiles, maxTiles)
    local tileSize = config.tileSize or 64

    local mapWidth = tilesX * tileSize
    local mapHeight = tilesY * tileSize

    local buildingCount = math.random(5, 8)
    local encounterCount = math.random(4, 6)
    local spawnCount = math.random(2, 3)

    local map = {
        id = config.id or "generated_map",
        name = config.name or "Generated Map",
        width = mapWidth,
        height = mapHeight,
        tileSize = tileSize,
        season = themeData.season,
        backgroundColor = themeData.bgColor,

        buildings = generateBuildings(theme, mapWidth, mapHeight, buildingCount),
        encounterZones = generateEncounterZones(theme, mapWidth, mapHeight, encounterCount, config.level or 1),
        spawnPoints = generateSpawnPoints(mapWidth, mapHeight, spawnCount),
        collisionMap = generateCollisionMap(mapWidth, mapHeight, tileSize),

        npcs = {},
        objects = {},
        layers = {
            ground = {}
        },

        metadata = {
            theme = theme,
            level = config.level or 1,
            generated = true
        }
    }

    if config.includeTeleporter ~= false then
        table.insert(map.npcs, {
            id = "teleporter",
            type = "teleporter",
            name = "Dimensional Guide",
            x = mapWidth / 2,
            y = mapHeight / 2 - 100,
            dialogue = "I can guide you to other realms. Where would you like to go?"
        })
    end

    return map
end

function MapGenerator.getThemes()
    local themes = {}
    for name, _ in pairs(THEMES) do
        table.insert(themes, name)
    end
    return themes
end

function MapGenerator.getThemeData(theme)
    return THEMES[theme]
end

return MapGenerator
