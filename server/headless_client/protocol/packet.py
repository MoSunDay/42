import struct
import json
from typing import Optional, Dict, Any

from .constants import HEADER_SIZE, PACKET_TYPE, RELIABLE_TYPES

_HEADER = struct.Struct("!HBBIIBBB")
_LEN_FMT = struct.Struct("!H")
_MSG_FMT = struct.Struct("!B")
_FLAGS_FMT = struct.Struct("!B")
_SEQ_FMT = struct.Struct("!I")
_ACK_FMT = struct.Struct("!IB")


def is_reliable(msg_type: int) -> bool:
    return msg_type in RELIABLE_TYPES


def pack_packet(
    msg_type: int,
    seq: int,
    ack: int,
    ack_mask: int,
    flags: int,
    payload: Optional[Dict[str, Any]] = None,
) -> bytes:
    payload_bytes = b""
    if payload is not None:
        payload_bytes = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    total_len = HEADER_SIZE + len(payload_bytes)
    header = _HEADER.pack(total_len, msg_type, flags, seq, ack, ack_mask)
    return header + payload_bytes


def unpack_packet(data: bytes) -> Optional[Dict[str, Any]]:
    if len(data) < HEADER_SIZE:
        return None
    total_len, msg_type, flags, seq = struct.unpack_from("!HBBI", data, 0)
    if total_len != len(data):
        return None
    ack, ack_mask = 0, 0
    if len(data) >= 13:
        ack, ack_mask = struct.unpack_from("!IB", data, 8)
    payload_bytes = data[HEADER_SIZE:total_len]
    payload = None
    if payload_bytes:
        try:
            payload = json.loads(payload_bytes.decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            payload = None
    return {
        "msg_type": msg_type,
        "seq": seq,
        "ack": ack,
        "ack_mask": ack_mask,
        "flags": flags,
        "payload": payload,
    }


def needs_ack(msg_type: int, flags: int) -> bool:
    reliable = is_reliable(msg_type) or bool(flags & 0x01)
    return reliable and msg_type != PACKET_TYPE["ACK"]
