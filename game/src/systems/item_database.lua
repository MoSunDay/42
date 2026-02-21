-- item_database.lua - Unified item database
-- Contains all equipment and consumable definitions

local ItemDatabase = {}

ItemDatabase.TYPE = {
    EQUIPMENT = "equipment",
    CONSUMABLE = "consumable"
}

ItemDatabase.SLOTS = {
    WEAPON = "weapon",
    HAT = "hat",
    CLOTHES = "clothes",
    SHOES = "shoes",
    NECKLACE = "necklace"
}

local SLOT_NAMES = {
    weapon = "Weapon",
    hat = "Hat",
    clothes = "Clothes",
    shoes = "Shoes",
    necklace = "Necklace"
}

local DATABASE = {
    -- Weapons (4 tiers)
    wooden_sword = {
        id = "wooden_sword",
        name = "Wooden Sword",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.WEAPON,
        attack = 5, defense = 0, speed = 0, hp = 0,
        crit = 0, eva = 0,
        price = 50,
        tier = 1,
        description = "A simple wooden training sword"
    },
    iron_sword = {
        id = "iron_sword",
        name = "Iron Sword",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.WEAPON,
        attack = 10, defense = 0, speed = 0, hp = 0,
        crit = 2, eva = 0,
        price = 150,
        tier = 1,
        description = "A sturdy iron sword"
    },
    steel_sword = {
        id = "steel_sword",
        name = "Steel Sword",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.WEAPON,
        attack = 18, defense = 0, speed = 1, hp = 0,
        crit = 3, eva = 0,
        price = 350,
        tier = 2,
        description = "A well-crafted steel blade"
    },
    flame_blade = {
        id = "flame_blade",
        name = "Flame Blade",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.WEAPON,
        attack = 25, defense = 0, speed = 0, hp = 0,
        crit = 5, eva = 0,
        price = 600,
        tier = 2,
        description = "A blade imbued with fire"
    },
    assassin_dagger = {
        id = "assassin_dagger",
        name = "Assassin Dagger",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.WEAPON,
        attack = 15, defense = 0, speed = 2, hp = 0,
        crit = 12, eva = 0,
        price = 500,
        tier = 2,
        description = "A deadly dagger for critical strikes"
    },
    dragon_slayer = {
        id = "dragon_slayer",
        name = "Dragon Slayer",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.WEAPON,
        attack = 35, defense = 5, speed = -1, hp = 20,
        crit = 8, eva = 0,
        price = 1200,
        tier = 3,
        description = "A legendary blade forged to slay dragons"
    },
    
    -- Hats (4 tiers)
    straw_hat = {
        id = "straw_hat",
        name = "Straw Hat",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.HAT,
        attack = 0, defense = 2, speed = 0, hp = 0,
        crit = 0, eva = 0,
        price = 30,
        tier = 1,
        description = "A simple straw hat"
    },
    leather_cap = {
        id = "leather_cap",
        name = "Leather Cap",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.HAT,
        attack = 0, defense = 5, speed = 0, hp = 10,
        crit = 0, eva = 1,
        price = 100,
        tier = 1,
        description = "A comfortable leather cap"
    },
    iron_helmet = {
        id = "iron_helmet",
        name = "Iron Helmet",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.HAT,
        attack = 0, defense = 12, speed = -1, hp = 20,
        crit = 0, eva = 0,
        price = 280,
        tier = 2,
        description = "A heavy iron helmet"
    },
    hood_of_shadows = {
        id = "hood_of_shadows",
        name = "Hood of Shadows",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.HAT,
        attack = 0, defense = 4, speed = 1, hp = 0,
        crit = 5, eva = 8,
        price = 450,
        tier = 2,
        description = "A hood that grants stealth"
    },
    crown = {
        id = "crown",
        name = "Crown",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.HAT,
        attack = 5, defense = 10, speed = 0, hp = 50,
        crit = 3, eva = 0,
        price = 800,
        tier = 3,
        description = "A royal crown of power"
    },
    dragon_helm = {
        id = "dragon_helm",
        name = "Dragon Helm",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.HAT,
        attack = 8, defense = 15, speed = 0, hp = 80,
        crit = 5, eva = 2,
        price = 1500,
        tier = 3,
        description = "Helmet forged from dragon scales"
    },
    
    -- Clothes (4 tiers)
    cloth_shirt = {
        id = "cloth_shirt",
        name = "Cloth Shirt",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 0, defense = 3, speed = 0, hp = 0,
        crit = 0, eva = 0,
        price = 40,
        tier = 1,
        description = "Simple cloth clothing"
    },
    leather_vest = {
        id = "leather_vest",
        name = "Leather Vest",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 0, defense = 8, speed = 0, hp = 15,
        crit = 0, eva = 2,
        price = 120,
        tier = 1,
        description = "Light leather protection"
    },
    chain_mail = {
        id = "chain_mail",
        name = "Chain Mail",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 0, defense = 15, speed = -1, hp = 30,
        crit = 0, eva = 0,
        price = 300,
        tier = 2,
        description = "Heavy chain mail armor"
    },
    wizard_robe = {
        id = "wizard_robe",
        name = "Wizard Robe",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 8, defense = 6, speed = 1, hp = 20,
        crit = 5, eva = 2,
        price = 450,
        tier = 2,
        description = "A mystical robe that enhances magic"
    },
    shadow_cloak = {
        id = "shadow_cloak",
        name = "Shadow Cloak",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 0, defense = 8, speed = 2, hp = 10,
        crit = 3, eva = 12,
        price = 600,
        tier = 2,
        description = "A cloak woven from shadows"
    },
    plate_armor = {
        id = "plate_armor",
        name = "Plate Armor",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 0, defense = 25, speed = -2, hp = 60,
        crit = 0, eva = 0,
        price = 900,
        tier = 3,
        description = "Full plate armor, very heavy"
    },
    dragon_armor = {
        id = "dragon_armor",
        name = "Dragon Armor",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.CLOTHES,
        attack = 5, defense = 20, speed = 0, hp = 100,
        crit = 3, eva = 3,
        price = 2000,
        tier = 3,
        description = "Legendary armor of dragon knights"
    },
    
    -- Shoes (4 tiers)
    sandals = {
        id = "sandals",
        name = "Sandals",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.SHOES,
        attack = 0, defense = 1, speed = 1, hp = 0,
        crit = 0, eva = 0,
        price = 25,
        tier = 1,
        description = "Light footwear"
    },
    leather_boots = {
        id = "leather_boots",
        name = "Leather Boots",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.SHOES,
        attack = 0, defense = 3, speed = 2, hp = 5,
        crit = 0, eva = 2,
        price = 90,
        tier = 1,
        description = "Sturdy leather boots"
    },
    iron_boots = {
        id = "iron_boots",
        name = "Iron Boots",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.SHOES,
        attack = 0, defense = 8, speed = -1, hp = 15,
        crit = 0, eva = 0,
        price = 220,
        tier = 2,
        description = "Heavy iron boots"
    },
    winged_boots = {
        id = "winged_boots",
        name = "Winged Boots",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.SHOES,
        attack = 2, defense = 2, speed = 5, hp = 0,
        crit = 2, eva = 5,
        price = 550,
        tier = 2,
        description = "Boots blessed with flight"
    },
    shadow_step = {
        id = "shadow_step",
        name = "Shadow Step",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.SHOES,
        attack = 0, defense = 3, speed = 4, hp = 0,
        crit = 5, eva = 10,
        price = 700,
        tier = 2,
        description = "Boots that grant supernatural agility"
    },
    greaves_of_might = {
        id = "greaves_of_might",
        name = "Greaves of Might",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.SHOES,
        attack = 3, defense = 12, speed = 0, hp = 30,
        crit = 2, eva = 0,
        price = 1000,
        tier = 3,
        description = "Powerful greaves of the paladin"
    },
    
    -- Necklaces (3 tiers + 2 special)
    copper_necklace = {
        id = "copper_necklace",
        name = "Copper Necklace",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.NECKLACE,
        attack = 2, defense = 2, speed = 0, hp = 10,
        crit = 1, eva = 0,
        price = 100,
        tier = 1,
        description = "A simple copper necklace"
    },
    silver_necklace = {
        id = "silver_necklace",
        name = "Silver Necklace",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.NECKLACE,
        attack = 4, defense = 4, speed = 1, hp = 25,
        crit = 2, eva = 1,
        price = 250,
        tier = 2,
        description = "A shiny silver necklace"
    },
    gold_necklace = {
        id = "gold_necklace",
        name = "Gold Necklace",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.NECKLACE,
        attack = 6, defense = 6, speed = 2, hp = 40,
        crit = 3, eva = 2,
        price = 600,
        tier = 2,
        description = "A precious gold necklace"
    },
    lucky_charm = {
        id = "lucky_charm",
        name = "Lucky Charm",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.NECKLACE,
        attack = 0, defense = 0, speed = 0, hp = 0,
        crit = 15, eva = 5,
        price = 800,
        tier = 2,
        description = "A charm that brings good fortune"
    },
    dragon_heart = {
        id = "dragon_heart",
        name = "Dragon Heart",
        type = ItemDatabase.TYPE.EQUIPMENT,
        slot = ItemDatabase.SLOTS.NECKLACE,
        attack = 10, defense = 10, speed = 3, hp = 80,
        crit = 8, eva = 5,
        price = 2500,
        tier = 3,
        description = "The heart of an ancient dragon"
    },
    
    -- Consumables
    health_potion = {
        id = "health_potion",
        name = "Health Potion",
        type = ItemDatabase.TYPE.CONSUMABLE,
        effect = "heal",
        value = 50,
        price = 25,
        description = "Restores 50 HP"
    },
    large_health_potion = {
        id = "large_health_potion",
        name = "Large Health Potion",
        type = ItemDatabase.TYPE.CONSUMABLE,
        effect = "heal",
        value = 150,
        price = 60,
        description = "Restores 150 HP"
    },
    full_restore = {
        id = "full_restore",
        name = "Full Restore",
        type = ItemDatabase.TYPE.CONSUMABLE,
        effect = "full_heal",
        value = 0,
        price = 150,
        description = "Fully restores HP"
    },
    antidote = {
        id = "antidote",
        name = "Antidote",
        type = ItemDatabase.TYPE.CONSUMABLE,
        effect = "cure_poison",
        value = 0,
        price = 20,
        description = "Cures poison status"
    },
    mystery_potion = {
        id = "mystery_potion",
        name = "Mystery Potion",
        type = ItemDatabase.TYPE.CONSUMABLE,
        effect = "random",
        value = 0,
        price = 40,
        description = "Random effect when used"
    },
    elixir_of_power = {
        id = "elixir_of_power",
        name = "Elixir of Power",
        type = ItemDatabase.TYPE.CONSUMABLE,
        effect = "temp_atk",
        value = 10,
        duration = 3,
        price = 100,
        description = "Temporarily boosts ATK by 10 for 3 turns"
    }
}

function ItemDatabase.getItem(itemId)
    return DATABASE[itemId]
end

function ItemDatabase.getEquipmentBySlot(slot)
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.EQUIPMENT and item.slot == slot then
            table.insert(items, item)
        end
    end
    table.sort(items, function(a, b) return (a.price or 0) < (b.price or 0) end)
    return items
end

function ItemDatabase.getConsumables()
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.CONSUMABLE then
            table.insert(items, item)
        end
    end
    table.sort(items, function(a, b) return (a.price or 0) < (b.price or 0) end)
    return items
end

function ItemDatabase.getAllEquipment()
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.EQUIPMENT then
            table.insert(items, item)
        end
    end
    return items
end

function ItemDatabase.getSlotName(slot)
    return SLOT_NAMES[slot] or slot
end

function ItemDatabase.isEquipment(itemId)
    local item = DATABASE[itemId]
    return item and item.type == ItemDatabase.TYPE.EQUIPMENT
end

function ItemDatabase.isConsumable(itemId)
    local item = DATABASE[itemId]
    return item and item.type == ItemDatabase.TYPE.CONSUMABLE
end

function ItemDatabase.getEquipmentByTier(tier)
    local items = {}
    for id, item in pairs(DATABASE) do
        if item.type == ItemDatabase.TYPE.EQUIPMENT and item.tier == tier then
            table.insert(items, item)
        end
    end
    table.sort(items, function(a, b) return (a.price or 0) < (b.price or 0) end)
    return items
end

return ItemDatabase
