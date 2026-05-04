#!/usr/bin/env python3
"""
Generate seasonal tileset tiles via Pixellab API (pixflux).
Produces grass, road, water tiles for spring/summer/autumn/winter.
"""

import sys
import time
from pathlib import Path

# Use sibling pixellab_client for API key and helpers
sys.path.insert(0, str(Path(__file__).parent))
from pixellab_client import (
    API_KEY,
    BASE_URL,
    HEADERS,
    AssetJob,
    submit_pixflux_job,
    OUTPUT_BASE,
)

TILESET_BASE = OUTPUT_BASE.parent / "tilesets"

SEASON_STYLE = "simple geometric pixel art, 32x32 tiles, clean outlines, limited 32 color palette, flat colors, minimal details, top-down RPG game terrain tile, seamless tileable"

SEASON_PROMPTS = {
    "spring": {
        "grass1": "bright green grass ground tile, spring meadow, tiny flower hints",
        "grass2": "light green grass tile, fresh spring growth, varied patches",
        "grass3": "vibrant green grass, lush spring field",
        "grass4": "yellow-green grass tile, sunlit spring ground",
        "road1": "dirt path tile, brown earth road, spring ground",
        "road2": "cobblestone road tile, gray stones, spring setting",
        "water": "clear blue water tile, gentle spring stream, shallow",
    },
    "summer": {
        "grass1": "deep green grass tile, summer meadow, thick growth",
        "grass2": "dark green grass, summer forest floor",
        "grass3": "emerald grass tile, summer field, lush",
        "grass4": "mossy green grass, shaded summer ground",
        "road1": "worn dirt path tile, dry earth, summer",
        "road2": "sun-bleached stone road, summer ground",
        "water": "deep blue lake water tile, summer pond surface",
    },
    "autumn": {
        "grass1": "golden brown grass tile, autumn meadow, fallen leaves",
        "grass2": "orange-tinted grass, dry autumn ground",
        "grass3": "red-brown grass tile, autumn forest floor, leaf litter",
        "grass4": "amber grass ground, warm autumn tones",
        "road1": "muddy dirt path, wet autumn earth",
        "road2": "cobblestone road with fallen leaves, autumn",
        "water": "dark blue water tile, autumn pond, still surface",
    },
    "winter": {
        "grass1": "snow-covered ground tile, white winter field",
        "grass2": "light blue-white snow tile, frost, winter ground",
        "grass3": "pure white snow ground, thick winter snow",
        "grass4": "icy ground tile, frozen earth, pale blue snow",
        "road1": "snow-dusted dirt path, winter trail",
        "road2": "icy stone road tile, frost, winter",
        "water": "frozen ice water tile, winter pond, blue-white ice surface",
    },
}


def build_jobs():
    jobs = []
    for season, tiles in SEASON_PROMPTS.items():
        for name, desc in tiles.items():
            prompt = f"{SEASON_STYLE}, {desc}"
            filename = name
            category = f"tilesets/{season}"
            job = AssetJob(
                category=category,
                filename=filename,
                prompt=prompt,
                width=32,
                height=32,
                no_background=False,
            )
            # Override output path to tilesets dir
            job._output_path = TILESET_BASE / season / f"{filename}.png"
            jobs.append(job)
    return jobs


@property
def _patched_output_path(self):
    """Allow job to use custom output path set externally."""
    if hasattr(self, "_output_path"):
        return self._output_path
    return OUTPUT_BASE / self.category / f"{self.filename}.png"


# Patch AssetJob.output_path to support custom tileset path
AssetJob.output_path = _patched_output_path


def run():
    if not API_KEY or API_KEY.startswith("$"):
        print("Error: PIXELLAB_API_KEY not set")
        sys.exit(1)

    jobs = build_jobs()
    total = len(jobs)
    print(f"\nSeasonal Tileset Generator")
    print(f"==========================")
    print(f"Total tiles: {total} ({len(SEASON_PROMPTS)} seasons x ~7 tiles)")
    print(f"API: {BASE_URL}/create-image-pixflux\n")

    # Filter existing
    pending = [j for j in jobs if not j.output_path.exists()]
    existing = total - len(pending)
    print(f"Already exist: {existing}, need to generate: {len(pending)}\n")

    if not pending:
        print("All tiles already generated!")
        return

    completed = 0
    failed = 0

    for i, job in enumerate(pending):
        print(f"  [{i + 1}/{len(pending)}] {job.category}/{job.filename} ...", end=" ")
        sys.stdout.flush()

        ok = submit_pixflux_job(job)
        if ok and job.status == "completed":
            print("done")
            completed += 1
        else:
            print(f"FAIL: {job.error}")
            failed += 1

        # Rate limit: ~2 req/sec max for free tier
        time.sleep(0.6)

    print(f"\nResult: {completed} success, {failed} failed")
    print(f"Output: {TILESET_BASE}")


if __name__ == "__main__":
    run()
