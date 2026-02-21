#!/usr/bin/env python3
"""Test script for UDP server"""

import socket
import time
import sys

sys.path.insert(0, ".")

from protocol.packet import Packet, PacketType, PacketBuilder


def recv_response(sock, expected_type=None, max_tries=5):
    for _ in range(max_tries):
        try:
            data, addr = sock.recvfrom(4096)
            response = Packet.unpack(data)

            if expected_type is None or response.msg_type == expected_type:
                return response
        except socket.timeout:
            return None
    return None


def test_server(host="127.0.0.1", port=9000):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(2.0)

    print(f"Testing UDP server at {host}:{port}")
    print("=" * 50)

    print("\n1. Testing login with 'test/123'...")
    login_pkt = PacketBuilder.login("test", "123")
    sock.sendto(login_pkt.pack(), (host, port))

    response = recv_response(sock, PacketType.LOGIN)
    if response:
        payload = response.get_payload_json()
        if payload:
            print(f"   Success: {payload.get('success')}")
            if payload.get("character"):
                char = payload["character"]
                print(
                    f"   Character: {char.get('characterName')} (Lv.{char.get('level')})"
                )
    else:
        print("   ERROR: No LOGIN response")

    print("\n2. Testing invalid login...")
    bad_login = PacketBuilder.login("invalid", "wrong")
    sock.sendto(bad_login.pack(), (host, port))

    response = recv_response(sock, PacketType.LOGIN)
    if response:
        payload = response.get_payload_json()
        if payload:
            print(f"   Success: {payload.get('success')}")
            print(f"   Error: {payload.get('error')}")
    else:
        print("   ERROR: No LOGIN response")

    print("\n3. Testing registration...")
    reg_pkt = PacketBuilder.register(
        "testuser_" + str(int(time.time()) % 10000), "pass123"
    )
    sock.sendto(reg_pkt.pack(), (host, port))

    response = recv_response(sock, PacketType.LOGIN)
    if response:
        payload = response.get_payload_json()
        if payload:
            print(f"   Success: {payload.get('success')}")
            if payload.get("character"):
                print(f"   New character: {payload['character'].get('characterName')}")
    else:
        print("   ERROR: No LOGIN response")

    print("\n4. Testing heartbeat...")
    hb_pkt = PacketBuilder.heartbeat(0)
    sock.sendto(hb_pkt.pack(), (host, port))

    response = recv_response(sock, PacketType.ACK)
    if response:
        print(f"   Response type: {response.msg_type.name}")
    else:
        print("   ERROR: No ACK response")

    print("\n" + "=" * 50)
    print("Test complete")

    sock.close()


if __name__ == "__main__":
    test_server()
