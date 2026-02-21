import time
import asyncio
from collections import deque
from typing import Dict, Optional, Tuple, Callable, Any
from dataclasses import dataclass, field

from .packet import Packet, PacketType, PacketBuilder
from .constants import (
    MAX_RETRIES,
    RETRY_TIMEOUT_MS,
    RECV_WINDOW_SIZE,
    SEND_BUFFER_SIZE,
    CONNECTION_TIMEOUT_MS,
    HEARTBEAT_INTERVAL_MS,
)


@dataclass
class PendingPacket:
    packet: Packet
    send_time: float = 0.0
    retries: int = 0
    last_send: float = 0.0


class ReliableChannel:
    def __init__(self, send_func: Callable[[bytes], None]):
        self.send_func = send_func

        self.next_seq = 1
        self.remote_seq = 0

        self.send_buffer: Dict[int, PendingPacket] = {}
        self.recv_window: Dict[int, Packet] = {}
        self.recv_queue: deque = deque(maxlen=SEND_BUFFER_SIZE)

        self.ack_mask = 0

        self.last_recv_time = time.time() * 1000
        self.last_send_time = time.time() * 1000

        self.connected = True

    def _now_ms(self) -> float:
        return time.time() * 1000

    def _next_sequence(self) -> int:
        seq = self.next_seq
        self.next_seq = (self.next_seq + 1) & 0xFFFFFFFF
        return seq

    def _update_ack_mask(self, ack_seq: int):
        diff = self.remote_seq - ack_seq
        if diff <= 0 or diff > 32:
            return

        self.ack_mask |= 1 << (diff - 1)

        if self.ack_mask.bit_length() > 32:
            self.ack_mask &= 0xFFFFFFFF

    def _calculate_ack_mask(self) -> Tuple[int, int]:
        ack = self.remote_seq
        ack_mask = 0

        for seq in self.recv_window:
            diff = ack - seq
            if 0 < diff <= 32:
                ack_mask |= 1 << (diff - 1)

        return ack, ack_mask

    def send(self, packet: Packet) -> bool:
        now = self._now_ms()
        self.last_send_time = now

        if packet.seq == 0:
            packet.seq = self._next_sequence()

        ack, ack_mask = self._calculate_ack_mask()
        packet.ack = ack
        packet.ack_mask = ack_mask

        data = packet.pack()
        self.send_func(data)

        if packet.needs_ack:
            pending = PendingPacket(
                packet=packet, send_time=now, retries=0, last_send=now
            )
            self.send_buffer[packet.seq] = pending

        return True

    def send_immediate(self, packet: Packet):
        now = self._now_ms()
        self.last_send_time = now

        ack, ack_mask = self._calculate_ack_mask()
        packet.ack = ack
        packet.ack_mask = ack_mask

        self.send_func(packet.pack())

    def recv(self, packet: Packet) -> Optional[Packet]:
        now = self._now_ms()
        self.last_recv_time = now

        self._process_acks(packet.ack, packet.ack_mask)

        if packet.msg_type == PacketType.ACK:
            return None

        if packet.seq > 0:
            if packet.seq <= self.remote_seq:
                diff = self.remote_seq - packet.seq
                if diff < RECV_WINDOW_SIZE:
                    return None
            elif packet.seq > self.remote_seq:
                self.remote_seq = packet.seq

            self.recv_window[packet.seq] = packet
            self._clean_recv_window()

        if packet.needs_ack:
            ack, ack_mask = self._calculate_ack_mask()
            ack_packet = PacketBuilder.ack(0, packet.seq, ack_mask)
            self.send_immediate(ack_packet)

        return packet

    def _process_acks(self, ack: int, ack_mask: int):
        to_remove = []

        for seq, pending in self.send_buffer.items():
            if seq == ack:
                to_remove.append(seq)
                continue

            diff = ack - seq
            if 0 < diff <= 32:
                if ack_mask & (1 << (diff - 1)):
                    to_remove.append(seq)

        for seq in to_remove:
            del self.send_buffer[seq]

    def _clean_recv_window(self):
        to_remove = []
        threshold = self.remote_seq - RECV_WINDOW_SIZE

        for seq in self.recv_window:
            if seq <= threshold:
                to_remove.append(seq)

        for seq in to_remove:
            del self.recv_window[seq]

    def update(self) -> list:
        now = self._now_ms()
        timeout_ms = RETRY_TIMEOUT_MS

        failed = []
        to_remove = []

        for seq, pending in self.send_buffer.items():
            elapsed = now - pending.last_send

            if elapsed >= timeout_ms:
                if pending.retries >= MAX_RETRIES:
                    failed.append(pending.packet)
                    to_remove.append(seq)
                else:
                    pending.retries += 1
                    pending.last_send = now

                    ack, ack_mask = self._calculate_ack_mask()
                    pending.packet.ack = ack
                    pending.packet.ack_mask = ack_mask

                    self.send_func(pending.packet.pack())

        for seq in to_remove:
            del self.send_buffer[seq]

        return failed

    def is_timed_out(self) -> bool:
        elapsed = self._now_ms() - self.last_recv_time
        return elapsed >= CONNECTION_TIMEOUT_MS

    def needs_heartbeat(self) -> bool:
        elapsed = self._now_ms() - self.last_send_time
        return elapsed >= HEARTBEAT_INTERVAL_MS

    def get_pending_count(self) -> int:
        return len(self.send_buffer)

    def get_stats(self) -> Dict[str, Any]:
        return {
            "next_seq": self.next_seq,
            "remote_seq": self.remote_seq,
            "pending_count": len(self.send_buffer),
            "recv_window_size": len(self.recv_window),
            "connected": self.connected,
            "last_recv_ms": self._now_ms() - self.last_recv_time,
            "last_send_ms": self._now_ms() - self.last_send_time,
        }


class ConnectionManager:
    def __init__(self):
        self.connections: Dict[str, ReliableChannel] = {}
        self.addr_to_session: Dict[Tuple[str, int], str] = {}
        self._session_counter = 0

    def _generate_session_id(self) -> str:
        self._session_counter += 1
        return f"sess_{self._session_counter}_{int(time.time() * 1000)}"

    def create_connection(
        self, addr: Tuple[str, int], send_func: Callable[[bytes, Tuple[str, int]], None]
    ) -> Tuple[str, ReliableChannel]:
        session_id = self._generate_session_id()

        def wrapped_send(data: bytes):
            send_func(data, addr)

        channel = ReliableChannel(wrapped_send)

        self.connections[session_id] = channel
        self.addr_to_session[addr] = session_id

        return session_id, channel

    def get_connection(self, session_id: str) -> Optional[ReliableChannel]:
        return self.connections.get(session_id)

    def get_connection_by_addr(
        self, addr: Tuple[str, int]
    ) -> Optional[ReliableChannel]:
        session_id = self.addr_to_session.get(addr)
        if session_id:
            return self.connections.get(session_id)
        return None

    def get_session_id(self, addr: Tuple[str, int]) -> Optional[str]:
        return self.addr_to_session.get(addr)

    def remove_connection(self, session_id: str):
        if session_id in self.connections:
            del self.connections[session_id]

        to_remove = [
            addr for addr, sid in self.addr_to_session.items() if sid == session_id
        ]
        for addr in to_remove:
            del self.addr_to_session[addr]

    def update_all(self) -> Dict[str, list]:
        results = {}
        timed_out = []

        for session_id, channel in self.connections.items():
            failed = channel.update()
            if failed:
                results[session_id] = failed

            if channel.is_timed_out():
                timed_out.append(session_id)

        for session_id in timed_out:
            self.remove_connection(session_id)

        return results

    def broadcast(self, packet: Packet, exclude: Optional[set] = None):
        exclude_set = exclude or set()
        for session_id, channel in self.connections.items():
            if session_id not in exclude_set:
                channel.send(packet)

    def get_connection_count(self) -> int:
        return len(self.connections)

    def get_all_sessions(self) -> list:
        return list(self.connections.keys())
