#!/bin/bash

export PIXELLAB_API_KEY="${PIXELLAB_API_KEY:-}"
BASE_URL="https://api.pixellab.ai/v2"
BASE_DIR="/Users/amos/opt/CodeProjects/42/game/assets/images/characters"
STYLE="simple geometric pixel art character, 48x48 pixels, clean outlines, limited 32 color palette, flat colors, game asset, transparent background"

CHARACTER_INFO=(
    "cleric:holy priest with staff, white and gold color scheme, robes with cross symbol"
    "knight:full plate armored warrior with shield, blue and silver color scheme, helmet"
    "wizard:mystical mage with magic book and pointed hat, dark purple color scheme, glowing aura"
    "ranger:forest scout with dual blades, teal and brown color scheme, cape"
    "archer:light armored ranger with bow, green and brown color scheme, hooded cloak"
    "rogue:stealthy assassin with daggers, dark gray and black color scheme, hooded"
    "warrior:heavy armored knight with large sword, red and steel color scheme, broad shoulders"
    "mage:robed wizard with magic staff, purple and blue color scheme, flowing robes"
)

DIRECTIONS_8=("north" "north-east" "east" "south-east" "south" "south-west" "west" "north-west")

get_desc() {
    local char=$1
    for entry in "${CHARACTER_INFO[@]}"; do
        if [[ "$entry" == "$char:"* ]]; then
            echo "${entry#*:}"
            return
        fi
    done
    echo "fantasy character"
}

generate_frame() {
    local char=$1
    local anim=$2
    local dir=$3
    local frame=$4
    local desc=$5
    
    local output="$BASE_DIR/$char/animations/$anim/$dir/frame_00$frame.png"
    
    if [ -f "$output" ]; then
        return 0
    fi
    
    local anim_desc=""
    if [ "$anim" = "walking" ]; then
        anim_desc="walking animation frame $frame, facing $dir direction, walking pose"
    else
        anim_desc="idle breathing animation frame $frame, facing $dir direction, subtle breathing motion"
    fi
    
    local response=$(curl -s -X POST "$BASE_URL/create-image-pixflux" \
        -H "Authorization: Bearer $PIXELLAB_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"description\": \"$STYLE, $desc, $anim_desc\", \"image_size\": {\"width\": 48, \"height\": 48}, \"no_background\": true, \"text_guidance_scale\": 8, \"outline\": \"single color black outline\", \"shading\": \"basic shading\", \"detail\": \"medium detail\"}")
    
    local base64_data=$(echo "$response" | jq -r '.image.base64')
    
    if [ "$base64_data" != "null" ] && [ -n "$base64_data" ]; then
        mkdir -p "$(dirname "$output")"
        echo "$base64_data" | base64 -d > "$output"
        echo "✓ $char/$anim/$dir/$frame"
        return 0
    else
        echo "✗ $char/$anim/$dir/$frame"
        return 1
    fi
}

generate_all_walking() {
    echo "=== Generating Walking Animations ==="
    for entry in "${CHARACTER_INFO[@]}"; do
        local char="${entry%%:*}"
        local desc="${entry#*:}"
        
        echo ""
        echo "--- $char ---"
        for dir in "${DIRECTIONS_8[@]}"; do
            echo "Direction: $dir"
            for frame in 0 1 2 3 4 5; do
                generate_frame "$char" "walking" "$dir" "$frame" "$desc"
                sleep 0.3
            done
        done
    done
}

generate_all_idle() {
    echo "=== Generating Breathing-Idle Animations ==="
    for entry in "${CHARACTER_INFO[@]}"; do
        local char="${entry%%:*}"
        local desc="${entry#*:}"
        
        echo ""
        echo "--- $char ---"
        for dir in "${DIRECTIONS_8[@]}"; do
            echo "Direction: $dir"
            for frame in 0 1 2 3; do
                generate_frame "$char" "breathing-idle" "$dir" "$frame" "$desc"
                sleep 0.3
            done
        done
    done
}

generate_missing() {
    echo "=== Generating Missing Frames ==="
    for entry in "${CHARACTER_INFO[@]}"; do
        local char="${entry%%:*}"
        local desc="${entry#*:}"
        
        # Check walking
        for dir in "${DIRECTIONS_8[@]}"; do
            for frame in 0 1 2 3 4 5; do
                local output="$BASE_DIR/$char/animations/walking/$dir/frame_00$frame.png"
                if [ ! -f "$output" ]; then
                    generate_frame "$char" "walking" "$dir" "$frame" "$desc"
                    sleep 0.3
                fi
            done
        done
        
        # Check idle
        for dir in "${DIRECTIONS_8[@]}"; do
            for frame in 0 1 2 3; do
                local output="$BASE_DIR/$char/animations/breathing-idle/$dir/frame_00$frame.png"
                if [ ! -f "$output" ]; then
                    generate_frame "$char" "breathing-idle" "$dir" "$frame" "$desc"
                    sleep 0.3
                fi
            done
        done
    done
}

show_progress() {
    echo "=== Animation Progress ==="
    for entry in "${CHARACTER_INFO[@]}"; do
        local char="${entry%%:*}"
        local walk=$(find "$BASE_DIR/$char/animations/walking" -name "*.png" 2>/dev/null | wc -l)
        local idle=$(find "$BASE_DIR/$char/animations/breathing-idle" -name "*.png" 2>/dev/null | wc -l)
        echo "$char: walking=$walk/48, idle=$idle/32"
    done
}

if [ -z "$PIXELLAB_API_KEY" ]; then
    echo "Error: PIXELLAB_API_KEY not set"
    exit 1
fi

case "${1:-progress}" in
    walking)
        generate_all_walking
        ;;
    idle)
        generate_all_idle
        ;;
    missing)
        generate_missing
        ;;
    progress)
        show_progress
        ;;
    *)
        echo "Usage: $0 {walking|idle|missing|progress}"
        ;;
esac
