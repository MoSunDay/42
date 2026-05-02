import struct
import json
from enum import IntEnum
from typing import Optional, Dict, Any, Tuple, List


class PacketType(IntEnum):
    NONE = 0

    LOGIN = 1
    REGISTER = 2
    LOGOUT = 3

    GET_CHARACTER = 10
    SAVE_CHARACTER = 11
    CREATE_CHARACTER = 12
    LIST_CHARACTERS = 13
    SELECT_CHARACTER = 14
    DELETE_CHARACTER = 15

    POSITION_UPDATE = 20
    BATTLE_ACTION = 21

    CHAT_MESSAGE = 30

    HEARTBEAT = 50
    ACK = 51
    NACK = 52

    ERROR = 100

    def is_reliable(self) -> bool:
        return self in (
            PacketType.LOGIN,
            PacketType.REGISTER,
            PacketType.LOGOUT,
            PacketType.GET_CHARACTER,
            PacketType.SAVE_CHARACTER,
            PacketType.CREATE_CHARACTER,
            PacketType.LIST_CHARACTERS,
            PacketType.SELECT_CHARACTER,
            PacketType.DELETE_CHARACTER,
            PacketType.BATTLE_ACTION,
            PacketType.CHAT_MESSAGE,
        )


_RELIABLE_TYPES = {
    PacketType.LOGIN,
    PacketType.REGISTER,
    PacketType.LOGOUT,
    PacketType.GET_CHARACTER,
    PacketType.SAVE_CHARACTER,
    PacketType.CREATE_CHARACTER,
    PacketType.LIST_CHARACTERS,
    PacketType.SELECT_CHARACTER,
    PacketType.DELETE_CHARACTER,
    PacketType.BATTLE_ACTION,
    PacketType.CHAT_MESSAGE,
}


def packet_type_is_reliable(msg_type: int) -> bool:
    return msg_type in _RELIABLE_TYPES


_HEADER = struct.Struct("!HBBI")


def create_packet(
    msg_type: PacketType,
    seq: int = 0,
    ack: int = 0,
    ack_mask: int = 0,
    payload: bytes = b"",
    flags: int = 0,
) -> Dict[str, Any]:
    return {
        "msg_type": msg_type,
        "seq": seq,
        "ack": ack,
        "ack_mask": ack_mask,
        "payload": payload,
        "flags": flags,
        "timestamp": 0,
    }


def is_reliable(packet: Dict[str, Any]) -> bool:
    return packet["msg_type"].is_reliable() or bool(packet["flags"] & 0x01)


def needs_ack(packet: Dict[str, Any]) -> bool:
    return is_reliable(packet) and packet["msg_type"] != PacketType.ACK


def set_flag(packet: Dict[str, Any], flag: int) -> None:
    packet["flags"] |= flag


def has_flag(packet: Dict[str, Any], flag: int) -> bool:
    return (packet["flags"] & flag) != 0


def unpack_packet(data: bytes) -> Dict[str, Any]:
    if len(data) < 8:
        raise ValueError(f"Packet too short: {len(data)} bytes")

    total_len, msg_type, flags, seq = _HEADER.unpack_from(data, 0)

    if total_len != len(data):
        raise ValueError(f"Length mismatch: expected {total_len}, got {len(data)}")

    ack, ack_mask = 0, 0
    if len(data) >= 13:
        ack, ack_mask = struct.unpack_from("!IB", data, 8)

    payload = data[13:total_len] if total_len > 13 else b""

    return create_packet(
        msg_type=PacketType(msg_type),
        seq=seq,
        ack=ack,
        ack_mask=ack_mask,
        payload=payload,
        flags=flags,
    )


def pack_packet(packet: Dict[str, Any]) -> bytes:
    total_len = 13 + len(packet["payload"])

    header = _HEADER.pack(
        total_len, int(packet["msg_type"]), packet["flags"], packet["seq"]
    )

    ack_data = struct.pack("!IB", packet["ack"], packet["ack_mask"])

    return header + ack_data + packet["payload"]


def get_payload_json(packet: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    if not packet["payload"]:
        return None
    try:
        return json.loads(packet["payload"].decode("utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError):
        return None


def set_payload_json(data: Dict[str, Any]) -> bytes:
    return json.dumps(data, ensure_ascii=False).encode("utf-8")


def build_ack(seq: int, ack: int, ack_mask: int = 0) -> Dict[str, Any]:
    return create_packet(msg_type=PacketType.ACK, seq=seq, ack=ack, ack_mask=ack_mask)


def build_heartbeat(seq: int) -> Dict[str, Any]:
    return create_packet(msg_type=PacketType.HEARTBEAT, seq=seq)


def build_error(seq: int, error_code: int, message: str) -> Dict[str, Any]:
    payload = set_payload_json({"code": error_code, "message": message})
    return create_packet(msg_type=PacketType.ERROR, seq=seq, payload=payload)


def build_login(username: str, password: str, seq: int = 0) -> Dict[str, Any]:
    payload = set_payload_json({"username": username, "password": password})
    return create_packet(msg_type=PacketType.LOGIN, seq=seq, payload=payload)


def build_login_response(
    seq: int,
    success: bool,
    characters: Optional[List[Dict[str, Any]]] = None,
    error: Optional[str] = None,
) -> Dict[str, Any]:
    data: Dict[str, Any] = {"success": success}
    if characters is not None:
        data["characters"] = characters
    if error:
        data["error"] = error
    return create_packet(
        msg_type=PacketType.LOGIN, seq=seq, payload=set_payload_json(data)
    )


def build_register(username: str, password: str, seq: int = 0) -> Dict[str, Any]:
    payload = set_payload_json({"username": username, "password": password})
    return create_packet(msg_type=PacketType.REGISTER, seq=seq, payload=payload)


def build_list_characters_response(
    seq: int, characters: List[Dict[str, Any]]
) -> Dict[str, Any]:
    return create_packet(
        msg_type=PacketType.LIST_CHARACTERS,
        seq=seq,
        payload=set_payload_json({"characters": characters}),
    )


def build_select_character(
    username: str, character_id: str, seq: int = 0
) -> Dict[str, Any]:
    return create_packet(
        msg_type=PacketType.SELECT_CHARACTER,
        seq=seq,
        payload=set_payload_json({"username": username, "characterId": character_id}),
    )


def build_select_character_response(
    seq: int,
    success: bool,
    character: Optional[Dict[str, Any]] = None,
    error: Optional[str] = None,
) -> Dict[str, Any]:
    data: Dict[str, Any] = {"success": success}
    if character:
        data["character"] = character
    if error:
        data["error"] = error
    return create_packet(
        msg_type=PacketType.SELECT_CHARACTER,
        seq=seq,
        payload=set_payload_json(data),
    )


def build_create_character(
    username: str, character_data: Dict[str, Any], seq: int = 0
) -> Dict[str, Any]:
    return create_packet(
        msg_type=PacketType.CREATE_CHARACTER,
        seq=seq,
        payload=set_payload_json({"username": username, "character": character_data}),
    )


def build_create_character_response(
    seq: int,
    success: bool,
    character: Optional[Dict[str, Any]] = None,
    error: Optional[str] = None,
) -> Dict[str, Any]:
    data: Dict[str, Any] = {"success": success}
    if character:
        data["character"] = character
    if error:
        data["error"] = error
    return create_packet(
        msg_type=PacketType.CREATE_CHARACTER,
        seq=seq,
        payload=set_payload_json(data),
    )


def build_delete_character(
    username: str, character_id: str, seq: int = 0
) -> Dict[str, Any]:
    return create_packet(
        msg_type=PacketType.DELETE_CHARACTER,
        seq=seq,
        payload=set_payload_json({"username": username, "characterId": character_id}),
    )


def build_delete_character_response(
    seq: int, success: bool, error: Optional[str] = None
) -> Dict[str, Any]:
    data: Dict[str, Any] = {"success": success}
    if error:
        data["error"] = error
    return create_packet(
        msg_type=PacketType.DELETE_CHARACTER,
        seq=seq,
        payload=set_payload_json(data),
    )


def build_position_update(seq: int, x: float, y: float, map_id: str) -> Dict[str, Any]:
    payload = set_payload_json({"x": x, "y": y, "mapId": map_id})
    return create_packet(msg_type=PacketType.POSITION_UPDATE, seq=seq, payload=payload)


def build_save_character(seq: int, character: Dict[str, Any]) -> Dict[str, Any]:
    return create_packet(
        msg_type=PacketType.SAVE_CHARACTER,
        seq=seq,
        payload=set_payload_json({"character": character}),
    )


def build_get_character(seq: int, username: str) -> Dict[str, Any]:
    return create_packet(
        msg_type=PacketType.GET_CHARACTER,
        seq=seq,
        payload=set_payload_json({"username": username}),
    )
