#!/bin/bash

API_KEY="${PIXELLAB_API_KEY:-}"
BASE_URL="https://api.pixellab.ai/v2"
OUTPUT_DIR="/Users/amos/opt/CodeProjects/42/game/assets/images/ui"

BASE_STYLE="dark fantasy RPG game UI, medieval gothic style, stone and metal texture, dark gray purple black colors, ornate decorative border"

generate_image() {
    local name=$1
    local description=$2
    local width=$3
    local height=$4
    local no_bg=$5
    
    echo "Generating: $name"
    
    local no_bg_flag="false"
    if [ "$no_bg" = "true" ]; then
        no_bg_flag="true"
    fi
    
    local response=$(curl -s -X POST "$BASE_URL/create-image-pixflux" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"description\": \"$description\",
            \"image_size\": {\"width\": $width, \"height\": $height},
            \"no_background\": $no_bg_flag,
            \"text_guidance_scale\": 8,
            \"outline\": \"single color black outline\",
            \"shading\": \"basic shading\",
            \"detail\": \"medium detail\"
        }")
    
    local base64_data=$(echo "$response" | jq -r '.image.base64')
    
    if [ "$base64_data" != "null" ] && [ -n "$base64_data" ]; then
        echo "$base64_data" | base64 -d > "$OUTPUT_DIR/$name"
        echo "  Saved: $name"
    else
        echo "  Error: $response"
    fi
    
    sleep 1
}

mkdir -p "$OUTPUT_DIR/panels_new"
mkdir -p "$OUTPUT_DIR/buttons_new"
mkdir -p "$OUTPUT_DIR/input_new"
mkdir -p "$OUTPUT_DIR/slots_new"
mkdir -p "$OUTPUT_DIR/bars_new"
mkdir -p "$OUTPUT_DIR/tabs_new"
mkdir -p "$OUTPUT_DIR/dialog_new"

echo "=== Generating Panels ==="
generate_image "panels_new/small_panel.png" "$BASE_STYLE, square panel background, flat design, 9-slice compatible" 64 64 false
generate_image "panels_new/login_panel.png" "$BASE_STYLE, tall rectangular panel, login dialog frame" 80 120 false
generate_image "panels_new/menu_panel.png" "$BASE_STYLE, medium panel, menu background" 80 80 false
generate_image "panels_new/chat_panel.png" "$BASE_STYLE, wide rectangular panel, chat window frame" 100 60 false
generate_image "panels_new/battle_panel.png" "$BASE_STYLE, horizontal panel, battle status display" 100 50 false

echo "=== Generating Buttons ==="
generate_image "buttons_new/button_normal.png" "$BASE_STYLE, square button, normal state, raised bevel" 48 24 false
generate_image "buttons_new/button_hover.png" "$BASE_STYLE, square button, hover state, glowing highlight" 48 24 false
generate_image "buttons_new/button_pressed.png" "$BASE_STYLE, square button, pressed state, sunken darker" 48 24 false
generate_image "buttons_new/button_disabled.png" "$BASE_STYLE, square button, disabled state, faded gray" 48 24 false
generate_image "buttons_new/button_accent_normal.png" "$BASE_STYLE, square button with magical glow, purple accent" 48 24 false
generate_image "buttons_new/button_accent_hover.png" "$BASE_STYLE, square button, bright magical glow hover" 48 24 false
generate_image "buttons_new/button_small_normal.png" "$BASE_STYLE, small button, normal state" 32 20 false
generate_image "buttons_new/button_small_hover.png" "$BASE_STYLE, small button, hover glow" 32 20 false
generate_image "buttons_new/button_small_pressed.png" "$BASE_STYLE, small button, pressed darker" 32 20 false
generate_image "buttons_new/button_small_disabled.png" "$BASE_STYLE, small button, disabled faded" 32 20 false

echo "=== Generating Input Fields ==="
generate_image "input_new/input_field.png" "$BASE_STYLE, text input box, normal state, rectangular frame" 64 24 false
generate_image "input_new/input_field_active.png" "$BASE_STYLE, text input box, active focused state, glowing border" 64 24 false
generate_image "input_new/input_field_small.png" "$BASE_STYLE, small text input box, normal" 48 20 false
generate_image "input_new/input_field_small_active.png" "$BASE_STYLE, small text input, active glowing" 48 20 false

echo "=== Generating Slots ==="
generate_image "slots_new/slot_normal.png" "$BASE_STYLE, inventory slot square, empty socket frame" 48 48 true
generate_image "slots_new/slot_hover.png" "$BASE_STYLE, inventory slot, hover highlight glow" 48 48 true
generate_image "slots_new/slot_selected.png" "$BASE_STYLE, inventory slot, selected bright border" 48 48 true
generate_image "slots_new/slot_equipment.png" "$BASE_STYLE, equipment slot, ornate frame, golden accent" 48 48 true

echo "=== Generating Bars ==="
generate_image "bars_new/hp_bar_bg.png" "$BASE_STYLE, horizontal bar background, dark frame" 64 12 false
generate_image "bars_new/hp_bar_high.png" "bright green health bar fill, pixel art, solid color" 64 12 false
generate_image "bars_new/hp_bar_medium.png" "yellow orange health bar fill, pixel art, solid color" 64 12 false
generate_image "bars_new/hp_bar_low.png" "red health bar fill, pixel art, solid color" 64 12 false
generate_image "bars_new/mp_bar_bg.png" "$BASE_STYLE, horizontal bar background, dark frame" 64 12 false
generate_image "bars_new/mp_bar_fill.png" "blue mana bar fill, pixel art, solid color" 64 12 false
generate_image "bars_new/exp_bar_bg.png" "$BASE_STYLE, horizontal bar background, dark frame" 64 12 false
generate_image "bars_new/exp_bar_fill.png" "golden experience bar fill, pixel art, solid color" 64 12 false

echo "=== Generating Tabs ==="
generate_image "tabs_new/tab_active.png" "$BASE_STYLE, tab button, active selected state, bright" 48 24 false
generate_image "tabs_new/tab_inactive.png" "$BASE_STYLE, tab button, inactive unselected state, dark" 48 24 false
generate_image "tabs_new/tab_small_active.png" "$BASE_STYLE, small tab, active bright" 32 18 false
generate_image "tabs_new/tab_small_inactive.png" "$BASE_STYLE, small tab, inactive dark" 32 18 false

echo "=== Generating Dialogs ==="
generate_image "dialog_new/dialog_panel.png" "$BASE_STYLE, dialog window panel, ornate frame" 80 64 false
generate_image "dialog_new/dialog_wide.png" "$BASE_STYLE, wide dialog panel, horizontal layout" 100 50 false
generate_image "dialog_new/tooltip_bg.png" "$BASE_STYLE, small tooltip background, simple frame" 64 32 false

echo "=== Generating Borders ==="
mkdir -p "$OUTPUT_DIR/borders_new"
generate_image "borders_new/panel_border.png" "$BASE_STYLE, decorative border frame, 9-slice compatible" 32 32 true
generate_image "borders_new/panel_border_small.png" "$BASE_STYLE, thin decorative border" 32 32 true
generate_image "borders_new/panel_border_thick.png" "$BASE_STYLE, thick ornate border" 32 32 true

echo ""
echo "=== Generation Complete ==="
echo "New assets saved to: $OUTPUT_DIR/*_new/"
echo ""
echo "To apply: manually review and move files from *_new to their final locations"
