from typing import Dict, Any, Optional, Callable, List
from storage.json_store import JsonStore
from protocol.packet import Packet, PacketBuilder, PacketType


class AuthHandler:
    def __init__(self, store: JsonStore):
        self.store = store

    def handle_login(
        self,
        packet: Packet,
        send_response: Callable[[Packet], None],
        session_id: Optional[str] = None,
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username", "")
        password = data.get("password", "")

        if not username or not password:
            self._send_error(send_response, packet.seq, 400, "Missing credentials")
            return

        success, characters = self.store.verify_login(username, password)

        if success and characters:
            response = PacketBuilder.login_response(
                seq=packet.seq, success=True, characters=characters
            )
        else:
            response = PacketBuilder.login_response(
                seq=packet.seq, success=False, error="Invalid username or password"
            )

        send_response(response)

    def handle_register(self, packet: Packet, send_response: Callable[[Packet], None]):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username", "")
        password = data.get("password", "")
        character_name = data.get("characterName")

        if not username or not password:
            self._send_error(send_response, packet.seq, 400, "Missing credentials")
            return

        if len(username) < 2 or len(username) > 20:
            self._send_error(
                send_response, packet.seq, 400, "Username must be 2-20 characters"
            )
            return

        if len(password) < 3:
            self._send_error(send_response, packet.seq, 400, "Password too short")
            return

        success, message = self.store.create_account(username, password, character_name)

        if success:
            _, characters = self.store.verify_login(username, password)
            response = PacketBuilder.login_response(
                seq=packet.seq, success=True, characters=characters
            )
        else:
            response = PacketBuilder.login_response(
                seq=packet.seq, success=False, error=message
            )

        send_response(response)

    def handle_logout(self, packet: Packet, send_response: Callable[[Packet], None]):
        data = packet.get_payload_json()
        if data and "username" in data:
            username = data["username"]

        response = Packet(
            msg_type=PacketType.LOGOUT,
            seq=packet.seq,
            payload=Packet.set_payload_json({"success": True}),
        )
        send_response(response)

    def _send_error(
        self, send_response: Callable[[Packet], None], seq: int, code: int, message: str
    ):
        response = PacketBuilder.error(seq, code, message)
        send_response(response)
