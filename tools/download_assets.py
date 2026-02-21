#!/usr/bin/env python3
"""
Download all completed assets
"""

import requests
import json
import time
import zipfile
import shutil
from pathlib import Path

API_TOKEN = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {"Authorization": f"Bearer {API_TOKEN}", "Content-Type": "application/json"}

SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR / "generated_assets"
RESULTS_FILE = OUTPUT_DIR / "generation_results.json"
GAME_ASSETS_DIR = SCRIPT_DIR.parent / "game" / "assets" / "images"

ENEMIES = [
    "slime",
    "goblin",
    "skeleton",
    "bat",
    "orc_warrior",
    "skeleton_knight",
    "wolf",
    "dark_mage",
    "orc_chieftain",
    "vampire",
    "golem",
    "demon",
    "ancient_dragon",
    "lich_king",
    "chaos_serpent",
]


def api_get(endpoint):
    url = f"{BASE_URL}{endpoint}"
    try:
        response = requests.get(url, headers=HEADERS, timeout=30)
        return response.json()
    except Exception as e:
        return {"error": str(e)}


def download_file(url, filepath):
    try:
        response = requests.get(url, stream=True, timeout=60)
        if response.status_code == 200:
            with open(filepath, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            return True
    except Exception as e:
        print(f"    Download error: {e}")
    return False


def download_character(char_id, char_name, is_enemy=False):
    result = api_get(f"/characters/{char_id}")

    if result.get("download_url"):
        print(f"  Downloading {char_name}...")

        zip_path = OUTPUT_DIR / f"{char_name}.zip"
        if not download_file(result["download_url"], zip_path):
            return False

        extract_dir = OUTPUT_DIR / "extracted" / char_name
        extract_dir.mkdir(parents=True, exist_ok=True)

        try:
            with zipfile.ZipFile(zip_path, "r") as zf:
                zf.extractall(extract_dir)
        except Exception as e:
            print(f"    Extract error: {e}")
            return False

        if is_enemy:
            dest_dir = GAME_ASSETS_DIR / "characters" / "enemies" / char_name
        else:
            dest_dir = GAME_ASSETS_DIR / "characters" / char_name

        dest_dir.mkdir(parents=True, exist_ok=True)

        rotations_src = extract_dir / "rotations"
        if rotations_src.exists():
            dest_rotations = dest_dir / "rotations"
            if dest_rotations.exists():
                shutil.rmtree(dest_rotations)
            shutil.copytree(rotations_src, dest_rotations)

        animations_src = extract_dir / "animations"
        if animations_src.exists():
            dest_animations = dest_dir / "animations"
            if dest_animations.exists():
                shutil.rmtree(dest_animations)
            shutil.copytree(animations_src, dest_animations)

        print(f"    Saved to: {dest_dir}")
        return True
    else:
        print(f"  {char_name}: Not ready yet")
        return False


def download_tileset(tileset_id, tileset_name):
    result = api_get(f"/tilesets/{tileset_id}")

    if result.get("download_url"):
        dest_dir = GAME_ASSETS_DIR / "tilesets" / "terrain"
        dest_dir.mkdir(parents=True, exist_ok=True)

        dest_path = dest_dir / f"{tileset_name}.png"
        if download_file(result["download_url"], dest_path):
            print(f"  Downloaded: {tileset_name}")
            return True
    else:
        print(f"  {tileset_name}: Not ready yet")
    return False


def main():
    if not RESULTS_FILE.exists():
        print("No generation results found. Run generate_assets.py first.")
        return

    with open(RESULTS_FILE, "r") as f:
        results = json.load(f)

    print("=" * 60)
    print("Downloading Characters")
    print("=" * 60)

    for char_name, info in results.get("characters", {}).items():
        char_id = info["id"]
        is_enemy = char_name in ENEMIES
        download_character(char_id, char_name, is_enemy)

    print("\n" + "=" * 60)
    print("Downloading Tilesets")
    print("=" * 60)

    for tileset_name, info in results.get("tilesets", {}).items():
        tileset_id = info["id"]
        download_tileset(tileset_id, tileset_name)

    print("\n" + "=" * 60)
    print("Download complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
