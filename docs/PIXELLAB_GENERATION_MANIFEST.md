# Pixellab Batch Generation Manifest

> Style: `simple geometric pixel art`, 32 colors max, transparent background
> Palette reference: `#1a1a2e #16213e #0f3460 #e8e8e8 #c8c8c8 #a0a0a0 #e94560 #ff6b6b #4ecdc4 #45b7d1 #2d5a27 #4a7c59 #8b7355 #d4a574 #9b59b6 #3498db #1abc9c #f39c12`

## Phase A: Missing Character Sprites (48x48, 8-direction rotations)

Use `rotate` tool on each concept, then `create-8-rotations-pro` if available.
Reference image: use existing `blue_hero` south rotation as style reference.

| ID | Prompt | Primary Color |
|----|--------|---------------|
| red_warrior | `red warrior character, heavy plate armor, crimson cape, holding battle axe, standing idle, 48x48 pixel art` | `#c0292b` |
| green_ranger | `green ranger character, forest green cloak, dual daggers, leather armor, standing idle, 48x48 pixel art` | `#16a085` |
| yellow_mage | `yellow mage character, golden robes, arcane staff with sun crystal, standing idle, 48x48 pixel art` | `#f39c12` |
| purple_assassin | `purple assassin character, dark purple hood, twin blades, shadow cloak, standing idle, 48x48 pixel art` | `#9b59b6` |
| cyan_priest | `cyan priest character, teal white robes, holy staff with water orb, standing idle, 48x48 pixel art` | `#1abc9c` |
| orange_knight | `orange knight character, burnt orange plate armor, shield and mace, standing idle, 48x48 pixel art` | `#e67e22` |
| pink_dancer | `pink dancer character, flowing magenta dress, ribbon fans, standing idle, 48x48 pixel art` | `#ff69b4` |
| hero | `blue hero character, blue tunic, short sword and wooden shield, adventure hat, standing idle, 48x48 pixel art` | `#3498db` |

### Per-character steps:
1. Generate south-facing concept with `create-image-flux` (48x48, reference: blue_hero)
2. Create 8-direction rotation with `rotate` or `create-8-rotations-pro`
3. Save rotations to `game/assets/images/characters/{id}/rotations/{dir}.png`
4. (Optional) Generate walking animation with `animate-with-text-new`: "character walking forward"

---

## Phase B: Missing NPC Sprites (48x48, 4-direction rotations)

Reference image: use existing `merchant` south rotation as style reference.

| ID | Prompt | Primary Color |
|----|--------|---------------|
| village_chief | `old village chief NPC, white beard, brown elder robes, wooden staff, friendly pose, 48x48 pixel art` | `#d4a574` |
| spring_guardian | `spring forest guardian NPC, green leaf armor, flower crown, nature staff, 48x48 pixel art` | `#2ecc71` |
| summer_merchant | `summer merchant NPC, sun hat, orange vest, trade goods backpack, 48x48 pixel art` | `#e67e22` |
| autumn_innkeeper | `autumn innkeeper NPC, brown apron, warm smile, carrying tray, 48x48 pixel art` | `#8b4513` |
| winter_priest | `winter priest NPC, white blue robes, ice crystal staff, gentle aura, 48x48 pixel art` | `#85c1e9` |

### Per-NPC steps:
1. Generate south-facing concept (48x48, reference: merchant NPC)
2. Create 4-direction rotation
3. Save to `game/assets/images/characters/npcs/{id}/rotations/{dir}.png`

---

## Phase C: Missing Portraits (64x64 large, 32x32 small)

Use `create-image-flux` with UI element generation.

### Large portraits (64x64):
Prompt template: `{character/NPC description} portrait icon, close-up face, pixel art, simple geometric style`

Missing large portraits:
- `cleric` - cleric face portrait, white gold hood, warm eyes
- `knight` - knight face portrait, steel helmet visor, blue plume
- `wizard` - wizard face portrait, purple pointed hat, long beard
- `ranger` - ranger face portrait, forest green hood mask, sharp eyes
- `red_warrior` through `hero` (8 character IDs from Phase A)
- `village_chief` through `winter_priest` (5 NPC IDs from Phase B)
- Enemy portraits: `slime`, `goblin`, `skeleton`, `bat`, `orc_warrior`, `skeleton_knight`, `wolf`, `dark_mage`, `orc_chieftain`, `vampire`, `demon` (11 enemies, `golem` + `demon` already exist)

### Small portraits (32x32):
Resize large portraits using `resize` tool to 32x32.

Save to: `game/assets/images/portraits/large/{id}.png` and `game/assets/images/portraits/small/{id}.png`

---

## Phase D: Empty UI Directory Assets

Use `create-ui-elements-pro` tool for all UI elements.

### login/ (login screen decorations)
| File | Size | Prompt |
|------|------|--------|
| `login_bg` | 1280x720 | `dark blue fantasy game login screen background, ornate gold border frame, subtle star pattern, pixel art` |
| `title_decoration` | 400x80 | `pixel art title banner decoration, gold diamond ornaments, thin gold lines, transparent background` |
| `login_frame` | 400x300 | `pixel art login panel frame, dark blue panel with gold ornate border, corner decorations` |

### character_select/ (character selection screen)
| File | Size | Prompt |
|------|------|--------|
| `char_slot_bg` | 180x240 | `pixel art character selection slot, dark panel with gold thin border, transparent background` |
| `char_slot_selected` | 180x240 | `pixel art selected character slot, glowing blue border, ornate gold corners, transparent background` |
| `class_icon_frame` | 64x64 | `pixel art class icon frame, circular gold border with gem accent` |

### chat/ (chat interface)
| File | Size | Prompt |
|------|------|--------|
| `chat_bg` | 350x150 | `pixel art chat panel background, dark semi-transparent, thin border, transparent background` |
| `chat_input_bg` | 330x30 | `pixel art chat input field, dark panel with subtle border, transparent background` |
| `chat_bubble` | 200x60 | `pixel art speech bubble, white with dark border, pointer triangle at bottom, transparent background` |

### menu/ (menu panels)
| File | Size | Prompt |
|------|------|--------|
| `menu_bg` | 200x250 | `pixel art menu panel, dark blue with gold ornate border, corner gems, transparent background` |
| `menu_item_bg` | 180x40 | `pixel art menu item background, dark panel subtle border, transparent background` |
| `menu_item_hover` | 180x40 | `pixel art menu item hover state, blue glow border, transparent background` |

---

## Generation Order

1. **Phase A** (characters) - most impactful, 8 characters x 8 directions = 64 images
2. **Phase B** (NPCs) - 5 NPCs x 4 directions = 20 images
3. **Phase C** (portraits) - ~30 portraits x 2 sizes = 60 images
4. **Phase D** (UI elements) - ~12 UI assets

**Total: ~156 images**

## Batch API Call Pattern

```
For each asset:
1. POST /v1/generate (or use MCP tool generate-pixel-art)
   - description: {prompt from table above}
   - size: {width}x{height}
   - style: simple geometric
   - no_background: true (for sprites/UI)
   - colors: {primary color from table}
   - reference_image: {path to style reference}
2. Save result to target path
3. For rotations: use rotate tool on the generated south-facing image
```
