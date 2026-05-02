import time
from typing import Tuple, Callable, Dict, Any, List, Optional

from .constants import (
    MAX_RETRIES,
    RETRY_TIMEOUT_MS,
    RECV_WINDOW_SIZE,
    HEARTBEAT_INTERVAL_MS,
    CONNECTION_TIMEOUT_MS,
    PACKET_TYPE,
)
from .packet import pack_packet, needs_ack


def create_rudp_state(send_fn: Callable[[bytes], None]) -> Dict[str, Any]:
    now = time.time() * 1000
    return {
        "send_fn": send_fn,
        "next_seq": 1,
        "remote_seq": 0,
        "send_buffer": {},
        "recv_window": {},
        "last_recv_time": now,
        "last_send_time": now,
    }


def _next_sequence(state: Dict[str, Any]) -> Tuple[Dict[str, Any], int]:
    seq = state["next_seq"]
    new_state = dict(state)
    new_state["next_seq"] = (seq + 1) & 0xFFFFFFFF
    return new_state, seq


def _calculate_ack_mask(state: Dict[str, Any]) -> Tuple[int, int]:
    ack = state["remote_seq"]
    ack_mask = 0
    for seq in state["recv_window"]:
        diff = ack - seq
        if 0 < diff <= 32:
            ack_mask |= 1 << (diff - 1)
    return ack, ack_mask


def _send_raw(state: Dict[str, Any], data: bytes) -> None:
    state["send_fn"](data)


def rudp_send(
    state: Dict[str, Any],
    msg_type: int,
    payload: Optional[Dict[str, Any]] = None,
    flags: int = 0,
) -> Dict[str, Any]:
    now = time.time() * 1000
    new_state = dict(state)
    new_state["last_send_time"] = now

    if msg_type not in (PACKET_TYPE["HEARTBEAT"], PACKET_TYPE["ACK"]):
        new_state, seq = _next_sequence(new_state)
    else:
        seq = 0

    ack, ack_mask = _calculate_ack_mask(new_state)
    data = pack_packet(msg_type, seq, ack, ack_mask, flags, payload)
    _send_raw(new_state, data)

    if needs_ack(msg_type, flags):
        new_state["send_buffer"] = dict(new_state["send_buffer"])
        new_state["send_buffer"][seq] = {
            "msg_type": msg_type,
            "seq": seq,
            "ack": ack,
            "ack_mask": ack_mask,
            "flags": flags,
            "payload": payload,
            "send_time": now,
            "retries": 0,
            "last_send": now,
        }

    return new_state


def rudp_send_immediate(
    state: Dict[str, Any],
    msg_type: int,
    payload: Optional[Dict[str, Any]] = None,
    flags: int = 0,
) -> Dict[str, Any]:
    now = time.time() * 1000
    new_state = dict(state)
    new_state["last_send_time"] = now

    ack, ack_mask = _calculate_ack_mask(new_state)
    data = pack_packet(msg_type, 0, ack, ack_mask, flags, payload)
    _send_raw(new_state, data)
    return new_state


def _process_acks(state: Dict[str, Any], ack_seq: int, ack_mask: int) -> Dict[str, Any]:
    new_buffer = dict(state["send_buffer"])
    to_remove = []
    for seq, pending in new_buffer.items():
        if seq == ack_seq:
            to_remove.append(seq)
            continue
        diff = ack_seq - seq
        if 0 < diff <= 32:
            if ack_mask & (1 << (diff - 1)):
                to_remove.append(seq)
    for seq in to_remove:
        del new_buffer[seq]
    new_state = dict(state)
    new_state["send_buffer"] = new_buffer
    return new_state


def _clean_recv_window(state: Dict[str, Any]) -> Dict[str, Any]:
    threshold = state["remote_seq"] - RECV_WINDOW_SIZE
    new_window = {
        seq: pkt for seq, pkt in state["recv_window"].items() if seq > threshold
    }
    new_state = dict(state)
    new_state["recv_window"] = new_window
    return new_state


def rudp_recv(
    state: Dict[str, Any], raw_packet: Dict[str, Any]
) -> Tuple[Dict[str, Any], Optional[Dict[str, Any]]]:
    now = time.time() * 1000
    new_state = dict(state)
    new_state["last_recv_time"] = now
    new_state = _process_acks(new_state, raw_packet["ack"], raw_packet["ack_mask"])

    msg_type = raw_packet["msg_type"]
    if msg_type == PACKET_TYPE["ACK"]:
        return new_state, None

    seq = raw_packet["seq"]
    if seq > 0:
        remote_seq = new_state["remote_seq"]
        if seq <= remote_seq:
            diff = remote_seq - seq
            if diff < RECV_WINDOW_SIZE:
                return new_state, None
        elif seq > remote_seq:
            new_state["remote_seq"] = seq
        new_state["recv_window"] = dict(new_state["recv_window"])
        new_state["recv_window"][seq] = raw_packet
        new_state = _clean_recv_window(new_state)

    if needs_ack(msg_type, raw_packet.get("flags", 0)):
        ack, ack_mask = _calculate_ack_mask(new_state)
        ack_data = pack_packet(
            PACKET_TYPE["ACK"], 0, raw_packet["seq"], ack_mask, 0, None
        )
        _send_raw(new_state, ack_data)

    return new_state, raw_packet


def rudp_update(state: Dict[str, Any]) -> Tuple[Dict[str, Any], List[Dict[str, Any]]]:
    now = time.time() * 1000
    new_buffer = dict(state["send_buffer"])
    failed = []
    to_remove = []

    for seq, pending in list(new_buffer.items()):
        elapsed = now - pending["last_send"]
        if elapsed >= RETRY_TIMEOUT_MS:
            if pending["retries"] >= MAX_RETRIES:
                failed.append(pending)
                to_remove.append(seq)
            else:
                new_pending = dict(pending)
                new_pending["retries"] += 1
                new_pending["last_send"] = now
                new_buffer[seq] = new_pending

                ack, ack_mask = _calculate_ack_mask(state)
                data = pack_packet(
                    new_pending["msg_type"],
                    new_pending["seq"],
                    ack,
                    ack_mask,
                    new_pending["flags"],
                    new_pending["payload"],
                )
                _send_raw(state, data)

    for seq in to_remove:
        del new_buffer[seq]

    new_state = dict(state)
    new_state["send_buffer"] = new_buffer
    new_state["last_send_time"] = now
    return new_state, failed


def rudp_needs_heartbeat(state: Dict[str, Any]) -> bool:
    elapsed = time.time() * 1000 - state["last_send_time"]
    return elapsed >= HEARTBEAT_INTERVAL_MS


def rudp_is_timed_out(state: Dict[str, Any]) -> bool:
    elapsed = time.time() * 1000 - state["last_recv_time"]
    return elapsed >= CONNECTION_TIMEOUT_MS
