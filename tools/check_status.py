#!/usr/bin/env python3
"""
Check generation status and download completed assets
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


def api_get(endpoint):
    """Make GET request to API"""
    url = f"{BASE_URL}{endpoint}"
    response = requests.get(url, headers=HEADERS)
    return response.json()


def download_file(url, filepath):
    """Download file from URL"""
    try:
        response = requests.get(url, stream=True, timeout=60)
        if response.status_code == 200:
            with open(filepath, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            return True
    except Exception as e:
        print(f"  Download error: {e}")
    return False


def check_character(char_id):
    """Check character status"""
    result = api_get(f"/characters/{char_id}")
    return result


def check_tileset(tileset_id):
    """Check tileset status"""
    result = api_get(f"/tilesets/{tileset_id}")
    return result


def check_map_object(obj_id):
    """Check map object status"""
    result = api_get(f"/map-objects/{obj_id}")
    return result


def download_and_extract_character(char_id, char_name, is_enemy=False):
    """Download and extract character ZIP"""
    print(f"  Downloading character: {char_name}")

    result = api_get(f"/characters/{char_id}")

    if result.get("download_url"):
        zip_path = OUTPUT_DIR / f"{char_name}.zip"
        if download_file(result["download_url"], zip_path):
            print(f"    Downloaded: {zip_path}")

            # Extract
            extract_dir = OUTPUT_DIR / "extracted" / char_name
            extract_dir.mkdir(parents=True, exist_ok=True)

            with zipfile.ZipFile(zip_path, "r") as zf:
                zf.extractall(extract_dir)

            print(f"    Extracted to: {extract_dir}")

            # Copy to game assets
            if is_enemy:
                dest_dir = GAME_ASSETS_DIR / "characters" / "enemies" / char_name
            else:
                dest_dir = GAME_ASSETS_DIR / "characters" / char_name

            dest_dir.mkdir(parents=True, exist_ok=True)

            # Copy rotations
            rotations_src = extract_dir / "rotations"
            if rotations_src.exists():
                dest_rotations = dest_dir / "rotations"
                if dest_rotations.exists():
                    shutil.rmtree(dest_rotations)
                shutil.copytree(rotations_src, dest_rotations)
                print(f"    Copied rotations to: {dest_rotations}")

            # Copy animations
            animations_src = extract_dir / "animations"
            if animations_src.exists():
                dest_animations = dest_dir / "animations"
                if dest_animations.exists():
                    shutil.rmtree(dest_animations)
                shutil.copytree(animations_src, dest_animations)
                print(f"    Copied animations to: {dest_animations}")

            return True
    else:
        print(f"    No download URL available yet")
        return False


def download_tileset(tileset_id, tileset_name):
    """Download tileset image"""
    print(f"  Downloading tileset: {tileset_name}")

    result = api_get(f"/tilesets/{tileset_id}")

    if result.get("download_url"):
        dest_dir = GAME_ASSETS_DIR / "tilesets" / "terrain"
        dest_dir.mkdir(parents=True, exist_ok=True)

        dest_path = dest_dir / f"{tileset_name}.png"
        if download_file(result["download_url"], dest_path):
            print(f"    Downloaded to: {dest_path}")
            return True
    else:
        print(f"    No download URL available yet")
    return False


def download_map_object(obj_id, obj_name):
    """Download map object image"""
    print(f"  Downloading map object: {obj_name}")

    result = api_get(f"/map-objects/{obj_id}")

    if result.get("download_url"):
        # Determine category
        if "tree" in obj_name:
            category = "trees"
        elif obj_name in [
            "village_house",
            "village_shop",
            "village_inn",
            "temple",
            "shrine",
        ]:
            category = "buildings"
        else:
            category = "props"

        dest_dir = GAME_ASSETS_DIR / "tilesets" / "objects" / category
        dest_dir.mkdir(parents=True, exist_ok=True)

        dest_path = dest_dir / f"{obj_name}.png"
        if download_file(result["download_url"], dest_path):
            print(f"    Downloaded to: {dest_path}")
            return True
    else:
        print(f"    No download URL available yet")
    return False


def check_all_status():
    """Check status of all generated assets"""
    if not RESULTS_FILE.exists():
        print("No generation results found. Run generate_assets.py first.")
        return None

    with open(RESULTS_FILE, "r") as f:
        results = json.load(f)

    status = {"characters": {}, "tilesets": {}, "map_objects": {}}

    print("=" * 60)
    print("Checking Character Status")
    print("=" * 60)

    for char_name, info in results.get("characters", {}).items():
        char_id = info["id"]
        result = check_character(char_id)

        # Check if ready
        rotations = result.get("rotations", {})
        animations = result.get("animations", [])

        ready = len(rotations) > 0
        status["characters"][char_name] = {
            "id": char_id,
            "ready": ready,
            "rotations": len(rotations),
            "animations": len(animations),
        }

        status_text = "READY" if ready else "PROCESSING"
        print(
            f"  {char_name}: {status_text} ({len(rotations)} rotations, {len(animations)} animations)"
        )

    print("\n" + "=" * 60)
    print("Checking Tileset Status")
    print("=" * 60)

    for tileset_name, info in results.get("tilesets", {}).items():
        tileset_id = info["id"]
        result = check_tileset(tileset_id)

        ready = result.get("download_url") is not None
        status["tilesets"][tileset_name] = {"id": tileset_id, "ready": ready}

        status_text = "READY" if ready else "PROCESSING"
        print(f"  {tileset_name}: {status_text}")

    print("\n" + "=" * 60)
    print("Checking Map Object Status")
    print("=" * 60)

    for obj_name, info in results.get("map_objects", {}).items():
        obj_id = info["id"]
        result = check_map_object(obj_id)

        ready = result.get("download_url") is not None
        status["map_objects"][obj_name] = {"id": obj_id, "ready": ready}

        status_text = "READY" if ready else "PROCESSING"
        print(f"  {obj_name}: {status_text}")

    return status


def download_all_ready():
    """Download all ready assets"""
    if not RESULTS_FILE.exists():
        print("No generation results found. Run generate_assets.py first.")
        return

    with open(RESULTS_FILE, "r") as f:
        results = json.load(f)

    # Define enemies
    enemies = [
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

    npcs = [
        "village_chief",
        "spring_guardian",
        "summer_merchant",
        "autumn_innkeeper",
        "winter_priest",
    ]

    print("=" * 60)
    print("Downloading Characters")
    print("=" * 60)

    for char_name, info in results.get("characters", {}).items():
        char_id = info["id"]
        is_enemy = char_name in enemies
        is_npc = char_name in npcs

        if is_enemy:
            download_and_extract_character(char_id, char_name, is_enemy=True)
        elif is_npc:
            # NPCs go to npcs folder
            download_and_extract_character(char_id, char_name, is_enemy=False)
        else:
            # Player
            download_and_extract_character(char_id, char_name, is_enemy=False)

    print("\n" + "=" * 60)
    print("Downloading Tilesets")
    print("=" * 60)

    for tileset_name, info in results.get("tilesets", {}).items():
        tileset_id = info["id"]
        download_tileset(tileset_id, tileset_name)

    print("\n" + "=" * 60)
    print("Downloading Map Objects")
    print("=" * 60)

    for obj_name, info in results.get("map_objects", {}).items():
        obj_id = info["id"]
        download_map_object(obj_id, obj_name)

    print("\n" + "=" * 60)
    print("Download complete!")
    print("=" * 60)


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        if sys.argv[1] == "download":
            download_all_ready()
        elif sys.argv[1] == "status":
            check_all_status()
        else:
            print("Usage: python check_status.py [status|download]")
    else:
        print("Checking status...")
        status = check_all_status()
        if status:
            print("\n" + "=" * 60)
            print("To download ready assets, run:")
            print("  python check_status.py download")
            print("=" * 60)
