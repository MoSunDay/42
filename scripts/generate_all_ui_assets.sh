#!/bin/bash

API_KEY="${PIXELLAB_API_KEY:-}"
BASE_URL="https://api.pixellab.ai/v2"
OUTPUT_DIR="/Users/amos/opt/CodeProjects/42/game/assets/images/ui"

BASE_STYLE="dark fantasy RPG UI, medieval gothic style, stone and metal texture, dark gray purple black colors, ornate decorative border, pixel art"
ICON_STYLE="dark fantasy RPG game icon, medieval style, gothic design, pixel art, simple clear symbol"

generate_image() {
    local name=$1
    local description=$2
    local width=$3
    local height=$4
    local no_bg=${5:-false}
    
    echo "Generating: $name ($width x $height)"
    
    local response=$(curl -s -X POST "$BASE_URL/create-image-pixflux" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"description\": \"$description\",
            \"image_size\": {\"width\": $width, \"height\": $height},
            \"no_background\": $no_bg,
            \"text_guidance_scale\": 8,
            \"outline\": \"single color black outline\",
            \"shading\": \"basic shading\",
            \"detail\": \"medium detail\"
        }")
    
    local base64_data=$(echo "$response" | jq -r '.image.base64')
    
    if [ "$base64_data" != "null" ] && [ -n "$base64_data" ]; then
        echo "$base64_data" | base64 -d > "$OUTPUT_DIR/$name"
        echo "  ✓ Saved: $name"
    else
        echo "  ✗ Error: $(echo "$response" | jq -r '.detail[0].msg // .detail // "unknown error"')"
    fi
    sleep 0.5
}

echo "========================================"
echo "  Dark Fantasy UI Asset Generator"
echo "  Total: 51 assets"
echo "========================================"
echo ""

# ============================================
# Phase 1: Core Panels/Bars/Tabs (8 items)
# ============================================
echo "=== Phase 1: Core UI Elements (8) ==="

generate_image "panels/character_select_panel.png" "$BASE_STYLE, character selection panel, tall rectangular frame, portrait display area" 80 100 false
generate_image "bars/hp_bar_small_bg.png" "$BASE_STYLE, small horizontal bar background, dark frame" 48 16 false
generate_image "bars/hp_bar_small_high.png" "bright green health bar fill, pixel art, solid vibrant color, no border" 48 16 false
generate_image "bars/mp_bar_small_bg.png" "$BASE_STYLE, small horizontal bar background, dark frame" 48 16 false
generate_image "bars/mp_bar_small_fill.png" "blue mana bar fill, pixel art, solid vibrant color, no border" 48 16 false
generate_image "tabs/tab_small_inactive.png" "$BASE_STYLE, small tab button, inactive unselected state, dark dimmed" 48 24 false
generate_image "minimap/minimap_frame.png" "$BASE_STYLE, circular minimap frame, decorative border, transparent center" 64 64 true
generate_image "minimap/minimap_label.png" "$BASE_STYLE, small label banner, dark background for text" 64 20 false

# ============================================
# Phase 2: Loading Screen (3 items)
# ============================================
echo ""
echo "=== Phase 2: Loading Screen (3) ==="

generate_image "loading/loading_panel.png" "$BASE_STYLE, loading screen panel, centered display frame" 100 60 false
generate_image "loading/loading_bar_bg.png" "$BASE_STYLE, loading bar background, horizontal track" 64 16 false
generate_image "loading/loading_bar_fill.png" "golden loading progress bar fill, pixel art, solid shiny color" 64 16 false

# ============================================
# Phase 3: Combat Icons (6 items)
# ============================================
echo ""
echo "=== Phase 3: Combat Icons (6) ==="

generate_image "icons/attack.png" "$ICON_STYLE, crossed swords attack icon, weapon symbol" 24 24 true
generate_image "icons/defend.png" "$ICON_STYLE, shield defend icon, protection symbol" 24 24 true
generate_image "icons/escape.png" "$ICON_STYLE, running feet escape icon, flee symbol" 24 24 true
generate_image "icons/auto.png" "$ICON_STYLE, circular arrows auto battle icon, autoplay symbol" 24 24 true
generate_image "icons/heal.png" "$ICON_STYLE, heart cross heal icon, health symbol" 24 24 true
generate_image "icons/fire.png" "$ICON_STYLE, flame fire magic icon, spell symbol" 24 24 true

# ============================================
# Phase 4: Item Icons (4 items)
# ============================================
echo ""
echo "=== Phase 4: Item Icons (4) ==="

generate_image "icons/hp_potion.png" "$ICON_STYLE, red potion bottle, health potion icon" 24 24 true
generate_image "icons/mp_potion.png" "$ICON_STYLE, blue potion bottle, mana potion icon" 24 24 true
generate_image "icons/item.png" "$ICON_STYLE, treasure chest item icon, loot symbol" 24 24 true
generate_image "icons/inventory.png" "$ICON_STYLE, backpack bag inventory icon, bag symbol" 24 24 true

# ============================================
# Phase 5: Equipment Icons (9 items)
# ============================================
echo ""
echo "=== Phase 5: Equipment Icons (9) ==="

generate_image "icons/sword.png" "$ICON_STYLE, medieval sword weapon icon, blade symbol" 24 24 true
generate_image "icons/bow.png" "$ICON_STYLE, archery bow weapon icon, ranged symbol" 24 24 true
generate_image "icons/dagger.png" "$ICON_STYLE, small dagger knife icon, assassin weapon" 24 24 true
generate_image "icons/staff.png" "$ICON_STYLE, magic staff wand icon, wizard weapon" 24 24 true
generate_image "icons/shield.png" "$ICON_STYLE, knight shield armor icon, defense symbol" 24 24 true
generate_image "icons/hat.png" "$ICON_STYLE, wizard hat helmet icon, head armor" 24 24 true
generate_image "icons/clothes.png" "$ICON_STYLE, armor chest plate icon, body armor" 24 24 true
generate_image "icons/shoes.png" "$ICON_STYLE, boots shoes icon, foot armor" 24 24 true
generate_image "icons/necklace.png" "$ICON_STYLE, amulet necklace icon, accessory symbol" 24 24 true

# ============================================
# Phase 6: Menu Icons (7 items)
# ============================================
echo ""
echo "=== Phase 6: Menu Icons (7) ==="

generate_image "icons/equipment.png" "$ICON_STYLE, armor suit equipment icon, gear symbol" 24 24 true
generate_image "icons/map.png" "$ICON_STYLE, scroll map icon, navigation symbol" 24 24 true
generate_image "icons/party.png" "$ICON_STYLE, group people party icon, team symbol" 24 24 true
generate_image "icons/pet.png" "$ICON_STYLE, paw print pet icon, companion symbol" 24 24 true
generate_image "icons/quest.png" "$ICON_STYLE, exclamation scroll quest icon, mission symbol" 24 24 true
generate_image "icons/settings.png" "$ICON_STYLE, gear cog settings icon, options symbol" 24 24 true
generate_image "icons/weapon.png" "$ICON_STYLE, crossed weapons slot icon, armament symbol" 24 24 true

# ============================================
# Phase 7: Magic/Misc Icons (7 items)
# ============================================
echo ""
echo "=== Phase 7: Magic/Misc Icons (7) ==="

generate_image "icons/ice.png" "$ICON_STYLE, snowflake ice crystal icon, frost magic symbol" 24 24 true
generate_image "icons/lightning.png" "$ICON_STYLE, thunder bolt lightning icon, electric magic symbol" 24 24 true
generate_image "icons/check.png" "$ICON_STYLE, checkmark tick icon, confirm symbol, bright accent" 24 24 true
generate_image "icons/close.png" "$ICON_STYLE, cross X close button icon, dismiss symbol" 24 24 true
generate_image "icons/x.png" "$ICON_STYLE, X mark cancel icon, reject symbol" 24 24 true
generate_image "icons/plus.png" "$ICON_STYLE, plus sign add icon, increase symbol" 24 24 true
generate_image "icons/minus.png" "$ICON_STYLE, minus sign subtract icon, decrease symbol" 24 24 true

echo ""
echo "========================================"
echo "  Generation Complete!"
echo "  Generated 51 dark fantasy UI assets"
echo "========================================"
