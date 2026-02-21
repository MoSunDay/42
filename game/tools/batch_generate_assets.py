#!/usr/bin/env python3
"""
Batch Asset Generator for Turn-Based RPG
Efficiently generates all game assets using Pixellab API
"""

import requests
import time
import json
import os
import zipfile
import io
import base64
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

API_KEY = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"

HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}

OUTPUT_BASE = Path(__file__).parent.parent / "assets" / "images"

STYLE_PARAMS = {
    "outline": "medium",
    "shading": "soft",
    "detail": "medium",
    "view": "low top-down",
}

PLAYER_CLASSES = [
    {
        "id": "warrior",
        "desc": "warrior character in heavy red armor with large sword, simple geometric pixel art, clean black outline",
    },
    {
        "id": "mage",
        "desc": "mage character in purple robes holding glowing staff, simple geometric pixel art, clean black outline",
    },
    {
        "id": "archer",
        "desc": "archer character in green light armor with bow, simple geometric pixel art, clean black outline",
    },
    {
        "id": "rogue",
        "desc": "rogue character in dark leather armor with daggers, simple geometric pixel art, clean black outline",
    },
    {
        "id": "cleric",
        "desc": "cleric character in white robes with holy symbol, simple geometric pixel art, clean black outline",
    },
    {
        "id": "knight",
        "desc": "knight character in blue plate armor with shield, simple geometric pixel art, clean black outline",
    },
    {
        "id": "wizard",
        "desc": "wizard character in purple hat and robes with magic book, simple geometric pixel art, clean black outline",
    },
    {
        "id": "ranger",
        "desc": "ranger character in green cloak with dual blades, simple geometric pixel art, clean black outline",
    },
]

ENEMIES = [
    {
        "id": "slime",
        "desc": "cute green slime blob enemy, simple geometric pixel art, round shape, clean outline",
    },
    {
        "id": "goblin",
        "desc": "small brown goblin enemy with pointy ears, simple geometric pixel art, clean outline",
    },
    {
        "id": "skeleton",
        "desc": "white skeleton enemy warrior with sword, simple geometric pixel art, clean outline",
    },
    {
        "id": "bat",
        "desc": "purple vampire bat enemy with spread wings, simple geometric pixel art, simple shape",
    },
    {
        "id": "orc_warrior",
        "desc": "green orc warrior enemy with axe, simple geometric pixel art, clean outline",
    },
    {
        "id": "skeleton_knight",
        "desc": "armored skeleton knight enemy with shield, simple geometric pixel art, clean outline",
    },
    {
        "id": "wolf",
        "desc": "gray dire wolf enemy with glowing eyes, simple geometric pixel art, clean outline",
    },
    {
        "id": "dark_mage",
        "desc": "dark purple mage enemy with shadow magic, simple geometric pixel art, clean outline",
    },
    {
        "id": "orc_chieftain",
        "desc": "large green orc chieftain boss with battle axe, simple geometric pixel art, clean outline",
    },
    {
        "id": "vampire",
        "desc": "elegant vampire lord boss in dark red cape, simple geometric pixel art, clean outline",
    },
    {
        "id": "golem",
        "desc": "stone golem boss with rocky body, simple geometric pixel art, clean outline",
    },
    {
        "id": "demon",
        "desc": "red demon boss with horns and flames, simple geometric pixel art, clean outline",
    },
    {
        "id": "ancient_dragon",
        "desc": "golden ancient dragon legendary boss with wings, simple geometric pixel art, clean outline",
    },
    {
        "id": "lich_king",
        "desc": "dark lich king legendary boss with skull staff, simple geometric pixel art, clean outline",
    },
    {
        "id": "chaos_serpent",
        "desc": "purple chaos serpent legendary boss, simple geometric pixel art, clean outline",
    },
]

NPCS = [
    {
        "id": "villager",
        "desc": "friendly villager NPC in brown clothes, simple geometric pixel art, clean outline",
    },
    {
        "id": "merchant",
        "desc": "merchant NPC with gold coins and bag, simple geometric pixel art, clean outline",
    },
    {
        "id": "healer",
        "desc": "healer NPC in green robes with staff, simple geometric pixel art, clean outline",
    },
    {
        "id": "guard",
        "desc": "town guard NPC in blue armor with spear, simple geometric pixel art, clean outline",
    },
    {
        "id": "quest_giver",
        "desc": "mysterious quest giver NPC in purple hood, simple geometric pixel art, clean outline",
    },
    {
        "id": "elder",
        "desc": "wise elder NPC with white beard and staff, simple geometric pixel art, clean outline",
    },
]

created_chars = {}
lock = threading.Lock()


def api_get(endpoint):
    try:
        r = requests.get(f"{BASE_URL}{endpoint}", headers=HEADERS)
        if r.status_code == 200:
            return r.json()
    except Exception as e:
        print(f"GET error: {e}")
    return None


def api_post(endpoint, data):
    try:
        r = requests.post(f"{BASE_URL}{endpoint}", headers=HEADERS, json=data)
        if r.status_code in [200, 202]:
            return r.json()
        else:
            print(f"POST error {r.status_code}: {r.text[:200]}")
    except Exception as e:
        print(f"POST error: {e}")
    return None


def wait_for_job(job_id, timeout=300):
    start = time.time()
    while time.time() - start < timeout:
        result = api_get(f"/background-jobs/{job_id}")
        if result:
            status = result.get("status")
            if status == "completed":
                return True
            if status == "failed":
                print(f"  Job failed")
                return False
        time.sleep(5)
    return False


def create_character(char_info, n_directions=8):
    print(f"[CREATE] {char_info['id']} ({n_directions} directions)")

    endpoint = (
        "/create-character-with-8-directions"
        if n_directions == 8
        else "/create-character-with-4-directions"
    )
    data = {
        "description": char_info["desc"],
        "image_size": {"width": 48, "height": 48},
        **STYLE_PARAMS,
    }

    result = api_post(endpoint, data)
    if result:
        char_id = result.get("character_id")
        job_id = result.get("background_job_id")
        print(f"  ID: {char_id}")
        return {
            "char_id": char_id,
            "job_id": job_id,
            "info": char_info,
            "n_dirs": n_directions,
        }
    return None


def add_animations(char_id, animations):
    for anim in animations:
        print(f"  Adding {anim} animation...")
        api_post(
            "/characters/animations",
            {
                "character_id": char_id,
                "template_animation_id": anim,
                "animation_name": anim.replace("-", "_"),
            },
        )


def download_character(char_id, output_dir):
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    url = f"{BASE_URL}/characters/{char_id}/zip"
    for attempt in range(5):
        try:
            r = requests.get(url, headers=HEADERS)
            if r.status_code == 200:
                z = zipfile.ZipFile(io.BytesIO(r.content))
                z.extractall(output_dir)
                return True
            elif r.status_code == 423:
                print(f"  Still generating, waiting... (attempt {attempt + 1})")
                time.sleep(10)
            else:
                print(f"  Download error: {r.status_code}")
        except Exception as e:
            print(f"  Download error: {e}")
        time.sleep(5)
    return False


def process_character(char_data):
    char_id = char_data["char_id"]
    job_id = char_data["job_id"]
    info = char_data["info"]
    n_dirs = char_data["n_dirs"]

    print(f"[WAIT] {info['id']} - waiting for generation...")
    if not wait_for_job(job_id):
        print(f"  Failed to generate {info['id']}")
        return False

    if n_dirs == 8:
        add_animations(char_id, ["walking", "breathing-idle"])
    else:
        add_animations(char_id, ["breathing-idle"])

    print(f"  Waiting for animations...")
    for _ in range(60):
        char_info = api_get(f"/characters/{char_id}")
        if char_info and not char_info.get("pending_jobs"):
            break
        time.sleep(3)

    if n_dirs == 8:
        output_dir = OUTPUT_BASE / "characters" / info["id"]
    else:
        parent = info.get("parent", "enemies")
        output_dir = OUTPUT_BASE / "characters" / parent / info["id"]

    print(f"[DOWNLOAD] {info['id']} -> {output_dir}")
    if download_character(char_id, output_dir):
        print(f"[DONE] {info['id']} complete!")
        return True
    return False


def create_ui_image(desc, filename, size=(128, 64)):
    print(f"[UI] Creating {filename}...")
    data = {
        "description": desc,
        "image_size": {"width": size[0], "height": size[1]},
        "no_background": True,
    }

    result = api_post("/create-image-pixflux", data)
    if result and "images" in result:
        output_dir = OUTPUT_BASE / "ui" / "panels"
        output_dir.mkdir(parents=True, exist_ok=True)

        img_data = result["images"][0]
        if img_data.startswith("data:image"):
            img_data = img_data.split(",")[1]

        img_bytes = base64.b64decode(img_data)
        with open(output_dir / filename, "wb") as f:
            f.write(img_bytes)
        print(f"  Saved: {filename}")
        return True
    return False


def create_portrait(char_id, size, filename):
    """Create portrait from character"""
    output_dir = OUTPUT_BASE / "portraits" / ("large" if size == 64 else "small")
    output_dir.mkdir(parents=True, exist_ok=True)

    char_info = api_get(f"/characters/{char_id}?include_preview=true")
    if char_info and "preview_image" in char_info:
        img_data = char_info["preview_image"]
        if img_data.startswith("data:image"):
            img_data = img_data.split(",")[1]

        img_bytes = base64.b64decode(img_data)
        with open(output_dir / filename, "wb") as f:
            f.write(img_bytes)
        print(f"  Portrait saved: {filename}")
        return True
    return False


def main():
    print("=" * 70)
    print("PIXEL ART ASSET GENERATOR - BATCH MODE")
    print("=" * 70)

    balance = api_get("/balance")
    if balance:
        sub = balance.get("subscription", {})
        print(f"Available generations: {sub.get('generations', 'N/A')}")
    print()

    all_chars = []

    # Phase 1: Submit all character creation jobs
    print("=" * 70)
    print("PHASE 1: Submitting character creation jobs...")
    print("=" * 70)

    for char_info in PLAYER_CLASSES:
        result = create_character(char_info, n_directions=8)
        if result:
            all_chars.append(result)
        time.sleep(1)

    for enemy_info in ENEMIES:
        enemy_info["parent"] = "enemies"
        result = create_character(enemy_info, n_directions=4)
        if result:
            all_chars.append(result)
        time.sleep(1)

    for npc_info in NPCS:
        npc_info["parent"] = "npcs"
        result = create_character(npc_info, n_directions=4)
        if result:
            all_chars.append(result)
        time.sleep(1)

    print(f"\nSubmitted {len(all_chars)} character creation jobs\n")

    # Phase 2: Process each character (wait + animate + download)
    print("=" * 70)
    print("PHASE 2: Processing characters...")
    print("=" * 70)

    completed = 0
    for char_data in all_chars:
        if process_character(char_data):
            completed += 1
        time.sleep(2)

    print(f"\nCompleted {completed}/{len(all_chars)} characters\n")

    # Phase 3: UI Elements
    print("=" * 70)
    print("PHASE 3: UI Elements")
    print("=" * 70)

    ui_elements = [
        (
            "dark fantasy login panel with ornate border, geometric pixel art",
            "login_panel.png",
        ),
        (
            "glowing blue fantasy button, geometric pixel art, clean edges",
            "button_primary.png",
        ),
        ("dark stone button with border, geometric pixel art", "button_secondary.png"),
        ("dark fantasy UI panel background, geometric pixel art", "panel_bg.png"),
        (
            "fantasy chat box frame with scroll border, geometric pixel art",
            "chat_box.png",
        ),
        ("health bar background frame, geometric pixel art", "hp_bar_bg.png"),
        ("green health bar fill, geometric pixel art", "hp_bar_fill.png"),
        ("mana bar background frame, geometric pixel art", "mp_bar_bg.png"),
        ("blue mana bar fill, geometric pixel art", "mp_bar_fill.png"),
        ("fantasy game menu panel, geometric pixel art", "menu_panel.png"),
        (
            "character selection panel with slots, geometric pixel art",
            "char_select_panel.png",
        ),
    ]

    for desc, filename in ui_elements:
        create_ui_image(desc, filename)
        time.sleep(2)

    print()
    print("=" * 70)
    print("ASSET GENERATION COMPLETE!")
    print("=" * 70)
    print(f"Output: {OUTPUT_BASE}")


if __name__ == "__main__":
    main()
