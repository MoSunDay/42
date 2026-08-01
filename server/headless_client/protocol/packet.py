import struct
import json
from typing import Optional, Dict, Any

from .constants import HEADER_SIZE, PACKET_TYPE, RELIABLE_TYPES

# 13-byte BE header: total_len u16 | msg_type u8 | flags u8 | seq u32 | ack u32 | ack_mask u8
_HEADER = struct.Struct("!HBBI")  # total_len, msg_type, flags, seq (8 bytes)
_ACK_FMT = struct.Struct("!IB")  # ack, ack_mask (5 bytes)


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
    header = _HEADER.pack(total_len, msg_type, flags, seq) + _ACK_FMT.pack(ack, ack_mask)
    return header + payload_bytes


def unpack_packet(data: bytes) -> Optional[Dict[str, Any]]:
    if len(data) < 8:
        return None
    total_len, msg_type, flags, seq = struct.unpack_from("!HBBI", data, 0)
    if len(data) < HEADER_SIZE:
        # 8-byte prefix only: ack/ack_mask default to 0
        return {
            "msg_type": msg_type,
            "seq": seq,
            "ack": 0,
            "ack_mask": 0,
            "flags": flags,
            "payload": None,
        }
    if total_len != len(data):
        return None
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
