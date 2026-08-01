from typing import Callable
from protocol.packet import build_error, get_payload_json


def send_error(send_fn: Callable, seq: int, code: int, message: str) -> None:
    response = build_error(seq, code, message)
    send_fn(response)


def parse_payload(packet):
    data = get_payload_json(packet)
    if not data:
        return None
    return data
