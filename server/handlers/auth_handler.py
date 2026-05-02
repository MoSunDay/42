from typing import Callable, Optional
from storage import json_store
from protocol.packet import (
    PacketType,
    create_packet,
    set_payload_json,
    build_login_response,
)
from handlers.common import send_error, parse_payload


def handle_login(
    packet,
    send_response: Callable,
    session_id: Optional[str] = None,
):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username", "")
    password = data.get("password", "")

    if not username or not password:
        send_error(send_response, packet["seq"], 400, "Missing credentials")
        return

    success, characters = json_store.verify_login(username, password)

    if success and characters:
        response = build_login_response(
            seq=packet["seq"], success=True, characters=characters
        )
    else:
        response = build_login_response(
            seq=packet["seq"], success=False, error="Invalid username or password"
        )

    send_response(response)


def handle_register(packet, send_response: Callable):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username", "")
    password = data.get("password", "")
    character_name = data.get("characterName")

    if not username or not password:
        send_error(send_response, packet["seq"], 400, "Missing credentials")
        return

    if len(username) < 2 or len(username) > 20:
        send_error(
            send_response, packet["seq"], 400, "Username must be 2-20 characters"
        )
        return

    if len(password) < 3:
        send_error(send_response, packet["seq"], 400, "Password too short")
        return

    success, message = json_store.create_account(username, password, character_name)

    if success:
        _, characters = json_store.verify_login(username, password)
        response = build_login_response(
            seq=packet["seq"], success=True, characters=characters
        )
    else:
        response = build_login_response(seq=packet["seq"], success=False, error=message)

    send_response(response)


def handle_logout(packet, send_response: Callable):
    response = create_packet(
        msg_type=PacketType.LOGOUT,
        seq=packet["seq"],
        payload=set_payload_json({"success": True}),
    )
    send_response(response)
