#!/usr/bin/env python3
"""Generate portraits from character sprites"""

from PIL import Image
from pathlib import Path

ASSETS = Path(__file__).parent.parent / "assets" / "images"


def create_portrait(char_dir, out_large, out_small):
    """Create 64x64 and 32x32 portraits from character south-facing sprite"""
    south_path = char_dir / "rotations" / "south.png"

    if not south_path.exists():
        # Try animations
        for anim in ["walking", "breathing-idle", "idle"]:
            anim_path = char_dir / "animations" / anim / "south" / "frame_000.png"
            if anim_path.exists():
                south_path = anim_path
                break

    if not south_path.exists():
        return False

    try:
        img = Image.open(south_path).convert("RGBA")

        # Create large portrait (64x64)
        large = img.resize((64, 64), Image.NEAREST)
        large.save(out_large)

        # Create small portrait (32x32)
        small = img.resize((32, 32), Image.NEAREST)
        small.save(out_small)

        return True
    except Exception as e:
        print(f"  Error: {e}")
        return False


def main():
    print("Generating portraits...\n")

    large_dir = ASSETS / "portraits" / "large"
    small_dir = ASSETS / "portraits" / "small"
    large_dir.mkdir(parents=True, exist_ok=True)
    small_dir.mkdir(parents=True, exist_ok=True)

    # Player characters
    players = [
        "warrior",
        "mage",
        "archer",
        "rogue",
        "cleric",
        "knight",
        "wizard",
        "ranger",
    ]

    print("Player portraits:")
    for name in players:
        char_dir = ASSETS / "characters" / name
        if char_dir.exists():
            out_large = large_dir / f"{name}.png"
            out_small = small_dir / f"{name}.png"
            if create_portrait(char_dir, out_large, out_small):
                print(f"  {name}: OK")
            else:
                print(f"  {name}: No sprite found")

    # Enemies
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

    print("\nEnemy portraits:")
    for name in enemies:
        char_dir = ASSETS / "characters" / "enemies" / name
        if char_dir.exists():
            out_large = large_dir / f"enemy_{name}.png"
            out_small = small_dir / f"enemy_{name}.png"
            if create_portrait(char_dir, out_large, out_small):
                print(f"  {name}: OK")
            else:
                print(f"  {name}: No sprite found")

    # NPCs
    npcs = ["villager", "merchant", "healer", "guard", "quest_giver", "elder"]

    print("\nNPC portraits:")
    for name in npcs:
        char_dir = ASSETS / "characters" / "npcs" / name
        if char_dir.exists():
            out_large = large_dir / f"npc_{name}.png"
            out_small = small_dir / f"npc_{name}.png"
            if create_portrait(char_dir, out_large, out_small):
                print(f"  {name}: OK")
            else:
                print(f"  {name}: No sprite found")

    # Count results
    large_count = len(list(large_dir.glob("*.png")))
    small_count = len(list(small_dir.glob("*.png")))

    print(f"\nGenerated: {large_count} large, {small_count} small portraits")


if __name__ == "__main__":
    main()
