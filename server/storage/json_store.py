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


def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


class JsonStore:
    def __init__(self, data_dir: str):
        self.data_dir = data_dir
        self.accounts_file = os.path.join(data_dir, "accounts.json")
        self._lock = threading.RLock()
        self._accounts: Dict[str, Dict[str, Any]] = {}
        self._ensure_data_dir()
        self._load_accounts()

    def _ensure_data_dir(self):
        os.makedirs(self.data_dir, exist_ok=True)

    def _get_default_accounts(self) -> Dict[str, Dict[str, Any]]:
        accounts = deepcopy(DEFAULT_ACCOUNTS)
        now = datetime.now().isoformat()

        accounts["test"]["password_hash"] = hash_password("123")
        accounts["test"]["created_at"] = now

        accounts["admin"]["password_hash"] = hash_password("admin")
        accounts["admin"]["created_at"] = now

        return accounts

    def _generate_character_id(self) -> str:
        return f"char_{uuid.uuid4().hex[:12]}"

    def _migrate_to_multi_character(self):
        for username, account in self._accounts.items():
            if "character" in account and "characters" not in account:
                old_char = account.pop("character")
                if "id" not in old_char:
                    old_char["id"] = self._generate_character_id()
                account["characters"] = [old_char]
        self._save_accounts()

    def _load_accounts(self):
        with self._lock:
            if os.path.exists(self.accounts_file):
                try:
                    with open(self.accounts_file, "r", encoding="utf-8") as f:
                        self._accounts = json.load(f)
                    self._migrate_to_multi_character()
                    return
                except (json.JSONDecodeError, IOError):
                    pass

            self._accounts = self._get_default_accounts()
            self._save_accounts()

    def _save_accounts(self):
        with self._lock:
            with open(self.accounts_file, "w", encoding="utf-8") as f:
                json.dump(self._accounts, f, indent=2, ensure_ascii=False)

    def create_account(
        self, username: str, password: str, character_name: Optional[str] = None
    ) -> tuple[bool, str]:
        with self._lock:
            if username in self._accounts:
                return False, "Username already exists"

            if character_name and self._is_character_name_taken(character_name):
                return False, "Character name already taken"

            now = datetime.now().isoformat()
            char_id = self._generate_character_id()
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
            self._accounts[username] = {
                "username": username,
                "password_hash": hash_password(password),
                "characters": [first_char],
                "created_at": now,
                "last_login": None,
            }
            self._save_accounts()
            return True, "Account created"

    def verify_login(self, username: str, password: str) -> tuple[bool, List[Dict]]:
        with self._lock:
            if username not in self._accounts:
                return False, []

            account = self._accounts[username]
            if account["password_hash"] != hash_password(password):
                return False, []

            account["last_login"] = datetime.now().isoformat()
            self._save_accounts()

            return True, deepcopy(account.get("characters", []))

    def _is_character_name_taken(self, character_name: str) -> bool:
        for account in self._accounts.values():
            for char in account.get("characters", []):
                if char.get("characterName", "").lower() == character_name.lower():
                    return True
        return False

    def get_characters(self, username: str) -> List[Dict[str, Any]]:
        with self._lock:
            if username not in self._accounts:
                return []
            return deepcopy(self._accounts[username].get("characters", []))

    def get_character_by_id(
        self, username: str, character_id: str
    ) -> Optional[Dict[str, Any]]:
        with self._lock:
            if username not in self._accounts:
                return None
            for char in self._accounts[username].get("characters", []):
                if char.get("id") == character_id:
                    return deepcopy(char)
            return None

    def create_character(
        self, username: str, character_data: Dict[str, Any]
    ) -> tuple[bool, str, Optional[Dict]]:
        with self._lock:
            if username not in self._accounts:
                return False, "Account not found", None

            account = self._accounts[username]
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

            if self._is_character_name_taken(char_name):
                return False, "Character name already taken", None

            new_char = {
                "id": self._generate_character_id(),
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
            self._save_accounts()

            return True, "Character created", deepcopy(new_char)

    def save_character_by_id(
        self, username: str, character_id: str, character_data: Dict[str, Any]
    ) -> bool:
        with self._lock:
            if username not in self._accounts:
                return False

            account = self._accounts[username]
            characters = account.get("characters", [])

            for i, char in enumerate(characters):
                if char.get("id") == character_id:
                    character_data["id"] = character_id
                    characters[i] = deepcopy(character_data)
                    self._save_accounts()
                    return True

            return False

    def delete_character(self, username: str, character_id: str) -> tuple[bool, str]:
        with self._lock:
            if username not in self._accounts:
                return False, "Account not found"

            account = self._accounts[username]
            characters = account.get("characters", [])

            if len(characters) <= 1:
                return False, "Cannot delete the last character"

            for i, char in enumerate(characters):
                if char.get("id") == character_id:
                    del characters[i]
                    self._save_accounts()
                    return True, "Character deleted"

            return False, "Character not found"

    def get_character(self, username: str) -> Optional[Dict[str, Any]]:
        with self._lock:
            if username not in self._accounts:
                return None
            characters = self._accounts[username].get("characters", [])
            return deepcopy(characters[0]) if characters else None

    def save_character(self, username: str, character: Dict[str, Any]) -> bool:
        with self._lock:
            if username not in self._accounts:
                return False

            char_id = character.get("id")
            if char_id:
                return self.save_character_by_id(username, char_id, character)

            account = self._accounts[username]
            if "characters" not in account or not account["characters"]:
                return False

            account["characters"][0] = deepcopy(character)
            self._save_accounts()
            return True

    def update_position(self, username: str, x: float, y: float, map_id: str) -> bool:
        with self._lock:
            if username not in self._accounts:
                return False

            characters = self._accounts[username].get("characters", [])
            if characters:
                char = characters[0]
                char["x"] = x
                char["y"] = y
                char["mapId"] = map_id
            return True

    def update_position_by_id(
        self, username: str, character_id: str, x: float, y: float, map_id: str
    ) -> bool:
        with self._lock:
            if username not in self._accounts:
                return False

            for char in self._accounts[username].get("characters", []):
                if char.get("id") == character_id:
                    char["x"] = x
                    char["y"] = y
                    char["mapId"] = map_id
                    return True
            return False

    def get_all_positions(self, exclude: Optional[str] = None) -> List[Dict[str, Any]]:
        with self._lock:
            positions = []
            for username, account in self._accounts.items():
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

    def account_exists(self, username: str) -> bool:
        with self._lock:
            return username in self._accounts

    def delete_account(self, username: str) -> bool:
        with self._lock:
            if username not in self._accounts:
                return False
            del self._accounts[username]
            self._save_accounts()
            return True

    def get_account_count(self) -> int:
        with self._lock:
            return len(self._accounts)
