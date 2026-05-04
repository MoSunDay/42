local Player = require("entities.player")
local Map = require("entities.map")
local MapManager = require("map.map_manager")
local Camera = require("core.camera")
local EncounterZone = require("entities.encounter_zone")
local BattleSystem = require("src.systems.battle.battle_system")
local AudioSystem = require("systems.audio_system")
local EquipmentSystem = require("systems.equipment_system")
local InventorySystem = require("src.systems.inventory_system")
local PartySystem = require("src.systems.party_system")
local ChatSystem = require("src.systems.chat_system")
local CollisionSystem = require("src.systems.collision_system")
local NetworkManager = require("src.network.network_manager")
local LoginUI = require("account.login_ui")
local CharacterSelectUI = require("account.character_select_ui")
local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")
local CompanionSystem = require("src.systems.companion_system")
local SkillPanel = require("src.ui.skill_panel")
local NPCManager = require("npcs.npc_manager")
local DialogUI = require("src.ui.dialog_ui")
local ShopUI = require("src.ui.shop_ui")
local RewardUI = require("src.ui.battle.reward_ui")
local DeathScreen = require("src.ui.death_screen")

local GameState = {}

local GAME_MODE = {
    LOGIN = "login",
    CHARACTER_SELECT = "character_select",
    EXPLORATION = "exploration",
    BATTLE = "battle"
}

local USE_NETWORK = true
local SERVER_HOST = "127.0.0.1"
local SERVER_PORT = 9000

function GameState.create(assetManager)
    local state = {}

    state.assetManager = assetManager

    state.mode = GAME_MODE.LOGIN

    state.network = NetworkManager.create()

    if USE_NETWORK then
        NetworkManager.connect(state.network, SERVER_HOST, SERVER_PORT)
    end

    state.loginUI = LoginUI.create(assetManager)
    LoginUI.set_network(state.loginUI, state.network)
    LoginUI.on_login(state.loginUI, function(characters, username)
        state.currentUsername = username
        state.mode = GAME_MODE.CHARACTER_SELECT
        CharacterSelectUI.set_characters(state.characterSelectUI, characters)
        CharacterSelectUI.set_network(state.characterSelectUI, state.network)
    end)

    state.characterSelectUI = CharacterSelectUI.create(assetManager)
    CharacterSelectUI.on_character_selected(state.characterSelectUI, function(character)
        NetworkManager.set_character(state.network, character)
        GameState.initialize_world(state, character)
    end)

    state.currentUsername = nil

    state.skillPanel = SkillPanel.create(assetManager)
    state.dialogUI = DialogUI.create(assetManager)
    state.shopUI = ShopUI.create(assetManager)
    state.rewardUI = RewardUI.create(assetManager)
    state.deathScreen = DeathScreen.create(assetManager)
    state.npcManager = NPCManager.create()

    state.map = nil
    state.player = nil
    state.camera = nil
    state.encounterZones = nil
    state.audioSystem = nil
    state.battleSystem = nil
    state.pendingBattleResult = nil

    state.time = 0

    return setmetatable(state, { __index = GameState })
end

function GameState.initialize_world(state, character)
    print("Initializing game world for: " .. character.characterName)

    local mapId = character.mapId or "newbie_village"
    local mapData = MapManager.load_map(mapId)

    if mapData then
        state.map = mapData
        print("Loaded map: " .. mapData.name .. " (" .. mapData.width .. "x" .. mapData.height .. ")")
    else
        print("Failed to load map '" .. mapId .. "', using fallback map")
        state.map = Map.create(2000, 2000)
    end

    local AnimationManager = require("src.animations.animation_manager")
    state.animationManager = AnimationManager.create()

    NPCManager.set_animation_manager(state.npcManager, state.animationManager)
    NPCManager.set_asset_manager(state.npcManager, state.assetManager)

    state.player = Player.create(character.x, character.y, state.assetManager)
    Player.set_animation_manager(state.player, state.animationManager)

    Player.set_appearance(state.player, character)

    state.equipmentSystem = EquipmentSystem.create()
    if character.equipment then
        EquipmentSystem.deserialize(state.equipmentSystem, character.equipment)
    end
    Player.set_equipment_system(state.player, state.equipmentSystem)

    state.inventorySystem = InventorySystem.create()
    if character.inventory then
        InventorySystem.deserialize(state.inventorySystem, character.inventory)
    else
        InventorySystem.add_item(state.inventorySystem, "health_potion")
        InventorySystem.add_item(state.inventorySystem, "health_potion")
        InventorySystem.add_item(state.inventorySystem, "large_health_potion")
        InventorySystem.add_item(state.inventorySystem, "antidote")
        InventorySystem.add_item(state.inventorySystem, "iron_sword")
        InventorySystem.add_item(state.inventorySystem, "leather_cap")
        InventorySystem.add_item(state.inventorySystem, "leather_vest")
        InventorySystem.add_item(state.inventorySystem, "leather_boots")
        InventorySystem.add_item(state.inventorySystem, "copper_necklace")
    end

    state.player.baseHp = character.maxHp
    state.player.maxHp = character.maxHp
    state.player.hp = character.hp
    state.player.baseAttack = character.attack
    state.player.baseDefense = character.defense
    Player.update_stats_with_equipment(state.player)

    if character.maxMp then
        state.player.maxMp = character.maxMp
        state.player.mp = character.mp or character.maxMp
    end
    if character.magicAttack then
        state.player.baseMagicAttack = character.magicAttack
        state.player.magicAttack = character.magicAttack
    end
    if character.classId then
        state.player.classId = character.classId
    end
    if character.skills then
        state.player.skills = character.skills
    end
    if character.skillCrystals then
        state.player.skillCrystals = character.skillCrystals
    end
    if character.critBonus then
        state.player.critBonus = character.critBonus
    end

    state.spiritCrystalSystem = SpiritCrystalSystem.create()
    if character.spiritCrystals then
        SpiritCrystalSystem.deserialize(state.spiritCrystalSystem, character.spiritCrystals)
    end
    EquipmentSystem.set_spirit_crystal_system(state.equipmentSystem, state.spiritCrystalSystem)

    state.companionSystem = CompanionSystem.create()
    if character.companions then
        local ItemDatabase = require("src.systems.item_database")
        state.companionSystem:deserialize(character.companions, ItemDatabase)
    end

    Player.set_map_bounds(state.player, state.map.width, state.map.height)

    state.collisionSystem = CollisionSystem.create(state.map)
    Player.set_collision_system(state.player, state.collisionSystem)

    if not CollisionSystem.is_walkable(state.collisionSystem, state.player.x, state.player.y) then
        print("Warning: Player spawned in non-walkable area, finding valid position...")
        local validX, validY = CollisionSystem.get_valid_position(
            state.collisionSystem, state.player.x, state.player.y, state.player.collisionRadius
        )
        state.player.x = validX
        state.player.y = validY
        state.player.targetX = validX
        state.player.targetY = validY
        print(string.format("Player position corrected to: (%.0f, %.0f)", validX, validY))

        character.x = validX
        character.y = validY
    end

    state.camera = Camera.create()

    if state.map and state.map.npcs then
        for _, npcDef in ipairs(state.map.npcs) do
            local npcType = npcDef.id or npcDef.type or "town_guard"
            local NPCDatabase = require("npcs.npc_database")
            local template = NPCDatabase.get_npc_data(npcType)
            if not template and npcDef.type then
                template = NPCDatabase.get_npc_data(npcDef.type)
            end
            if template then
                NPCManager.spawn_npc(state.npcManager, npcType, npcDef.x, npcDef.y)
            else
                local npc = {
                    id = state.npcManager.nextId,
                    type = npcType,
                    x = npcDef.x,
                    y = npcDef.y,
                    npcType = npcDef.type or "friendly",
                    name = npcDef.name or "NPC",
                    description = "",
                    color = {0.5, 0.5, 0.5},
                    size = 20,
                    canTalk = true,
                    canTrade = false,
                    dialogue = npcDef.dialogue or "...",
                    is_alive = true,
                    isChasing = false,
                    targetX = npcDef.x,
                    targetY = npcDef.y,
                    animationId = "npc_" .. state.npcManager.nextId,
                }
                state.npcManager.npcs[state.npcManager.nextId] = npc
                state.npcManager.nextId = state.npcManager.nextId + 1
            end
        end
        print("Spawned " .. #(state.map.npcs) .. " NPCs from map data")
    end

    state.encounterZones = {}
    GameState.generate_encounter_zones(state, 20)

    state.audioSystem = AudioSystem.create()
    AudioSystem.play_bgm(state.audioSystem, "exploration")

    state.battleSystem = BattleSystem.create(state.player, state.audioSystem, state.animationManager, state.assetManager, state.companionSystem)

    state.partySystem = PartySystem.create()
    state.partySystem:setPartyName("My Party")

    local playerMember = PartySystem.create_member_data(
        character.id or "player1",
        character.characterName,
        character.hp,
        character.maxHp,
        character.avatarColor
    )
    state.partySystem:add_member(playerMember)

    state.chatSystem = ChatSystem.create()

    state.chatSystem:add_message("System", "Welcome to the game!", {0.4, 0.8, 1.0})

    state.mode = GAME_MODE.EXPLORATION

    state.encounterSafeTimer = 3.0

    print("Game world initialized!")
end

function GameState.update(state, dt)
    state.time = state.time + dt

    if state.mode == GAME_MODE.LOGIN then
        LoginUI.update(state.loginUI, dt)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
    elseif state.mode == GAME_MODE.EXPLORATION then
        DialogUI.update(state.dialogUI, dt)
        ShopUI.update(state.shopUI, dt)

        if not DialogUI.is_open(state.dialogUI) and not ShopUI.is_open(state.shopUI) then
            Player.update(state.player, dt)
        end

        Camera.follow(state.camera, state.player.x, state.player.y, dt)

        if state.npcManager then
            NPCManager.update(state.npcManager, dt, state.player.x, state.player.y)
        end

        for _, zone in ipairs(state.encounterZones) do
            EncounterZone.update(zone, dt)
        end

        if state.chatSystem then
            state.chatSystem:update(dt)
        end

        if state.skillPanel then
            SkillPanel.update(state.skillPanel, dt)
        end

        RewardUI.update(state.rewardUI, dt)
        DeathScreen.update(state.deathScreen, dt)

        if state.encounterSafeTimer and state.encounterSafeTimer > 0 then
            state.encounterSafeTimer = state.encounterSafeTimer - dt
        else
            GameState.check_encounters(state)
        end
    elseif state.mode == GAME_MODE.BATTLE then
        BattleSystem.update(state.battleSystem, dt)

        if not state.battleSystem.is_active then
            GameState.end_battle(state)
        end
    end
end

function GameState.get_player_position(state)
    return state.player.x, state.player.y
end

function GameState.move_player_to(state, worldX, worldY)
    if state.mode == GAME_MODE.EXPLORATION then
        Player.move_to(state.player, worldX, worldY)
    end
end

function GameState.generate_encounter_zones(state, count)
    state.encounterZones = {}

    for i = 1, count do
        local x = math.random(200, state.map.width - 200)
        local y = math.random(200, state.map.height - 200)
        local radius = math.random(25, 35)

        local zone = EncounterZone.create(x, y, radius)
        if state.assetManager then
            EncounterZone.set_asset_manager(zone, state.assetManager)
        end
        table.insert(state.encounterZones, zone)
    end

    print("Generated " .. count .. " visible encounter monsters")
end

function GameState.check_encounters(state)
    if state.encounterSafeTimer and state.encounterSafeTimer > 0 then
        return
    end

    for _, zone in ipairs(state.encounterZones) do
        if EncounterZone.contains(zone, state.player.x, state.player.y) then
            if EncounterZone.trigger(zone) then
                GameState.start_battle(state)
                break
            end
        end
    end
end

function GameState.start_battle(state)
    print("Battle triggered!")
    state.mode = GAME_MODE.BATTLE
    state.player.isMoving = false

    local enemyCount = math.random(1, 3)
    BattleSystem.start_battle(state.battleSystem, enemyCount)

    AudioSystem.play_bgm(state.audioSystem, "battle")
end

function GameState.end_battle(state)
    local battleState = BattleSystem.get_state(state.battleSystem)

    if battleState == "victory" then
        state.pendingBattleResult = "victory"
        state.pendingRewards = BattleSystem.end_battle(state.battleSystem, "victory")
        RewardUI.show(state.rewardUI, state.pendingRewards)
        AudioSystem.play_sfx(state.audioSystem, "victory")
        state.mode = GAME_MODE.EXPLORATION
        state.encounterSafeTimer = 999
        return
    elseif battleState == "defeat" then
        state.pendingBattleResult = "defeat"
        DeathScreen.show(state.deathScreen)
        AudioSystem.play_sfx(state.audioSystem, "defeat")
        state.mode = GAME_MODE.EXPLORATION
        state.encounterSafeTimer = 999
        return
    end

    GameState.sync_player_to_character(state)

    state.mode = GAME_MODE.EXPLORATION
    state.encounterSafeTimer = 2.0
    AudioSystem.play_bgm(state.audioSystem, "exploration")
end

function GameState.confirm_battle_result(state)
    if state.pendingBattleResult == "victory" then
        if state.pendingRewards then
            if state.pendingRewards.crystals and state.spiritCrystalSystem then
                for _, crystal in ipairs(state.pendingRewards.crystals) do
                    SpiritCrystalSystem.add_crystal(state.spiritCrystalSystem, crystal.tier, 1)
                end
            end
        end
        RewardUI.hide(state.rewardUI)
    elseif state.pendingBattleResult == "defeat" then
        state.player.hp = state.player.maxHp
        state.player.x = 1000
        state.player.y = 1000
        DeathScreen.hide(state.deathScreen)
    end

    state.pendingBattleResult = nil
    state.pendingRewards = nil
    GameState.sync_player_to_character(state)
    state.encounterSafeTimer = 2.0
    AudioSystem.play_bgm(state.audioSystem, "exploration")
end

function GameState.sync_player_to_character(state)
    local character = state.network and state.network:get_character()
    if character and state.player then
        character.hp = state.player.hp
        character.maxHp = state.player.maxHp
        character.attack = state.player.attack
        character.defense = state.player.defense
        character.x = state.player.x
        character.y = state.player.y
        character.mp = state.player.mp
        character.maxMp = state.player.maxMp
        character.magicAttack = state.player.magicAttack
        character.classId = state.player.classId
        character.skills = state.player.skills
        character.skillCrystals = state.player.skillCrystals
        character.critBonus = state.player.critBonus

        if state.equipmentSystem then
            character.equipment = EquipmentSystem.serialize(state.equipmentSystem)
        end

        if state.inventorySystem then
            character.inventory = InventorySystem.serialize(state.inventorySystem)
        end

        if state.spiritCrystalSystem then
            character.spiritCrystals = SpiritCrystalSystem.serialize(state.spiritCrystalSystem)
        end

        if state.companionSystem then
            character.companions = state.companionSystem:serialize()
        end

        state.network:save_character(character)
    end
end

function GameState.get_mode(state)
    return state.mode
end

function GameState.get_battle_system(state)
    return state.battleSystem
end

function GameState.get_audio_system(state)
    return state.audioSystem
end

function GameState.get_party_system(state)
    return state.partySystem
end

function GameState.get_chat_system(state)
    return state.chatSystem
end

function GameState.send_chat_message(state, text)
    if state.chatSystem and state.player then
        local character = state.network and state.network:get_character()
        local senderName = character and character.characterName or "Player"

        state.chatSystem:sendMessage(senderName, text, state.player,
                                    character and character.avatarColor or {1, 1, 1})
    end
end

function GameState.get_login_ui(state)
    return state.loginUI
end

function GameState.get_character_select_ui(state)
    return state.characterSelectUI
end

function GameState.get_current_username(state)
    return state.currentUsername
end

function GameState.textinput(state, text)
    if state.mode == GAME_MODE.LOGIN then
        LoginUI.textinput(state.loginUI, text)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
        CharacterSelectUI.textinput(state.characterSelectUI, text)
    end
end

function GameState.keypressed(state, key)
    if state.mode == GAME_MODE.LOGIN then
        LoginUI.keypressed(state.loginUI, key)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
        local character = CharacterSelectUI.keypressed(state.characterSelectUI, key)
        if character then
            CharacterSelectUI.trigger_character_selected(state.characterSelectUI, character)
        end
    end
end

function GameState.mousepressed(state, x, y, button)
    if state.mode == GAME_MODE.LOGIN then
        LoginUI.mousepressed(state.loginUI, x, y, button)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
        local character = CharacterSelectUI.mousepressed(state.characterSelectUI, x, y, button)
        if character then
            CharacterSelectUI.trigger_character_selected(state.characterSelectUI, character)
        end
    end
end

function GameState.get_equipment_system(state)
    return state.equipmentSystem
end

function GameState.get_inventory_system(state)
    return state.inventorySystem
end

function GameState.get_spirit_crystal_system(state)
    return state.spiritCrystalSystem
end

function GameState.get_companion_system(state)
    return state.companionSystem
end

function GameState.get_skill_panel(state)
    return state.skillPanel
end

function GameState.get_dialog_ui(state)
    return state.dialogUI
end

function GameState.get_shop_ui(state)
    return state.shopUI
end

function GameState.get_reward_ui(state)
    return state.rewardUI
end

function GameState.get_death_screen(state)
    return state.deathScreen
end

function GameState.get_npc_manager(state)
    return state.npcManager
end

function GameState.interact_nearby_npc(state)
    if not state.npcManager or not state.player then return false end
    local npcs = NPCManager.get_npcs_in_range(state.npcManager, state.player.x, state.player.y, 80)
    if #npcs == 0 then return false end

    table.sort(npcs, function(a, b)
        local da = math.sqrt((a.x - state.player.x)^2 + (a.y - state.player.y)^2)
        local db = math.sqrt((b.x - state.player.x)^2 + (b.y - state.player.y)^2)
        return da < db
    end)

    local npc = npcs[1]
    if npc.canTrade and npc.shop and #npc.shop > 0 then
        ShopUI.open(state.shopUI, npc, state.spiritCrystalSystem)
    elseif npc.canTalk or npc.dialogue then
        DialogUI.open(state.dialogUI, npc)
    end
    return true
end

GameState.MODE = GAME_MODE

GameState.getMode = GameState.get_mode
GameState.getBattleSystem = GameState.get_battle_system
GameState.getAudioSystem = GameState.get_audio_system
GameState.getPartySystem = GameState.get_party_system
GameState.getChatSystem = GameState.get_chat_system
GameState.getPlayerPosition = GameState.get_player_position
GameState.movePlayerTo = GameState.move_player_to
GameState.getLoginUI = GameState.get_login_ui
GameState.getCharacterSelectUI = GameState.get_character_select_ui
GameState.getSkillPanel = GameState.get_skill_panel
GameState.getDialogUI = GameState.get_dialog_ui
GameState.getShopUI = GameState.get_shop_ui
GameState.getRewardUI = GameState.get_reward_ui
GameState.getDeathScreen = GameState.get_death_screen
GameState.getNpcManager = GameState.get_npc_manager
GameState.sendChatMessage = GameState.send_chat_message
GameState.interactNearbyNPC = GameState.interact_nearby_npc
GameState.endBattle = GameState.end_battle
GameState.confirmBattleResult = GameState.confirm_battle_result

return GameState
