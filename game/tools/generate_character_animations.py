#!/usr/bin/env python3
"""
Character Animation Generator - Phase 5
Generates sprite animations for enemies and NPCs.
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import math
import random

BASE_DIR = "assets/images/characters"

ENEMY_CONFIGS = {
    "slime": {"base_color": (50, 200, 100), "size": 32, "shape": "blob", "frames": 4},
    "goblin": {
        "base_color": (100, 150, 80),
        "size": 40,
        "shape": "humanoid",
        "frames": 6,
    },
    "skeleton": {
        "base_color": (220, 220, 200),
        "size": 44,
        "shape": "humanoid",
        "frames": 6,
    },
    "bat": {"base_color": (80, 60, 100), "size": 28, "shape": "flying", "frames": 4},
    "orc_warrior": {
        "base_color": (120, 100, 80),
        "size": 52,
        "shape": "humanoid",
        "frames": 6,
    },
    "skeleton_knight": {
        "base_color": (180, 180, 190),
        "size": 52,
        "shape": "humanoid",
        "frames": 6,
    },
    "wolf": {
        "base_color": (100, 90, 80),
        "size": 48,
        "shape": "quadruped",
        "frames": 6,
    },
    "dark_mage": {
        "base_color": (60, 40, 100),
        "size": 44,
        "shape": "humanoid",
        "frames": 6,
    },
    "orc_chieftain": {
        "base_color": (150, 80, 60),
        "size": 60,
        "shape": "humanoid",
        "frames": 6,
    },
    "vampire": {
        "base_color": (150, 50, 80),
        "size": 48,
        "shape": "humanoid",
        "frames": 6,
    },
    "golem": {
        "base_color": (120, 110, 100),
        "size": 64,
        "shape": "humanoid",
        "frames": 4,
    },
    "demon": {
        "base_color": (180, 60, 60),
        "size": 56,
        "shape": "humanoid",
        "frames": 6,
    },
    "ancient_dragon": {
        "base_color": (200, 150, 50),
        "size": 96,
        "shape": "dragon",
        "frames": 6,
    },
    "lich_king": {
        "base_color": (80, 60, 120),
        "size": 56,
        "shape": "humanoid",
        "frames": 6,
    },
    "chaos_serpent": {
        "base_color": (100, 50, 150),
        "size": 80,
        "shape": "serpent",
        "frames": 6,
    },
}

NPC_CONFIGS = {
    "villager": {
        "base_color": (139, 90, 43),
        "cloth_color": (100, 140, 180),
        "size": 40,
        "shape": "humanoid",
    },
    "merchant": {
        "base_color": (160, 120, 80),
        "cloth_color": (180, 140, 60),
        "size": 40,
        "shape": "humanoid",
    },
    "healer": {
        "base_color": (200, 180, 160),
        "cloth_color": (220, 220, 240),
        "size": 40,
        "shape": "humanoid",
    },
    "guard": {
        "base_color": (180, 150, 130),
        "cloth_color": (80, 80, 100),
        "size": 44,
        "shape": "humanoid",
    },
    "quest_giver": {
        "base_color": (180, 140, 100),
        "cloth_color": (140, 100, 60),
        "size": 40,
        "shape": "humanoid",
    },
    "elder": {
        "base_color": (200, 200, 200),
        "cloth_color": (100, 80, 120),
        "size": 40,
        "shape": "humanoid",
    },
}

DIRECTIONS = ["south", "west", "east", "north"]


def adjust_color(color, factor):
    r = min(255, max(0, int(color[0] * factor)))
    g = min(255, max(0, int(color[1] * factor)))
    b = min(255, max(0, int(color[2] * factor)))
    return (r, g, b)


def draw_blob_sprite(draw, cx, cy, size, color, frame, direction):
    wobble = math.sin(frame * math.pi / 2) * 2
    base_r = size // 2 - 2

    for i in range(3):
        r = base_r - i * 3
        c = adjust_color(color, 1.0 - i * 0.15)
        offset_y = wobble if i == 0 else wobble * 0.5
        draw.ellipse([cx - r, cy - r + offset_y, cx + r, cy + r + offset_y], fill=c)

    eye_offset = 4 if direction == "east" else -4 if direction == "west" else 0
    draw.ellipse(
        [cx - 4 + eye_offset, cy - 4, cx - 1 + eye_offset, cy - 1], fill=(0, 0, 0)
    )
    draw.ellipse(
        [cx + 1 + eye_offset, cy - 4, cx + 4 + eye_offset, cy - 1], fill=(0, 0, 0)
    )


def draw_humanoid_sprite(
    draw, cx, cy, size, color, frame, direction, has_cloth=False, cloth_color=None
):
    head_r = size // 6
    body_h = size // 2
    leg_w = size // 8
    arm_w = size // 10

    leg_swing = math.sin(frame * math.pi / 3) * 4
    arm_swing = math.sin(frame * math.pi / 3) * 3

    draw.ellipse(
        [cx - head_r, cy - size // 2, cx + head_r, cy - size // 2 + head_r * 2],
        fill=color,
    )

    if has_cloth and cloth_color:
        draw.rectangle(
            [cx - size // 4, cy - size // 6, cx + size // 4, cy + size // 6],
            fill=cloth_color,
        )
    else:
        draw.rectangle(
            [cx - size // 4, cy - size // 6, cx + size // 4, cy + size // 6],
            fill=adjust_color(color, 0.8),
        )

    draw.rectangle(
        [
            cx - leg_w - 2,
            cy + size // 6,
            cx - 2,
            cy + size // 6 + body_h // 2 + leg_swing,
        ],
        fill=color,
    )
    draw.rectangle(
        [
            cx + 2,
            cy + size // 6,
            cx + leg_w + 2,
            cy + size // 6 + body_h // 2 - leg_swing,
        ],
        fill=color,
    )

    draw.rectangle(
        [
            cx - size // 4 - arm_w,
            cy - size // 8 + arm_swing,
            cx - size // 4,
            cy + size // 8 + arm_swing,
        ],
        fill=color,
    )
    draw.rectangle(
        [
            cx + size // 4,
            cy - size // 8 - arm_swing,
            cx + size // 4 + arm_w,
            cy + size // 8 - arm_swing,
        ],
        fill=color,
    )


def draw_flying_sprite(draw, cx, cy, size, color, frame, direction):
    wing_angle = math.sin(frame * math.pi / 2) * 15

    body_color = adjust_color(color, 0.8)
    wing_color = color

    draw.ellipse(
        [cx - size // 6, cy - size // 4, cx + size // 6, cy + size // 4],
        fill=body_color,
    )

    wing_offset = int(wing_angle)
    draw.polygon(
        [
            (cx - size // 6, cy),
            (cx - size // 2, cy - wing_offset - 5),
            (cx - size // 2, cy + wing_offset + 5),
        ],
        fill=wing_color,
    )
    draw.polygon(
        [
            (cx + size // 6, cy),
            (cx + size // 2, cy + wing_offset - 5),
            (cx + size // 2, cy - wing_offset + 5),
        ],
        fill=wing_color,
    )

    draw.ellipse([cx - 2, cy - size // 6, cx + 2, cy - size // 6 + 3], fill=(255, 0, 0))


def draw_quadruped_sprite(draw, cx, cy, size, color, frame, direction):
    leg_offset = math.sin(frame * math.pi / 3) * 3

    draw.ellipse(
        [cx - size // 3, cy - size // 6, cx + size // 3, cy + size // 6], fill=color
    )
    draw.ellipse(
        [cx - size // 4, cy - size // 4, cx, cy], fill=adjust_color(color, 0.9)
    )

    draw.ellipse([cx - 2, cy - size // 5, cx + 2, cy - size // 5 + 3], fill=(0, 0, 0))

    for i, leg_x in enumerate([-size // 4, -size // 8, size // 8, size // 4]):
        swing = leg_offset if i % 2 == 0 else -leg_offset
        draw.rectangle(
            [cx + leg_x - 2, cy + size // 6, cx + leg_x + 2, cy + size // 3 + swing],
            fill=adjust_color(color, 0.7),
        )


def draw_dragon_sprite(draw, cx, cy, size, color, frame, direction):
    wing_angle = math.sin(frame * math.pi / 3) * 10

    draw.ellipse(
        [cx - size // 4, cy - size // 8, cx + size // 4, cy + size // 8], fill=color
    )
    draw.ellipse(
        [cx + size // 6, cy - size // 6, cx + size // 3, cy + size // 10],
        fill=adjust_color(color, 0.9),
    )

    wing_offset = int(wing_angle)
    draw.polygon(
        [
            (cx - size // 8, cy - size // 8),
            (cx - size // 2, cy - size // 3 - wing_offset),
            (cx - size // 2, cy),
        ],
        fill=adjust_color(color, 0.8),
    )
    draw.polygon(
        [
            (cx - size // 8, cy - size // 8),
            (cx - size // 2, cy + size // 6 - wing_offset),
            (cx - size // 2, cy),
        ],
        fill=adjust_color(color, 0.8),
    )

    draw.polygon(
        [
            (cx + size // 3, cy - size // 10),
            (cx + size // 2, cy - size // 8),
            (cx + size // 3, cy),
        ],
        fill=adjust_color(color, 0.7),
    )

    draw.ellipse(
        [cx + size // 3 - 4, cy - size // 10 - 2, cx + size // 3, cy - size // 10 + 2],
        fill=(255, 50, 50),
    )


def draw_serpent_sprite(draw, cx, cy, size, color, frame, direction):
    wave = math.sin(frame * math.pi / 3)

    points = []
    for i in range(10):
        x = cx - size // 2 + i * size // 10
        y = cy + math.sin(i * 0.5 + frame * 0.5) * 8
        points.append((x, y))

    for i in range(len(points) - 1):
        thickness = size // 6 - abs(i - 5) * 2
        if thickness > 0:
            draw.line([points[i], points[i + 1]], fill=color, width=thickness)

    draw.ellipse(
        [cx + size // 3 - 8, cy - 6, cx + size // 3, cy + 6],
        fill=adjust_color(color, 0.9),
    )
    draw.ellipse(
        [cx + size // 3 - 4, cy - 2, cx + size // 3 - 2, cy + 2], fill=(255, 0, 0)
    )
    draw.ellipse(
        [cx + size // 3 - 4, cy - 1, cx + size // 3 - 2, cy + 1], fill=(255, 0, 0)
    )


def generate_enemy_sprites():
    print("Generating enemy sprites...")

    for enemy_id, config in ENEMY_CONFIGS.items():
        enemy_dir = f"{BASE_DIR}/enemies/{enemy_id}"
        os.makedirs(f"{enemy_dir}/rotations", exist_ok=True)
        os.makedirs(f"{enemy_dir}/animations/idle", exist_ok=True)

        size = config["size"]
        base_color = config["base_color"]
        shape = config["shape"]
        frames = config["frames"]

        for direction in DIRECTIONS:
            img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)
            cx, cy = size // 2, size // 2

            if shape == "blob":
                draw_blob_sprite(draw, cx, cy, size, base_color, 0, direction)
            elif shape == "flying":
                draw_flying_sprite(draw, cx, cy, size, base_color, 0, direction)
            elif shape == "quadruped":
                draw_quadruped_sprite(draw, cx, cy, size, base_color, 0, direction)
            elif shape == "dragon":
                draw_dragon_sprite(draw, cx, cy, size, base_color, 0, direction)
            elif shape == "serpent":
                draw_serpent_sprite(draw, cx, cy, size, base_color, 0, direction)
            else:
                draw_humanoid_sprite(draw, cx, cy, size, base_color, 0, direction)

            filepath = f"{enemy_dir}/rotations/{direction}.png"
            img.save(filepath)

        for direction in DIRECTIONS:
            dir_path = f"{enemy_dir}/animations/idle/{direction}"
            os.makedirs(dir_path, exist_ok=True)

            for frame in range(frames):
                img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
                draw = ImageDraw.Draw(img)
                cx, cy = size // 2, size // 2

                if shape == "blob":
                    draw_blob_sprite(draw, cx, cy, size, base_color, frame, direction)
                elif shape == "flying":
                    draw_flying_sprite(draw, cx, cy, size, base_color, frame, direction)
                elif shape == "quadruped":
                    draw_quadruped_sprite(
                        draw, cx, cy, size, base_color, frame, direction
                    )
                elif shape == "dragon":
                    draw_dragon_sprite(draw, cx, cy, size, base_color, frame, direction)
                elif shape == "serpent":
                    draw_serpent_sprite(
                        draw, cx, cy, size, base_color, frame, direction
                    )
                else:
                    draw_humanoid_sprite(
                        draw, cx, cy, size, base_color, frame, direction
                    )

                filepath = f"{dir_path}/frame_{frame:03d}.png"
                img.save(filepath)

        print(f"  Created sprites for {enemy_id}")


def generate_npc_sprites():
    print("Generating NPC sprites...")

    for npc_id, config in NPC_CONFIGS.items():
        npc_dir = f"{BASE_DIR}/npcs/{npc_id}"
        os.makedirs(f"{npc_dir}/rotations", exist_ok=True)
        os.makedirs(f"{npc_dir}/animations/idle", exist_ok=True)

        size = config["size"]
        base_color = config["base_color"]
        cloth_color = config.get("cloth_color")

        for direction in DIRECTIONS:
            img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)
            cx, cy = size // 2, size // 2

            draw_humanoid_sprite(
                draw, cx, cy, size, base_color, 0, direction, True, cloth_color
            )

            filepath = f"{npc_dir}/rotations/{direction}.png"
            img.save(filepath)

        for direction in DIRECTIONS:
            dir_path = f"{npc_dir}/animations/idle/{direction}"
            os.makedirs(dir_path, exist_ok=True)

            for frame in range(4):
                img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
                draw = ImageDraw.Draw(img)
                cx, cy = size // 2, size // 2

                draw_humanoid_sprite(
                    draw, cx, cy, size, base_color, frame, direction, True, cloth_color
                )

                filepath = f"{dir_path}/frame_{frame:03d}.png"
                img.save(filepath)

        print(f"  Created sprites for {npc_id}")


def main():
    print("=" * 50)
    print("Phase 5: Character Animation Generation")
    print("=" * 50)

    generate_enemy_sprites()
    generate_npc_sprites()

    print("\n" + "=" * 50)
    print("Phase 5 Complete!")
    print("=" * 50)


if __name__ == "__main__":
    main()
