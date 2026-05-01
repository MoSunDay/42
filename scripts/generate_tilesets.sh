#!/bin/bash

export PIXELLAB_API_KEY="${PIXELLAB_API_KEY:-}"
BASE_URL="https://api.pixellab.ai/v2"
BASE_DIR="/Users/amos/opt/CodeProjects/42/game/assets/images/tilesets"
STYLE="simple geometric pixel art tileset, 32x32 pixels, clean outlines, limited 32 color palette, flat colors, game asset"

generate_tile() {
    local theme=$1
    local name=$2
    local desc=$3
    local size=${4:-32}
    
    local output="$BASE_DIR/$theme/$name.png"
    
    if [ -f "$output" ] && [ -s "$output" ]; then
        echo "  Skip $name (exists)"
        return 0
    fi
    
    echo "Generating: $theme/$name"
    
    local response=$(curl -s -X POST "$BASE_URL/create-image-pixflux" \
        -H "Authorization: Bearer $PIXELLAB_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"description\": \"$STYLE, $desc\", \"image_size\": {\"width\": $size, \"height\": $size}, \"no_background\": false, \"text_guidance_scale\": 8, \"outline\": \"single color black outline\", \"shading\": \"basic shading\", \"detail\": \"medium detail\"}")
    
    local base64_data=$(echo "$response" | jq -r '.image.base64')
    
    if [ "$base64_data" != "null" ] && [ -n "$base64_data" ]; then
        mkdir -p "$(dirname "$output")"
        echo "$base64_data" | base64 -d > "$output"
        echo "  ✓ Saved"
    else
        echo "  ✗ Error: $(echo "$response" | jq -r '.detail[0].msg // .detail // "unknown"')"
    fi
    sleep 0.4
}

generate_terrain() {
    echo "=== Terrain Tiles ==="
    mkdir -p "$BASE_DIR/terrain"
    
    generate_tile "terrain" "grass" "green grass ground tile, lush meadow"
    generate_tile "terrain" "grass_alt" "light green grass tile, varied grass patches"
    generate_tile "terrain" "dirt" "brown dirt ground tile, earth path"
    generate_tile "terrain" "dirt_path" "dirt path tile, worn trail"
    generate_tile "terrain" "stone" "gray stone floor tile, cobblestone"
    generate_tile "terrain" "stone_alt" "dark stone dungeon floor tile"
    generate_tile "terrain" "water" "blue water tile, lake surface"
    generate_tile "terrain" "water_deep" "deep blue water tile, ocean"
    generate_tile "terrain" "sand" "yellow sand tile, desert beach"
    generate_tile "terrain" "snow" "white snow tile, frozen ground"
    generate_tile "terrain" "lava" "orange red lava tile, molten rock"
    generate_tile "terrain" "void" "dark purple void tile, mystical abyss"
    generate_tile "terrain" "wood" "brown wooden floor tile, planks"
    generate_tile "terrain" "brick" "red brick floor tile, indoor"
}

generate_objects() {
    echo "=== Object Tiles ==="
    mkdir -p "$BASE_DIR/objects/trees"
    mkdir -p "$BASE_DIR/objects/buildings"
    mkdir -p "$BASE_DIR/objects/props"
    
    # Trees
    generate_tile "objects/trees" "tree_oak" "green oak tree, full foliage, pixel art" 48
    generate_tile "objects/trees" "tree_pine" "green pine tree, conifer, pixel art" 48
    generate_tile "objects/trees" "tree_dead" "dead tree, bare branches, spooky" 48
    generate_tile "objects/trees" "tree_palm" "palm tree, tropical, pixel art" 48
    
    # Buildings
    generate_tile "objects/buildings" "house_small" "small cottage house, medieval" 64
    generate_tile "objects/buildings" "house_tavern" "tavern building, wooden inn" 64
    generate_tile "objects/buildings" "tower" "stone watch tower, medieval" 48
    generate_tile "objects/buildings" "well" "stone well, water well" 32
    
    # Props
    generate_tile "objects/props" "rock" "gray rock boulder, stone" 32
    generate_tile "objects/props" "rock_small" "small pebble stones" 32
    generate_tile "objects/props" "bush" "green bush, shrub" 32
    generate_tile "objects/props" "chest" "treasure chest, wooden box" 32
    generate_tile "objects/props" "barrel" "wooden barrel, container" 32
    generate_tile "objects/props" "crate" "wooden crate, box" 32
    generate_tile "objects/props" "sign" "wooden sign post" 32
    generate_tile "objects/props" "lantern" "hanging lantern, light source" 32
    generate_tile "objects/props" "campfire" "burning campfire, fire pit" 32
    generate_tile "objects/props" "flower_red" "red flower, bloom" 32
    generate_tile "objects/props" "flower_yellow" "yellow flower, bloom" 32
    generate_tile "objects/props" "mushroom" "red mushroom, toadstool" 32
}

generate_theme_tilesets() {
    echo "=== Theme Tilesets ==="
    
    # Forest theme
    mkdir -p "$BASE_DIR/forest"
    generate_tile "forest" "floor" "forest ground tile, mossy earth, fallen leaves"
    generate_tile "forest" "grass" "forest grass tile, wild grass"
    generate_tile "forest" "path" "forest dirt path, winding trail"
    generate_tile "forest" "water" "forest pond water, still water"
    generate_tile "forest" "tree_base" "tree trunk base tile"
    
    # Desert theme
    mkdir -p "$BASE_DIR/desert"
    generate_tile "desert" "sand" "desert sand tile, golden dunes"
    generate_tile "desert" "sand_alt" "desert sand variant, wind patterns"
    generate_tile "desert" "rock" "desert rock, sandstone"
    generate_tile "desert" "dunes" "sand dunes tile, rolling hills"
    
    # Dungeon theme
    mkdir -p "$BASE_DIR/dungeon"
    generate_tile "dungeon" "floor" "dungeon stone floor, dark bricks"
    generate_tile "dungeon" "floor_alt" "dungeon cracked floor, worn stones"
    generate_tile "dungeon" "wall" "dungeon wall tile, stone blocks"
    generate_tile "dungeon" "door" "dungeon door, iron gate"
    
    # Volcanic theme
    mkdir -p "$BASE_DIR/volcanic"
    generate_tile "volcanic" "floor" "volcanic rock floor, obsidian"
    generate_tile "volcanic" "lava" "flowing lava tile, molten rock"
    generate_tile "volcanic" "ash" "volcanic ash ground, gray dust"
    generate_tile "volcanic" "crack" "lava crack in ground, glowing"
    
    # Sky theme
    mkdir -p "$BASE_DIR/sky"
    generate_tile "sky" "cloud" "white cloud tile, fluffy"
    generate_tile "sky" "cloud_alt" "gray cloud tile, stormy"
    generate_tile "sky" "platform" "sky floating platform, marble"
    generate_tile "sky" "rainbow" "rainbow tile, colorful arc"
    
    # Underwater theme
    mkdir -p "$BASE_DIR/underwater"
    generate_tile "underwater" "floor" "underwater sand floor, sea bed"
    generate_tile "underwater" "coral" "coral reef tile, colorful"
    generate_tile "underwater" "seaweed" "seaweed patch, kelp forest"
    generate_tile "underwater" "rock" "underwater rock, barnacles"
}

if [ -z "$PIXELLAB_API_KEY" ]; then
    echo "Error: PIXELLAB_API_KEY not set"
    exit 1
fi

case "${1:-all}" in
    terrain)
        generate_terrain
        ;;
    objects)
        generate_objects
        ;;
    themes)
        generate_theme_tilesets
        ;;
    all)
        generate_terrain
        generate_objects
        generate_theme_tilesets
        ;;
    *)
        echo "Usage: $0 {terrain|objects|themes|all}"
        ;;
esac

echo ""
echo "Done!"
