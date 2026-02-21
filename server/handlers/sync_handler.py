from typing import Callable, Dict, Any, Optional
from storage.json_store import JsonStore
from protocol.packet import Packet, PacketBuilder, PacketType


class SyncHandler:
    def __init__(self, store: JsonStore):
        self.store = store
        self._player_sessions: Dict[str, Dict[str, Any]] = {}

    def register_player(self, username: str, character_id: str, session_id: str):
        self._player_sessions[session_id] = {
            "username": username,
            "character_id": character_id,
            "map_id": "",
            "x": 0,
            "y": 0,
        }

    def unregister_player(self, session_id: str):
        if session_id in self._player_sessions:
            del self._player_sessions[session_id]

    def get_player_by_session(self, session_id: str) -> Optional[Dict[str, Any]]:
        return self._player_sessions.get(session_id)

    def handle_position_update(
        self,
        packet: Packet,
        send_response: Callable[[Packet], None],
        session_id: Optional[str] = None,
    ):
        data = packet.get_payload_json()
        if not data:
            return

        x = data.get("x", 0)
        y = data.get("y", 0)
        map_id = data.get("mapId", "")

        if not session_id or session_id not in self._player_sessions:
            return

        player_info = self._player_sessions[session_id]
        username = player_info["username"]
        character_id = player_info["character_id"]

        self.store.update_position_by_id(username, character_id, x, y, map_id)

        player_info.update(
            {
                "map_id": map_id,
                "x": x,
                "y": y,
            }
        )

    def handle_battle_action(
        self,
        packet: Packet,
        send_response: Callable[[Packet], None],
        broadcast: Optional[Callable[[Packet, str], None]] = None,
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        action_type = data.get("action")
        username = data.get("username")

        if not action_type or not username:
            self._send_error(send_response, packet.seq, 400, "Missing action data")
            return

        response = Packet(
            msg_type=PacketType.BATTLE_ACTION,
            seq=packet.seq,
            payload=Packet.set_payload_json(
                {
                    "success": True,
                    "action": action_type,
                    "username": username,
                    "data": data.get("data", {}),
                }
            ),
        )
        send_response(response)

        if broadcast:
            broadcast(response, username)

    def handle_chat_message(
        self,
        packet: Packet,
        send_response: Callable[[Packet], None],
        broadcast: Optional[Callable[[Packet, str], None]] = None,
    ):
        data = packet.get_payload_json()
        if not data:
            self._send_error(send_response, packet.seq, 400, "Invalid payload")
            return

        username = data.get("username")
        message = data.get("message")

        if not username or not message:
            self._send_error(send_response, packet.seq, 400, "Missing chat data")
            return

        if len(message) > 200:
            self._send_error(send_response, packet.seq, 400, "Message too long")
            return

        chat_packet = Packet(
            msg_type=PacketType.CHAT_MESSAGE,
            seq=packet.seq,
            payload=Packet.set_payload_json({"username": username, "message": message}),
        )

        if broadcast:
            broadcast(chat_packet, username)
        else:
            send_response(chat_packet)

    def get_nearby_players(
        self, session_id: str, map_id: str, radius: float = 500
    ) -> list:
        nearby = []

        if session_id not in self._player_sessions:
            return nearby

        my_info = self._player_sessions[session_id]

        for sid, info in self._player_sessions.items():
            if sid == session_id:
                continue
            if info["map_id"] != map_id:
                continue

            dx = info["x"] - my_info["x"]
            dy = info["y"] - my_info["y"]
            dist = (dx * dx + dy * dy) ** 0.5

            if dist <= radius:
                nearby.append(
                    {
                        "username": info["username"],
                        "characterId": info["character_id"],
                        "characterName": info.get("character_name", ""),
                        "x": info["x"],
                        "y": info["y"],
                    }
                )

        return nearby

    def get_online_count(self) -> int:
        return len(self._player_sessions)

    def _send_error(
        self, send_response: Callable[[Packet], None], seq: int, code: int, message: str
    ):
        response = PacketBuilder.error(seq, code, message)
        send_response(response)
