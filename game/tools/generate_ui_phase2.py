#!/usr/bin/env python3
"""
UI Asset Generator - Phase 2
Generates battle backgrounds, inventory slots, dialogs, loading screens,
class icons, and battle effects.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE_DIR = "assets/images/ui"

COLORS = {
    "accent": (233, 69, 96),
    "accent_alt": (78, 205, 196),
    "accent_blue": (69, 182, 209),
    "panel": (22, 33, 62),
    "panel_light": (31, 42, 72),
    "panel_dark": (15, 52, 96),
    "border": (69, 182, 209),
    "text": (232, 232, 232),
    "text_dim": (160, 160, 160),
    "background": (26, 26, 46),
    "success": (51, 204, 77),
    "warning": (243, 191, 51),
    "error": (230, 77, 77),
    "hp_high": (51, 204, 77),
    "hp_medium": (230, 219, 51),
    "hp_low": (230, 77, 77),
}

BATTLE_BG_COLORS = {
    "forest": {
        "gradient1": (18, 30, 18),
        "gradient2": (30, 46, 26),
        "ground": (51, 64, 38),
        "decor": (30, 77, 38),
    },
    "desert": {
        "gradient1": (46, 36, 22),
        "gradient2": (66, 51, 33),
        "ground": (79, 64, 46),
        "decor": (128, 102, 64),
    },
    "dungeon": {
        "gradient1": (15, 15, 20),
        "gradient2": (26, 26, 36),
        "ground": (20, 20, 25),
        "decor": (46, 38, 51),
    },
    "boss": {
        "gradient1": (20, 10, 15),
        "gradient2": (46, 20, 30),
        "ground": (30, 15, 20),
        "decor": (128, 38, 51),
    },
    "sky": {
        "gradient1": (30, 36, 66),
        "gradient2": (46, 51, 79),
        "ground": (128, 140, 153),
        "decor": (179, 201, 230),
    },
    "volcanic": {
        "gradient1": (46, 15, 5),
        "gradient2": (66, 26, 10),
        "ground": (51, 20, 10),
        "decor": (230, 102, 38),
    },
}

CLASS_COLORS = {
    "warrior": (179, 102, 77),
    "mage": (102, 128, 204),
    "archer": (102, 179, 102),
    "rogue": (128, 102, 128),
    "cleric": (230, 230, 153),
    "knight": (153, 153, 179),
    "wizard": (179, 102, 204),
    "ranger": (128, 179, 128),
}


def create_gradient_bg(width, height, colors, diagonal=True):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if diagonal:
        for i in range(width + height):
            t = i / (width + height)
            r = int(
                colors["gradient1"][0]
                + t * (colors["gradient2"][0] - colors["gradient1"][0])
            )
            g = int(
                colors["gradient1"][1]
                + t * (colors["gradient2"][1] - colors["gradient1"][1])
            )
            b = int(
                colors["gradient1"][2]
                + t * (colors["gradient2"][2] - colors["gradient1"][2])
            )

            for y in range(max(0, i - width), min(height, i)):
                x = i - y
                if 0 <= x < width:
                    draw.point((x, y), (r, g, b, 255))
    else:
        for y in range(height):
            t = y / height
            r = int(
                colors["gradient1"][0]
                + t * (colors["gradient2"][0] - colors["gradient1"][0])
            )
            g = int(
                colors["gradient1"][1]
                + t * (colors["gradient2"][1] - colors["gradient1"][1])
            )
            b = int(
                colors["gradient1"][2]
                + t * (colors["gradient2"][2] - colors["gradient1"][2])
            )
            draw.line([(0, y), (width, y)], (r, g, b, 255))

    return img


def draw_rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def generate_battle_backgrounds():
    print("Generating battle backgrounds...")
    os.makedirs(f"{BASE_DIR}/battle_bg", exist_ok=True)

    width, height = 1280, 720

    for bg_type, colors in BATTLE_BG_COLORS.items():
        img = create_gradient_bg(width, height, colors)
        draw = ImageDraw.Draw(img)

        ground_y = int(height * 0.6)
        for y in range(ground_y, height):
            alpha = int(255 * 0.4 * (1 - (y - ground_y) / (height - ground_y) * 0.5))
            c = colors["ground"]
            draw.line([(0, y), (width, y)], (c[0], c[1], c[2], alpha))

        for i in range(5):
            x = 100 + i * 250
            h = 30 + (i * 37) % 50
            c = colors["decor"]
            for dy in range(h):
                spread = int(dy * 0.3)
                alpha = int(255 * (1 - dy / h) * 0.5)
                draw.line(
                    [
                        (x - spread, height - ground_y // 2 - dy),
                        (x + spread, height - ground_y // 2 - dy),
                    ],
                    (c[0], c[1], c[2], alpha),
                )

        filepath = f"{BASE_DIR}/battle_bg/{bg_type}.png"
        img.save(filepath)
        print(f"  Created {filepath}")


def generate_inventory_slots():
    print("Generating inventory slots...")
    os.makedirs(f"{BASE_DIR}/slots", exist_ok=True)

    size = 60
    radius = 8

    slot_configs = [
        ("slot_normal", COLORS["panel"], COLORS["border"], 1),
        ("slot_hover", COLORS["panel_light"], COLORS["accent_blue"], 2),
        ("slot_selected", COLORS["panel_dark"], COLORS["accent"], 2),
        ("slot_equipment", COLORS["panel"], COLORS["success"], 2),
    ]

    for name, fill, outline, width in slot_configs:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        draw_rounded_rect(
            draw,
            (2, 2, size - 3, size - 3),
            radius,
            fill + (255,),
            outline + (255,),
            width,
        )

        filepath = f"{BASE_DIR}/slots/{name}.png"
        img.save(filepath)
        print(f"  Created {filepath}")


def generate_dialog_assets():
    print("Generating dialog assets...")
    os.makedirs(f"{BASE_DIR}/dialog", exist_ok=True)

    configs = [
        ("dialog_panel", (500, 200), 15),
        ("dialog_wide", (600, 150), 12),
        ("tooltip_bg", (250, 120), 10),
    ]

    for name, size, radius in configs:
        img = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        draw_rounded_rect(
            draw,
            (2, 2, size[0] - 3, size[1] - 3),
            radius,
            COLORS["panel"] + (240,),
            COLORS["border"] + (255,),
            2,
        )

        filepath = f"{BASE_DIR}/dialog/{name}.png"
        img.save(filepath)
        print(f"  Created {filepath}")


def generate_loading_assets():
    print("Generating loading assets...")
    os.makedirs(f"{BASE_DIR}/loading", exist_ok=True)

    bar_configs = [
        ("loading_bar_bg", (300, 20), COLORS["panel_dark"]),
        ("loading_bar_fill", (300, 20), COLORS["accent_blue"]),
        ("loading_panel", (400, 300), None),
    ]

    for name, size, fill_color in bar_configs:
        img = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        if "panel" in name:
            draw_rounded_rect(
                draw,
                (2, 2, size[0] - 3, size[1] - 3),
                15,
                COLORS["background"] + (240,),
                COLORS["border"] + (255,),
                2,
            )
        else:
            draw_rounded_rect(
                draw,
                (1, 1, size[0] - 2, size[1] - 2),
                5,
                fill_color + (255,),
                COLORS["border"] + (200,),
                1,
            )

        filepath = f"{BASE_DIR}/loading/{name}.png"
        img.save(filepath)
        print(f"  Created {filepath}")


def draw_class_icon(draw, size, color, class_type):
    cx, cy = size // 2, size // 2
    r = size // 2 - 8

    draw.ellipse(
        [cx - r, cy - r, cx + r, cy + r],
        fill=color + (255,),
        outline=COLORS["border"] + (255,),
        width=2,
    )

    inner_r = r - 6
    symbols = {
        "warrior": [(-8, 0), (8, 0), (0, -12), (0, 12)],
        "mage": [(-6, -6), (6, -6), (0, 8)],
        "archer": [(0, -10), (-8, 8), (8, 8)],
        "rogue": [(-6, -6), (6, -6), (-6, 6), (6, 6)],
        "cleric": [(0, -10), (-6, 0), (6, 0), (0, 10)],
        "knight": [(-8, -5), (8, -5), (0, 10)],
        "wizard": [(0, -12), (-8, 4), (8, 4)],
        "ranger": [(-8, 0), (8, 0), (0, -8), (0, 8)],
    }

    for point in symbols.get(class_type, []):
        draw.ellipse(
            [
                cx + point[0] - 3,
                cy + point[1] - 3,
                cx + point[0] + 3,
                cy + point[1] + 3,
            ],
            fill=COLORS["text"] + (255,),
        )


def generate_class_icons():
    print("Generating class icons...")
    os.makedirs(f"{BASE_DIR}/classes", exist_ok=True)

    size = 64

    for class_type, color in CLASS_COLORS.items():
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        draw_class_icon(draw, size, color, class_type)

        filepath = f"{BASE_DIR}/classes/{class_type}.png"
        img.save(filepath)
        print(f"  Created {filepath}")


def generate_battle_effects():
    print("Generating battle effects...")
    os.makedirs(f"{BASE_DIR}/effects", exist_ok=True)

    effect_configs = [
        ("effect_hit", 48, COLORS["warning"]),
        ("effect_heal", 48, COLORS["success"]),
        ("effect_levelup", 64, COLORS["warning"]),
        ("effect_attack_slash", 64, COLORS["accent"]),
        ("effect_attack_impact", 48, COLORS["accent_alt"]),
        ("effect_buff", 32, COLORS["accent_blue"]),
        ("effect_debuff", 32, COLORS["error"]),
        ("effect_critical", 48, COLORS["warning"]),
    ]

    for name, size, color in effect_configs:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        cx, cy = size // 2, size // 2

        for i in range(4, 0, -1):
            r = (size // 2 - 4) * i // 4
            alpha = int(255 * (5 - i) / 4)
            draw.ellipse(
                [cx - r, cy - r, cx + r, cy + r],
                fill=color + (alpha // 2,),
                outline=color + (alpha,),
            )

        if "hit" in name or "impact" in name:
            for angle in range(0, 360, 45):
                import math

                rad = math.radians(angle)
                x1 = cx + int(math.cos(rad) * 8)
                y1 = cy + int(math.sin(rad) * 8)
                x2 = cx + int(math.cos(rad) * (size // 2 - 4))
                y2 = cy + int(math.sin(rad) * (size // 2 - 4))
                draw.line([(x1, y1), (x2, y2)], fill=color + (255,), width=2)

        filepath = f"{BASE_DIR}/effects/{name}.png"
        img.save(filepath)
        print(f"  Created {filepath}")


def main():
    print("=" * 50)
    print("Phase 2: UI Asset Generation")
    print("=" * 50)

    generate_battle_backgrounds()
    generate_inventory_slots()
    generate_dialog_assets()
    generate_loading_assets()
    generate_class_icons()
    generate_battle_effects()

    print("\n" + "=" * 50)
    print("Phase 2 Complete!")
    print("=" * 50)


if __name__ == "__main__":
    main()
