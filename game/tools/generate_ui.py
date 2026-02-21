#!/usr/bin/env python3
"""
UI Assets Generator - Creates UI elements and portraits
"""

import requests
import base64
from pathlib import Path

API_KEY = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
OUTPUT_BASE = Path(__file__).parent.parent / "assets" / "images"


def create_image(desc, filename, size=(128, 64), no_bg=True):
    print(f"Creating: {filename}")
    data = {
        "description": desc,
        "image_size": {"width": size[0], "height": size[1]},
        "no_background": no_bg,
    }

    r = requests.post(f"{BASE_URL}/create-image-pixflux", headers=HEADERS, json=data)
    if r.status_code == 200:
        result = r.json()
        if "images" in result and result["images"]:
            img_data = result["images"][0]
            if img_data.startswith("data:image"):
                img_data = img_data.split(",")[1]

            img_bytes = base64.b64decode(img_data)
            filepath = OUTPUT_BASE / filename
            filepath.parent.mkdir(parents=True, exist_ok=True)
            with open(filepath, "wb") as f:
                f.write(img_bytes)
            print(f"  Saved: {filepath}")
            return True
    else:
        print(f"  Error: {r.status_code} - {r.text[:200]}")
    return False


def main():
    print("\nUI ASSETS GENERATOR\n")

    ui_elements = [
        # Login screen
        (
            "dark fantasy login panel with ornate border, geometric pixel art style, dark background",
            "ui/login/panel.png",
            (400, 300),
        ),
        (
            "glowing blue fantasy button with ornate edges, geometric pixel art",
            "ui/buttons/primary.png",
            (200, 50),
        ),
        (
            "dark stone button with golden border, geometric pixel art",
            "ui/buttons/secondary.png",
            (200, 50),
        ),
        (
            "input text field with dark border, geometric pixel art",
            "ui/login/input_field.png",
            (250, 40),
        ),
        # Character selection
        (
            "character selection panel with 4 slots, geometric pixel art style",
            "ui/character_select/panel.png",
            (500, 400),
        ),
        (
            "empty character slot frame, geometric pixel art style",
            "ui/character_select/slot_empty.png",
            (100, 120),
        ),
        (
            "create new character button, geometric pixel art style",
            "ui/character_select/create_button.png",
            (100, 40),
        ),
        # Chat box
        (
            "fantasy chat box frame with semi-transparent background, geometric pixel art",
            "ui/chat/frame.png",
            (350, 200),
        ),
        (
            "chat message input field, geometric pixel art",
            "ui/chat/input.png",
            (300, 30),
        ),
        # Menu
        (
            "fantasy game menu panel, geometric pixel art style",
            "ui/menu/panel.png",
            (200, 300),
        ),
        (
            "menu button with hover effect, geometric pixel art",
            "ui/menu/button.png",
            (160, 40),
        ),
        # HUD elements
        (
            "health bar background frame, geometric pixel art",
            "ui/hud/hp_bar_bg.png",
            (120, 24),
        ),
        (
            "green health bar fill, geometric pixel art",
            "ui/hud/hp_bar_fill.png",
            (116, 20),
        ),
        (
            "mana bar background frame, geometric pixel art",
            "ui/hud/mp_bar_bg.png",
            (120, 24),
        ),
        (
            "blue mana bar fill, geometric pixel art",
            "ui/hud/mp_bar_fill.png",
            (116, 20),
        ),
        (
            "experience bar background, geometric pixel art",
            "ui/hud/exp_bar_bg.png",
            (200, 16),
        ),
        (
            "golden experience bar fill, geometric pixel art",
            "ui/hud/exp_bar_fill.png",
            (196, 12),
        ),
        # Icons
        ("skill icon frame, geometric pixel art", "ui/icons/skill_frame.png", (48, 48)),
        (
            "inventory slot, geometric pixel art",
            "ui/icons/inventory_slot.png",
            (40, 40),
        ),
        ("gold coin icon, geometric pixel art", "ui/icons/gold.png", (24, 24)),
        ("heart health icon, geometric pixel art", "ui/icons/heart.png", (24, 24)),
        ("sword attack icon, geometric pixel art", "ui/icons/sword.png", (24, 24)),
        ("shield defense icon, geometric pixel art", "ui/icons/shield.png", (24, 24)),
        ("magic wand icon, geometric pixel art", "ui/icons/magic.png", (24, 24)),
        ("potion bottle icon, geometric pixel art", "ui/icons/potion.png", (24, 24)),
        # Panels
        (
            "inventory panel background, geometric pixel art style",
            "ui/panels/inventory.png",
            (300, 400),
        ),
        (
            "stats panel background, geometric pixel art style",
            "ui/panels/stats.png",
            (200, 300),
        ),
        (
            "equipment panel background, geometric pixel art style",
            "ui/panels/equipment.png",
            (250, 350),
        ),
        (
            "quest log panel, geometric pixel art style",
            "ui/panels/quest_log.png",
            (350, 400),
        ),
        # Battle UI
        (
            "battle action menu panel, geometric pixel art",
            "ui/battle/action_panel.png",
            (200, 150),
        ),
        (
            "battle enemy info panel, geometric pixel art",
            "ui/battle/enemy_info.png",
            (250, 80),
        ),
        (
            "battle player info panel, geometric pixel art",
            "ui/battle/player_info.png",
            (250, 100),
        ),
    ]

    completed = 0
    for desc, path, size in ui_elements:
        if create_image(desc, path, size):
            completed += 1

    print(f"\nCompleted: {completed}/{len(ui_elements)} UI elements")


if __name__ == "__main__":
    main()
