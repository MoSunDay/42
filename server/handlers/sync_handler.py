from typing import Callable, Dict, Any, Optional
from storage import json_store
from protocol.packet import (
    PacketType,
    create_packet,
    set_payload_json,
    get_payload_json,
)
from handlers.common import send_error, parse_payload


_player_sessions: Dict[str, Dict[str, Any]] = {}


def register_player(username: str, character_id: str, session_id: str):
    _player_sessions[session_id] = {
        "username": username,
        "character_id": character_id,
        "map_id": "",
        "x": 0,
        "y": 0,
    }


def unregister_player(session_id: str):
    if session_id in _player_sessions:
        del _player_sessions[session_id]


def get_player_by_session(session_id: str) -> Optional[Dict[str, Any]]:
    return _player_sessions.get(session_id)


def handle_position_update(
    packet,
    send_response: Callable,
    session_id: Optional[str] = None,
):
    data = get_payload_json(packet)
    if not data:
        return

    x = data.get("x", 0)
    y = data.get("y", 0)
    map_id = data.get("mapId", "")

    if not session_id or session_id not in _player_sessions:
        return

    player_info = _player_sessions[session_id]
    username = player_info["username"]
    character_id = player_info["character_id"]

    json_store.update_position_by_id(username, character_id, x, y, map_id)

    player_info.update(
        {
            "map_id": map_id,
            "x": x,
            "y": y,
        }
    )


def handle_battle_action(
    packet,
    send_response: Callable,
    broadcast: Optional[Callable] = None,
):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    action_type = data.get("action")
    username = data.get("username")

    if not action_type or not username:
        send_error(send_response, packet["seq"], 400, "Missing action data")
        return

    response = create_packet(
        msg_type=PacketType.BATTLE_ACTION,
        seq=packet["seq"],
        payload=set_payload_json(
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
    packet,
    send_response: Callable,
    broadcast: Optional[Callable] = None,
):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username")
    message = data.get("message")

    if not username or not message:
        send_error(send_response, packet["seq"], 400, "Missing chat data")
        return

    if len(message) > 200:
        send_error(send_response, packet["seq"], 400, "Message too long")
        return

    chat_packet = create_packet(
        msg_type=PacketType.CHAT_MESSAGE,
        seq=packet["seq"],
        payload=set_payload_json({"username": username, "message": message}),
    )

    if broadcast:
        broadcast(chat_packet, username)
    else:
        send_response(chat_packet)


def get_nearby_players(session_id: str, map_id: str, radius: float = 500) -> list:
    nearby = []

    if session_id not in _player_sessions:
        return nearby

    my_info = _player_sessions[session_id]

    for sid, info in _player_sessions.items():
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


def get_online_count() -> int:
    return len(_player_sessions)
