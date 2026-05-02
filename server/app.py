#!/usr/bin/env python3
"""
Game UDP Server
Reliable UDP protocol for game state synchronization
Multi-character support
"""

import asyncio
import socket
import time
import os
import signal
from typing import Dict, Any, Tuple

from protocol.packet import (
    PacketType,
    unpack_packet,
    pack_packet,
    build_ack,
    build_heartbeat,
    build_error,
    build_select_character_response,
    get_payload_json,
)
from protocol.rudp import (
    create_conn_manager,
    conn_create,
    conn_get,
    conn_get_by_addr,
    conn_get_session_id,
    conn_update_all,
    conn_broadcast,
    channel_send,
    channel_send_immediate,
    channel_recv,
    channel_needs_heartbeat,
)
from protocol.constants import DEFAULT_PORT, BUFFER_SIZE, HEARTBEAT_INTERVAL_MS
from storage import json_store
from handlers import auth_handler, character_handler, sync_handler


_state: Dict[str, Any] = {
    "host": "0.0.0.0",
    "port": DEFAULT_PORT,
    "socket": None,
    "running": False,
    "session_characters": {},
    "last_heartbeat": time.time() * 1000,
    "conn_manager": None,
}


def _send_to(data: bytes, addr: Tuple[str, int]):
    if _state["socket"]:
        try:
            _state["socket"].sendto(data, addr)
        except Exception as e:
            print(f"Send error to {addr}: {e}")


def start(host: str = "0.0.0.0", port: int = DEFAULT_PORT):
    _state["host"] = host
    _state["port"] = port
    _state["socket"] = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    _state["socket"].setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    _state["socket"].bind((host, port))
    _state["socket"].setblocking(False)
    _state["running"] = True

    data_dir = os.path.join(os.path.dirname(__file__), "data")
    json_store.init(data_dir)

    _state["conn_manager"] = create_conn_manager()

    print("=" * 50)
    print("Game UDP Server - Multi-Character Support")
    print("=" * 50)
    print(f"Listening on {host}:{port}")
    print(f"Protocol: RUDP (Reliable UDP)")
    print(f"Accounts: {json_store.get_account_count()}")
    print("=" * 50)
    print("Press Ctrl+C to stop")


def stop():
    _state["running"] = False
    if _state["socket"]:
        _state["socket"].close()
    print("\nServer stopped")


async def run(host: str = "0.0.0.0", port: int = DEFAULT_PORT):
    start(host, port)
    loop = asyncio.get_event_loop()

    if not _state["socket"]:
        return

    while _state["running"]:
        try:
            data, addr = await loop.sock_recvfrom(_state["socket"], BUFFER_SIZE)
            await _handle_packet(data, addr)
        except asyncio.CancelledError:
            break
        except Exception as e:
            if _state["running"]:
                print(f"Error: {e}")

        _update_connections()
        _send_heartbeats()


async def _handle_packet(data: bytes, addr: Tuple[str, int]):
    try:
        packet = unpack_packet(data)
    except ValueError as e:
        print(f"Invalid packet from {addr}: {e}")
        return

    if packet["msg_type"] == PacketType.HEARTBEAT:
        _handle_heartbeat(addr, packet)
        return

    manager = _state["conn_manager"]

    if packet["msg_type"] == PacketType.ACK:
        channel = conn_get_by_addr(manager, addr)
        if channel:
            channel_recv(channel, packet)
        return

    channel = conn_get_by_addr(manager, addr)
    if not channel:
        channel = _create_connection(addr)

    processed = channel_recv(channel, packet)
    if processed is None:
        return

    _dispatch_packet(processed, addr, channel)


def _create_connection(addr: Tuple[str, int]):
    manager = _state["conn_manager"]
    session_id, channel = conn_create(manager, addr, _send_to)
    print(f"New connection: {addr} -> {session_id}")
    return channel


def _dispatch_packet(packet, addr: Tuple[str, int], channel):
    manager = _state["conn_manager"]
    session_id = conn_get_session_id(manager, addr) or ""
    session_info = _state["session_characters"].get(session_id)

    def send_response(resp):
        channel_send(channel, resp)

    def broadcast(resp, exclude_session: str):
        conn_broadcast(manager, resp, {exclude_session})

    msg_type = packet["msg_type"]

    if msg_type == PacketType.LOGIN:
        _handle_login(packet, addr, channel, send_response)
    elif msg_type == PacketType.REGISTER:
        _handle_register(packet, addr, channel, send_response)
    elif msg_type == PacketType.LOGOUT:
        _handle_logout(packet, session_id, send_response)
    elif msg_type == PacketType.LIST_CHARACTERS:
        character_handler.handle_list_characters(packet, send_response)
    elif msg_type == PacketType.SELECT_CHARACTER:
        _handle_select_character(packet, session_id, channel, send_response)
    elif msg_type == PacketType.CREATE_CHARACTER:
        character_handler.handle_create_character(packet, send_response)
    elif msg_type == PacketType.DELETE_CHARACTER:
        character_handler.handle_delete_character(packet, send_response)
    elif msg_type == PacketType.GET_CHARACTER:
        character_handler.handle_get_character(packet, send_response)
    elif msg_type == PacketType.SAVE_CHARACTER:
        character_handler.handle_save_character(packet, send_response)
    elif msg_type == PacketType.POSITION_UPDATE:
        sync_handler.handle_position_update(packet, send_response, session_id)
    elif msg_type == PacketType.BATTLE_ACTION:
        sync_handler.handle_battle_action(packet, send_response, broadcast)
    elif msg_type == PacketType.CHAT_MESSAGE:
        sync_handler.handle_chat_message(packet, send_response, broadcast)


def _handle_login(packet, addr, channel, send_response):
    data = get_payload_json(packet)
    if not data:
        return

    username = data.get("username", "")
    manager = _state["conn_manager"]

    def on_login_success(resp):
        send_response(resp)
        resp_data = get_payload_json(resp)
        if resp_data and resp_data.get("success"):
            session_id = conn_get_session_id(manager, addr)
            if session_id:
                _state["session_characters"][session_id] = (username, "")
            print(f"User logged in: {username} (selecting character)")

    auth_handler.handle_login(
        packet, on_login_success, conn_get_session_id(manager, addr)
    )


def _handle_register(packet, addr, channel, send_response):
    data = get_payload_json(packet)
    if not data:
        return

    username = data.get("username", "")
    manager = _state["conn_manager"]

    def on_register_success(resp):
        send_response(resp)
        resp_data = get_payload_json(resp)
        if resp_data and resp_data.get("success"):
            session_id = conn_get_session_id(manager, addr)
            if session_id:
                _state["session_characters"][session_id] = (username, "")
            print(f"User registered: {username} (selecting character)")

    auth_handler.handle_register(packet, on_register_success)


def _handle_select_character(packet, session_id: str, channel, send_response):
    data = get_payload_json(packet)
    if not data:
        return

    session_info = _state["session_characters"].get(session_id)
    if not session_info:
        response = build_select_character_response(
            seq=packet["seq"], success=False, error="Not logged in"
        )
        send_response(response)
        return

    username = data.get("username") or session_info[0]
    character_id = data.get("characterId", "")

    old_session = None
    for sid, info in _state["session_characters"].items():
        if sid != session_id and info[0] == username and info[1] == character_id:
            old_session = sid
            break

    if old_session:
        sync_handler.unregister_player(old_session)
        del _state["session_characters"][old_session]
        manager = _state["conn_manager"]
        old_channel = conn_get(manager, old_session)
        if old_channel:
            kick_packet = build_error(0, 409, "Kicked: Logged in from another location")
            channel_send(old_channel, kick_packet)
        print(
            f"Kicked old session: {old_session} (user={username}, char={character_id})"
        )

    character = json_store.get_character_by_id(username, character_id)

    if character:
        _state["session_characters"][session_id] = (username, character_id)
        sync_handler.register_player(username, character_id, session_id)
        response = build_select_character_response(
            seq=packet["seq"], success=True, character=character
        )
        print(
            f"Character selected: {username}/{character.get('characterName', character_id)}"
        )
    else:
        response = build_select_character_response(
            seq=packet["seq"], success=False, error="Character not found"
        )

    send_response(response)


def _handle_logout(packet, session_id: str, send_response):
    session_info = _state["session_characters"].get(session_id)
    if session_info:
        username, character_id = session_info
        sync_handler.unregister_player(session_id)
        if session_id in _state["session_characters"]:
            del _state["session_characters"][session_id]
        print(f"User logged out: {username}/{character_id}")

    auth_handler.handle_logout(packet, send_response)


def _handle_heartbeat(addr: Tuple[str, int], packet):
    manager = _state["conn_manager"]
    channel = conn_get_by_addr(manager, addr)
    if channel:
        channel["last_recv_time"] = time.time() * 1000
        ack = build_ack(0, packet["seq"])
        _send_to(pack_packet(ack), addr)


def _update_connections():
    manager = _state["conn_manager"]
    results = conn_update_all(manager)

    for session_id, failed_packets in results.items():
        if failed_packets:
            print(f"Connection {session_id}: {len(failed_packets)} packets failed")

    for session_id in list(_state["session_characters"].keys()):
        if not conn_get(manager, session_id):
            session_info = _state["session_characters"].pop(session_id, None)
            if session_info:
                username, character_id = session_info
                sync_handler.unregister_player(session_id)
                print(f"Session expired: {session_id} ({username}/{character_id})")


def _send_heartbeats():
    now = time.time() * 1000
    if now - _state["last_heartbeat"] < HEARTBEAT_INTERVAL_MS:
        return

    _state["last_heartbeat"] = now
    manager = _state["conn_manager"]

    for session_id, channel in list(manager["connections"].items()):
        if channel_needs_heartbeat(channel):
            heartbeat = build_heartbeat(channel["next_seq"])
            channel_send_immediate(channel, heartbeat)


async def main():
    loop = asyncio.get_event_loop()

    def signal_handler():
        stop()
        loop.stop()

    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, signal_handler)

    await run()


if __name__ == "__main__":
    asyncio.run(main())
