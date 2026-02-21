#!/usr/bin/env python3
"""
Queue animations for all generated characters
"""

import requests
import json
from pathlib import Path

API_TOKEN = "${PIXELLAB_API_KEY:-}"
BASE_URL = "https://api.pixellab.ai/v2"
HEADERS = {"Authorization": f"Bearer {API_TOKEN}", "Content-Type": "application/json"}

SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR / "generated_assets"
RESULTS_FILE = OUTPUT_DIR / "generation_results.json"


def api_post(endpoint, data):
    url = f"{BASE_URL}{endpoint}"
    response = requests.post(url, headers=HEADERS, json=data)
    return response.json()


def queue_animation(char_id, animation_id):
    """Queue animation for a character"""
    payload = {
        "character_id": char_id,
        "template_animation_id": animation_id,
        "async_mode": True,
    }

    result = api_post("/characters/animations", payload)

    if result.get("success") or result.get("background_job_id"):
        print(f"  Queued: {animation_id}")
        return True
    else:
        print(f"  Failed: {result}")
        return False


def main():
    if not RESULTS_FILE.exists():
        print("No generation results found. Run generate_assets.py first.")
        return

    with open(RESULTS_FILE, "r") as f:
        results = json.load(f)

    animations = ["walking", "breathing-idle"]

    print("=" * 60)
    print("Queueing animations for all characters")
    print("=" * 60)

    for char_name, info in results.get("characters", {}).items():
        char_id = info["id"]
        print(f"\n{char_name} ({char_id[:8]}...):")

        for anim in animations:
            queue_animation(char_id, anim)

    print("\n" + "=" * 60)
    print("Done queueing animations!")
    print("=" * 60)


if __name__ == "__main__":
    main()
