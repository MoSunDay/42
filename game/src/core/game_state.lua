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

local GameState = {}
GameState.__index = GameState

local GAME_MODE = {
    LOGIN = "login",
    CHARACTER_SELECT = "character_select",
    EXPLORATION = "exploration",
    BATTLE = "battle"
}

local USE_NETWORK = true
local SERVER_HOST = "127.0.0.1"
local SERVER_PORT = 9000

function GameState.new(assetManager)
    local self = setmetatable({}, GameState)

    self.assetManager = assetManager

    self.mode = GAME_MODE.LOGIN

    self.network = NetworkManager.new()
    
    if USE_NETWORK then
        self.network:connect(SERVER_HOST, SERVER_PORT)
    end

    self.loginUI = LoginUI.new()
    self.loginUI:setNetwork(self.network)
    self.loginUI:onLogin(function(characters, username)
        self.currentUsername = username
        self.mode = GAME_MODE.CHARACTER_SELECT
        self.characterSelectUI:setCharacters(characters)
        self.characterSelectUI:setNetwork(self.network)
    end)

    self.characterSelectUI = CharacterSelectUI.new()
    self.characterSelectUI:onCharacterSelected(function(character)
        self.network:set_character(character)
        self:initializeWorld(character)
    end)

    self.currentUsername = nil

    self.map = nil
    self.player = nil
    self.camera = nil
    self.encounterZones = nil
    self.audioSystem = nil
    self.battleSystem = nil

    self.time = 0

    return self
end

-- Initialize game world after login
function GameState:initializeWorld(character)
    print("Initializing game world for: " .. character.characterName)

    -- 加载地图（使用MapManager）
    local mapId = character.mapId or "town_01"
    local mapData = MapManager.loadMap(mapId)

    if mapData then
        -- 使用新地图系统
        self.map = mapData
        print("Loaded map: " .. mapData.name .. " (" .. mapData.width .. "x" .. mapData.height .. ")")
    else
        -- 回退到旧地图系统
        print("Failed to load map '" .. mapId .. "', using fallback map")
        self.map = Map.new(2000, 2000)
    end

    -- Create animation manager
    local AnimationManager = require("src.animations.animation_manager")
    self.animationManager = AnimationManager.new()

    -- 创建玩家（使用角色数据）
    self.player = Player.new(character.x, character.y, self.assetManager)
    self.player:setAnimationManager(self.animationManager)

    -- Set player appearance (unified avatar and sprite)
    self.player:setAppearance(character)

    -- Equipment system
    self.equipmentSystem = EquipmentSystem.new()
    if character.equipment then
        self.equipmentSystem:deserialize(character.equipment)
    end
    self.player:setEquipmentSystem(self.equipmentSystem)

    self.inventorySystem = InventorySystem.new()
    if character.inventory then
        self.inventorySystem:deserialize(character.inventory)
    else
        self.inventorySystem:addItem("health_potion")
        self.inventorySystem:addItem("health_potion")
        self.inventorySystem:addItem("large_health_potion")
        self.inventorySystem:addItem("antidote")
        self.inventorySystem:addItem("iron_sword")
        self.inventorySystem:addItem("leather_cap")
        self.inventorySystem:addItem("leather_vest")
        self.inventorySystem:addItem("leather_boots")
        self.inventorySystem:addItem("copper_necklace")
    end

    self.player.gold = character.gold
    self.player.maxHp = character.maxHp
    self.player.hp = character.hp
    self.player.baseAttack = character.attack
    self.player.baseDefense = character.defense
    self.player:updateStatsWithEquipment()
    -- Don't override movement speed, keep default 250
    -- self.player.speed is for movement, character.speed is for battle
    
    self.spiritCrystalSystem = SpiritCrystalSystem.new()
    if character.spiritCrystals then
        self.spiritCrystalSystem:deserialize(character.spiritCrystals)
    end
    self.equipmentSystem:setSpiritCrystalSystem(self.spiritCrystalSystem)
    
    self.companionSystem = CompanionSystem.new()
    if character.companions then
        local ItemDatabase = require("src.systems.item_database")
        self.companionSystem:deserialize(character.companions, ItemDatabase)
    end

    -- 设置玩家的地图边界
    self.player:setMapBounds(self.map.width, self.map.height)

    -- 创建碰撞系统
    self.collisionSystem = CollisionSystem.new(self.map)
    self.player:setCollisionSystem(self.collisionSystem)

    -- 验证并修正玩家位置（确保不在建筑内）
    if not self.collisionSystem:isWalkable(self.player.x, self.player.y) then
        print("Warning: Player spawned in non-walkable area, finding valid position...")
        local validX, validY = self.collisionSystem:getValidPosition(
            self.player.x, self.player.y, self.player.collisionRadius
        )
        self.player.x = validX
        self.player.y = validY
        self.player.targetX = validX
        self.player.targetY = validY
        print(string.format("Player position corrected to: (%.0f, %.0f)", validX, validY))

        -- Update character data
        character.x = validX
        character.y = validY
    end

    -- 创建相机
    self.camera = Camera.new()

    -- Encounter zones (暗雷)
    self.encounterZones = {}
    self:generateEncounterZones(20)

    -- Audio system
    self.audioSystem = AudioSystem.new()
    self.audioSystem:playBGM("exploration")

    -- Battle system
    self.battleSystem = BattleSystem.new(self.player, self.audioSystem, self.animationManager, self.assetManager)

    -- Party system
    self.partySystem = PartySystem.new()
    self.partySystem:setPartyName("My Party")

    -- Add current player to party
    local playerMember = PartySystem.createMemberData(
        character.id or "player1",
        character.characterName,
        character.hp,
        character.maxHp,
        character.avatarColor
    )
    self.partySystem:addMember(playerMember)

    -- Chat system
    self.chatSystem = ChatSystem.new()

    -- Send welcome message
    self.chatSystem:addMessage("System", "Welcome to the game!", {0.4, 0.8, 1.0})

    -- Switch to exploration mode
    self.mode = GAME_MODE.EXPLORATION

    -- Add safe period after login (no encounters for 3 seconds)
    self.encounterSafeTimer = 3.0

    print("Game world initialized!")
end

function GameState:update(dt)
    self.time = self.time + dt

    if self.mode == GAME_MODE.LOGIN then
        -- Update login UI
        self.loginUI:update(dt)
    elseif self.mode == GAME_MODE.CHARACTER_SELECT then
        -- Character select screen (no updates needed)
    elseif self.mode == GAME_MODE.EXPLORATION then
        -- 更新玩家
        self.player:update(dt)

        -- 更新相机跟随玩家
        self.camera:follow(self.player.x, self.player.y, dt)

        -- Update encounter zones (visible monsters)
        for _, zone in ipairs(self.encounterZones) do
            zone:update(dt)
        end

        -- Update chat system
        if self.chatSystem then
            self.chatSystem:update(dt)
        end

        -- Update safe timer
        if self.encounterSafeTimer and self.encounterSafeTimer > 0 then
            self.encounterSafeTimer = self.encounterSafeTimer - dt
        else
            -- Check for encounter zones only after safe period
            self:checkEncounters()
        end
    elseif self.mode == GAME_MODE.BATTLE then
        -- Update battle system
        self.battleSystem:update(dt)

        -- Check if battle ended
        if not self.battleSystem.isActive then
            self:endBattle()
        end
    end
end

function GameState:getPlayerPosition()
    return self.player.x, self.player.y
end

function GameState:movePlayerTo(worldX, worldY)
    if self.mode == GAME_MODE.EXPLORATION then
        self.player:moveTo(worldX, worldY)
    end
end

-- Generate random encounter zones
function GameState:generateEncounterZones(count)
    self.encounterZones = {}

    for i = 1, count do
        local x = math.random(200, self.map.width - 200)
        local y = math.random(200, self.map.height - 200)
        local radius = math.random(25, 35)  -- Visible monster size

        table.insert(self.encounterZones, EncounterZone.new(x, y, radius))
    end

    print("Generated " .. count .. " visible encounter monsters (明雷)")
end

-- Check if player entered encounter zone
function GameState:checkEncounters()
    -- Skip if in safe period
    if self.encounterSafeTimer and self.encounterSafeTimer > 0 then
        return
    end

    for _, zone in ipairs(self.encounterZones) do
        if zone:contains(self.player.x, self.player.y) then
            if zone:trigger() then
                self:startBattle()
                break
            end
        end
    end
end

-- Start battle
function GameState:startBattle()
    print("Battle triggered!")
    self.mode = GAME_MODE.BATTLE
    self.player.isMoving = false

    -- Start battle with 1-3 enemies
    local enemyCount = math.random(1, 3)
    self.battleSystem:startBattle(enemyCount)

    -- Switch to battle music
    self.audioSystem:playBGM("battle")
end

-- End battle
function GameState:endBattle()
    local state = self.battleSystem:getState()

    if state == "victory" then
        local rewards = self.battleSystem:endBattle("victory")
        if rewards then
            self.player:gainGold(rewards.gold)
            print(string.format("Victory! Gained %d gold", rewards.gold))
            
            if rewards.crystals and self.spiritCrystalSystem then
                for _, crystal in ipairs(rewards.crystals) do
                    self.spiritCrystalSystem:addCrystal(crystal.type, crystal.tier, 1)
                    print(string.format("Obtained: %s", crystal.name))
                end
            end
        end
        self.audioSystem:playSFX("victory")
    elseif state == "defeat" then
        print("Player defeated!")
        self.player.hp = self.player.maxHp
        self.player.x = 1000
        self.player.y = 1000
        self.audioSystem:playSFX("defeat")
    end

    self:syncPlayerToCharacter()

    self.mode = GAME_MODE.EXPLORATION
    self.encounterSafeTimer = 2.0
    self.audioSystem:playBGM("exploration")
end

-- Sync player data to character (save progress)
function GameState:syncPlayerToCharacter()
    local character = self.network and self.network:get_character()
    if character and self.player then
        character.gold = self.player.gold
        character.hp = self.player.hp
        character.maxHp = self.player.maxHp
        character.attack = self.player.attack
        character.defense = self.player.defense
        character.x = self.player.x
        character.y = self.player.y
        
        if self.equipmentSystem then
            character.equipment = self.equipmentSystem:serialize()
        end
        
        if self.inventorySystem then
            character.inventory = self.inventorySystem:serialize()
        end
        
        if self.spiritCrystalSystem then
            character.spiritCrystals = self.spiritCrystalSystem:serialize()
        end
        
        if self.companionSystem then
            character.companions = self.companionSystem:serialize()
        end

        self.network:save_character(character)
    end
end

-- Get game mode
function GameState:getMode()
    return self.mode
end

-- Get battle system
function GameState:getBattleSystem()
    return self.battleSystem
end

-- Get audio system
function GameState:getAudioSystem()
    return self.audioSystem
end

-- Get party system
function GameState:getPartySystem()
    return self.partySystem
end

-- Get chat system
function GameState:getChatSystem()
    return self.chatSystem
end

-- Send chat message
function GameState:sendChatMessage(text)
    if self.chatSystem and self.player then
        local character = self.network and self.network:get_character()
        local senderName = character and character.characterName or "Player"

        -- Pass player entity as owner so bubble follows the player
        self.chatSystem:sendMessage(senderName, text, self.player,
                                    character and character.avatarColor or {1, 1, 1})
    end
end

-- Get login UI
function GameState:getLoginUI()
    return self.loginUI
end

-- Get character select UI
function GameState:getCharacterSelectUI()
    return self.characterSelectUI
end

-- Get current username
function GameState:getCurrentUsername()
    return self.currentUsername
end

-- Handle text input
function GameState:textinput(text)
    if self.mode == GAME_MODE.LOGIN then
        self.loginUI:textinput(text)
    elseif self.mode == GAME_MODE.CHARACTER_SELECT then
        self.characterSelectUI:textinput(text)
    end
end

-- Handle key press
function GameState:keypressed(key)
    if self.mode == GAME_MODE.LOGIN then
        self.loginUI:keypressed(key)
    elseif self.mode == GAME_MODE.CHARACTER_SELECT then
        self.characterSelectUI:keypressed(key)
    end
end

-- Handle mouse press
function GameState:mousepressed(x, y, button)
    if self.mode == GAME_MODE.LOGIN then
        self.loginUI:mousepressed(x, y, button)
    elseif self.mode == GAME_MODE.CHARACTER_SELECT then
        self.characterSelectUI:mousepressed(x, y, button)
    end
end

-- Get equipment system
function GameState:getEquipmentSystem()
    return self.equipmentSystem
end

-- Get inventory system
function GameState:getInventorySystem()
    return self.inventorySystem
end

-- Get spirit crystal system
function GameState:getSpiritCrystalSystem()
    return self.spiritCrystalSystem
end

-- Get companion system
function GameState:getCompanionSystem()
    return self.companionSystem
end

-- Get party system
function GameState:getPartySystem()
    return self.partySystem
end

-- Export game modes
GameState.MODE = GAME_MODE

return GameState

