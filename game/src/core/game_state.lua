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

    state.network = NetworkManager.new()

    if USE_NETWORK then
        state.network:connect(SERVER_HOST, SERVER_PORT)
    end

    state.loginUI = LoginUI.new(assetManager)
    state.loginUI:setNetwork(state.network)
    state.loginUI:onLogin(function(characters, username)
        state.currentUsername = username
        state.mode = GAME_MODE.CHARACTER_SELECT
        state.characterSelectUI:setCharacters(characters)
        state.characterSelectUI:setNetwork(state.network)
    end)

    state.characterSelectUI = CharacterSelectUI.new(assetManager)
    state.characterSelectUI:onCharacterSelected(function(character)
        state.network:set_character(character)
        GameState.initializeWorld(state, character)
    end)

    state.currentUsername = nil

    state.skillPanel = SkillPanel.create(assetManager)

    state.map = nil
    state.player = nil
    state.camera = nil
    state.encounterZones = nil
    state.audioSystem = nil
    state.battleSystem = nil

    state.time = 0

    return state
end

function GameState.initializeWorld(state, character)
    print("Initializing game world for: " .. character.characterName)

    local mapId = character.mapId or "town_01"
    local mapData = MapManager.loadMap(mapId)

    if mapData then
        state.map = mapData
        print("Loaded map: " .. mapData.name .. " (" .. mapData.width .. "x" .. mapData.height .. ")")
    else
        print("Failed to load map '" .. mapId .. "', using fallback map")
        state.map = Map.create(2000, 2000)
    end

    local AnimationManager = require("src.animations.animation_manager")
    state.animationManager = AnimationManager.create()

    state.player = Player.create(character.x, character.y, state.assetManager)
    Player.setAnimationManager(state.player, state.animationManager)

    Player.setAppearance(state.player, character)

    state.equipmentSystem = EquipmentSystem.create()
    if character.equipment then
        EquipmentSystem.deserialize(state.equipmentSystem, character.equipment)
    end
    Player.setEquipmentSystem(state.player, state.equipmentSystem)

    state.inventorySystem = InventorySystem.create()
    if character.inventory then
        InventorySystem.deserialize(state.inventorySystem, character.inventory)
    else
        InventorySystem.addItem(state.inventorySystem, "health_potion")
        InventorySystem.addItem(state.inventorySystem, "health_potion")
        InventorySystem.addItem(state.inventorySystem, "large_health_potion")
        InventorySystem.addItem(state.inventorySystem, "antidote")
        InventorySystem.addItem(state.inventorySystem, "iron_sword")
        InventorySystem.addItem(state.inventorySystem, "leather_cap")
        InventorySystem.addItem(state.inventorySystem, "leather_vest")
        InventorySystem.addItem(state.inventorySystem, "leather_boots")
        InventorySystem.addItem(state.inventorySystem, "copper_necklace")
    end

    state.player.maxHp = character.maxHp
    state.player.hp = character.hp
    state.player.baseAttack = character.attack
    state.player.baseDefense = character.defense
    Player.updateStatsWithEquipment(state.player)

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
    EquipmentSystem.setSpiritCrystalSystem(state.equipmentSystem, state.spiritCrystalSystem)

    state.companionSystem = CompanionSystem.new()
    if character.companions then
        local ItemDatabase = require("src.systems.item_database")
        state.companionSystem:deserialize(character.companions, ItemDatabase)
    end

    Player.setMapBounds(state.player, state.map.width, state.map.height)

    state.collisionSystem = CollisionSystem.create(state.map)
    Player.setCollisionSystem(state.player, state.collisionSystem)

    if not CollisionSystem.isWalkable(state.collisionSystem, state.player.x, state.player.y) then
        print("Warning: Player spawned in non-walkable area, finding valid position...")
        local validX, validY = CollisionSystem.getValidPosition(
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

    state.encounterZones = {}
    GameState.generateEncounterZones(state, 20)

    state.audioSystem = AudioSystem.create()
    AudioSystem.playBGM(state.audioSystem, "exploration")

    state.battleSystem = BattleSystem.create(state.player, state.audioSystem, state.animationManager, state.assetManager, state.companionSystem)

    state.partySystem = PartySystem.new()
    state.partySystem:setPartyName("My Party")

    local playerMember = PartySystem.createMemberData(
        character.id or "player1",
        character.characterName,
        character.hp,
        character.maxHp,
        character.avatarColor
    )
    state.partySystem:addMember(playerMember)

    state.chatSystem = ChatSystem.new()

    state.chatSystem:addMessage("System", "Welcome to the game!", {0.4, 0.8, 1.0})

    state.mode = GAME_MODE.EXPLORATION

    state.encounterSafeTimer = 3.0

    print("Game world initialized!")
end

function GameState.update(state, dt)
    state.time = state.time + dt

    if state.mode == GAME_MODE.LOGIN then
        state.loginUI:update(dt)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
    elseif state.mode == GAME_MODE.EXPLORATION then
        Player.update(state.player, dt)

        Camera.follow(state.camera, state.player.x, state.player.y, dt)

        for _, zone in ipairs(state.encounterZones) do
            EncounterZone.update(zone, dt)
        end

        if state.chatSystem then
            state.chatSystem:update(dt)
        end

        if state.skillPanel then
            SkillPanel.update(state.skillPanel, dt)
        end

        if state.encounterSafeTimer and state.encounterSafeTimer > 0 then
            state.encounterSafeTimer = state.encounterSafeTimer - dt
        else
            GameState.checkEncounters(state)
        end
    elseif state.mode == GAME_MODE.BATTLE then
        BattleSystem.update(state.battleSystem, dt)

        if not state.battleSystem.isActive then
            GameState.endBattle(state)
        end
    end
end

function GameState.getPlayerPosition(state)
    return state.player.x, state.player.y
end

function GameState.movePlayerTo(state, worldX, worldY)
    if state.mode == GAME_MODE.EXPLORATION then
        Player.moveTo(state.player, worldX, worldY)
    end
end

function GameState.generateEncounterZones(state, count)
    state.encounterZones = {}

    for i = 1, count do
        local x = math.random(200, state.map.width - 200)
        local y = math.random(200, state.map.height - 200)
        local radius = math.random(25, 35)

        local zone = EncounterZone.create(x, y, radius)
        if state.assetManager then
            EncounterZone.setAssetManager(zone, state.assetManager)
        end
        table.insert(state.encounterZones, zone)
    end

    print("Generated " .. count .. " visible encounter monsters")
end

function GameState.checkEncounters(state)
    if state.encounterSafeTimer and state.encounterSafeTimer > 0 then
        return
    end

    for _, zone in ipairs(state.encounterZones) do
        if EncounterZone.contains(zone, state.player.x, state.player.y) then
            if EncounterZone.trigger(zone) then
                GameState.startBattle(state)
                break
            end
        end
    end
end

function GameState.startBattle(state)
    print("Battle triggered!")
    state.mode = GAME_MODE.BATTLE
    state.player.isMoving = false

    local enemyCount = math.random(1, 3)
    BattleSystem.startBattle(state.battleSystem, enemyCount)

    AudioSystem.playBGM(state.audioSystem, "battle")
end

function GameState.endBattle(state)
    local battleState = BattleSystem.getState(state.battleSystem)

    if battleState == "victory" then
        local rewards = BattleSystem.endBattle(state.battleSystem, "victory")
        if rewards then
            if rewards.crystals and state.spiritCrystalSystem then
                for _, crystal in ipairs(rewards.crystals) do
                    SpiritCrystalSystem.addCrystal(state.spiritCrystalSystem, crystal.type, crystal.tier, 1)
                    print(string.format("Obtained: %s", crystal.name))
                end
            end
        end
        AudioSystem.playSFX(state.audioSystem, "victory")
    elseif battleState == "defeat" then
        print("Player defeated!")
        state.player.hp = state.player.maxHp
        state.player.x = 1000
        state.player.y = 1000
        AudioSystem.playSFX(state.audioSystem, "defeat")
    end

    GameState.syncPlayerToCharacter(state)

    state.mode = GAME_MODE.EXPLORATION
    state.encounterSafeTimer = 2.0
    AudioSystem.playBGM(state.audioSystem, "exploration")
end

function GameState.syncPlayerToCharacter(state)
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

function GameState.getMode(state)
    return state.mode
end

function GameState.getBattleSystem(state)
    return state.battleSystem
end

function GameState.getAudioSystem(state)
    return state.audioSystem
end

function GameState.getPartySystem(state)
    return state.partySystem
end

function GameState.getChatSystem(state)
    return state.chatSystem
end

function GameState.sendChatMessage(state, text)
    if state.chatSystem and state.player then
        local character = state.network and state.network:get_character()
        local senderName = character and character.characterName or "Player"

        state.chatSystem:sendMessage(senderName, text, state.player,
                                    character and character.avatarColor or {1, 1, 1})
    end
end

function GameState.getLoginUI(state)
    return state.loginUI
end

function GameState.getCharacterSelectUI(state)
    return state.characterSelectUI
end

function GameState.getCurrentUsername(state)
    return state.currentUsername
end

function GameState.textinput(state, text)
    if state.mode == GAME_MODE.LOGIN then
        state.loginUI:textinput(text)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
        state.characterSelectUI:textinput(text)
    end
end

function GameState.keypressed(state, key)
    if state.mode == GAME_MODE.LOGIN then
        state.loginUI:keypressed(key)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
        state.characterSelectUI:keypressed(key)
    end
end

function GameState.mousepressed(state, x, y, button)
    if state.mode == GAME_MODE.LOGIN then
        state.loginUI:mousepressed(x, y, button)
    elseif state.mode == GAME_MODE.CHARACTER_SELECT then
        state.characterSelectUI:mousepressed(x, y, button)
    end
end

function GameState.getEquipmentSystem(state)
    return state.equipmentSystem
end

function GameState.getInventorySystem(state)
    return state.inventorySystem
end

function GameState.getSpiritCrystalSystem(state)
    return state.spiritCrystalSystem
end

function GameState.getCompanionSystem(state)
    return state.companionSystem
end

function GameState.getSkillPanel(state)
    return state.skillPanel
end

GameState.MODE = GAME_MODE

return GameState
