package.path = package.path .. ";src/?.lua;src/tools/?.lua;src/core/?.lua;src/ui/?.lua"

local PlaceholderAssets = require("src.tools.placeholder_assets")

print("=== Placeholder Asset Generator ===")
print("Generating missing game assets...\n")

local function safe_gen(label, fn)
    local ok, err = pcall(fn)
    if ok then
        print("[OK] " .. label)
    else
        print("[FAIL] " .. label .. ": " .. tostring(err))
    end
end

safe_gen("Character sprites (8 IDs x 8 directions)", PlaceholderAssets.generate_characters)
safe_gen("NPC sprites (5 IDs x 4 directions)", PlaceholderAssets.generate_npcs)
safe_gen("Portraits (large 64x64 + small 32x32)", PlaceholderAssets.generate_portraits)
safe_gen("UI elements (login/character_select/chat/menu)", PlaceholderAssets.generate_ui_elements)

print("\n=== Done! ===")
print("Run the game once to execute, or use: love game --generate-assets")
print("Then replace placeholders with Pixellab-generated assets per docs/PIXELLAB_GENERATION_MANIFEST.md")
