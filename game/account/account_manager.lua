-- account_manager.lua - Account management system
-- 账号管理系统

local json = require("lib.json")
local CharacterData = require("account.character_data")

local AccountManager = {}

AccountManager.currentCharacter = nil
AccountManager.isLoggedIn = false
AccountManager.accounts = {}

local DEFAULT_ACCOUNTS_FILE = "default_accounts.json"

local function load_default_accounts_config()
    if love.filesystem and love.filesystem.getInfo(DEFAULT_ACCOUNTS_FILE) then
        local content = love.filesystem.read(DEFAULT_ACCOUNTS_FILE)
        if content then
            local ok, data = pcall(json.decode, content)
            if ok and type(data) == "table" then
                return data
            end
        end
    end
    return {}
end

function AccountManager.init()
    AccountManager.load_accounts()
    
    if next(AccountManager.accounts) == nil then
        AccountManager.create_default_accounts()
    end
    
    print("Account system initialized")
end

function AccountManager.create_default_accounts()
    local config = load_default_accounts_config()

    local defaults = {
        {
            username = "test",
            characterName = "Test Hero",
            maxHp = 150, hp = 150, attack = 25, defense = 10,
            avatarColor = {0.3, 0.5, 1.0},
            mapId = "newbie_village", x = 1600, y = 1600,
            charId = "char_test_001",
            appearanceId = "blue_hero",
        },
        {
            username = "admin",
            characterName = "Admin",
            maxHp = 250, hp = 250, attack = 50, defense = 20,
            avatarColor = {1.0, 0.8, 0.2},
            mapId = "newbie_village", x = 1600, y = 1600,
            charId = "char_admin_001",
            appearanceId = "yellow_mage",
        },
        {
            username = "admin",
            characterName = "Warrior",
            maxHp = 200, hp = 200, attack = 40, defense = 15,
            avatarColor = {1.0, 0.3, 0.3},
            mapId = "four_seasons_city", x = 2400, y = 2100,
            charId = "char_admin_002",
            appearanceId = "red_warrior",
        },
        {
            username = "player",
            characterName = "Brave Knight",
            maxHp = 100, hp = 100, attack = 15, defense = 5,
            avatarColor = {0.8, 0.3, 0.3},
            mapId = "newbie_village", x = 1600, y = 1600,
            charId = "char_player_001",
            appearanceId = "orange_knight",
        },
    }

    for _, def in ipairs(defaults) do
        local char = CharacterData.create({
            username = def.username,
            characterName = def.characterName,
            maxHp = def.maxHp,
            hp = def.hp,
            attack = def.attack,
            defense = def.defense,
            avatarColor = def.avatarColor,
            mapId = def.mapId,
            x = def.x,
            y = def.y,
        })
        char.id = def.charId
        char.appearanceId = def.appearanceId

        local password = config[def.username] or ""
        if not AccountManager.accounts[def.username] then
            AccountManager.accounts[def.username] = {
                password = password,
                characters = {char},
            }
        else
            table.insert(AccountManager.accounts[def.username].characters, char)
        end
    end

    local names = {}
    for username, _ in pairs(AccountManager.accounts) do
        table.insert(names, username)
    end
    print("Created default accounts: " .. table.concat(names, ", "))
end

-- Login (returns account, not character - character selection comes next)
function AccountManager.login(username, password)
    if not username or username == "" then
        return false, "Username cannot be empty"
    end

    if not password or password == "" then
        return false, "Password cannot be empty"
    end

    local account = AccountManager.accounts[username]

    if not account then
        return false, "Account not found"
    end

    if account.password ~= password then
        return false, "Incorrect password"
    end

    -- Login successful (but character not selected yet)
    AccountManager.isLoggedIn = true

    print("Login successful: " .. username)
    return true, username
end

-- Select character (called after login)
function AccountManager.select_character(character)
    AccountManager.currentCharacter = character
    return character
end

-- Logout
function AccountManager.logout()
    if AccountManager.isLoggedIn then
        AccountManager.save_character()
    end
    
    AccountManager.currentCharacter = nil
    AccountManager.isLoggedIn = false
    
    print("Logged out")
end

-- Get current character
function AccountManager.get_current_character()
    return AccountManager.currentCharacter
end

-- Check if logged in
function AccountManager.is_user_logged_in()
    return AccountManager.isLoggedIn
end

-- Save current character data
function AccountManager.save_character()
    if not AccountManager.isLoggedIn or not AccountManager.currentCharacter then
        return false
    end
    
    local username = AccountManager.currentCharacter.username
    if AccountManager.accounts[username] then
        local account = AccountManager.accounts[username]
        for i, char in ipairs(account.characters) do
            if char.id == AccountManager.currentCharacter.id then
                account.characters[i] = AccountManager.currentCharacter
                break
            end
        end
        print("Character data saved for: " .. username)
        return true
    end
    
    return false
end

-- Load accounts from file (placeholder - will implement file I/O later)
function AccountManager.load_accounts()
    -- TODO: Load from file
    -- For now, accounts will be created in memory
    print("Loading accounts from memory...")
end

-- Save accounts to file (placeholder)
function AccountManager.save_accounts()
    -- TODO: Save to file
    print("Saving accounts to memory...")
end

-- Register new account
function AccountManager.register(username, password, characterName)
    if not username or username == "" then
        return false, "Username cannot be empty"
    end

    if not password or password == "" then
        return false, "Password cannot be empty"
    end

    if AccountManager.accounts[username] then
        return false, "Username already exists"
    end

    -- Create new account with empty character list
    AccountManager.accounts[username] = {
        password = password,
        characters = {}
    }

    print("Account registered: " .. username)
    return true, "Account created successfully"
end

-- Get account by username
function AccountManager.get_account(username)
    return AccountManager.accounts[username]
end

return AccountManager

