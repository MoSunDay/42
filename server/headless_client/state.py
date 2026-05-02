from typing import Dict, Any, Optional, List


def initial_state() -> Dict[str, Any]:
    return {
        "connected": False,
        "mode": "disconnected",
        "username": None,
        "characters": [],
        "character": None,
        "player": None,
        "position": None,
        "battle_state": None,
    }


def update_state(state: Dict[str, Any], event: Dict[str, Any]) -> Dict[str, Any]:
    event_type = event.get("type")

    if event_type == "connected":
        return {
            **state,
            "connected": True,
            "mode": "login",
        }

    if event_type == "login_success":
        return {
            **state,
            "mode": "character_select",
            "username": event.get("username"),
            "characters": event.get("characters", []),
        }

    if event_type == "login_failed":
        return {**state, "mode": "login"}

    if event_type == "character_selected":
        character = event.get("character", {})
        return {
            **state,
            "mode": "exploration",
            "character": character,
            "player": _extract_player(character),
            "position": _extract_position(character),
        }

    if event_type == "battle_start":
        return {
            **state,
            "mode": "battle",
            "battle_state": event.get("battle"),
        }

    if event_type == "battle_end":
        return {
            **state,
            "mode": "exploration",
            "battle_state": None,
            "player": event.get("player", state["player"]),
        }

    if event_type == "position_update":
        return {**state, "position": event.get("position", state["position"])}

    if event_type == "player_update":
        return {**state, "player": event.get("player", state["player"])}

    if event_type == "disconnected":
        return initial_state()

    return state


def _extract_player(character: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    if not character:
        return None
    return {
        "name": character.get("characterName", ""),
        "level": character.get("level", 1),
        "classId": character.get("classId", ""),
        "hp": character.get("hp", 0),
        "maxHp": character.get("maxHp", 0),
        "mp": character.get("mp", 0),
        "maxMp": character.get("maxMp", 0),
        "attack": character.get("attack", 0),
        "defense": character.get("defense", 0),
        "speed": character.get("speed", 0),
        "magicAttack": character.get("magicAttack", 0),
        "experience": character.get("experience", 0),
        "experienceToNext": character.get("experienceToNext", 0),
        "skillCrystals": character.get("skillCrystals", 0),
        "skills": character.get("skills", []),
        "equipment": character.get("equipment", {}),
        "inventory": character.get("inventory", {}),
    }


def _extract_position(character: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    if not character:
        return None
    return {
        "x": character.get("x", 0),
        "y": character.get("y", 0),
        "mapId": character.get("mapId", "town_01"),
    }


def get_summary(state: Dict[str, Any]) -> Dict[str, Any]:
    result = {
        "connected": state["connected"],
        "mode": state["mode"],
        "username": state["username"],
    }
    if state["player"]:
        result["player"] = {
            "name": state["player"]["name"],
            "level": state["player"]["level"],
            "classId": state["player"]["classId"],
            "hp": state["player"]["hp"],
            "maxHp": state["player"]["maxHp"],
            "mp": state["player"]["mp"],
            "maxMp": state["player"]["maxMp"],
        }
    if state["position"]:
        result["position"] = state["position"]
    if state["battle_state"]:
        result["battle"] = state["battle_state"]
    if state["characters"]:
        result["characters"] = [
            {
                "id": c.get("id", ""),
                "name": c.get("characterName", ""),
                "level": c.get("level", 1),
                "classId": c.get("classId", ""),
            }
            for c in state["characters"]
        ]
    return result
