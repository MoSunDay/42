#!/usr/bin/env python3
"""
Standalone test for protocol
"""

import sys

sys.path.insert(0, ".")

from protocol.packet import Packet, PacketType, PacketBuilder


def test_packet_serialization():
    print("Testing packet serialization...")

    pkt = PacketBuilder.login("testuser", "password123")
    data = pkt.pack()

    print(f"Original: type={pkt.msg_type.name}, seq={pkt.seq}")
    print(f"Packed: {len(data)} bytes")

    unpacked = Packet.unpack(data)
    print(f"Unpacked: type={unpacked.msg_type.name}, seq={unpacked.seq}")

    payload = unpacked.get_payload_json()
    print(f"Payload: {payload}")

    assert unpacked.msg_type == pkt.msg_type
    assert unpacked.seq == pkt.seq
    assert payload["username"] == "testuser"
    assert payload["password"] == "password123"

    print("PASS: Packet serialization works correctly")


def test_ack_mask():
    print("\nTesting ACK mask...")

    pkt = Packet(PacketType.ACK, seq=1, ack=100, ack_mask=0b10101010)
    data = pkt.pack()

    unpacked = Packet.unpack(data)

    print(f"ACK: {unpacked.ack}, Mask: {unpacked.ack_mask:08b}")

    assert unpacked.ack == 100
    assert unpacked.ack_mask == 0b10101010

    print("PASS: ACK mask works correctly")


def test_json_payload():
    print("\nTesting JSON payload...")

    test_data = {
        "username": "player1",
        "character": {"name": "Hero", "level": 5, "items": ["sword", "shield"]},
        "position": [100.5, 200.3],
    }

    payload = Packet.set_payload_json(test_data)
    pkt = Packet(PacketType.SAVE_CHARACTER, payload=payload)
    data = pkt.pack()

    unpacked = Packet.unpack(data)
    result = unpacked.get_payload_json()

    print(f"Original: {test_data}")
    print(f"Result: {result}")

    assert result["username"] == "player1"
    assert result["character"]["name"] == "Hero"
    assert result["position"][0] == 100.5

    print("PASS: JSON payload works correctly")


def test_reliable_flag():
    print("\nTesting reliable flag...")

    login = Packet(PacketType.LOGIN)
    assert login.is_reliable == True
    assert login.needs_ack == True
    print(f"LOGIN: reliable={login.is_reliable}, needs_ack={login.needs_ack}")

    position = Packet(PacketType.POSITION_UPDATE)
    assert position.is_reliable == False
    assert position.needs_ack == False
    print(f"POSITION: reliable={position.is_reliable}, needs_ack={position.needs_ack}")

    ack = Packet(PacketType.ACK)
    assert ack.is_reliable == False
    assert ack.needs_ack == False
    print(f"ACK: reliable={ack.is_reliable}, needs_ack={ack.needs_ack}")

    print("PASS: Reliable flag works correctly")


if __name__ == "__main__":
    test_packet_serialization()
    test_ack_mask()
    test_json_payload()
    test_reliable_flag()
    print("\n" + "=" * 50)
    print("All tests passed!")
