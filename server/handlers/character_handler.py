from typing import Callable, Optional, Dict, Any
from storage.json_store import JsonStore
from protocol.packet import Packet, PacketBuilder, PacketType


class CharacterHandler:
    def __init__(self, store: JsonStore):
        self.store = store

    def handle_list_characters(
        self, packet: Packet, send_response: Callable[[Packet], None]
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username")
        if not username:
            self._send_error(send_response, packet.seq, 400, "Missing username")
            return

        characters = self.store.get_characters(username)
        response = PacketBuilder.list_characters_response(packet.seq, characters)
        send_response(response)

    def handle_select_character(
        self, packet: Packet, send_response: Callable[[Packet], None]
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username")
        character_id = data.get("characterId")

        if not username:
            self._send_error(send_response, packet.seq, 400, "Missing username")
            return

        if not character_id:
            self._send_error(send_response, packet.seq, 400, "Missing characterId")
            return

        character = self.store.get_character_by_id(username, character_id)

        if character:
            response = PacketBuilder.select_character_response(
                seq=packet.seq, success=True, character=character
            )
        else:
            response = PacketBuilder.select_character_response(
                seq=packet.seq, success=False, error="Character not found"
            )

        send_response(response)

    def handle_create_character(
        self, packet: Packet, send_response: Callable[[Packet], None]
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username")
        character_data = data.get("character", {})

        if not username:
            self._send_error(send_response, packet.seq, 400, "Missing username")
            return

        success, message, new_character = self.store.create_character(
            username, character_data
        )

        if success:
            response = PacketBuilder.create_character_response(
                seq=packet.seq, success=True, character=new_character
            )
            send_response(response)
        else:
            self._send_error(send_response, packet.seq, 400, message)

    def handle_delete_character(
        self, packet: Packet, send_response: Callable[[Packet], None]
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username")
        character_id = data.get("characterId")

        if not username:
            self._send_error(send_response, packet.seq, 400, "Missing username")
            return

        if not character_id:
            self._send_error(send_response, packet.seq, 400, "Missing characterId")
            return

        success, message = self.store.delete_character(username, character_id)

        if success:
            response = PacketBuilder.delete_character_response(
                seq=packet.seq, success=True
            )
            send_response(response)
        else:
            response = PacketBuilder.delete_character_response(
                seq=packet.seq, success=False, error=message
            )
            send_response(response)

    def handle_get_character(
        self, packet: Packet, send_response: Callable[[Packet], None]
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username")
        if not username:
            self._send_error(send_response, packet.seq, 400, "Missing username")
            return

        character = self.store.get_character(username)

        if character:
            response = Packet(
                msg_type=PacketType.GET_CHARACTER,
                seq=packet.seq,
                payload=Packet.set_payload_json(
                    {"success": True, "character": character}
                ),
            )
            send_response(response)
        else:
            self._send_error(send_response, packet.seq, 404, "Character not found")

    def handle_save_character(
        self, packet: Packet, send_response: Callable[[Packet], None]
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        character = data.get("character")
        username = data.get("username")

        if not character or not username:
            self._send_error(send_response, packet.seq, 400, "Missing character data")
            return

        required = ["characterName", "level", "hp", "maxHp"]
        for field in required:
            if field not in character:
                self._send_error(
                    send_response, packet.seq, 400, f"Missing field: {field}"
                )
                return

        char_id = character.get("id")
        if char_id:
            success = self.store.save_character_by_id(username, char_id, character)
        else:
            success = self.store.save_character(username, character)

        response = Packet(
            msg_type=PacketType.SAVE_CHARACTER,
            seq=packet.seq,
            payload=Packet.set_payload_json(
                {
                    "success": success,
                    "message": "Character saved" if success else "Save failed",
                }
            ),
        )
        send_response(response)

    def _send_error(
        self, send_response: Callable[[Packet], None], seq: int, code: int, message: str
    ):
        response = PacketBuilder.error(seq, code, message)
        send_response(response)
