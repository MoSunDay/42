#!/bin/bash

API_KEY="${PIXELLAB_API_KEY:-}"
BASE_URL="https://api.pixellab.ai/v2"
BASE_DIR="/Users/amos/opt/CodeProjects/42/game/assets/images/characters"

BASE_STYLE="simple geometric pixel art character, 48x48 pixels, clean outlines, limited 32 color palette, flat colors, game asset, transparent background"

CHARACTERS=("warrior" "mage" "archer" "rogue" "cleric" "knight" "wizard" "ranger")

DIRECTIONS_8=("north" "north-east" "east" "south-east" "south" "south-west" "west" "north-west")
DIRECTIONS_4=("north" "east" "south" "west")

CHARACTER_DESCRIPTIONS=(
    "warrior:heavy armored knight with large sword, red and steel color scheme, broad shoulders"
    "mage:robed wizard with magic staff, purple and blue color scheme, flowing robes"
    "archer:light armored ranger with bow, green and brown color scheme, hooded cloak"
    "rogue:stealthy assassin with daggers, dark gray and black color scheme, hooded"
    "cleric:holy priest with staff, white and gold color scheme, robes with cross symbol"
    "knight:full plate armored warrior with shield, blue and silver color scheme, helmet"
    "wizard:mystical mage with magic book and pointed hat, dark purple color scheme, glowing aura"
    "ranger:forest scout with dual blades, teal and brown color scheme, cape"
)

generate_image() {
    local name=$1
    local description=$2
    local width=$3
    local height=$4
    local no_bg=${5:-true}
    local output_path=$6
    
    echo "Generating: $output_path"
    
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
        mkdir -p "$(dirname "$output_path")"
        echo "$base64_data" | base64 -d > "$output_path"
        echo "  ✓ Saved"
    else
        echo "  ✗ Error: $(echo "$response" | jq -r '.detail[0].msg // .detail // "unknown error"')"
    fi
    sleep 0.5
}

get_character_desc() {
    local char=$1
    for entry in "${CHARACTER_DESCRIPTIONS[@]}"; do
        if [[ "$entry" == "$char:"* ]]; then
            echo "${entry#*:}"
            return
        fi
    done
    echo "fantasy character"
}

echo "========================================"
echo "  Character Asset Generator"
echo "========================================"
echo ""

if [ -z "$API_KEY" ]; then
    echo "Error: PIXELLAB_API_KEY not set"
    exit 1
fi

if [ "$1" = "rotations" ]; then
    echo "=== Generating Rotations (8-direction static sprites) ==="
    
    CLASSES=("cleric" "knight" "wizard" "ranger")
    
    for char in "${CLASSES[@]}"; do
        echo ""
        echo "--- $char ---"
        desc=$(get_character_desc "$char")
        
        for dir in "${DIRECTIONS_8[@]}"; do
            output="$BASE_DIR/$char/rotations/$dir.png"
            if [ ! -f "$output" ]; then
                generate_image "$dir" "$BASE_STYLE, $desc, facing $dir direction, standing pose" 48 48 true "$output"
            else
                echo "  Skipping $dir (exists)"
            fi
        done
    done
    
elif [ "$1" = "walking" ]; then
    echo "=== Generating Walking Animations (6 frames per direction) ==="
    
    CLASSES=("cleric" "knight" "wizard" "ranger" "archer" "rogue")
    
    for char in "${CLASSES[@]}"; do
        echo ""
        echo "--- $char ---"
        desc=$(get_character_desc "$char")
        
        for dir in "${DIRECTIONS_8[@]}"; do
            echo "  Direction: $dir"
            for frame in 0 1 2 3 4 5; do
                output="$BASE_DIR/$char/animations/walking/$dir/frame_00$frame.png"
                if [ ! -f "$output" ]; then
                    generate_image "walk_$frame" "$BASE_STYLE, $desc, walking animation frame $frame, facing $dir direction, walking pose" 48 48 true "$output"
                else
                    echo "    Skipping frame $frame (exists)"
                fi
            done
        done
    done
    
elif [ "$1" = "idle" ]; then
    echo "=== Generating Breathing-Idle Animations (4 frames per direction) ==="
    
    for char in "${CHARACTERS[@]}"; do
        echo ""
        echo "--- $char ---"
        desc=$(get_character_desc "$char")
        
        for dir in "${DIRECTIONS_8[@]}"; do
            echo "  Direction: $dir"
            for frame in 0 1 2 3; do
                output="$BASE_DIR/$char/animations/breathing-idle/$dir/frame_00$frame.png"
                if [ ! -f "$output" ]; then
                    generate_image "idle_$frame" "$BASE_STYLE, $desc, idle breathing animation frame $frame, facing $dir direction, subtle breathing motion" 48 48 true "$output"
                else
                    echo "    Skipping frame $frame (exists)"
                fi
            done
        done
    done
    
elif [ "$1" = "metadata" ]; then
    echo "=== Generating metadata.json files ==="
    
    CLASSES=("cleric" "knight" "wizard" "ranger")
    
    for char in "${CLASSES[@]}"; do
        output="$BASE_DIR/$char/metadata.json"
        if [ ! -f "$output" ]; then
            cat > "$output" << EOF
{
  "id": "$char",
  "name": "$(echo $char | sed 's/.*/\u&/')",
  "animations": {
    "walking": {
      "frame_count": 6,
      "frame_duration": 0.1,
      "directions": ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
    },
    "breathing-idle": {
      "frame_count": 4,
      "frame_duration": 0.2,
      "directions": ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
    }
  },
  "rotations": ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
}
EOF
            echo "  ✓ Created $output"
        else
            echo "  Skipping $char (metadata exists)"
        fi
    done
    
elif [ "$1" = "portraits" ]; then
    echo "=== Generating Character Portraits ==="
    
    PORTRAIT_DIR="/Users/amos/opt/CodeProjects/42/game/assets/images/portraits"
    
    CLASSES_LARGE=("cleric" "knight" "wizard" "ranger")
    CLASSES_SMALL=("cleric" "knight" "wizard" "ranger")
    
    echo ""
    echo "--- Large Portraits (64x64) ---"
    for char in "${CLASSES_LARGE[@]}"; do
        desc=$(get_character_desc "$char")
        output="$PORTRAIT_DIR/large/$char.png"
        if [ ! -f "$output" ]; then
            generate_image "$char" "$BASE_STYLE, $desc, portrait headshot, 64x64, facing forward" 64 64 true "$output"
        else
            echo "  Skipping $char (exists)"
        fi
    done
    
    echo ""
    echo "--- Small Portraits (32x32) ---"
    for char in "${CLASSES_SMALL[@]}"; do
        desc=$(get_character_desc "$char")
        output="$PORTRAIT_DIR/small/$char.png"
        if [ ! -f "$output" ]; then
            generate_image "$char" "$BASE_STYLE, $desc, portrait headshot, 32x32, facing forward" 32 32 true "$output"
        else
            echo "  Skipping $char (exists)"
        fi
    done

else
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  rotations  - Generate 8-direction static sprites for cleric/knight/wizard/ranger"
    echo "  walking    - Generate walking animations for all classes"
    echo "  idle       - Generate breathing-idle animations for all classes"
    echo "  metadata   - Generate metadata.json files"
    echo "  portraits  - Generate character portraits"
    echo ""
    echo "Example: $0 rotations"
fi

echo ""
echo "Done!"
