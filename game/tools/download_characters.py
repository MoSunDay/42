#!/usr/bin/env python3
"""
Download all generated characters from Pixellab
"""

import requests
import time
import zipfile
import io
from pathlib import Path

API_KEY = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
OUTPUT_BASE = Path(__file__).parent.parent / "assets" / "images"

CHARACTER_MAPPING = {
    # Players
    "warrior": ("player", "warrior"),
    "mage": ("player", "mage"),
    "archer": ("player", "archer"),
    "rogue": ("player", "rogue"),
    "cleric": ("player", "cleric"),
    "knight": ("player", "knight"),
    "wizard": ("player", "wizard"),
    "ranger": ("player", "ranger"),
    # Enemies
    "slime": ("enemy", "slime"),
    "goblin": ("enemy", "goblin"),
    "skeleton": ("enemy", "skeleton"),
    "bat": ("enemy", "bat"),
    "orc_warrior": ("enemy", "orc_warrior"),
    "skeleton_knight": ("enemy", "skeleton_knight"),
    "wolf": ("enemy", "wolf"),
    "dark_mage": ("enemy", "dark_mage"),
    "orc_chieftain": ("enemy", "orc_chieftain"),
    "vampire": ("enemy", "vampire"),
    "golem": ("enemy", "golem"),
    "demon": ("enemy", "demon"),
    "ancient_dragon": ("enemy", "ancient_dragon"),
    "lich_king": ("enemy", "lich_king"),
    "chaos_serpent": ("enemy", "chaos_serpent"),
    # NPCs
    "villager": ("npc", "villager"),
    "merchant": ("npc", "merchant"),
    "healer": ("npc", "healer"),
    "guard": ("npc", "guard"),
    "quest_giver": ("npc", "quest_giver"),
    "elder": ("npc", "elder"),
}


def api_get(endpoint):
    r = requests.get(f"{BASE_URL}{endpoint}", headers=HEADERS)
    return r.json() if r.status_code == 200 else None


def api_post(endpoint, data):
    r = requests.post(f"{BASE_URL}{endpoint}", headers=HEADERS, json=data)
    return r.json() if r.status_code in [200, 202] else None


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

    for attempt in range(5):
        try:
            r = requests.get(f"{BASE_URL}/characters/{char_id}/zip", headers=HEADERS)
            if r.status_code == 200:
                z = zipfile.ZipFile(io.BytesIO(r.content))
                z.extractall(output_dir)
                return True
            elif r.status_code == 423:
                print(f"    Still generating, waiting... (attempt {attempt + 1})")
                time.sleep(15)
            else:
                print(f"    Download error: {r.status_code}")
        except Exception as e:
            print(f"    Error: {e}")
        time.sleep(5)
    return False


def identify_char(name):
    name_lower = name.lower()
    for key, (ctype, cname) in CHARACTER_MAPPING.items():
        if key in name_lower:
            return ctype, cname
    return None, None


def main():
    print("\n" + "=" * 60)
    print("DOWNLOADING ALL CHARACTERS")
    print("=" * 60 + "\n")

    result = api_get("/characters?limit=50")
    chars = result.get("data", result.get("characters", []))

    print(f"Found {len(chars)} characters\n")

    processed = 0
    for char in chars:
        char_id = char.get("id", char.get("character_id"))
        name = char.get("name", "unknown")

        ctype, cname = identify_char(name)
        if not ctype:
            print(f"Skipping unknown: {name[:40]}...")
            continue

        print(f"[{ctype.upper()}] {cname}")

        # Check if already downloaded
        if ctype == "player":
            check_dir = OUTPUT_BASE / "characters" / cname / "rotations"
        elif ctype == "enemy":
            check_dir = OUTPUT_BASE / "characters" / "enemies" / cname / "rotations"
        else:
            check_dir = OUTPUT_BASE / "characters" / "npcs" / cname / "rotations"

        if check_dir.exists() and list(check_dir.glob("*.png")):
            existing = len(list(check_dir.glob("*.png")))
            print(f"  Already exists ({existing} rotations)")
            continue

        # Check character status
        char_info = api_get(f"/characters/{char_id}")
        if not char_info:
            print("  Could not get character info")
            continue

        rotations = char_info.get("rotations", {})
        pending = char_info.get("pending_jobs", [])

        print(f"  Rotations: {len(rotations)}, Pending: {len(pending)}")

        # Add animations if not yet added
        if ctype == "player" and not char_info.get("animations"):
            print("  Adding walking animation...")
            add_animation(char_id, "walking")
            print("  Adding breathing-idle animation...")
            add_animation(char_id, "breathing-idle")
        elif ctype != "player" and not char_info.get("animations"):
            print("  Adding idle animation...")
            add_animation(char_id, "breathing-idle")

        # Wait for pending jobs
        if pending:
            print("  Waiting for pending jobs...")
            for _ in range(30):
                char_info = api_get(f"/characters/{char_id}")
                if not char_info.get("pending_jobs"):
                    break
                time.sleep(5)

        # Download
        if ctype == "player":
            out_dir = OUTPUT_BASE / "characters" / cname
        elif ctype == "enemy":
            out_dir = OUTPUT_BASE / "characters" / "enemies" / cname
        else:
            out_dir = OUTPUT_BASE / "characters" / "npcs" / cname

        print(f"  Downloading to {out_dir}...")
        if download_char(char_id, out_dir):
            file_count = len(list(Path(out_dir).rglob("*.png")))
            print(f"  Downloaded! ({file_count} files)")
            processed += 1
        else:
            print("  Download failed")

        time.sleep(2)

    print(f"\n{'=' * 60}")
    print(f"DOWNLOADED {processed} characters")
    print("=" * 60)


if __name__ == "__main__":
    main()
