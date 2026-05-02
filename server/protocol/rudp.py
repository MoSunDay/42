import time
from collections import deque
from typing import Dict, Optional, Tuple, Callable, Any, List

from .packet import (
    create_packet,
    pack_packet,
    needs_ack,
    build_ack,
    PacketType,
)
from .constants import (
    MAX_RETRIES,
    RETRY_TIMEOUT_MS,
    RECV_WINDOW_SIZE,
    SEND_BUFFER_SIZE,
    CONNECTION_TIMEOUT_MS,
    HEARTBEAT_INTERVAL_MS,
)


def create_channel(send_fn: Callable[[bytes], None]) -> Dict[str, Any]:
    now = time.time() * 1000
    return {
        "send_fn": send_fn,
        "next_seq": 1,
        "remote_seq": 0,
        "send_buffer": {},
        "recv_window": {},
        "last_recv_time": now,
        "last_send_time": now,
        "connected": True,
    }


def _next_sequence(channel: Dict[str, Any]) -> int:
    seq = channel["next_seq"]
    channel["next_seq"] = (seq + 1) & 0xFFFFFFFF
    return seq


def _calculate_ack_mask(channel: Dict[str, Any]) -> Tuple[int, int]:
    ack = channel["remote_seq"]
    ack_mask = 0
    for seq in channel["recv_window"]:
        diff = ack - seq
        if 0 < diff <= 32:
            ack_mask |= 1 << (diff - 1)
    return ack, ack_mask


def _process_acks(channel: Dict[str, Any], ack: int, ack_mask: int) -> None:
    to_remove = []
    for seq, pending in channel["send_buffer"].items():
        if seq == ack:
            to_remove.append(seq)
            continue
        diff = ack - seq
        if 0 < diff <= 32:
            if ack_mask & (1 << (diff - 1)):
                to_remove.append(seq)
    for seq in to_remove:
        del channel["send_buffer"][seq]


def _clean_recv_window(channel: Dict[str, Any]) -> None:
    threshold = channel["remote_seq"] - RECV_WINDOW_SIZE
    to_remove = [seq for seq in channel["recv_window"] if seq <= threshold]
    for seq in to_remove:
        del channel["recv_window"][seq]


def channel_send(channel: Dict[str, Any], packet: Dict[str, Any]) -> bool:
    now = time.time() * 1000
    channel["last_send_time"] = now

    if packet["seq"] == 0:
        packet["seq"] = _next_sequence(channel)

    ack, ack_mask = _calculate_ack_mask(channel)
    packet["ack"] = ack
    packet["ack_mask"] = ack_mask

    data = pack_packet(packet)
    channel["send_fn"](data)

    if needs_ack(packet):
        channel["send_buffer"][packet["seq"]] = {
            "packet": packet,
            "send_time": now,
            "retries": 0,
            "last_send": now,
        }

    return True


def channel_send_immediate(channel: Dict[str, Any], packet: Dict[str, Any]) -> None:
    now = time.time() * 1000
    channel["last_send_time"] = now

    ack, ack_mask = _calculate_ack_mask(channel)
    packet["ack"] = ack
    packet["ack_mask"] = ack_mask

    channel["send_fn"](pack_packet(packet))


def channel_recv(
    channel: Dict[str, Any], packet: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    now = time.time() * 1000
    channel["last_recv_time"] = now

    _process_acks(channel, packet["ack"], packet["ack_mask"])

    if packet["msg_type"] == PacketType.ACK:
        return None

    if packet["seq"] > 0:
        if packet["seq"] <= channel["remote_seq"]:
            diff = channel["remote_seq"] - packet["seq"]
            if diff < RECV_WINDOW_SIZE:
                return None
        elif packet["seq"] > channel["remote_seq"]:
            channel["remote_seq"] = packet["seq"]

        channel["recv_window"][packet["seq"]] = packet
        _clean_recv_window(channel)

    if needs_ack(packet):
        ack, ack_mask = _calculate_ack_mask(channel)
        ack_packet = build_ack(0, packet["seq"], ack_mask)
        channel_send_immediate(channel, ack_packet)

    return packet


def channel_update(channel: Dict[str, Any]) -> list:
    now = time.time() * 1000
    failed = []
    to_remove = []

    for seq, pending in channel["send_buffer"].items():
        elapsed = now - pending["last_send"]
        if elapsed >= RETRY_TIMEOUT_MS:
            if pending["retries"] >= MAX_RETRIES:
                failed.append(pending["packet"])
                to_remove.append(seq)
            else:
                pending["retries"] += 1
                pending["last_send"] = now

                ack, ack_mask = _calculate_ack_mask(channel)
                pending["packet"]["ack"] = ack
                pending["packet"]["ack_mask"] = ack_mask

                channel["send_fn"](pack_packet(pending["packet"]))

    for seq in to_remove:
        del channel["send_buffer"][seq]

    return failed


def channel_is_timed_out(channel: Dict[str, Any]) -> bool:
    elapsed = time.time() * 1000 - channel["last_recv_time"]
    return elapsed >= CONNECTION_TIMEOUT_MS


def channel_needs_heartbeat(channel: Dict[str, Any]) -> bool:
    elapsed = time.time() * 1000 - channel["last_send_time"]
    return elapsed >= HEARTBEAT_INTERVAL_MS


def channel_get_pending_count(channel: Dict[str, Any]) -> int:
    return len(channel["send_buffer"])


def channel_get_stats(channel: Dict[str, Any]) -> Dict[str, Any]:
    now = time.time() * 1000
    return {
        "next_seq": channel["next_seq"],
        "remote_seq": channel["remote_seq"],
        "pending_count": len(channel["send_buffer"]),
        "recv_window_size": len(channel["recv_window"]),
        "connected": channel["connected"],
        "last_recv_ms": now - channel["last_recv_time"],
        "last_send_ms": now - channel["last_send_time"],
    }


def create_conn_manager() -> Dict[str, Any]:
    return {
        "connections": {},
        "addr_to_session": {},
        "session_counter": 0,
    }


def _generate_session_id(manager: Dict[str, Any]) -> str:
    manager["session_counter"] += 1
    return f"sess_{manager['session_counter']}_{int(time.time() * 1000)}"


def conn_create(
    manager: Dict[str, Any],
    addr: Tuple[str, int],
    send_func: Callable[[bytes, Tuple[str, int]], None],
) -> Tuple[str, Dict[str, Any]]:
    session_id = _generate_session_id(manager)

    def wrapped_send(data: bytes):
        send_func(data, addr)

    channel = create_channel(wrapped_send)

    manager["connections"][session_id] = channel
    manager["addr_to_session"][addr] = session_id

    return session_id, channel


def conn_get(manager: Dict[str, Any], session_id: str) -> Optional[Dict[str, Any]]:
    return manager["connections"].get(session_id)


def conn_get_by_addr(
    manager: Dict[str, Any], addr: Tuple[str, int]
) -> Optional[Dict[str, Any]]:
    session_id = manager["addr_to_session"].get(addr)
    if session_id:
        return manager["connections"].get(session_id)
    return None


def conn_get_session_id(
    manager: Dict[str, Any], addr: Tuple[str, int]
) -> Optional[str]:
    return manager["addr_to_session"].get(addr)


def conn_remove(manager: Dict[str, Any], session_id: str) -> None:
    if session_id in manager["connections"]:
        del manager["connections"][session_id]

    to_remove = [
        addr for addr, sid in manager["addr_to_session"].items() if sid == session_id
    ]
    for addr in to_remove:
        del manager["addr_to_session"][addr]


def conn_update_all(manager: Dict[str, Any]) -> Dict[str, list]:
    results = {}
    timed_out = []

    for session_id, channel in manager["connections"].items():
        failed = channel_update(channel)
        if failed:
            results[session_id] = failed

        if channel_is_timed_out(channel):
            timed_out.append(session_id)

    for session_id in timed_out:
        conn_remove(manager, session_id)

    return results


def conn_broadcast(
    manager: Dict[str, Any],
    packet: Dict[str, Any],
    exclude: Optional[set] = None,
) -> None:
    exclude_set = exclude or set()
    for session_id, channel in manager["connections"].items():
        if session_id not in exclude_set:
            channel_send(channel, packet)


def conn_get_count(manager: Dict[str, Any]) -> int:
    return len(manager["connections"])


def conn_get_all_sessions(manager: Dict[str, Any]) -> list:
    return list(manager["connections"].keys())
