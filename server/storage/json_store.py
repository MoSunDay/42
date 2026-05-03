import json
import os
import hashlib
import threading
import uuid
from typing import Dict, Any, Optional, List
from datetime import datetime
from copy import deepcopy


MAX_CHARACTERS_PER_ACCOUNT = 10

DEFAULT_ACCOUNTS: Dict[str, Dict[str, Any]] = {
    "test": {
        "username": "test",
        "password_hash": "",
        "characters": [
            {
                "id": "char_test_default",
                "characterName": "Test Hero",
                "level": 5,
                "exp": 50,
                "gold": 500,
                "hp": 150,
                "maxHp": 150,
                "attack": 25,
                "defense": 10,
                "speed": 6,
                "x": 1600,
                "y": 1600,
                "mapId": "newbie_village",
                "avatarColor": [0.3, 0.5, 1.0],
            }
        ],
        "created_at": "",
        "last_login": None,
    },
    "admin": {
        "username": "admin",
        "password_hash": "",
        "characters": [
            {
                "id": "char_admin_default",
                "characterName": "Admin",
                "level": 10,
                "exp": 0,
                "gold": 9999,
                "hp": 300,
                "maxHp": 300,
                "attack": 50,
                "defense": 20,
                "speed": 8,
                "x": 2400,
                "y": 2100,
                "mapId": "four_seasons_city",
                "avatarColor": [1.0, 0.8, 0.2],
            }
        ],
        "created_at": "",
        "last_login": None,
    },
}

_lock = threading.RLock()
_data_dir = ""
_accounts_file = ""
_accounts: Dict[str, Dict[str, Any]] = {}


def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


def init(data_dir: str):
    global _data_dir, _accounts_file
    _data_dir = data_dir
    _accounts_file = os.path.join(data_dir, "accounts.json")
    os.makedirs(_data_dir, exist_ok=True)
    _load_accounts()


def _get_default_accounts() -> Dict[str, Dict[str, Any]]:
    accounts = deepcopy(DEFAULT_ACCOUNTS)
    now = datetime.now().isoformat()
    test_pass = os.environ.get("GAME_TEST_PASSWORD", "changeme")
    admin_pass = os.environ.get("GAME_ADMIN_PASSWORD", "changeme")
    accounts["test"]["password_hash"] = hash_password(test_pass)
    accounts["test"]["created_at"] = now
    accounts["admin"]["password_hash"] = hash_password(admin_pass)
    accounts["admin"]["created_at"] = now
    return accounts


def _generate_character_id() -> str:
    return f"char_{uuid.uuid4().hex[:12]}"


def _is_character_name_taken(character_name: str) -> bool:
    for account in _accounts.values():
        for char in account.get("characters", []):
            if char.get("characterName", "").lower() == character_name.lower():
                return True
    return False


def _migrate_to_multi_character():
    for username, account in _accounts.items():
        if "character" in account and "characters" not in account:
            old_char = account.pop("character")
            if "id" not in old_char:
                old_char["id"] = _generate_character_id()
            account["characters"] = [old_char]
    _save_accounts()


def _load_accounts():
    global _accounts
    with _lock:
        if os.path.exists(_accounts_file):
            try:
                with open(_accounts_file, "r", encoding="utf-8") as f:
                    _accounts = json.load(f)
                _migrate_to_multi_character()
                return
            except (json.JSONDecodeError, IOError):
                pass

        _accounts = _get_default_accounts()
        _save_accounts()


def _save_accounts():
    with _lock:
        with open(_accounts_file, "w", encoding="utf-8") as f:
            json.dump(_accounts, f, indent=2, ensure_ascii=False)


def create_account(
    username: str, password: str, character_name: Optional[str] = None
) -> tuple[bool, str]:
    with _lock:
        if username in _accounts:
            return False, "Username already exists"

        if character_name and _is_character_name_taken(character_name):
            return False, "Character name already taken"

        now = datetime.now().isoformat()
        char_id = _generate_character_id()
        first_char = {
            "id": char_id,
            "characterName": character_name or username,
            "level": 1,
            "exp": 0,
            "gold": 100,
            "hp": 100,
            "maxHp": 100,
            "attack": 15,
            "defense": 5,
            "speed": 6,
            "x": 1600,
            "y": 1600,
            "mapId": "newbie_village",
            "avatarColor": [0.2, 0.6, 1.0],
        }
        _accounts[username] = {
            "username": username,
            "password_hash": hash_password(password),
            "characters": [first_char],
            "created_at": now,
            "last_login": None,
        }
        _save_accounts()
        return True, "Account created"


def verify_login(username: str, password: str) -> tuple[bool, List[Dict]]:
    with _lock:
        if username not in _accounts:
            return False, []

        account = _accounts[username]
        if account["password_hash"] != hash_password(password):
            return False, []

        account["last_login"] = datetime.now().isoformat()
        _save_accounts()

        return True, deepcopy(account.get("characters", []))


def get_characters(username: str) -> List[Dict[str, Any]]:
    with _lock:
        if username not in _accounts:
            return []
        return deepcopy(_accounts[username].get("characters", []))


def get_character_by_id(username: str, character_id: str) -> Optional[Dict[str, Any]]:
    with _lock:
        if username not in _accounts:
            return None
        for char in _accounts[username].get("characters", []):
            if char.get("id") == character_id:
                return deepcopy(char)
        return None


def create_character(
    username: str, character_data: Dict[str, Any]
) -> tuple[bool, str, Optional[Dict]]:
    with _lock:
        if username not in _accounts:
            return False, "Account not found", None

        account = _accounts[username]
        characters = account.get("characters", [])

        if len(characters) >= MAX_CHARACTERS_PER_ACCOUNT:
            return (
                False,
                f"Maximum {MAX_CHARACTERS_PER_ACCOUNT} characters allowed",
                None,
            )

        char_name = character_data.get("characterName", "")
        if not char_name:
            return False, "Character name is required", None

        if len(char_name) < 2 or len(char_name) > 20:
            return False, "Character name must be 2-20 characters", None

        if _is_character_name_taken(char_name):
            return False, "Character name already taken", None

        new_char = {
            "id": _generate_character_id(),
            "characterName": char_name,
            "level": 1,
            "exp": 0,
            "gold": 100,
            "hp": 100,
            "maxHp": 100,
            "attack": 15,
            "defense": 5,
            "speed": 6,
            "x": 1600,
            "y": 1600,
            "mapId": "newbie_village",
            "avatarColor": character_data.get("avatarColor", [0.2, 0.6, 1.0]),
        }

        if "characters" not in account:
            account["characters"] = []
        account["characters"].append(new_char)
        _save_accounts()

        return True, "Character created", deepcopy(new_char)


def save_character_by_id(
    username: str, character_id: str, character_data: Dict[str, Any]
) -> bool:
    with _lock:
        if username not in _accounts:
            return False

        account = _accounts[username]
        characters = account.get("characters", [])

        for i, char in enumerate(characters):
            if char.get("id") == character_id:
                character_data["id"] = character_id
                characters[i] = deepcopy(character_data)
                _save_accounts()
                return True

        return False


def delete_character(username: str, character_id: str) -> tuple[bool, str]:
    with _lock:
        if username not in _accounts:
            return False, "Account not found"

        account = _accounts[username]
        characters = account.get("characters", [])

        if len(characters) <= 1:
            return False, "Cannot delete the last character"

        for i, char in enumerate(characters):
            if char.get("id") == character_id:
                del characters[i]
                _save_accounts()
                return True, "Character deleted"

        return False, "Character not found"


def get_character(username: str) -> Optional[Dict[str, Any]]:
    with _lock:
        if username not in _accounts:
            return None
        characters = _accounts[username].get("characters", [])
        return deepcopy(characters[0]) if characters else None


def save_character(username: str, character: Dict[str, Any]) -> bool:
    with _lock:
        if username not in _accounts:
            return False

        char_id = character.get("id")
        if char_id:
            return save_character_by_id(username, char_id, character)

        account = _accounts[username]
        if "characters" not in account or not account["characters"]:
            return False

        account["characters"][0] = deepcopy(character)
        _save_accounts()
        return True


def update_position(username: str, x: float, y: float, map_id: str) -> bool:
    with _lock:
        if username not in _accounts:
            return False

        characters = _accounts[username].get("characters", [])
        if characters:
            char = characters[0]
            char["x"] = x
            char["y"] = y
            char["mapId"] = map_id
        return True


def update_position_by_id(
    username: str, character_id: str, x: float, y: float, map_id: str
) -> bool:
    with _lock:
        if username not in _accounts:
            return False

        for char in _accounts[username].get("characters", []):
            if char.get("id") == character_id:
                char["x"] = x
                char["y"] = y
                char["mapId"] = map_id
                return True
        return False


def get_all_positions(exclude: Optional[str] = None) -> List[Dict[str, Any]]:
    with _lock:
        positions = []
        for username, account in _accounts.items():
            if username == exclude:
                continue
            for char in account.get("characters", []):
                positions.append(
                    {
                        "username": username,
                        "characterId": char.get("id", ""),
                        "x": char.get("x", 0),
                        "y": char.get("y", 0),
                        "mapId": char.get("mapId", ""),
                        "characterName": char.get("characterName", ""),
                    }
                )
        return positions


def account_exists(username: str) -> bool:
    with _lock:
        return username in _accounts


def delete_account(username: str) -> bool:
    with _lock:
        if username not in _accounts:
            return False
        del _accounts[username]
        _save_accounts()
        return True


def get_account_count() -> int:
    with _lock:
        return len(_accounts)
