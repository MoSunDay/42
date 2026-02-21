#!/usr/bin/env python3
"""
PixelLab Resource Generator for 42 RPG Game
Generates all game assets using PixelLab API v2
"""

import requests
import json
import time
import os
import sys
from pathlib import Path

API_TOKEN = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {"Authorization": f"Bearer {API_TOKEN}", "Content-Type": "application/json"}

OUTPUT_DIR = Path(__file__).parent / "generated_assets"


def api_post(endpoint, data):
    """Make POST request to API"""
    url = f"{BASE_URL}{endpoint}"
    response = requests.post(url, headers=HEADERS, json=data)
    return response.json()


def api_get(endpoint):
    """Make GET request to API"""
    url = f"{BASE_URL}{endpoint}"
    response = requests.get(url, headers=HEADERS)
    return response.json()


def wait_for_job(job_id, timeout=300):
    """Wait for background job to complete"""
    start = time.time()
    while time.time() - start < timeout:
        result = api_get(f"/background-jobs/{job_id}")
        status = result.get("status", "unknown")
        if status == "completed":
            return True, result
        elif status == "failed":
            return False, result
        print(f"  Job {job_id[:8]}... status: {status}")
        time.sleep(10)
    return False, {"error": "timeout"}


def download_file(url, filepath):
    """Download file from URL"""
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(filepath, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        return True
    return False


# ============================================================
# CHARACTER DEFINITIONS
# ============================================================

PLAYER_CHARACTERS = {
    "hero": {
        "description": "fantasy hero with blue cloak and sword, brave adventurer",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 8,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    }
}

ENEMIES = {
    # Tier 1: Common
    "slime": {
        "description": "cute green slime blob with googly eyes, gelatinous creature",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "thick",
        "shading": "soft",
        "detail": "medium",
    },
    "goblin": {
        "description": "mischievous green goblin with pointy ears and rusty dagger",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "medium",
    },
    "skeleton": {
        "description": "animated skeleton warrior holding rusty sword, glowing eyes",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "thin",
        "shading": "hard",
        "detail": "high",
    },
    "bat": {
        "description": "vicious flying bat with red eyes and spread wings",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "thin",
        "shading": "soft",
        "detail": "medium",
    },
    # Tier 2: Elite
    "orc_warrior": {
        "description": "large green orc warrior with battle axe and tribal armor",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "hard",
        "detail": "high",
    },
    "skeleton_knight": {
        "description": "armored skeleton knight with shield and sword, tattered cape",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "hard",
        "detail": "high",
    },
    "wolf": {
        "description": "ferocious gray dire wolf with sharp fangs, aggressive stance",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "medium",
    },
    "dark_mage": {
        "description": "sinister dark mage in purple robes, holding glowing staff",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
    # Tier 3: Boss
    "orc_chieftain": {
        "description": "massive orc chieftain with tribal armor and warhammer",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "thick",
        "shading": "hard",
        "detail": "high",
    },
    "vampire": {
        "description": "elegant vampire lord in black cape, pale skin, red eyes",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
    "golem": {
        "description": "massive stone golem with glowing eyes, rocky body",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "thick",
        "shading": "hard",
        "detail": "medium",
    },
    "demon": {
        "description": "fearsome red demon with horns, wings and flaming sword",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "hard",
        "detail": "high",
    },
    # Tier 4: Legendary
    "ancient_dragon": {
        "description": "majestic golden ancient dragon with scales and wings",
        "image_size": {"width": 64, "height": 64},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
    "lich_king": {
        "description": "undead lich king with crown, staff and tattered robes",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
    "chaos_serpent": {
        "description": "purple chaos serpent with multiple heads, mystical aura",
        "image_size": {"width": 64, "height": 64},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
}

NPCS = {
    "village_chief": {
        "description": "wise old village chief with white beard and wooden staff",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "medium",
    },
    "spring_guardian": {
        "description": "nature spirit with flower crown and green robes",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
    "summer_merchant": {
        "description": "cheerful merchant with colorful clothes and goods bag",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "medium",
    },
    "autumn_innkeeper": {
        "description": "friendly innkeeper with apron and ale mug",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "medium",
    },
    "winter_priest": {
        "description": "mysterious ice priest in white robes with crystal staff",
        "image_size": {"width": 48, "height": 48},
        "n_directions": 4,
        "view": "low top-down",
        "outline": "medium",
        "shading": "soft",
        "detail": "high",
    },
}

TILESETS = {
    "ocean_beach": {
        "lower_description": "deep blue ocean water with waves",
        "upper_description": "sandy yellow beach",
        "tile_size": {"width": 32, "height": 32},
    },
    "beach_grass": {
        "lower_description": "sandy beach",
        "upper_description": "bright green grass with small flowers",
        "tile_size": {"width": 32, "height": 32},
    },
    "grass_path": {
        "lower_description": "green grass",
        "upper_description": "brown dirt path",
        "tile_size": {"width": 32, "height": 32},
    },
    "forest_floor": {
        "lower_description": "green grass",
        "upper_description": "dense forest floor with leaves",
        "tile_size": {"width": 32, "height": 32},
    },
    "summer_grass": {
        "lower_description": "vibrant summer grass",
        "upper_description": "stone cobble path",
        "tile_size": {"width": 32, "height": 32},
    },
    "autumn_leaves": {
        "lower_description": "orange and brown autumn grass",
        "upper_description": "fallen leaves path",
        "tile_size": {"width": 32, "height": 32},
    },
    "winter_snow": {
        "lower_description": "white snow ground",
        "upper_description": "icy frozen path",
        "tile_size": {"width": 32, "height": 32},
    },
}

MAP_OBJECTS = {
    "spring_tree": {
        "description": "cherry blossom tree with pink flowers, full bloom",
        "image_size": {"width": 64, "height": 80},
        "view": "high top-down",
    },
    "summer_tree": {
        "description": "lush green oak tree with full foliage",
        "image_size": {"width": 64, "height": 80},
        "view": "high top-down",
    },
    "autumn_tree": {
        "description": "maple tree with orange and red autumn leaves",
        "image_size": {"width": 64, "height": 80},
        "view": "high top-down",
    },
    "winter_tree": {
        "description": "pine tree covered in white snow",
        "image_size": {"width": 64, "height": 80},
        "view": "high top-down",
    },
    "village_house": {
        "description": "cozy medieval cottage with thatched roof and chimney",
        "image_size": {"width": 64, "height": 64},
        "view": "high top-down",
    },
    "village_shop": {
        "description": "market stall with colorful awning and goods",
        "image_size": {"width": 64, "height": 64},
        "view": "high top-down",
    },
    "village_inn": {
        "description": "wooden inn building with hanging sign",
        "image_size": {"width": 80, "height": 64},
        "view": "high top-down",
    },
    "temple": {
        "description": "stone temple with columns and ornate entrance",
        "image_size": {"width": 96, "height": 80},
        "view": "high top-down",
    },
    "shrine": {
        "description": "small wooden shrine with paper lanterns",
        "image_size": {"width": 48, "height": 48},
        "view": "high top-down",
    },
    "rock": {
        "description": "mossy gray rock",
        "image_size": {"width": 32, "height": 32},
        "view": "high top-down",
    },
    "flowers": {
        "description": "colorful wildflowers patch",
        "image_size": {"width": 32, "height": 32},
        "view": "high top-down",
    },
    "campfire": {
        "description": "burning campfire with logs and flames",
        "image_size": {"width": 32, "height": 32},
        "view": "high top-down",
    },
}

ANIMATION_TEMPLATES = ["walking", "breathing-idle", "fight-stance-idle-8-frames"]

# ============================================================
# GENERATION FUNCTIONS
# ============================================================


def create_character(char_id, char_data, n_directions=8):
    """Create a character with rotations"""
    print(f"Creating character: {char_id}")

    endpoint = (
        "/create-character-with-8-directions"
        if n_directions == 8
        else "/create-character-with-4-directions"
    )

    payload = {
        "description": char_data["description"],
        "image_size": char_data["image_size"],
        "view": char_data.get("view", "low top-down"),
        "outline": char_data.get("outline", "medium"),
        "shading": char_data.get("shading", "soft"),
        "detail": char_data.get("detail", "medium"),
        "async_mode": True,
    }

    result = api_post(endpoint, payload)

    if result.get("success") or result.get("character_id"):
        char_id_result = result.get("character_id")
        job_id = result.get("background_job_id")
        print(f"  Created: {char_id_result}, Job: {job_id}")
        return char_id_result, job_id
    else:
        print(f"  Error: {result}")
        return None, None


def animate_character(char_id, animation_id, directions=None):
    """Queue animation for a character"""
    payload = {
        "character_id": char_id,
        "template_animation_id": animation_id,
        "async_mode": True,
    }
    if directions:
        payload["directions"] = directions

    result = api_post("/characters/animations", payload)

    if result.get("success") or result.get("background_job_id"):
        print(f"  Animation queued: {animation_id}")
        return True
    else:
        print(f"  Animation error: {result}")
        return False


def create_tileset(tileset_id, tileset_data):
    """Create a Wang tileset"""
    print(f"Creating tileset: {tileset_id}")

    payload = {
        "lower_description": tileset_data["lower_description"],
        "upper_description": tileset_data["upper_description"],
        "tile_size": tileset_data["tile_size"],
        "view": "low top-down",
    }

    result = api_post("/tilesets", payload)

    if result.get("success") or result.get("tileset_id"):
        tileset_id_result = result.get("tileset_id")
        job_id = result.get("background_job_id")
        print(f"  Created: {tileset_id_result}, Job: {job_id}")
        return tileset_id_result, job_id
    else:
        print(f"  Error: {result}")
        return None, None


def create_map_object(obj_id, obj_data):
    """Create a map object"""
    print(f"Creating map object: {obj_id}")

    payload = {
        "description": obj_data["description"],
        "image_size": obj_data["image_size"],
        "view": obj_data.get("view", "high top-down"),
    }

    result = api_post("/map-objects", payload)

    if result.get("success") or result.get("map_object_id"):
        obj_id_result = result.get("map_object_id")
        job_id = result.get("background_job_id")
        print(f"  Created: {obj_id_result}, Job: {job_id}")
        return obj_id_result, job_id
    else:
        print(f"  Error: {result}")
        return None, None


def download_character_zip(char_id, output_path):
    """Download character as ZIP"""
    print(f"Downloading character: {char_id}")

    result = api_get(f"/characters/{char_id}/zip")

    if result.get("download_url"):
        zip_path = output_path / f"{char_id}.zip"
        if download_file(result["download_url"], zip_path):
            print(f"  Downloaded: {zip_path}")
            return True
    return False


# ============================================================
# MAIN GENERATION
# ============================================================


def main():
    OUTPUT_DIR.mkdir(exist_ok=True)

    results = {"characters": {}, "tilesets": {}, "map_objects": {}}

    print("=" * 60)
    print("Phase 1: Creating Player Characters")
    print("=" * 60)
    for char_id, char_data in PLAYER_CHARACTERS.items():
        cid, job = create_character(
            char_id, char_data, char_data.get("n_directions", 8)
        )
        if cid:
            results["characters"][char_id] = {"id": cid, "job": job, "animations": []}

    print("\n" + "=" * 60)
    print("Phase 2: Creating Enemies")
    print("=" * 60)
    for enemy_id, enemy_data in ENEMIES.items():
        cid, job = create_character(
            enemy_id, enemy_data, enemy_data.get("n_directions", 4)
        )
        if cid:
            results["characters"][enemy_id] = {"id": cid, "job": job, "animations": []}

    print("\n" + "=" * 60)
    print("Phase 3: Creating NPCs")
    print("=" * 60)
    for npc_id, npc_data in NPCS.items():
        cid, job = create_character(npc_id, npc_data, npc_data.get("n_directions", 4))
        if cid:
            results["characters"][npc_id] = {"id": cid, "job": job, "animations": []}

    print("\n" + "=" * 60)
    print("Phase 4: Creating Tilesets")
    print("=" * 60)
    for tileset_id, tileset_data in TILESETS.items():
        tid, job = create_tileset(tileset_id, tileset_data)
        if tid:
            results["tilesets"][tileset_id] = {"id": tid, "job": job}

    print("\n" + "=" * 60)
    print("Phase 5: Creating Map Objects")
    print("=" * 60)
    for obj_id, obj_data in MAP_OBJECTS.items():
        oid, job = create_map_object(obj_id, obj_data)
        if oid:
            results["map_objects"][obj_id] = {"id": oid, "job": job}

    # Save results
    results_file = OUTPUT_DIR / "generation_results.json"
    with open(results_file, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nResults saved to: {results_file}")

    print("\n" + "=" * 60)
    print("Phase 6: Waiting for generation to complete...")
    print("=" * 60)

    # Wait and queue animations
    time.sleep(60)  # Wait for characters to be ready

    print("\n" + "=" * 60)
    print("Phase 7: Queueing animations for all characters")
    print("=" * 60)
    for char_id, info in results["characters"].items():
        print(f"\nAnimations for: {char_id}")
        for anim in ["walking", "breathing-idle"]:
            if animate_character(info["id"], anim):
                info["animations"].append(anim)

    # Update results
    with open(results_file, "w") as f:
        json.dump(results, f, indent=2)

    print("\n" + "=" * 60)
    print("Generation complete! Check status with check_status.py")
    print("=" * 60)

    return results


if __name__ == "__main__":
    main()
