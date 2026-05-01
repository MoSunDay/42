-- account_manager.lua - Account management system
-- 账号管理系统

local CharacterData = require("account.character_data")

local AccountManager = {}

-- Current logged in character
AccountManager.currentCharacter = nil
AccountManager.isLoggedIn = false

-- Account database (in-memory, will be saved to file)
AccountManager.accounts = {}

-- Initialize account system
function AccountManager.init()
    -- Load accounts from file
    AccountManager.loadAccounts()
    
    -- Create default accounts if none exist
    if next(AccountManager.accounts) == nil then
        AccountManager.createDefaultAccounts()
    end
    
    print("Account system initialized")
end

-- Create default test accounts
function AccountManager.createDefaultAccounts()
    -- Account 1: test/123 (with multiple characters)
    local char1 = CharacterData.new({
        username = "test",
        characterName = "Test Hero",
        maxHp = 150,
        hp = 150,
        attack = 25,
        defense = 10,
        avatarColor = {0.3, 0.5, 1.0},
        mapId = "newbie_village",
        x = 1600,
        y = 1600,
    })
    char1.id = "char_test_001"
    char1.appearanceId = "blue_hero"

    AccountManager.accounts["test"] = {
        password = "123",
        characters = {char1}
    }

    -- Account 2: admin/admin (with multiple characters)
    local char2 = CharacterData.new({
        username = "admin",
        characterName = "Admin",
        maxHp = 250,
        hp = 250,
        attack = 50,
        defense = 20,
        avatarColor = {1.0, 0.8, 0.2},
        mapId = "newbie_village",
        x = 1600,
        y = 1600,
    })
    char2.id = "char_admin_001"
    char2.appearanceId = "yellow_mage"

    local char3 = CharacterData.new({
        username = "admin",
        characterName = "Warrior",
        maxHp = 200,
        hp = 200,
        attack = 40,
        defense = 15,
        avatarColor = {1.0, 0.3, 0.3},
        mapId = "four_seasons_city",
        x = 2400,
        y = 2100,
    })
    char3.id = "char_admin_002"
    char3.appearanceId = "red_warrior"

    AccountManager.accounts["admin"] = {
        password = "admin",
        characters = {char2, char3}
    }

    -- Account 3: player/pass (single character)
    local char4 = CharacterData.new({
        username = "player",
        characterName = "Brave Knight",
        maxHp = 100,
        hp = 100,
        attack = 15,
        defense = 5,
        avatarColor = {0.8, 0.3, 0.3},
        mapId = "newbie_village",
        x = 1600,
        y = 1600,
    })
    char4.id = "char_player_001"
    char4.appearanceId = "orange_knight"

    AccountManager.accounts["player"] = {
        password = "pass",
        characters = {char4}
    }
    
    print("Created 3 default accounts:")
    print("  - test/123")
    print("  - admin/admin")
    print("  - player/pass")
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
function AccountManager.selectCharacter(character)
    AccountManager.currentCharacter = character
    return character
end

-- Logout
function AccountManager.logout()
    if AccountManager.isLoggedIn then
        AccountManager.saveCharacter()
    end
    
    AccountManager.currentCharacter = nil
    AccountManager.isLoggedIn = false
    
    print("Logged out")
end

-- Get current character
function AccountManager.getCurrentCharacter()
    return AccountManager.currentCharacter
end

-- Check if logged in
function AccountManager.isUserLoggedIn()
    return AccountManager.isLoggedIn
end

-- Save current character data
function AccountManager.saveCharacter()
    if not AccountManager.isLoggedIn or not AccountManager.currentCharacter then
        return false
    end
    
    local username = AccountManager.currentCharacter.username
    if AccountManager.accounts[username] then
        AccountManager.accounts[username].character = AccountManager.currentCharacter
        print("Character data saved for: " .. username)
        return true
    end
    
    return false
end

-- Load accounts from file (placeholder - will implement file I/O later)
function AccountManager.loadAccounts()
    -- TODO: Load from file
    -- For now, accounts will be created in memory
    print("Loading accounts from memory...")
end

-- Save accounts to file (placeholder)
function AccountManager.saveAccounts()
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
function AccountManager.getAccount(username)
    return AccountManager.accounts[username]
end

return AccountManager

