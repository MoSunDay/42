local AnimationManager = require("src.animations.animation_manager")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local PetUI = {}

function PetUI.create()
    local state = {}
    state.colors = Theme.colors.pet
    return state
end

function PetUI.draw_pet(state, pet, playerX, playerY, animationManager, assetManager)
    if not pet then return end

    local petX = playerX - 40
    local petY = playerY + 10

    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if animationManager and pet.animationId then
        offsetX, offsetY, rotation, scaleX, scaleY = AnimationManager.get_transform(animationManager, pet.animationId)
    end

    love.graphics.push()
    love.graphics.translate(petX + offsetX, petY + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    love.graphics.setColor(pet.color)
    love.graphics.circle("fill", 0, 0, pet.size)

    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", -pet.size * 0.3, -pet.size * 0.2, pet.size * 0.15)
    love.graphics.circle("fill", pet.size * 0.3, -pet.size * 0.2, pet.size * 0.15)

    love.graphics.pop()

    local barW, barH = 60, 10
    local hpPercent = pet.hp / pet.maxHp
    Components.drawOrnateHPBar(
        petX - barW / 2, petY - pet.size - 20,
        barW, barH, hpPercent, nil, assetManager
    )
end

function PetUI.draw_pet_panel(state, pet, x, y, width, height, assetManager)
    if not pet then return end

    Components.drawOrnatePanel(x, y, width, height, assetManager, {
        title = pet.name,
        corners = true,
        glow = true,
        shimmer = true
    })

    Theme.draw_gem_icon(x + 25, y + 25, 12, Theme.gem.emerald)

    love.graphics.setColor(Theme.gold.bright)
    love.graphics.setFont(love.graphics.get_font())
    love.graphics.print(pet.name, x + 45, y + 12)

    local hpPercent = pet.hp / pet.maxHp
    Components.drawOrnateHPBar(x + 10, y + 35, width - 20, 12, hpPercent, nil, assetManager)

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.print("ATK:" .. pet.attack .. "  DEF:" .. pet.defense, x + 10, y + 55)
end

return PetUI
