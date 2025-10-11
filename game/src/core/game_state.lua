-- game_state.lua - 游戏状态管理
-- 管理所有游戏实体和状态

local Player = require("entities.player")
local Map = require("entities.map")
local Camera = require("core.camera")
local EncounterZone = require("entities.encounter_zone")
local BattleSystem = require("systems.battle_system")
local AudioSystem = require("systems.audio_system")
local AccountManager = require("account.account_manager")
local LoginUI = require("account.login_ui")

local GameState = {}
GameState.__index = GameState

-- Game modes
local GAME_MODE = {
    LOGIN = "login",
    EXPLORATION = "exploration",
    BATTLE = "battle"
}

function GameState.new(assetManager)
    local self = setmetatable({}, GameState)

    self.assetManager = assetManager

    -- Initialize account system
    AccountManager.init()

    -- Game mode (start with login)
    self.mode = GAME_MODE.LOGIN

    -- Login UI
    self.loginUI = LoginUI.new()

    -- These will be initialized after login
    self.map = nil
    self.player = nil
    self.camera = nil
    self.encounterZones = nil
    self.audioSystem = nil
    self.battleSystem = nil

    -- 游戏时间
    self.time = 0

    return self
end

-- Initialize game world after login
function GameState:initializeWorld(character)
    print("Initializing game world for: " .. character.characterName)

    -- 创建地图
    self.map = Map.new(2000, 2000)

    -- 创建玩家（使用角色数据）
    self.player = Player.new(character.x, character.y, self.assetManager)

    -- Sync player stats with character data
    self.player.level = character.level
    self.player.exp = character.exp
    self.player.gold = character.gold
    self.player.maxHp = character.maxHp
    self.player.hp = character.hp
    self.player.attack = character.attack
    self.player.defense = character.defense
    -- Don't override movement speed, keep default 250
    -- self.player.speed is for movement, character.speed is for battle

    -- 设置玩家的地图边界
    self.player:setMapBounds(self.map.width, self.map.height)

    -- 创建相机
    self.camera = Camera.new()

    -- Encounter zones (暗雷)
    self.encounterZones = {}
    self:generateEncounterZones(20)

    -- Audio system
    self.audioSystem = AudioSystem.new()
    self.audioSystem:playBGM("exploration")

    -- Battle system
    self.battleSystem = BattleSystem.new(self.player, self.audioSystem)

    -- Switch to exploration mode
    self.mode = GAME_MODE.EXPLORATION

    print("Game world initialized!")
end

function GameState:update(dt)
    self.time = self.time + dt

    if self.mode == GAME_MODE.LOGIN then
        -- Update login UI
        self.loginUI:update(dt)
    elseif self.mode == GAME_MODE.EXPLORATION then
        -- 更新玩家
        self.player:update(dt)

        -- 更新相机跟随玩家
        self.camera:follow(self.player.x, self.player.y, dt)

        -- Check for encounter zones
        self:checkEncounters()
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
        local x = math.random(100, self.map.width - 100)
        local y = math.random(100, self.map.height - 100)
        local radius = math.random(30, 60)

        table.insert(self.encounterZones, EncounterZone.new(x, y, radius))
    end

    print("Generated " .. count .. " encounter zones")
end

-- Check if player entered encounter zone
function GameState:checkEncounters()
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
        -- Give rewards
        local rewards = self.battleSystem:endBattle("victory")
        if rewards then
            self.player:gainExp(rewards.exp)
            self.player:gainGold(rewards.gold)
        end
        -- Play victory sound
        self.audioSystem:playSFX("victory")
    elseif state == "defeat" then
        -- Game over or respawn logic
        print("Player defeated!")
        self.player.hp = self.player.maxHp
        self.player.x = 1000
        self.player.y = 1000
        -- Play defeat sound
        self.audioSystem:playSFX("defeat")
    end

    -- Sync player data to character
    self:syncPlayerToCharacter()

    -- Return to exploration mode
    self.mode = GAME_MODE.EXPLORATION

    -- Switch back to exploration music
    self.audioSystem:playBGM("exploration")
end

-- Sync player data to character (save progress)
function GameState:syncPlayerToCharacter()
    local character = AccountManager.getCurrentCharacter()
    if character and self.player then
        character.level = self.player.level
        character.exp = self.player.exp
        character.gold = self.player.gold
        character.hp = self.player.hp
        character.maxHp = self.player.maxHp
        character.attack = self.player.attack
        character.defense = self.player.defense
        character.x = self.player.x
        character.y = self.player.y

        -- Save to account manager
        AccountManager.saveCharacter()
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

-- Get login UI
function GameState:getLoginUI()
    return self.loginUI
end

-- Handle login text input
function GameState:textinput(text)
    if self.mode == GAME_MODE.LOGIN then
        self.loginUI:textinput(text)
    end
end

-- Handle login key press
function GameState:keypressed(key)
    if self.mode == GAME_MODE.LOGIN then
        local character = self.loginUI:keypressed(key)
        if character then
            -- Login successful, initialize world
            self:initializeWorld(character)
        end
    end
end

-- Export game modes
GameState.MODE = GAME_MODE

return GameState

