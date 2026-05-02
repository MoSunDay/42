#!/usr/bin/env python3
import json
import sys
import os
import time

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "server"))
from headless_client import (
    is_connected,
    connect,
    get_state,
    battle_action,
    use_skill,
    use_item,
    attack,
    defend,
    flee,
)

SKILL_DATA = {
    "dual_blade": {
        "aoe": [
            {"id": "storm_blade", "mp": 35, "priority": 3},
            {"id": "shadow_blade", "mp": 25, "priority": 2},
            {"id": "whirlwind", "mp": 15, "priority": 1},
        ],
        "single": [
            {"id": "phantom_slash", "mp": 20, "priority": 2},
            {"id": "whirlwind", "mp": 15, "priority": 1},
        ],
    },
    "great_sword": {
        "aoe": [],
        "single": [
            {"id": "world_slash", "mp": 45, "priority": 3},
            {"id": "mountain_breaker", "mp": 25, "priority": 2},
            {"id": "heavy_strike", "mp": 12, "priority": 1},
        ],
    },
    "blade_master": {
        "aoe": [
            {"id": "heaven_blade", "mp": 40, "priority": 3},
            {"id": "sword_aura", "mp": 28, "priority": 2},
            {"id": "sweep", "mp": 18, "priority": 1},
        ],
        "single": [],
    },
    "sealer": {
        "aoe": [],
        "single": [
            {"id": "confusion", "mp": 35, "priority": 3},
            {"id": "silence", "mp": 25, "priority": 2},
            {"id": "bind_curse", "mp": 20, "priority": 1},
        ],
    },
    "healer": {
        "aoe": [],
        "single": [],
        "heal": [
            {"id": "revival_light", "mp": 45, "priority": 3},
            {"id": "group_heal", "mp": 30, "priority": 2},
            {"id": "heal", "mp": 15, "priority": 1},
        ],
    },
    "elementalist": {
        "aoe": [
            {"id": "thunder_strike", "mp": 40, "priority": 3},
            {"id": "ice_fall", "mp": 28, "priority": 2},
            {"id": "fire_storm", "mp": 30, "priority": 1},
        ],
        "single": [],
    },
}


def decide_battle_action(state: dict, strategy: str = "balanced") -> dict:
    player = state.get("player", {})
    battle = state.get("battle_state", {})
    hp = player.get("hp", 0)
    max_hp = player.get("maxHp", 1)
    mp = player.get("mp", 0)
    hp_pct = hp / max(max_hp, 1)
    class_id = player.get("classId", "")
    enemies = battle.get("enemies", []) if battle else []
    alive_enemies = [e for e in enemies if e.get("hp", 0) > 0]
    num_enemies = len(alive_enemies)

    heal_threshold = {"aggressive": 0.2, "balanced": 0.35, "defensive": 0.5}.get(
        strategy, 0.35
    )

    class_skills = SKILL_DATA.get(class_id, {})

    if hp_pct < heal_threshold:
        heal_skills = class_skills.get("heal", [])
        usable = [s for s in heal_skills if mp >= s["mp"]]
        if usable:
            best = max(usable, key=lambda s: s["priority"])
            return {"action": "skill", "skill_id": best["id"], "targets": []}

    if num_enemies >= 2:
        aoe_skills = class_skills.get("aoe", [])
        usable = [s for s in aoe_skills if mp >= s["mp"]]
        if usable:
            best = max(usable, key=lambda s: s["priority"])
            return {"action": "skill", "skill_id": best["id"], "targets": []}

    if mp >= 15:
        single_skills = class_skills.get("single", [])
        aoe_skills = class_skills.get("aoe", [])
        all_skills = single_skills + aoe_skills
        usable = [s for s in all_skills if mp >= s["mp"]]
        if usable:
            best = max(usable, key=lambda s: s["priority"])
            target = alive_enemies[0].get("id") if alive_enemies else None
            return {
                "action": "skill",
                "skill_id": best["id"],
                "targets": [target] if target else [],
            }

    if strategy == "defensive" and hp_pct < 0.6:
        return {"action": "defend"}

    target = alive_enemies[0].get("id") if alive_enemies else None
    return {"action": "attack", "target": target}


def run_auto_battle(strategy: str = "balanced", max_turns: int = 100) -> None:
    if not is_connected():
        result = connect()
        if not result.get("success"):
            print(json.dumps({"error": "Cannot connect", "detail": result}))
            sys.exit(1)

    log = []
    for turn in range(max_turns):
        state = get_state()
        if state.get("mode") != "battle":
            log.append({"turn": turn, "event": "battle_end", "mode": state.get("mode")})
            break

        action = decide_battle_action(state, strategy)
        if action["action"] == "skill":
            result = use_skill(action["skill_id"], action.get("targets", []))
        elif action["action"] == "defend":
            result = defend()
        elif action["action"] == "flee":
            result = flee()
        else:
            result = attack(action.get("target"))

        log.append({"turn": turn, "action": action, "result": result})
        time.sleep(0.3)

    print(json.dumps({"log": log}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Auto Battle AI")
    parser.add_argument(
        "--strategy",
        default="balanced",
        choices=["aggressive", "balanced", "defensive"],
    )
    parser.add_argument("--max-turns", type=int, default=100)
    args = parser.parse_args()
    run_auto_battle(args.strategy, args.max_turns)
