import socket
import time
import json
import select
from typing import Optional, Dict, Any, Callable

from .protocol.constants import PACKET_TYPE, DEFAULT_HOST, DEFAULT_PORT, BUFFER_SIZE
from .protocol.packet import pack_packet, unpack_packet, needs_ack
from .protocol.rudp import (
    create_rudp_state,
    rudp_send,
    rudp_send_immediate,
    rudp_recv,
    rudp_update,
    rudp_needs_heartbeat,
)
from .state import initial_state, update_state, get_summary


_conn: Dict[str, Any] = {
    "socket": None,
    "rudp": None,
    "state": None,
    "username": None,
    "pending": None,
    "response_handlers": {},
}


def _reset_conn() -> None:
    _conn["socket"] = None
    _conn["rudp"] = None
    _conn["state"] = initial_state()
    _conn["username"] = None
    _conn["pending"] = None
    _conn["response_handlers"] = {}


def connect(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT) -> Dict[str, Any]:
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(5.0)
        sock.connect((host, port))
        _conn["socket"] = sock
        _conn["rudp"] = create_rudp_state(lambda data: sock.send(data))
        _conn["state"] = update_state(initial_state(), {"type": "connected"})
        return {"success": True, "host": host, "port": port}
    except Exception as e:
        return {"success": False, "error": str(e)}


def disconnect() -> Dict[str, Any]:
    if _conn["socket"]:
        try:
            _conn["socket"].close()
        except Exception:
            pass
    _reset_conn()
    return {"success": True}


def is_connected() -> bool:
    return _conn["socket"] is not None and _conn["state"]["connected"]


def _pump_network(timeout: float = 0.1) -> None:
    sock = _conn["socket"]
    if not sock:
        return
    rudp = _conn.get("rudp")
    if not rudp:
        return

    try:
        ready = select.select([sock], [], [], timeout)
        if ready[0]:
            data, _ = sock.recvfrom(BUFFER_SIZE)
            raw = unpack_packet(data)
            if raw:
                rudp, processed = rudp_recv(rudp, raw)
                _conn["rudp"] = rudp
                if processed:
                    _handle_response(processed)
    except (socket.timeout, OSError):
        pass

    rudp, failed = rudp_update(rudp)
    _conn["rudp"] = rudp
    if failed:
        _conn["pending"] = None

    if rudp_needs_heartbeat(rudp):
        rudp = rudp_send_immediate(rudp, PACKET_TYPE["HEARTBEAT"])
        _conn["rudp"] = rudp


def _handle_response(packet: Dict[str, Any]) -> None:
    msg_type = packet["msg_type"]
    payload = packet.get("payload")
    handler = _conn["response_handlers"].get(msg_type)
    if handler:
        handler(payload)
        _conn["response_handlers"].pop(msg_type, None)


def _send_and_wait(
    msg_type: int,
    payload: Optional[Dict[str, Any]] = None,
    response_type: Optional[int] = None,
    timeout: float = 5.0,
    on_response: Optional[Callable] = None,
) -> Dict[str, Any]:
    rudp = _conn.get("rudp")
    if not rudp:
        return {"success": False, "error": "Not connected"}

    resp_type = response_type if response_type is not None else msg_type
    result = {"success": False, "error": "timeout"}

    def _on_resp(payload):
        nonlocal result
        result = payload if payload else {"success": False, "error": "empty response"}
        if on_response:
            on_response(result)

    _conn["response_handlers"][resp_type] = _on_resp
    _conn["rudp"] = rudp_send(rudp, msg_type, payload)

    deadline = time.time() + timeout
    while time.time() < deadline:
        _pump_network(0.05)
        if _conn["response_handlers"].get(resp_type) is None:
            return result

    _conn["response_handlers"].pop(resp_type, None)
    return result


def _on_login_response(resp: Dict[str, Any], username: str) -> None:
    if resp.get("success"):
        _conn["username"] = username
        _conn["state"] = update_state(
            _conn["state"],
            {
                "type": "login_success",
                "username": username,
                "characters": resp.get("characters", []),
            },
        )
    else:
        _conn["state"] = update_state(_conn["state"], {"type": "login_failed"})


def login(username: str, password: str) -> Dict[str, Any]:
    if not is_connected():
        return {"success": False, "error": "Not connected"}

    def on_resp(resp):
        _on_login_response(resp, username)

    return _send_and_wait(
        PACKET_TYPE["LOGIN"],
        {"username": username, "password": password},
        on_response=on_resp,
    )


def register(username: str, password: str) -> Dict[str, Any]:
    if not is_connected():
        return {"success": False, "error": "Not connected"}

    def on_resp(resp):
        _on_login_response(resp, username)

    return _send_and_wait(
        PACKET_TYPE["REGISTER"],
        {"username": username, "password": password},
        on_response=on_resp,
    )


def list_characters() -> Dict[str, Any]:
    if not is_connected() or not _conn["username"]:
        return {"success": False, "error": "Not logged in"}
    return _send_and_wait(
        PACKET_TYPE["LIST_CHARACTERS"],
        {"username": _conn["username"]},
    )


def create_character(
    name: str, class_id: str, appearance: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    if not is_connected() or not _conn["username"]:
        return {"success": False, "error": "Not logged in"}
    char_data = {
        "characterName": name,
        "classId": class_id,
        **(appearance or {}),
    }
    return _send_and_wait(
        PACKET_TYPE["CREATE_CHARACTER"],
        {"username": _conn["username"], "character": char_data},
    )


def select_character(character_id: str) -> Dict[str, Any]:
    if not is_connected() or not _conn["username"]:
        return {"success": False, "error": "Not logged in"}

    def on_resp(resp):
        if resp.get("success") and resp.get("character"):
            _conn["state"] = update_state(
                _conn["state"],
                {"type": "character_selected", "character": resp["character"]},
            )

    return _send_and_wait(
        PACKET_TYPE["SELECT_CHARACTER"],
        {"username": _conn["username"], "characterId": character_id},
        on_response=on_resp,
    )


def delete_character(character_id: str) -> Dict[str, Any]:
    if not is_connected() or not _conn["username"]:
        return {"success": False, "error": "Not logged in"}
    return _send_and_wait(
        PACKET_TYPE["DELETE_CHARACTER"],
        {"username": _conn["username"], "characterId": character_id},
    )


def get_state() -> Dict[str, Any]:
    return get_summary(_conn.get("state") or initial_state())


def move_to(x: float, y: float) -> Dict[str, Any]:
    if not is_connected():
        return {"success": False, "error": "Not connected"}
    rudp = _conn.get("rudp")
    if not rudp:
        return {"success": False, "error": "No RUDP"}
    _conn["rudp"] = rudp_send_immediate(
        rudp,
        PACKET_TYPE["POSITION_UPDATE"],
        {
            "username": _conn["username"],
            "x": x,
            "y": y,
            "mapId": (_conn["state"].get("position") or {}).get("mapId", "town_01"),
        },
    )
    _conn["state"] = update_state(
        _conn["state"],
        {"type": "position_update", "position": {"x": x, "y": y}},
    )
    return {"success": True, "x": x, "y": y}


def battle_action(action: str, **kwargs) -> Dict[str, Any]:
    if not is_connected():
        return {"success": False, "error": "Not connected"}
    return _send_and_wait(
        PACKET_TYPE["BATTLE_ACTION"],
        {"username": _conn["username"], "action": action, "data": kwargs},
    )


def use_skill(skill_id: str, targets: list = None) -> Dict[str, Any]:
    return battle_action("skill", skillId=skill_id, targets=targets or [])


def use_item(item_id: str) -> Dict[str, Any]:
    return battle_action("item", itemId=item_id)


def attack(target_id: str = None) -> Dict[str, Any]:
    return battle_action("attack", targetId=target_id)


def defend() -> Dict[str, Any]:
    return battle_action("defend")


def flee() -> Dict[str, Any]:
    return battle_action("flee")


def save() -> Dict[str, Any]:
    if not is_connected() or not _conn["username"]:
        return {"success": False, "error": "Not logged in"}
    character = _conn["state"].get("character")
    if not character:
        return {"success": False, "error": "No character selected"}
    return _send_and_wait(
        PACKET_TYPE["SAVE_CHARACTER"],
        {"username": _conn["username"], "character": character},
    )


def send_chat(message: str) -> Dict[str, Any]:
    if not is_connected():
        return {"success": False, "error": "Not connected"}
    return _send_and_wait(
        PACKET_TYPE["CHAT_MESSAGE"],
        {"username": _conn["username"], "message": message},
    )


def logout() -> Dict[str, Any]:
    if not is_connected():
        return {"success": False, "error": "Not connected"}
    result = _send_and_wait(
        PACKET_TYPE["LOGOUT"],
        {"username": _conn["username"]},
    )
    _reset_conn()
    return result
