import struct
import json
from enum import IntEnum
from typing import Optional, Dict, Any, Tuple, List


class PacketType(IntEnum):
    NONE = 0

    LOGIN = 1
    REGISTER = 2
    LOGOUT = 3

    GET_CHARACTER = 10
    SAVE_CHARACTER = 11
    CREATE_CHARACTER = 12
    LIST_CHARACTERS = 13
    SELECT_CHARACTER = 14
    DELETE_CHARACTER = 15

    POSITION_UPDATE = 20
    BATTLE_ACTION = 21

    CHAT_MESSAGE = 30

    HEARTBEAT = 50
    ACK = 51
    NACK = 52

    ERROR = 100

    def is_reliable(self) -> bool:
        return self in (
            PacketType.LOGIN,
            PacketType.REGISTER,
            PacketType.LOGOUT,
            PacketType.GET_CHARACTER,
            PacketType.SAVE_CHARACTER,
            PacketType.CREATE_CHARACTER,
            PacketType.LIST_CHARACTERS,
            PacketType.SELECT_CHARACTER,
            PacketType.DELETE_CHARACTER,
            PacketType.BATTLE_ACTION,
            PacketType.CHAT_MESSAGE,
        )


class Packet:
    TYPE = struct.Struct("!BBI")
    HEADER = struct.Struct("!HBBI")
    FULL_HEADER = struct.Struct("!HBBIIBBB")

    def __init__(
        self,
        msg_type: PacketType,
        seq: int = 0,
        ack: int = 0,
        ack_mask: int = 0,
        payload: bytes = b"",
        flags: int = 0,
    ):
        self.msg_type = msg_type
        self.seq = seq
        self.ack = ack
        self.ack_mask = ack_mask
        self.payload = payload
        self.flags = flags
        self.timestamp = 0

    @property
    def is_reliable(self) -> bool:
        return self.msg_type.is_reliable() or bool(self.flags & 0x01)

    @property
    def needs_ack(self) -> bool:
        return self.is_reliable and self.msg_type != PacketType.ACK

    def set_flag(self, flag: int):
        self.flags |= flag

    def has_flag(self, flag: int) -> bool:
        return (self.flags & flag) != 0

    @classmethod
    def unpack(cls, data: bytes) -> "Packet":
        if len(data) < 8:
            raise ValueError(f"Packet too short: {len(data)} bytes")

        total_len, msg_type, flags, seq = cls.HEADER.unpack_from(data, 0)

        if total_len != len(data):
            raise ValueError(f"Length mismatch: expected {total_len}, got {len(data)}")

        ack, ack_mask = 0, 0
        if len(data) >= 13:
            ack, ack_mask = struct.unpack_from("!IB", data, 8)

        payload = data[13:total_len] if total_len > 13 else b""

        return cls(
            msg_type=PacketType(msg_type),
            seq=seq,
            ack=ack,
            ack_mask=ack_mask,
            payload=payload,
            flags=flags,
        )

    def pack(self) -> bytes:
        total_len = 13 + len(self.payload)

        header = self.HEADER.pack(total_len, int(self.msg_type), self.flags, self.seq)

        ack_data = struct.pack("!IB", self.ack, self.ack_mask)

        return header + ack_data + self.payload

    def get_payload_json(self) -> Optional[Dict[str, Any]]:
        if not self.payload:
            return None
        try:
            return json.loads(self.payload.decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            return None

    @staticmethod
    def set_payload_json(data: Dict[str, Any]) -> bytes:
        return json.dumps(data, ensure_ascii=False).encode("utf-8")

    def __repr__(self):
        return (
            f"Packet(type={self.msg_type.name}, seq={self.seq}, "
            f"ack={self.ack}, ack_mask={self.ack_mask:08b}, "
            f"payload_len={len(self.payload)})"
        )


class PacketBuilder:
    @staticmethod
    def ack(seq: int, ack: int, ack_mask: int = 0) -> Packet:
        return Packet(msg_type=PacketType.ACK, seq=seq, ack=ack, ack_mask=ack_mask)

    @staticmethod
    def heartbeat(seq: int) -> Packet:
        return Packet(msg_type=PacketType.HEARTBEAT, seq=seq)

    @staticmethod
    def error(seq: int, error_code: int, message: str) -> Packet:
        payload = Packet.set_payload_json({"code": error_code, "message": message})
        return Packet(msg_type=PacketType.ERROR, seq=seq, payload=payload)

    @staticmethod
    def login(username: str, password: str, seq: int = 0) -> Packet:
        payload = Packet.set_payload_json({"username": username, "password": password})
        return Packet(msg_type=PacketType.LOGIN, seq=seq, payload=payload)

    @staticmethod
    def login_response(
        seq: int,
        success: bool,
        characters: Optional[List[Dict[str, Any]]] = None,
        error: Optional[str] = None,
    ) -> Packet:
        data: Dict[str, Any] = {"success": success}
        if characters is not None:
            data["characters"] = characters
        if error:
            data["error"] = error
        return Packet(
            msg_type=PacketType.LOGIN, seq=seq, payload=Packet.set_payload_json(data)
        )

    @staticmethod
    def register(username: str, password: str, seq: int = 0) -> Packet:
        payload = Packet.set_payload_json({"username": username, "password": password})
        return Packet(msg_type=PacketType.REGISTER, seq=seq, payload=payload)

    @staticmethod
    def list_characters_response(seq: int, characters: List[Dict[str, Any]]) -> Packet:
        return Packet(
            msg_type=PacketType.LIST_CHARACTERS,
            seq=seq,
            payload=Packet.set_payload_json({"characters": characters}),
        )

    @staticmethod
    def select_character(username: str, character_id: str, seq: int = 0) -> Packet:
        return Packet(
            msg_type=PacketType.SELECT_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json(
                {"username": username, "characterId": character_id}
            ),
        )

    @staticmethod
    def select_character_response(
        seq: int,
        success: bool,
        character: Optional[Dict[str, Any]] = None,
        error: Optional[str] = None,
    ) -> Packet:
        data: Dict[str, Any] = {"success": success}
        if character:
            data["character"] = character
        if error:
            data["error"] = error
        return Packet(
            msg_type=PacketType.SELECT_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json(data),
        )

    @staticmethod
    def create_character(
        username: str, character_data: Dict[str, Any], seq: int = 0
    ) -> Packet:
        return Packet(
            msg_type=PacketType.CREATE_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json(
                {"username": username, "character": character_data}
            ),
        )

    @staticmethod
    def create_character_response(
        seq: int,
        success: bool,
        character: Optional[Dict[str, Any]] = None,
        error: Optional[str] = None,
    ) -> Packet:
        data: Dict[str, Any] = {"success": success}
        if character:
            data["character"] = character
        if error:
            data["error"] = error
        return Packet(
            msg_type=PacketType.CREATE_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json(data),
        )

    @staticmethod
    def delete_character(username: str, character_id: str, seq: int = 0) -> Packet:
        return Packet(
            msg_type=PacketType.DELETE_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json(
                {"username": username, "characterId": character_id}
            ),
        )

    @staticmethod
    def delete_character_response(
        seq: int, success: bool, error: Optional[str] = None
    ) -> Packet:
        data: Dict[str, Any] = {"success": success}
        if error:
            data["error"] = error
        return Packet(
            msg_type=PacketType.DELETE_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json(data),
        )

    @staticmethod
    def position_update(seq: int, x: float, y: float, map_id: str) -> Packet:
        payload = Packet.set_payload_json({"x": x, "y": y, "mapId": map_id})
        return Packet(msg_type=PacketType.POSITION_UPDATE, seq=seq, payload=payload)

    @staticmethod
    def save_character(seq: int, character: Dict[str, Any]) -> Packet:
        return Packet(
            msg_type=PacketType.SAVE_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json({"character": character}),
        )

    @staticmethod
    def get_character(seq: int, username: str) -> Packet:
        return Packet(
            msg_type=PacketType.GET_CHARACTER,
            seq=seq,
            payload=Packet.set_payload_json({"username": username}),
        )
