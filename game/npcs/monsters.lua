-- monsters.lua - Monster definitions by theme
-- 怪物定义

local MONSTERS = {}

local function M(id, name, hp, atk, def, spd, exp, gold, color, size, aggr, chase, drops)
    return {
        type = "monster",
        name = name,
        description = id:gsub("_", " "):gsub("(%a)(%S*)", function(a,b) return string.upper(a)..b end),
        hp = hp, maxHp = hp,
        attack = atk, defense = def, speed = spd,
        exp = exp, gold = gold,
        color = color, size = size or 18,
        aggressive = aggr, chaseRange = chase,
        dropTable = drops
    }
end

MONSTERS.BASIC = {
    slime = M("slime", "Slime", 30, 5, 2, 3, 10, 5, {0.2, 0.8, 0.3}, 18, false, nil,
        {{item = "Slime Gel", chance = 0.5}, {item = "Small Potion", chance = 0.2}}),
    goblin = M("goblin", "Goblin", 50, 8, 3, 5, 20, 10, {0.6, 0.4, 0.2}, 18, true, 150,
        {{item = "Goblin Ear", chance = 0.4}, {item = "Rusty Dagger", chance = 0.15}}),
    skeleton = M("skeleton", "Skeleton", 40, 10, 1, 4, 15, 8, {0.9, 0.9, 0.9}, 18, true, 120,
        {{item = "Bone", chance = 0.6}, {item = "Old Sword", chance = 0.1}}),
    orc = M("orc", "Orc", 80, 12, 5, 3, 35, 20, {0.4, 0.6, 0.3}, 22, true, 200,
        {{item = "Orc Tusk", chance = 0.3}, {item = "Iron Axe", chance = 0.12}}),
    wolf = M("wolf", "Wolf", 45, 9, 2, 7, 18, 6, {0.5, 0.5, 0.5}, 18, true, 250,
        {{item = "Wolf Pelt", chance = 0.5}, {item = "Sharp Fang", chance = 0.3}}),
    bat = M("bat", "Bat", 25, 6, 1, 8, 12, 4, {0.3, 0.2, 0.3}, 15, false, nil,
        {{item = "Bat Wing", chance = 0.4}}),
}

MONSTERS.DESERT = {
    scorpion = M("scorpion", "Scorpion", 55, 12, 4, 5, 25, 12, {0.7, 0.5, 0.2}, 18, true, 150,
        {{item = "Scorpion Sting", chance = 0.4}, {item = "Venom Sac", chance = 0.2}}),
    sandworm = M("sandworm", "Sandworm", 80, 15, 6, 4, 40, 25, {0.8, 0.7, 0.4}, 24, true, 200,
        {{item = "Worm Scale", chance = 0.5}, {item = "Desert Crystal", chance = 0.15}}),
    mummy = M("mummy", "Mummy", 70, 14, 8, 3, 35, 30, {0.6, 0.5, 0.3}, 20, true, 120,
        {{item = "Ancient Bandage", chance = 0.5}, {item = "Cursed Ring", chance = 0.1}}),
}

MONSTERS.SNOW = {
    icewolf = M("icewolf", "Ice Wolf", 60, 12, 4, 7, 30, 15, {0.7, 0.8, 0.9}, 19, true, 250,
        {{item = "Ice Fang", chance = 0.4}, {item = "Frost Pelt", chance = 0.3}}),
    yeti = M("yeti", "Yeti", 120, 20, 10, 4, 60, 40, {0.9, 0.9, 0.95}, 28, true, 180,
        {{item = "Yeti Fur", chance = 0.4}, {item = "Frozen Heart", chance = 0.1}}),
    frostgiant = M("frostgiant", "Frost Giant", 180, 25, 15, 3, 100, 80, {0.6, 0.7, 0.85}, 32, true, 200,
        {{item = "Giant's Ice Shard", chance = 0.3}, {item = "Frost Hammer", chance = 0.1}}),
}

MONSTERS.VOLCANIC = {
    firebat = M("firebat", "Fire Bat", 40, 10, 2, 9, 20, 10, {0.9, 0.3, 0.1}, 16, true, 180,
        {{item = "Fire Wing", chance = 0.4}, {item = "Ember", chance = 0.3}}),
    ["lava elemental"] = M("lava elemental", "Lava Elemental", 100, 22, 12, 3, 55, 35, {0.9, 0.4, 0.1}, 24, true, 150,
        {{item = "Molten Core", chance = 0.3}, {item = "Fire Essence", chance = 0.2}}),
    demon = M("demon", "Demon", 150, 28, 14, 5, 80, 60, {0.6, 0.1, 0.1}, 26, true, 250,
        {{item = "Demon Horn", chance = 0.3}, {item = "Dark Essence", chance = 0.15}}),
}

MONSTERS.CAVE = {
    spider = M("spider", "Cave Spider", 45, 11, 3, 6, 22, 11, {0.3, 0.3, 0.3}, 17, true, 160,
        {{item = "Spider Silk", chance = 0.5}, {item = "Venom Gland", chance = 0.2}}),
    rockgolem = M("rockgolem", "Rock Golem", 130, 18, 20, 2, 50, 30, {0.5, 0.5, 0.5}, 26, false, nil,
        {{item = "Stone Core", chance = 0.4}, {item = "Rare Ore", chance = 0.15}}),
}

MONSTERS.SKY = {
    harpy = M("harpy", "Harpy", 70, 16, 5, 8, 38, 22, {0.8, 0.7, 0.6}, 20, true, 280,
        {{item = "Harpy Feather", chance = 0.5}, {item = "Wind Crystal", chance = 0.15}}),
    cloudspirit = M("cloudspirit", "Cloud Spirit", 55, 14, 3, 7, 32, 18, {0.9, 0.92, 0.98}, 22, false, nil,
        {{item = "Mist Essence", chance = 0.4}, {item = "Cloud Fragment", chance = 0.2}}),
    angel = M("angel", "Fallen Angel", 160, 26, 12, 6, 90, 70, {0.9, 0.85, 0.7}, 24, true, 200,
        {{item = "Angel Feather", chance = 0.3}, {item = "Celestial Blade", chance = 0.08}}),
}

MONSTERS.SWAMP = {
    swampcreature = M("swampcreature", "Swamp Creature", 75, 15, 8, 3, 35, 20, {0.4, 0.5, 0.3}, 22, true, 140,
        {{item = "Swamp Mud", chance = 0.5}, {item = "Decayed Essence", chance = 0.2}}),
    mosquito = M("mosquito", "Giant Mosquito", 35, 8, 1, 9, 18, 8, {0.3, 0.2, 0.2}, 14, true, 200,
        {{item = "Mosquito Proboscis", chance = 0.4}, {item = "Insect Wing", chance = 0.3}}),
    troll = M("troll", "Swamp Troll", 140, 22, 10, 4, 70, 45, {0.4, 0.5, 0.35}, 28, true, 180,
        {{item = "Troll Blood", chance = 0.4}, {item = "Regeneration Ring", chance = 0.1}}),
}

MONSTERS.CRYSTAL = {
    crystalgolem = M("crystalgolem", "Crystal Golem", 120, 20, 18, 2, 60, 40, {0.6, 0.7, 0.9}, 26, false, nil,
        {{item = "Crystal Shard", chance = 0.5}, {item = "Prismatic Gem", chance = 0.15}}),
    elemental = M("elemental", "Elemental", 90, 24, 6, 5, 50, 35, {0.5, 0.8, 0.9}, 22, true, 170,
        {{item = "Elemental Core", chance = 0.3}, {item = "Energy Essence", chance = 0.25}}),
    shadow = M("shadow", "Shadow", 65, 18, 2, 8, 40, 25, {0.1, 0.1, 0.15}, 20, true, 220,
        {{item = "Shadow Essence", chance = 0.4}, {item = "Dark Crystal", chance = 0.2}}),
}

MONSTERS.RUINS = {
    ghost = M("ghost", "Ghost", 50, 14, 1, 6, 30, 18, {0.7, 0.8, 0.9, 0.6}, 19, true, 200,
        {{item = "Ectoplasm", chance = 0.5}, {item = "Spirit Orb", chance = 0.15}}),
    cursewarrior = M("cursewarrior", "Cursed Warrior", 110, 24, 14, 4, 65, 50, {0.3, 0.3, 0.35}, 24, true, 160,
        {{item = "Cursed Armor", chance = 0.2}, {item = "Ancient Blade", chance = 0.1}}),
}

MONSTERS.MYSTICAL = {
    voidcreature = M("voidcreature", "Void Creature", 100, 28, 8, 7, 70, 55, {0.2, 0.1, 0.3}, 24, true, 250,
        {{item = "Void Essence", chance = 0.3}, {item = "Dimensional Shard", chance = 0.15}}),
    phantom = M("phantom", "Phantom", 80, 22, 3, 8, 55, 40, {0.6, 0.4, 0.8, 0.5}, 22, true, 230,
        {{item = "Phantom Dust", chance = 0.4}, {item = "Illusion Gem", chance = 0.2}}),
    eldritch = M("eldritch", "Eldritch Horror", 200, 35, 15, 5, 120, 100, {0.2, 0.4, 0.3}, 30, true, 280,
        {{item = "Eldritch Fragment", chance = 0.3}, {item = "Madness Essence", chance = 0.2}}),
}

function MONSTERS.getAll()
    local all = {}
    for _, group in pairs(MONSTERS) do
        if type(group) == "table" then
            for id, data in pairs(group) do
                all[id] = data
            end
        end
    end
    return all
end

function MONSTERS.getByTheme(theme)
    return MONSTERS[theme:upper()] or {}
end

return MONSTERS
