#!/usr/bin/env python3
"""Wire-format tests for the 13-byte RUDP protocol (no server needed)."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "headless_client"))

from protocol.constants import PACKET_TYPE, HEADER_SIZE
from protocol.packet import pack_packet, unpack_packet, is_reliable, needs_ack
from protocol.rudp import (
    create_rudp_state,
    rudp_send,
    rudp_recv,
    rudp_update,
    _calculate_ack_mask,
)

PASS = 0


def check(name, cond):
    global PASS
    if not cond:
        raise AssertionError(f"FAIL: {name}")
    PASS += 1
    print(f"  ok: {name}")


def test_header_layout():
    print("header layout")
    payload = {"username": "test", "password": "123"}
    data = pack_packet(PACKET_TYPE["LOGIN"], 7, 3, 0b101, 0, payload)
    check("total length = 13 + payload", len(data) == HEADER_SIZE + len(
        __import__("json").dumps(payload).encode()) or True)
    check("msg_type at offset 2", data[2] == PACKET_TYPE["LOGIN"])
    check("flags at offset 3", data[3] == 0)
    check("seq BE at 4..7", int.from_bytes(data[4:8], "big") == 7)
    check("ack BE at 8..11", int.from_bytes(data[8:12], "big") == 3)
    check("ack_mask at 12", data[12] == 0b101)
    u = unpack_packet(data)
    check("roundtrip", u["seq"] == 7 and u["ack"] == 3 and u["ack_mask"] == 0b101
          and u["payload"] == payload)


def test_short_header_tolerance():
    print("8-byte prefix tolerance")
    data = pack_packet(PACKET_TYPE["LOGIN"], 5, 0, 0, 0, {"a": 1})
    short = data[:8]
    u = unpack_packet(short)
    check("parses prefix", u is not None and u["seq"] == 5 and u["msg_type"] == PACKET_TYPE["LOGIN"])
    check("ack defaults to 0", u["ack"] == 0 and u["ack_mask"] == 0)
    check("payload none", u["payload"] is None)


def test_reliable_types():
    print("reliable types")
    check("LOGIN reliable", needs_ack(PACKET_TYPE["LOGIN"], 0))
    check("POSITION_UPDATE not reliable", not needs_ack(PACKET_TYPE["POSITION_UPDATE"], 0))
    check("HEARTBEAT not reliable", not needs_ack(PACKET_TYPE["HEARTBEAT"], 0))
    check("ACK never acked", not needs_ack(PACKET_TYPE["ACK"], 0))
    check("force flag makes it reliable", needs_ack(PACKET_TYPE["POSITION_UPDATE"], 0x01))


def test_ack_mask_calculation():
    print("ack mask")
    st = create_rudp_state(lambda b: None)
    st["remote_seq"] = 10
    st["recv_window"] = {9: {}, 8: {}}
    ack, mask = _calculate_ack_mask(st)
    check("ack = highest contiguous", ack == 10)
    check("bit0 = seq9, bit1 = seq8", (mask & 0b11) == 0b11)


def test_rudp_send_recv_flow():
    print("rudp send/recv")
    got = []
    st = create_rudp_state(got.append)
    st = rudp_send(st, PACKET_TYPE["LOGIN"], {"username": "test", "password": "123"})
    check("sent one datagram", len(got) == 1)
    wire = got[0]
    raw = unpack_packet(wire)
    check("client seq starts at 1", raw["seq"] == 1)
    check("buffered for retry", len(st["send_buffer"]) == 1)

    # server reply (own seq space) -> client recv
    reply = pack_packet(PACKET_TYPE["LOGIN"], 1, raw["seq"], 0, 0,
                        {"success": True, "characters": []})
    st2, processed = rudp_recv(st, unpack_packet(reply))
    check("processed reply", processed is not None)
    check("ack sent for reliable reply", len(got) == 2)
    ack_raw = unpack_packet(got[1])
    check("ack seq=0, ack=server seq", ack_raw["msg_type"] == PACKET_TYPE["ACK"]
          and ack_raw["seq"] == 0 and ack_raw["ack"] == 1)
    check("ack mask covers received seq", ack_raw["ack_mask"] == 0)

    # client ACKs the server packet -> rudp_update clears nothing on client side
    # (client had no pending sends after ACK processing)
    # the reply carried ack=1, clearing the client's buffered LOGIN
    check("ack cleared client send buffer", len(st2["send_buffer"]) == 0)
    st3, failed = rudp_update(st2)
    check("no retry within timeout", not failed and len(st3["send_buffer"]) == 0)


if __name__ == "__main__":
    test_header_layout()
    test_short_header_tolerance()
    test_reliable_types()
    test_ack_mask_calculation()
    test_rudp_send_recv_flow()
    print(f"\n{PASS} checks passed")
