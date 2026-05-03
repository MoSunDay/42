#!/usr/bin/env python3
"""
UI Asset Manifest - Complete definitions for all ~104 UI assets.
Run this script to batch-generate all UI assets via Pixellab API v2.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pixellab_client import AssetJob, batch_generate, OUTPUT_BASE

STYLE_PREFIX = "fantasy RPG pixel art, dark navy blue and gold theme, "
ICON_STYLE = "pixel art game icon, 32x32, simple geometric style, "

all_assets: list[AssetJob] = []


def icon(name, desc, palette=None):
    all_assets.append(
        AssetJob(
            category="icons",
            filename=name,
            prompt=f"{ICON_STYLE}{desc}",
            width=32,
            height=32,
            no_background=True,
            color_palette=palette,
        )
    )


def btn(name, desc, w=48, h=24, palette=None):
    all_assets.append(
        AssetJob(
            category="buttons",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=w,
            height=h,
            no_background=True,
            color_palette=palette,
        )
    )


def bar(name, desc, w=64, h=16, palette=None, no_bg=True):
    all_assets.append(
        AssetJob(
            category="bars",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=w,
            height=h,
            no_background=no_bg,
            color_palette=palette,
        )
    )


def tab(name, desc, palette=None):
    all_assets.append(
        AssetJob(
            category="tabs",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=48,
            height=24,
            no_background=True,
            color_palette=palette,
        )
    )


def slot(name, desc, palette=None):
    all_assets.append(
        AssetJob(
            category="slots",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=48,
            height=48,
            no_background=True,
            color_palette=palette,
        )
    )


def panel(name, desc, w, h, palette=None, no_bg=True):
    all_assets.append(
        AssetJob(
            category="panels",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=w,
            height=h,
            no_background=no_bg,
            color_palette=palette,
        )
    )


def border(name, desc, palette=None):
    all_assets.append(
        AssetJob(
            category="borders",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=32,
            height=32,
            no_background=True,
            color_palette=palette,
        )
    )


def inp(name, desc, w, h, palette=None, no_bg=True):
    all_assets.append(
        AssetJob(
            category="input",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=w,
            height=h,
            no_background=no_bg,
            color_palette=palette,
        )
    )


def dlg(name, desc, w, h, palette=None, no_bg=True):
    all_assets.append(
        AssetJob(
            category="dialog",
            filename=name,
            prompt=f"{STYLE_PREFIX}{desc}",
            width=w,
            height=h,
            no_background=no_bg,
            color_palette=palette,
        )
    )


def effect(name, desc, w, h, palette=None):
    all_assets.append(
        AssetJob(
            category="effects",
            filename=name,
            prompt=f"pixel art battle effect sprite, {desc}",
            width=w,
            height=h,
            no_background=True,
            color_palette=palette,
        )
    )


def cls_icon(name, desc, palette=None):
    all_assets.append(
        AssetJob(
            category="classes",
            filename=name,
            prompt=f"{ICON_STYLE}{desc}",
            width=64,
            height=64,
            no_background=True,
            color_palette=palette,
        )
    )


# ============================================================
# Phase 0: Icons (33 assets, 32x32)
# ============================================================
icon("attack", "crossed swords attack icon, red and silver blades", "red and silver")
icon("auto", "gear cog auto-battle icon, grey and cyan", "grey and cyan")
icon("bow", "wooden bow with arrow icon, brown and green", "brown and green")
icon("check", "green checkmark icon in circle", "green")
icon("close", "red X close button icon in circle", "red")
icon("clothes", "armor chest piece icon, brown leather", "brown")
icon("dagger", "dagger knife icon, silver blade purple handle", "silver and purple")
icon("defend", "shield defense icon, blue and silver", "blue and silver")
icon("equipment", "knight helmet equipment icon, gold and steel", "gold")
icon("escape", "running feet escape icon, grey", "grey")
icon("fire", "flame fire spell icon, red orange yellow", "red and orange")
icon("hat", "wizard hat icon, brown with buckle", "brown")
icon("heal", "cross heal icon, green and white", "green and white")
icon("hp_potion", "red health potion bottle icon, red liquid glass bottle", "red")
icon("ice", "ice crystal icon, cyan and white", "cyan and white")
icon("inventory", "backpack bag inventory icon, brown and gold", "brown and gold")
icon("item", "treasure chest item icon, gold and brown", "gold and brown")
icon("lightning", "lightning bolt icon, yellow and white", "yellow")
icon("map", "scroll map icon, parchment and brown", "parchment brown")
icon("minus", "minus sign icon in red circle", "red")
icon("mp_potion", "blue mana potion bottle icon, blue liquid glass bottle", "blue")
icon("necklace", "gem necklace jewelry icon, gold chain gem pendant", "gold")
icon("party", "group of people party icon, blue", "blue")
icon("pet", "animal paw print pet icon, brown", "brown")
icon("plus", "plus sign icon in green circle", "green")
icon("quest", "exclamation mark quest icon, yellow", "yellow")
icon("settings", "gear settings icon, grey", "grey")
icon("shield", "knight shield icon, blue and silver", "blue and silver")
icon("shoes", "boots shoes icon, brown leather", "brown")
icon("staff", "magic staff wand icon, purple crystal gold shaft", "purple and gold")
icon("sword", "long sword icon, silver blade gold hilt", "silver and gold")
icon("weapon", "battle axe weapon icon, silver and brown", "silver and brown")
icon("x", "X mark icon, red on dark background", "red")

# ============================================================
# Phase 1: Buttons (10), Bars (12), Tabs (4), Slots (4)
# ============================================================
btn(
    "button_normal",
    "empty blank button, plain dark navy blue rectangle with thin gold border, no symbols no text no decoration inside, solid fill, pixel art game UI",
    palette="dark navy blue and gold",
)
btn(
    "button_hover",
    "empty blank button hover state, plain dark navy blue rectangle with bright gold glowing border, no symbols no text no decoration inside, pixel art game UI",
    palette="navy blue and bright gold",
)
btn(
    "button_pressed",
    "empty blank button pressed state, plain dark navy blue rectangle with inset darker gold border, no symbols no text no decoration inside, pixel art game UI",
    palette="navy blue and gold",
)
btn(
    "button_disabled",
    "empty blank disabled button, plain dark grey rectangle with dim grey border, no symbols no text no decoration inside, pixel art game UI",
    palette="dark grey",
)
btn(
    "button_accent_normal",
    "empty blank accent button, plain teal cyan rectangle with thin white border, no symbols no text no decoration inside, pixel art game UI",
    palette="teal cyan and white",
)
btn(
    "button_accent_hover",
    "empty blank accent button hover, plain teal cyan rectangle with bright white glowing border, no symbols no text no decoration inside, pixel art game UI",
    palette="teal cyan and bright white",
)
btn(
    "button_small_normal",
    "small empty blank button, plain dark navy square with gold border, no symbols no text, pixel art",
    w=32,
    h=32,
    palette="navy blue and gold",
)
btn(
    "button_small_hover",
    "small empty blank button hover, plain dark navy square with bright gold glow border, no symbols no text, pixel art",
    w=32,
    h=32,
    palette="navy blue and gold",
)
btn(
    "button_small_pressed",
    "small empty blank button pressed, plain dark navy square with inset border, no symbols no text, pixel art",
    w=32,
    h=32,
    palette="navy blue and gold",
)
btn(
    "button_small_disabled",
    "small empty blank disabled button, plain dark grey square with dim border, no symbols no text, pixel art",
    w=32,
    h=32,
    palette="dark grey",
)

bar(
    "hp_bar_bg",
    "health bar background frame, dark panel with thin border, pixel art UI",
    palette="dark navy",
)
bar(
    "hp_bar_high",
    "health bar fill green high HP, bright green fill, pixel art UI bar",
    palette="bright green",
)
bar(
    "hp_bar_medium",
    "health bar fill yellow medium HP, yellow fill, pixel art UI bar",
    palette="yellow",
)
bar(
    "hp_bar_low",
    "health bar fill red low HP, red fill, pixel art UI bar",
    palette="red",
)
bar(
    "hp_bar_small_bg",
    "small health bar background, dark panel, pixel art",
    w=32,
    h=32,
    palette="dark navy",
)
bar(
    "hp_bar_small_high",
    "small health bar green fill, pixel art",
    w=32,
    h=32,
    palette="green",
)
bar(
    "mp_bar_bg",
    "mana bar background frame, dark panel with thin border, pixel art UI",
    palette="dark navy",
)
bar(
    "mp_bar_fill",
    "mana bar blue fill, bright blue fill, pixel art UI bar",
    palette="blue",
)
bar(
    "mp_bar_small_bg",
    "small mana bar background, dark panel, pixel art",
    w=32,
    h=32,
    palette="dark navy",
)
bar(
    "mp_bar_small_fill",
    "small mana bar blue fill, pixel art",
    w=32,
    h=32,
    palette="blue",
)
bar(
    "exp_bar_bg",
    "experience bar background frame, dark panel, pixel art UI",
    palette="dark navy",
)
bar(
    "exp_bar_fill",
    "experience bar golden fill, gold amber fill, pixel art UI bar",
    palette="gold",
)

tab(
    "tab_active",
    "active tab button, bright gold border on dark navy, selected state, pixel art",
    palette="gold and navy",
)
tab(
    "tab_inactive",
    "inactive tab button, dim grey border on dark panel, pixel art",
    palette="grey and dark navy",
)
tab(
    "tab_small_active",
    "small active tab, bright gold border, pixel art",
    palette="gold and navy",
)
tab("tab_small_inactive", "small inactive tab, dim border, pixel art", palette="grey")

slot(
    "slot_normal",
    "inventory slot normal state, dark panel with thin border, pixel art",
    palette="dark navy and grey",
)
slot(
    "slot_hover",
    "inventory slot hover state, blue glow border, pixel art",
    palette="blue glow",
)
slot(
    "slot_selected",
    "inventory slot selected state, gold border highlight, pixel art",
    palette="gold",
)
slot(
    "slot_equipment",
    "equipment slot, green border indicating equipped, pixel art",
    palette="green",
)

# ============================================================
# Phase 2: Panels (6), Borders (3), Input (4)
# ============================================================
panel(
    "small_panel",
    "small UI panel background, dark navy semi-transparent with gold border, pixel art",
    64,
    64,
    palette="dark navy and gold",
)
panel(
    "menu_panel",
    "menu panel background, dark navy with gold ornate border, pixel art",
    80,
    80,
    palette="dark navy and gold",
)
panel(
    "chat_panel",
    "chat panel background, dark semi-transparent panel, pixel art",
    100,
    60,
    palette="dark navy semi-transparent",
)
panel(
    "login_panel",
    "login screen panel, dark navy panel with gold ornate border, pixel art",
    80,
    120,
    palette="dark navy and gold",
)
panel(
    "character_select_panel",
    "character selection panel, dark navy with gold border, pixel art",
    80,
    100,
    palette="dark navy and gold",
)
panel(
    "battle_panel",
    "battle UI panel, dark navy with gold border, pixel art",
    100,
    50,
    palette="dark navy and gold",
)

border(
    "panel_border",
    "gold ornate panel border decoration, pixel art frame corner",
    palette="gold",
)
border(
    "panel_border_small",
    "small gold panel border, thin gold frame, pixel art",
    palette="gold",
)
border(
    "panel_border_thick",
    "thick gold ornate panel border, pixel art frame",
    palette="gold",
)

inp(
    "input_field",
    "text input field, dark panel with subtle border, pixel art UI",
    64,
    24,
    palette="dark navy",
)
inp(
    "input_field_active",
    "active text input field, bright border glow, pixel art UI",
    64,
    24,
    palette="cyan glow",
)
inp(
    "input_field_small",
    "small text input field, dark panel, pixel art UI",
    48,
    32,
    palette="dark navy",
)
inp(
    "input_field_small_active",
    "small active text input field, bright border, pixel art UI",
    48,
    32,
    palette="cyan glow",
)

# ============================================================
# Phase 3: Dialog (3), Chat (2), Menu (2), Loading (3), Minimap (2)
# ============================================================
dlg(
    "dialog_panel",
    "NPC dialog panel, dark navy with gold border, speech bubble frame, pixel art",
    80,
    64,
    palette="dark navy and gold",
)
dlg(
    "dialog_wide",
    "wide dialog panel, dark navy with gold border, pixel art",
    100,
    50,
    palette="dark navy and gold",
)
dlg(
    "tooltip_bg",
    "tooltip background, dark semi-transparent panel, pixel art",
    64,
    32,
    palette="dark semi-transparent",
)

all_assets.append(
    AssetJob(
        category="chat",
        filename="chat_bg",
        prompt=f"{STYLE_PREFIX}chat window background, dark navy semi-transparent panel with thin border",
        width=350,
        height=150,
        no_background=True,
        color_palette="dark navy semi-transparent",
    )
)
all_assets.append(
    AssetJob(
        category="chat",
        filename="chat_input_bg",
        prompt=f"{STYLE_PREFIX}chat text input background, dark panel with subtle border",
        width=330,
        height=30,
        no_background=True,
        color_palette="dark navy",
    )
)

all_assets.append(
    AssetJob(
        category="menu",
        filename="menu_bg",
        prompt=f"{STYLE_PREFIX}game menu panel background, dark navy with gold ornate border, corner decorations",
        width=200,
        height=250,
        no_background=True,
        color_palette="dark navy and gold",
    )
)
all_assets.append(
    AssetJob(
        category="menu",
        filename="menu_item_bg",
        prompt=f"{STYLE_PREFIX}menu item background, dark panel with subtle border",
        width=180,
        height=40,
        no_background=True,
        color_palette="dark navy",
    )
)

all_assets.append(
    AssetJob(
        category="loading",
        filename="loading_panel",
        prompt=f"{STYLE_PREFIX}loading screen panel, dark background with gold border",
        width=100,
        height=60,
        no_background=True,
        color_palette="dark navy and gold",
    )
)
all_assets.append(
    AssetJob(
        category="loading",
        filename="loading_bar_bg",
        prompt=f"{STYLE_PREFIX}loading bar background, dark panel with border",
        width=64,
        height=16,
        no_background=True,
        color_palette="dark navy",
    )
)
all_assets.append(
    AssetJob(
        category="loading",
        filename="loading_bar_fill",
        prompt=f"{STYLE_PREFIX}loading bar fill, cyan blue gradient fill",
        width=64,
        height=16,
        no_background=True,
        color_palette="cyan blue",
    )
)

all_assets.append(
    AssetJob(
        category="minimap",
        filename="minimap_frame",
        prompt=f"{STYLE_PREFIX}minimap circular frame border, gold ornate frame, pixel art",
        width=64,
        height=64,
        no_background=True,
        color_palette="gold",
    )
)
all_assets.append(
    AssetJob(
        category="minimap",
        filename="minimap_label",
        prompt=f"{STYLE_PREFIX}minimap label background, small dark panel, pixel art",
        width=64,
        height=20,
        no_background=True,
        color_palette="dark navy",
    )
)

# ============================================================
# Phase 4: Login (2), Character Select (2), Classes (8), Effects (8)
# ============================================================
all_assets.append(
    AssetJob(
        category="login",
        filename="login_bg",
        prompt="fantasy RPG pixel art login screen background, dark blue starry night sky, ornate gold border frame, subtle magic particles",
        width=400,
        height=225,
        no_background=False,
        color_palette="dark navy blue and gold",
    )
)
all_assets.append(
    AssetJob(
        category="login",
        filename="title_decoration",
        prompt="pixel art title banner decoration, gold diamond ornaments, thin gold lines, transparent background, ornate frame",
        width=400,
        height=80,
        no_background=True,
        color_palette="gold",
    )
)

all_assets.append(
    AssetJob(
        category="character_select",
        filename="char_slot_bg",
        prompt="empty blank character card slot frame, dark navy panel with thin gold border, completely empty inside, no text no symbols no character, transparent background, pixel art",
        width=180,
        height=240,
        no_background=True,
        color_palette="dark navy and gold",
    )
)
all_assets.append(
    AssetJob(
        category="character_select",
        filename="char_slot_selected",
        prompt="empty blank selected character card slot frame, glowing blue border, gold corner accents, completely empty inside, no text no symbols no character, transparent background, pixel art",
        width=180,
        height=240,
        no_background=True,
        color_palette="blue glow and gold",
    )
)

cls_icon("warrior", "warrior class icon, heavy sword, red and steel", "red and steel")
cls_icon("mage", "mage class icon, magic staff, purple robes", "purple")
cls_icon("archer", "archer class icon, bow and arrow, green", "green")
cls_icon("rogue", "rogue class icon, daggers, dark grey hood", "dark grey")
cls_icon("cleric", "cleric class icon, holy cross staff, white gold", "white and gold")
cls_icon("knight", "knight class icon, shield and sword, blue steel", "blue and steel")
cls_icon("wizard", "wizard class icon, pointed hat magic book, purple", "purple")
cls_icon("ranger", "ranger class icon, dual blades, teal green", "teal green")

effect(
    "effect_hit",
    "impact hit effect, white flash burst, 48x48",
    48,
    48,
    "white and yellow",
)
effect("effect_heal", "healing effect, green sparkles rising, 48x48", 48, 48, "green")
effect("effect_levelup", "level up effect, golden light burst, 64x64", 64, 64, "gold")
effect("effect_debuff", "debuff effect, purple poison drops, 32x32", 32, 32, "purple")
effect("effect_buff", "buff effect, blue aura glow, 32x32", 32, 32, "blue")
effect(
    "effect_attack_slash", "sword slash attack effect, red arc, 64x64", 64, 64, "red"
)
effect(
    "effect_attack_impact",
    "impact shockwave effect, white rings, 48x48",
    48,
    48,
    "white",
)
effect(
    "effect_critical",
    "critical hit explosion effect, golden sparks, 48x48",
    48,
    48,
    "gold and red",
)

# ============================================================
# Phase 5: Battle Backgrounds (6 assets, large)
# ============================================================
all_assets.append(
    AssetJob(
        category="battle_bg",
        filename="forest",
        prompt="pixel art RPG battle background, enchanted forest scene, tall ancient trees, lush green canopy, dappled sunlight, mystical fog, fantasy atmosphere",
        width=688,
        height=384,
        no_background=False,
        color_palette="dark green and brown",
    )
)
all_assets.append(
    AssetJob(
        category="battle_bg",
        filename="desert",
        prompt="pixel art RPG battle background, vast desert scene, sand dunes, hot sun glare, distant pyramids, heat haze, fantasy atmosphere",
        width=688,
        height=384,
        no_background=False,
        color_palette="sandy yellow and orange",
    )
)
all_assets.append(
    AssetJob(
        category="battle_bg",
        filename="dungeon",
        prompt="pixel art RPG battle background, dark dungeon cavern, stone brick walls, torchlight, cobwebs, ominous shadows, fantasy atmosphere",
        width=688,
        height=384,
        no_background=False,
        color_palette="dark grey and purple",
    )
)
all_assets.append(
    AssetJob(
        category="battle_bg",
        filename="sky",
        prompt="pixel art RPG battle background, sky floating islands scene, clouds, mountain peaks, sunset colors, wind, fantasy atmosphere",
        width=688,
        height=384,
        no_background=False,
        color_palette="blue and orange sunset",
    )
)
all_assets.append(
    AssetJob(
        category="battle_bg",
        filename="volcanic",
        prompt="pixel art RPG battle background, volcanic lava field, molten lava rivers, smoke, ash, red glow, dark sky, fantasy atmosphere",
        width=688,
        height=384,
        no_background=False,
        color_palette="red orange and black",
    )
)
all_assets.append(
    AssetJob(
        category="battle_bg",
        filename="boss",
        prompt="pixel art RPG battle background, dark throne room, evil lair, purple crystals, dark magic aura, ominous pillars, fantasy boss arena",
        width=688,
        height=384,
        no_background=False,
        color_palette="dark purple and red",
    )
)


_replace = False


def print_usage():
    print(
        f"Usage: {sys.argv[0]} [--replace] [all|phase0|...|phase5|list|status|restore]"
    )
    print(f"  --replace  - Backup existing assets and regenerate")
    print(f"  all        - Generate all phases")
    print(f"  phase0     - Icons (33 assets)")
    print(f"  phase1     - Buttons + Bars + Tabs + Slots (30 assets)")
    print(f"  phase2     - Panels + Borders + Input (13 assets)")
    print(f"  phase3     - Dialog + Chat + Menu + Loading + Minimap (12 assets)")
    print(f"  phase4     - Login + CharSelect + Classes + Effects (20 assets)")
    print(f"  phase5     - Battle Backgrounds (6 assets)")
    print(f"  list       - List all assets with details")
    print(f"  status     - Quick status check")
    print(f"  restore    - Restore .bak files")


def run_phase(phase: int):
    phase_ranges = {
        0: (0, 33),
        1: (33, 63),
        2: (63, 76),
        3: (76, 88),
        4: (88, 108),
        5: (108, 114),
    }
    start, end = phase_ranges.get(phase, (0, len(all_assets)))
    jobs = all_assets[start:end]
    use_pixflux = phase == 0
    batch_generate(jobs, use_pixflux=use_pixflux, replace=_replace)


def run_all():
    for phase in range(6):
        print(f"\n{'#' * 60}")
        print(f"# Phase {phase}")
        print(f"{'#' * 60}")
        run_phase(phase)


if __name__ == "__main__":
    args = sys.argv[1:]
    if "--replace" in args:
        _replace = True
        args.remove("--replace")

    if args:
        arg = args[0]
        if arg == "all":
            run_all()
        elif arg.startswith("phase"):
            run_phase(int(arg.replace("phase", "")))
        elif arg == "restore":
            for p in OUTPUT_BASE.rglob("*.bak"):
                target = p.with_suffix("")
                p.rename(target)
                print(f"  Restored: {target.relative_to(OUTPUT_BASE)}")
            print("Done.")
        elif arg == "list":
            for i, job in enumerate(all_assets):
                exists = "EXISTS" if job.output_path.exists() else "MISSING"
                print(f"  [{i:3d}] {exists:7s} {job.key} ({job.width}x{job.height})")
            print(f"\nTotal: {len(all_assets)} assets")
            missing = sum(1 for j in all_assets if not j.output_path.exists())
            print(f"Missing: {missing}, Existing: {len(all_assets) - missing}")
        elif arg == "status":
            for i, job in enumerate(all_assets):
                exists = job.output_path.exists()
                print(f"  [{i:3d}] {'OK' if exists else '--':2s} {job.key}")
            missing = sum(1 for j in all_assets if not j.output_path.exists())
            print(f"\nMissing: {missing}/{len(all_assets)}")
        else:
            print_usage()
    else:
        print_usage()
