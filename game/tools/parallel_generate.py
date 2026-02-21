#!/usr/bin/env python3
"""
Parallel Asset Generator - Efficiently creates all game assets
"""

import requests
import time
import json
import zipfile
import io
import base64
from pathlib import Path
from datetime import datetime

API_KEY = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
OUTPUT_BASE = Path(__file__).parent.parent / "assets" / "images"

STYLE = {
    "outline": "medium",
    "shading": "soft",
    "detail": "medium",
    "view": "low top-down",
}

ASSETS = {
    "players": [
        (
            "mage",
            "mage character in purple robes holding glowing staff, simple geometric pixel art, clean black outline",
        ),
        (
            "archer",
            "archer character in green light armor with bow, simple geometric pixel art, clean black outline",
        ),
        (
            "rogue",
            "rogue character in dark leather armor with daggers, simple geometric pixel art, clean black outline",
        ),
        (
            "cleric",
            "cleric character in white robes with holy symbol, simple geometric pixel art, clean black outline",
        ),
        (
            "knight",
            "knight character in blue plate armor with shield, simple geometric pixel art, clean black outline",
        ),
        (
            "wizard",
            "wizard character in purple hat and robes with magic book, simple geometric pixel art, clean black outline",
        ),
        (
            "ranger",
            "ranger character in green cloak with dual blades, simple geometric pixel art, clean black outline",
        ),
    ],
    "enemies": [
        (
            "slime",
            "cute green slime blob enemy, simple geometric pixel art, round shape, clean outline",
        ),
        (
            "goblin",
            "small brown goblin enemy with pointy ears, simple geometric pixel art, clean outline",
        ),
        (
            "skeleton",
            "white skeleton enemy warrior with sword, simple geometric pixel art, clean outline",
        ),
        (
            "bat",
            "purple vampire bat enemy with spread wings, simple geometric pixel art, simple shape",
        ),
        (
            "orc_warrior",
            "green orc warrior enemy with axe, simple geometric pixel art, clean outline",
        ),
        (
            "skeleton_knight",
            "armored skeleton knight enemy with shield, simple geometric pixel art, clean outline",
        ),
        (
            "wolf",
            "gray dire wolf enemy with glowing eyes, simple geometric pixel art, clean outline",
        ),
        (
            "dark_mage",
            "dark purple mage enemy with shadow magic, simple geometric pixel art, clean outline",
        ),
        (
            "orc_chieftain",
            "large green orc chieftain boss with battle axe, simple geometric pixel art, clean outline",
        ),
        (
            "vampire",
            "elegant vampire lord boss in dark red cape, simple geometric pixel art, clean outline",
        ),
        (
            "golem",
            "stone golem boss with rocky body, simple geometric pixel art, clean outline",
        ),
        (
            "demon",
            "red demon boss with horns and flames, simple geometric pixel art, clean outline",
        ),
        (
            "ancient_dragon",
            "golden ancient dragon legendary boss with wings, simple geometric pixel art, clean outline",
        ),
        (
            "lich_king",
            "dark lich king legendary boss with skull staff, simple geometric pixel art, clean outline",
        ),
        (
            "chaos_serpent",
            "purple chaos serpent legendary boss, simple geometric pixel art, clean outline",
        ),
    ],
    "npcs": [
        (
            "villager",
            "friendly villager NPC in brown clothes, simple geometric pixel art, clean outline",
        ),
        (
            "merchant",
            "merchant NPC with gold coins and bag, simple geometric pixel art, clean outline",
        ),
        (
            "healer",
            "healer NPC in green robes with staff, simple geometric pixel art, clean outline",
        ),
        (
            "guard",
            "town guard NPC in blue armor with spear, simple geometric pixel art, clean outline",
        ),
        (
            "quest_giver",
            "mysterious quest giver NPC in purple hood, simple geometric pixel art, clean outline",
        ),
        (
            "elder",
            "wise elder NPC with white beard and staff, simple geometric pixel art, clean outline",
        ),
    ],
}


def api_get(endpoint):
    r = requests.get(
        f"{BASE_URL}{endpoint}", headers={"Authorization": f"Bearer {API_KEY}"}
    )
    return r.json() if r.status_code == 200 else None


def api_post(endpoint, data):
    r = requests.post(f"{BASE_URL}{endpoint}", headers=HEADERS, json=data)
    return r.json() if r.status_code in [200, 202] else None


def create_char(name, desc, dirs=8):
    endpoint = (
        "/create-character-with-8-directions"
        if dirs == 8
        else "/create-character-with-4-directions"
    )
    result = api_post(
        endpoint,
        {"description": desc, "image_size": {"width": 48, "height": 48}, **STYLE},
    )
    if result:
        print(f"  Created: {name} -> {result.get('character_id')}")
        return result.get("character_id"), result.get("background_job_id")
    return None, None


def add_animation(char_id, anim_name):
    return api_post(
        "/characters/animations",
        {
            "character_id": char_id,
            "template_animation_id": anim_name,
            "animation_name": anim_name,
        },
    )


def download_char(char_id, output_dir):
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    for _ in range(10):
        r = requests.get(
            f"{BASE_URL}/characters/{char_id}/zip",
            headers={"Authorization": f"Bearer {API_KEY}"},
        )
        if r.status_code == 200:
            z = zipfile.ZipFile(io.BytesIO(r.content))
            z.extractall(output_dir)
            return True
        time.sleep(10)
    return False


def main():
    print(f"\n{'=' * 60}")
    print(f"PARALLEL ASSET GENERATOR - {datetime.now()}")
    print(f"{'=' * 60}\n")

    chars = []

    # Phase 1: Create all characters
    print("PHASE 1: Creating characters...")
    for name, desc in ASSETS["players"]:
        cid, jid = create_char(name, desc, 8)
        if cid:
            chars.append(("player", name, cid))
        time.sleep(1)

    for name, desc in ASSETS["enemies"]:
        cid, jid = create_char(name, desc, 4)
        if cid:
            chars.append(("enemy", name, cid))
        time.sleep(1)

    for name, desc in ASSETS["npcs"]:
        cid, jid = create_char(name, desc, 4)
        if cid:
            chars.append(("npc", name, cid))
        time.sleep(1)

    print(f"\nCreated {len(chars)} characters\n")

    # Phase 2: Add animations (with delay to allow character generation)
    print("PHASE 2: Adding animations...")
    time.sleep(120)  # Wait for initial characters to process

    for ctype, name, cid in chars:
        print(f"  Animating: {name}")
        if ctype == "player":
            add_animation(cid, "walking")
            add_animation(cid, "breathing-idle")
        else:
            add_animation(cid, "breathing-idle")
        time.sleep(2)

    # Phase 3: Download all
    print("\nPHASE 3: Downloading (waiting 3 min for animations)...")
    time.sleep(180)

    for ctype, name, cid in chars:
        if ctype == "player":
            out = OUTPUT_BASE / "characters" / name
        elif ctype == "enemy":
            out = OUTPUT_BASE / "characters" / "enemies" / name
        else:
            out = OUTPUT_BASE / "characters" / "npcs" / name

        print(f"  Downloading: {name}")
        if download_char(cid, out):
            print(f"    ✓ Saved to {out}")
        else:
            print(f"    ✗ Failed to download {name}")

    print(f"\n{'=' * 60}")
    print("COMPLETE!")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
