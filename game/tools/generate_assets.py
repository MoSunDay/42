#!/usr/bin/env python3
"""
Asset Generator for Turn-Based RPG
Uses Pixellab API to generate all game assets with consistent style
"""

import requests
import time
import json
import os
import zipfile
import io
from pathlib import Path

API_KEY = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"

HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}

STYLE_PARAMS = {
    "outline": "medium",
    "shading": "soft",
    "detail": "medium",
    "view": "low top-down",
}

PLAYER_CLASSES = [
    {
        "id": "warrior",
        "desc": "warrior in heavy red armor with large sword, geometric pixel art style, clean lines",
    },
    {
        "id": "mage",
        "desc": "mage in purple robes with glowing staff, geometric pixel art style, clean lines",
    },
    {
        "id": "archer",
        "desc": "archer in green light armor with bow, geometric pixel art style, clean lines",
    },
    {
        "id": "rogue",
        "desc": "rogue in dark leather armor with daggers, geometric pixel art style, clean lines",
    },
    {
        "id": "cleric",
        "desc": "cleric in white robes with holy symbol, geometric pixel art style, clean lines",
    },
    {
        "id": "knight",
        "desc": "knight in blue plate armor with shield, geometric pixel art style, clean lines",
    },
    {
        "id": "wizard",
        "desc": "wizard in purple hat and robes with magic book, geometric pixel art style, clean lines",
    },
    {
        "id": "ranger",
        "desc": "ranger in green cloak with dual blades, geometric pixel art style, clean lines",
    },
]

ENEMIES = [
    {
        "id": "slime",
        "desc": "cute green slime blob, geometric pixel art style, simple round shape",
    },
    {
        "id": "goblin",
        "desc": "small brown goblin with pointy ears, geometric pixel art style, clean lines",
    },
    {
        "id": "skeleton",
        "desc": "white skeleton warrior with sword, geometric pixel art style, clean lines",
    },
    {
        "id": "bat",
        "desc": "purple vampire bat with spread wings, geometric pixel art style, simple shape",
    },
    {
        "id": "orc_warrior",
        "desc": "green orc warrior with axe, geometric pixel art style, clean lines",
    },
    {
        "id": "skeleton_knight",
        "desc": "armored skeleton knight with shield, geometric pixel art style, clean lines",
    },
    {
        "id": "wolf",
        "desc": "gray dire wolf with glowing eyes, geometric pixel art style, clean lines",
    },
    {
        "id": "dark_mage",
        "desc": "dark purple mage with shadow magic, geometric pixel art style, clean lines",
    },
    {
        "id": "orc_chieftain",
        "desc": "large green orc chieftain with battle axe, geometric pixel art style, clean lines",
    },
    {
        "id": "vampire",
        "desc": "elegant vampire lord in dark red cape, geometric pixel art style, clean lines",
    },
    {
        "id": "golem",
        "desc": "stone golem with rocky body, geometric pixel art style, clean lines",
    },
    {
        "id": "demon",
        "desc": "red demon with horns and flames, geometric pixel art style, clean lines",
    },
    {
        "id": "ancient_dragon",
        "desc": "golden ancient dragon with wings, geometric pixel art style, clean lines",
    },
    {
        "id": "lich_king",
        "desc": "dark lich king with skull staff, geometric pixel art style, clean lines",
    },
    {
        "id": "chaos_serpent",
        "desc": "purple chaos serpent dragon, geometric pixel art style, clean lines",
    },
]

NPCS = [
    {
        "id": "villager",
        "desc": "friendly villager in brown clothes, geometric pixel art style, clean lines",
    },
    {
        "id": "merchant",
        "desc": "merchant with gold coins and bag, geometric pixel art style, clean lines",
    },
    {
        "id": "healer",
        "desc": "healer in green robes with staff, geometric pixel art style, clean lines",
    },
    {
        "id": "guard",
        "desc": "town guard in blue armor with spear, geometric pixel art style, clean lines",
    },
    {
        "id": "quest_giver",
        "desc": "mysterious quest giver in purple hood, geometric pixel art style, clean lines",
    },
    {
        "id": "elder",
        "desc": "wise elder with white beard and staff, geometric pixel art style, clean lines",
    },
]

UI_ELEMENTS = [
    {
        "id": "login_panel",
        "desc": "dark fantasy login panel with ornate border, geometric pixel art style",
    },
    {
        "id": "button_primary",
        "desc": "glowing blue fantasy button, geometric pixel art style, clean edges",
    },
    {
        "id": "button_secondary",
        "desc": "dark stone button with border, geometric pixel art style, clean edges",
    },
    {
        "id": "panel_bg",
        "desc": "dark fantasy UI panel background with subtle border, geometric pixel art style",
    },
    {
        "id": "chat_box",
        "desc": "fantasy chat box frame with scroll border, geometric pixel art style",
    },
    {
        "id": "hp_bar_bg",
        "desc": "health bar background frame, geometric pixel art style",
    },
    {
        "id": "hp_bar_fill",
        "desc": "green health bar fill gradient, geometric pixel art style",
    },
    {"id": "mp_bar_bg", "desc": "mana bar background frame, geometric pixel art style"},
    {
        "id": "mp_bar_fill",
        "desc": "blue mana bar fill gradient, geometric pixel art style",
    },
    {
        "id": "menu_panel",
        "desc": "fantasy game menu panel with ornate corners, geometric pixel art style",
    },
]

TERRAIN_TILES = [
    {
        "id": "grass_1",
        "desc": "green grass tile with small flowers, geometric pixel art style",
    },
    {"id": "grass_2", "desc": "darker green grass tile, geometric pixel art style"},
    {"id": "road_1", "desc": "stone road tile with cracks, geometric pixel art style"},
    {"id": "road_2", "desc": "cobblestone road tile, geometric pixel art style"},
    {"id": "dirt", "desc": "brown dirt ground tile, geometric pixel art style"},
    {"id": "water", "desc": "blue water tile with ripples, geometric pixel art style"},
]

OUTPUT_BASE = Path(__file__).parent.parent / "assets" / "images"


def api_request(method, endpoint, data=None):
    url = f"{BASE_URL}{endpoint}"
    try:
        if method == "GET":
            response = requests.get(url, headers=HEADERS)
        else:
            response = requests.post(url, headers=HEADERS, json=data)

        if response.status_code in [200, 202]:
            return response.json()
        else:
            print(f"  Error {response.status_code}: {response.text[:200]}")
            return None
    except Exception as e:
        print(f"  Request failed: {e}")
        return None


def wait_for_job(job_id, timeout=300):
    start = time.time()
    while time.time() - start < timeout:
        result = api_request("GET", f"/background-jobs/{job_id}")
        if result and result.get("status") == "completed":
            return True
        elif result and result.get("status") == "failed":
            print(f"  Job failed: {result.get('error')}")
            return False
        time.sleep(5)
    print(f"  Job timeout after {timeout}s")
    return False


def download_character_zip(character_id, output_dir):
    url = f"{BASE_URL}/characters/{character_id}/zip"
    try:
        response = requests.get(url, headers=HEADERS)
        if response.status_code == 200:
            z = zipfile.ZipFile(io.BytesIO(response.content))
            z.extractall(output_dir)
            return True
        elif response.status_code == 423:
            print("  Character still generating, retrying...")
            time.sleep(10)
            return download_character_zip(character_id, output_dir)
        else:
            print(f"  Download failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"  Download error: {e}")
        return False


def create_player_character(char_info):
    print(f"Creating player character: {char_info['id']}")

    data = {
        "description": char_info["desc"],
        "image_size": {"width": 48, "height": 48},
        **STYLE_PARAMS,
    }

    result = api_request("POST", "/create-character-with-8-directions", data)
    if not result:
        return None

    character_id = result.get("character_id")
    job_id = result.get("background_job_id")

    print(f"  Character ID: {character_id}")
    print(f"  Waiting for character generation...")

    if not wait_for_job(job_id):
        return None

    print(f"  Adding walking animation...")
    walk_result = api_request(
        "POST",
        "/characters/animations",
        {
            "character_id": character_id,
            "template_animation_id": "walking",
            "animation_name": "walking",
        },
    )

    print(f"  Adding idle animation...")
    idle_result = api_request(
        "POST",
        "/characters/animations",
        {
            "character_id": character_id,
            "template_animation_id": "breathing-idle",
            "animation_name": "breathing-idle",
        },
    )

    time.sleep(5)

    print(f"  Waiting for animations...")
    for _ in range(60):
        char_info_result = api_request("GET", f"/characters/{character_id}")
        if char_info_result:
            pending = char_info_result.get("pending_jobs", [])
            if not pending:
                break
        time.sleep(5)

    output_dir = OUTPUT_BASE / "characters" / char_info["id"]
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"  Downloading to {output_dir}...")
    if download_character_zip(character_id, output_dir):
        print(f"  ✓ Player character {char_info['id']} complete!")
        return character_id

    return None


def create_enemy(enemy_info):
    print(f"Creating enemy: {enemy_info['id']}")

    data = {
        "description": enemy_info["desc"],
        "image_size": {"width": 48, "height": 48},
        **STYLE_PARAMS,
    }

    result = api_request("POST", "/create-character-with-4-directions", data)
    if not result:
        return None

    character_id = result.get("character_id")
    job_id = result.get("background_job_id")

    print(f"  Enemy ID: {character_id}")
    print(f"  Waiting for generation...")

    if not wait_for_job(job_id):
        return None

    print(f"  Adding idle animation...")
    api_request(
        "POST",
        "/characters/animations",
        {
            "character_id": character_id,
            "template_animation_id": "breathing-idle",
            "animation_name": "idle",
        },
    )

    time.sleep(5)

    for _ in range(30):
        char_info = api_request("GET", f"/characters/{character_id}")
        if char_info and not char_info.get("pending_jobs"):
            break
        time.sleep(5)

    output_dir = OUTPUT_BASE / "characters" / "enemies" / enemy_info["id"]
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"  Downloading to {output_dir}...")
    if download_character_zip(character_id, output_dir):
        print(f"  ✓ Enemy {enemy_info['id']} complete!")
        return character_id

    return None


def create_npc(npc_info):
    print(f"Creating NPC: {npc_info['id']}")

    data = {
        "description": npc_info["desc"],
        "image_size": {"width": 48, "height": 48},
        **STYLE_PARAMS,
    }

    result = api_request("POST", "/create-character-with-4-directions", data)
    if not result:
        return None

    character_id = result.get("character_id")
    job_id = result.get("background_job_id")

    print(f"  NPC ID: {character_id}")

    if not wait_for_job(job_id):
        return None

    print(f"  Adding idle animation...")
    api_request(
        "POST",
        "/characters/animations",
        {
            "character_id": character_id,
            "template_animation_id": "breathing-idle",
            "animation_name": "idle",
        },
    )

    time.sleep(5)

    for _ in range(30):
        char_info = api_request("GET", f"/characters/{character_id}")
        if char_info and not char_info.get("pending_jobs"):
            break
        time.sleep(5)

    output_dir = OUTPUT_BASE / "characters" / "npcs" / npc_info["id"]
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"  Downloading to {output_dir}...")
    if download_character_zip(character_id, output_dir):
        print(f"  ✓ NPC {npc_info['id']} complete!")
        return character_id

    return None


def create_ui_element(ui_info):
    print(f"Creating UI element: {ui_info['id']}")

    data = {
        "description": ui_info["desc"],
        "image_size": {"width": 128, "height": 64},
        "no_background": True,
    }

    result = api_request("POST", "/create-image-pixflux", data)
    if not result:
        return None

    output_dir = OUTPUT_BASE / "ui" / "panels"
    output_dir.mkdir(parents=True, exist_ok=True)

    if "images" in result:
        import base64

        for i, img_data in enumerate(result["images"]):
            if img_data.startswith("data:image"):
                img_data = img_data.split(",")[1]
            img_bytes = base64.b64decode(img_data)
            with open(output_dir / f"{ui_info['id']}.png", "wb") as f:
                f.write(img_bytes)
            print(f"  ✓ UI element {ui_info['id']} saved!")
            return True

    return False


def create_tileset():
    print("Creating terrain tileset...")

    data = {
        "lower_description": "deep blue ocean water",
        "upper_description": "sandy beach shore",
        "tile_size": {"width": 32, "height": 32},
        "view": "low top-down",
    }

    result = api_request("POST", "/create-tileset", data)
    if not result:
        return None

    job_id = result.get("background_job_id") or result.get("job_id")
    tileset_id = result.get("tileset_id")

    print(f"  Tileset ID: {tileset_id}")

    if job_id:
        print("  Waiting for tileset generation...")
        wait_for_job(job_id)

    output_dir = OUTPUT_BASE / "tilesets" / "terrain"
    output_dir.mkdir(parents=True, exist_ok=True)

    if tileset_id:
        for _ in range(30):
            ts_result = api_request("GET", f"/tilesets/{tileset_id}")
            if ts_result and ts_result.get("status") == "completed":
                if "images" in ts_result:
                    import base64

                    for i, img_data in enumerate(ts_result["images"]):
                        if img_data.startswith("data:image"):
                            img_data = img_data.split(",")[1]
                        img_bytes = base64.b64decode(img_data)
                        with open(output_dir / f"tile_{i}.png", "wb") as f:
                            f.write(img_bytes)
                print("  ✓ Tileset saved!")
                return True
            time.sleep(5)

    return False


def main():
    print("=" * 60)
    print("PIXEL ART ASSET GENERATOR")
    print("=" * 60)
    print(f"Output directory: {OUTPUT_BASE}")
    print()

    balance = api_request("GET", "/balance")
    if balance:
        print(f"API Balance: {balance.get('data', {})}")
    print()

    print("=" * 60)
    print("PHASE 1: Player Characters (8 classes)")
    print("=" * 60)
    for char_info in PLAYER_CLASSES:
        create_player_character(char_info)
        time.sleep(2)

    print()
    print("=" * 60)
    print("PHASE 2: Enemies (15 types)")
    print("=" * 60)
    for enemy_info in ENEMIES:
        create_enemy(enemy_info)
        time.sleep(2)

    print()
    print("=" * 60)
    print("PHASE 3: NPCs (6 types)")
    print("=" * 60)
    for npc_info in NPCS:
        create_npc(npc_info)
        time.sleep(2)

    print()
    print("=" * 60)
    print("PHASE 4: UI Elements")
    print("=" * 60)
    for ui_info in UI_ELEMENTS:
        create_ui_element(ui_info)
        time.sleep(1)

    print()
    print("=" * 60)
    print("PHASE 5: Terrain Tiles")
    print("=" * 60)
    create_tileset()

    print()
    print("=" * 60)
    print("ASSET GENERATION COMPLETE!")
    print("=" * 60)


if __name__ == "__main__":
    main()
