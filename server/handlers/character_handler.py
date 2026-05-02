from typing import Callable
from storage import json_store
from protocol.packet import (
    PacketType,
    create_packet,
    set_payload_json,
    build_list_characters_response,
    build_create_character_response,
    build_delete_character_response,
)
from handlers.common import send_error, parse_payload


def handle_list_characters(packet, send_response: Callable):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username")
    if not username:
        send_error(send_response, packet["seq"], 400, "Missing username")
        return

    characters = json_store.get_characters(username)
    response = build_list_characters_response(packet["seq"], characters)
    send_response(response)


def handle_create_character(packet, send_response: Callable):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username")
    character_data = data.get("character", {})

    if not username:
        send_error(send_response, packet["seq"], 400, "Missing username")
        return

    success, message, new_character = json_store.create_character(
        username, character_data
    )

    if success:
        response = build_create_character_response(
            seq=packet["seq"], success=True, character=new_character
        )
        send_response(response)
    else:
        send_error(send_response, packet["seq"], 400, message)


def handle_delete_character(packet, send_response: Callable):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username")
    character_id = data.get("characterId")

    if not username:
        send_error(send_response, packet["seq"], 400, "Missing username")
        return

    if not character_id:
        send_error(send_response, packet["seq"], 400, "Missing characterId")
        return

    success, message = json_store.delete_character(username, character_id)

    if success:
        response = build_delete_character_response(seq=packet["seq"], success=True)
        send_response(response)
    else:
        response = build_delete_character_response(
            seq=packet["seq"], success=False, error=message
        )
        send_response(response)


def handle_get_character(packet, send_response: Callable):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    username = data.get("username")
    if not username:
        send_error(send_response, packet["seq"], 400, "Missing username")
        return

    character = json_store.get_character(username)

    if character:
        response = create_packet(
            msg_type=PacketType.GET_CHARACTER,
            seq=packet["seq"],
            payload=set_payload_json({"success": True, "character": character}),
        )
        send_response(response)
    else:
        send_error(send_response, packet["seq"], 404, "Character not found")


def handle_save_character(packet, send_response: Callable):
    data = parse_payload(packet)
    if not data:
        send_error(send_response, packet["seq"], 400, "Invalid payload")
        return

    character = data.get("character")
    username = data.get("username")

    if not character or not username:
        send_error(send_response, packet["seq"], 400, "Missing character data")
        return

    required = ["characterName", "level", "hp", "maxHp"]
    for field in required:
        if field not in character:
            send_error(send_response, packet["seq"], 400, f"Missing field: {field}")
            return

    char_id = character.get("id")
    if char_id:
        success = json_store.save_character_by_id(username, char_id, character)
    else:
        success = json_store.save_character(username, character)

    response = create_packet(
        msg_type=PacketType.SAVE_CHARACTER,
        seq=packet["seq"],
        payload=set_payload_json(
            {
                "success": success,
                "message": "Character saved" if success else "Save failed",
            }
        ),
    )
    send_response(response)
