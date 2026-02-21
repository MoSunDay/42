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
from typing import Optional, Tuple, Dict, Any

from protocol.packet import Packet, PacketType, PacketBuilder
from protocol.rudp import ConnectionManager, ReliableChannel
from protocol.constants import DEFAULT_PORT, BUFFER_SIZE, HEARTBEAT_INTERVAL_MS
from storage.json_store import JsonStore
from handlers.auth_handler import AuthHandler
from handlers.character_handler import CharacterHandler
from handlers.sync_handler import SyncHandler


class GameUDPServer:
    def __init__(self, host: str = "0.0.0.0", port: int = DEFAULT_PORT):
        self.host = host
        self.port = port
        self.socket: Optional[socket.socket] = None
        self.running = False

        self.data_dir = os.path.join(os.path.dirname(__file__), "data")
        self.store = JsonStore(self.data_dir)

        self.conn_manager = ConnectionManager()
        self.auth_handler = AuthHandler(self.store)
        self.char_handler = CharacterHandler(self.store)
        self.sync_handler = SyncHandler(self.store)

        self._session_characters: Dict[str, Tuple[str, str]] = {}
        self._last_heartbeat = time.time() * 1000

    def start(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.socket.setblocking(False)
        self.running = True

        print("=" * 50)
        print("Game UDP Server - Multi-Character Support")
        print("=" * 50)
        print(f"Listening on {self.host}:{self.port}")
        print(f"Protocol: RUDP (Reliable UDP)")
        print(f"Accounts: {self.store.get_account_count()}")
        print("=" * 50)
        print("Press Ctrl+C to stop")

    def stop(self):
        self.running = False
        if self.socket:
            self.socket.close()
        print("\nServer stopped")

    async def run(self):
        self.start()
        loop = asyncio.get_event_loop()

        if not self.socket:
            return

        while self.running:
            try:
                data, addr = await loop.sock_recvfrom(self.socket, BUFFER_SIZE)
                await self._handle_packet(data, addr)
            except asyncio.CancelledError:
                break
            except Exception as e:
                if self.running:
                    print(f"Error: {e}")

            self._update_connections()
            self._send_heartbeats()

    async def _handle_packet(self, data: bytes, addr: Tuple[str, int]):
        try:
            packet = Packet.unpack(data)
        except ValueError as e:
            print(f"Invalid packet from {addr}: {e}")
            return

        if packet.msg_type == PacketType.HEARTBEAT:
            self._handle_heartbeat(addr, packet)
            return

        if packet.msg_type == PacketType.ACK:
            channel = self.conn_manager.get_connection_by_addr(addr)
            if channel:
                channel.recv(packet)
            return

        channel = self.conn_manager.get_connection_by_addr(addr)
        if not channel:
            channel = self._create_connection(addr)

        processed = channel.recv(packet)
        if processed is None:
            return

        self._dispatch_packet(processed, addr, channel)

    def _create_connection(self, addr: Tuple[str, int]) -> ReliableChannel:
        session_id, channel = self.conn_manager.create_connection(addr, self._send_to)
        print(f"New connection: {addr} -> {session_id}")
        return channel

    def _send_to(self, data: bytes, addr: Tuple[str, int]):
        if self.socket:
            try:
                self.socket.sendto(data, addr)
            except Exception as e:
                print(f"Send error to {addr}: {e}")

    def _dispatch_packet(
        self, packet: Packet, addr: Tuple[str, int], channel: ReliableChannel
    ):
        session_id = self.conn_manager.get_session_id(addr) or ""
        session_info = self._session_characters.get(session_id)
        username = session_info[0] if session_info else ""
        character_id = session_info[1] if session_info else ""

        def send_response(resp: Packet):
            channel.send(resp)

        def broadcast(resp: Packet, exclude_session: str):
            exclude_set = {exclude_session}
            self.conn_manager.broadcast(resp, exclude_set)

        if packet.msg_type == PacketType.LOGIN:
            self._handle_login(packet, addr, channel, send_response)
        elif packet.msg_type == PacketType.REGISTER:
            self._handle_register(packet, addr, channel, send_response)
        elif packet.msg_type == PacketType.LOGOUT:
            self._handle_logout(packet, session_id, send_response)
        elif packet.msg_type == PacketType.LIST_CHARACTERS:
            self.char_handler.handle_list_characters(packet, send_response)
        elif packet.msg_type == PacketType.SELECT_CHARACTER:
            self._handle_select_character(packet, session_id, channel, send_response)
        elif packet.msg_type == PacketType.CREATE_CHARACTER:
            self.char_handler.handle_create_character(packet, send_response)
        elif packet.msg_type == PacketType.DELETE_CHARACTER:
            self.char_handler.handle_delete_character(packet, send_response)
        elif packet.msg_type == PacketType.GET_CHARACTER:
            self.char_handler.handle_get_character(packet, send_response)
        elif packet.msg_type == PacketType.SAVE_CHARACTER:
            self.char_handler.handle_save_character(packet, send_response)
        elif packet.msg_type == PacketType.POSITION_UPDATE:
            self.sync_handler.handle_position_update(packet, send_response, session_id)
        elif packet.msg_type == PacketType.BATTLE_ACTION:
            self.sync_handler.handle_battle_action(packet, send_response, broadcast)
        elif packet.msg_type == PacketType.CHAT_MESSAGE:
            self.sync_handler.handle_chat_message(packet, send_response, broadcast)

    def _handle_login(
        self,
        packet: Packet,
        addr: Tuple[str, int],
        channel: ReliableChannel,
        send_response,
    ):
        data = packet.get_payload_json()
        if not data:
            return

        username = data.get("username", "")

        def on_login_success(resp: Packet):
            send_response(resp)
            resp_data = resp.get_payload_json()
            if resp_data and resp_data.get("success"):
                session_id = self.conn_manager.get_session_id(addr)
                if session_id:
                    self._session_characters[session_id] = (username, "")
                print(f"User logged in: {username} (selecting character)")

        self.auth_handler.handle_login(
            packet, on_login_success, self.conn_manager.get_session_id(addr)
        )

    def _handle_register(
        self,
        packet: Packet,
        addr: Tuple[str, int],
        channel: ReliableChannel,
        send_response,
    ):
        data = packet.get_payload_json()
        if not data:
            return

        username = data.get("username", "")

        def on_register_success(resp: Packet):
            send_response(resp)
            resp_data = resp.get_payload_json()
            if resp_data and resp_data.get("success"):
                session_id = self.conn_manager.get_session_id(addr)
                if session_id:
                    self._session_characters[session_id] = (username, "")
                print(f"User registered: {username} (selecting character)")

        self.auth_handler.handle_register(packet, on_register_success)

    def _handle_select_character(
        self,
        packet: Packet,
        session_id: str,
        channel: ReliableChannel,
        send_response,
    ):
        data = packet.get_payload_json()
        if not data:
            return

        session_info = self._session_characters.get(session_id)
        if not session_info:
            response = PacketBuilder.select_character_response(
                seq=packet.seq, success=False, error="Not logged in"
            )
            send_response(response)
            return

        username = data.get("username") or session_info[0]
        character_id = data.get("characterId", "")

        old_session = None
        for sid, info in self._session_characters.items():
            if sid != session_id and info[0] == username and info[1] == character_id:
                old_session = sid
                break

        if old_session:
            self.sync_handler.unregister_player(old_session)
            del self._session_characters[old_session]
            old_channel = self.conn_manager.get_connection(old_session)
            if old_channel:
                kick_packet = PacketBuilder.error(
                    0, 409, "Kicked: Logged in from another location"
                )
                old_channel.send(kick_packet)
            print(
                f"Kicked old session: {old_session} (user={username}, char={character_id})"
            )

        character = self.store.get_character_by_id(username, character_id)

        if character:
            self._session_characters[session_id] = (username, character_id)
            self.sync_handler.register_player(username, character_id, session_id)
            response = PacketBuilder.select_character_response(
                seq=packet.seq, success=True, character=character
            )
            print(
                f"Character selected: {username}/{character.get('characterName', character_id)}"
            )
        else:
            response = PacketBuilder.select_character_response(
                seq=packet.seq, success=False, error="Character not found"
            )

        send_response(response)

    def _handle_logout(self, packet: Packet, session_id: str, send_response):
        session_info = self._session_characters.get(session_id)
        if session_info:
            username, character_id = session_info
            self.sync_handler.unregister_player(session_id)
            if session_id in self._session_characters:
                del self._session_characters[session_id]
            print(f"User logged out: {username}/{character_id}")

        self.auth_handler.handle_logout(packet, send_response)

    def _handle_heartbeat(self, addr: Tuple[str, int], packet: Packet):
        channel = self.conn_manager.get_connection_by_addr(addr)
        if channel:
            channel.last_recv_time = time.time() * 1000
            ack = PacketBuilder.ack(0, packet.seq)
            self._send_to(ack.pack(), addr)

    def _update_connections(self):
        results = self.conn_manager.update_all()

        for session_id, failed_packets in results.items():
            if failed_packets:
                print(f"Connection {session_id}: {len(failed_packets)} packets failed")

        for session_id in list(self._session_characters.keys()):
            if not self.conn_manager.get_connection(session_id):
                session_info = self._session_characters.pop(session_id, None)
                if session_info:
                    username, character_id = session_info
                    self.sync_handler.unregister_player(session_id)
                    print(f"Session expired: {session_id} ({username}/{character_id})")

    def _send_heartbeats(self):
        now = time.time() * 1000
        if now - self._last_heartbeat < HEARTBEAT_INTERVAL_MS:
            return

        self._last_heartbeat = now

        for session_id, channel in list(self.conn_manager.connections.items()):
            if channel.needs_heartbeat():
                heartbeat = PacketBuilder.heartbeat(channel.next_seq)
                channel.send_immediate(heartbeat)


async def main():
    server = GameUDPServer()
    loop = asyncio.get_event_loop()

    def signal_handler():
        server.stop()
        loop.stop()

    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, signal_handler)

    await server.run()


if __name__ == "__main__":
    asyncio.run(main())
