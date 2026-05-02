#!/usr/bin/env python3
import argparse
import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "server"))
from headless_client import (
    connect,
    disconnect,
    is_connected,
    login,
    register,
    list_characters,
    create_character,
    select_character,
    delete_character,
    get_state,
    move_to,
    battle_action,
    use_skill,
    use_item,
    attack,
    defend,
    flee,
    save,
    send_chat,
    logout,
)


def _out(result: dict) -> None:
    print(json.dumps(result, ensure_ascii=False, indent=2))


def main():
    parser = argparse.ArgumentParser(
        description="42 RPG Headless Game Client",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command")

    p = sub.add_parser("connect", help="Connect to game server")
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--port", type=int, default=9000)

    p = sub.add_parser("login", help="Login with username/password")
    p.add_argument("--user", required=True)
    p.add_argument("--pass", dest="password", required=True)

    p = sub.add_parser("register", help="Register new account")
    p.add_argument("--user", required=True)
    p.add_argument("--pass", dest="password", required=True)

    sub.add_parser("list-characters", help="List account characters")

    p = sub.add_parser("create-character", help="Create a new character")
    p.add_argument("--name", required=True)
    p.add_argument(
        "--class",
        dest="class_id",
        required=True,
        choices=[
            "dual_blade",
            "great_sword",
            "blade_master",
            "sealer",
            "healer",
            "elementalist",
        ],
    )

    p = sub.add_parser("select-character", help="Select a character to play")
    p.add_argument("--id", dest="char_id", required=True)

    p = sub.add_parser("delete-character", help="Delete a character")
    p.add_argument("--id", dest="char_id", required=True)

    sub.add_parser("state", help="Get current game state")

    p = sub.add_parser("move", help="Move character to coordinates")
    p.add_argument("--x", type=float, required=True)
    p.add_argument("--y", type=float, required=True)

    p = sub.add_parser("battle", help="Execute battle action")
    p.add_argument(
        "--action", required=True, choices=["attack", "skill", "item", "defend", "flee"]
    )
    p.add_argument("--skill-id", default=None)
    p.add_argument("--target", default=None)
    p.add_argument("--targets", nargs="*", default=None)

    sub.add_parser("save", help="Save character progress")

    p = sub.add_parser("chat", help="Send chat message")
    p.add_argument("--msg", required=True)

    sub.add_parser("logout", help="Logout and disconnect")

    sub.add_parser("disconnect", help="Disconnect from server")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    result = _dispatch(args)
    _out(result)
    if not result.get("success", True):
        sys.exit(1)


def _dispatch(args) -> dict:
    cmd = args.command

    if cmd == "connect":
        return connect(args.host, args.port)

    if cmd == "disconnect":
        return disconnect()

    if cmd == "login":
        if not is_connected():
            connect()
        return login(args.user, args.password)

    if cmd == "register":
        if not is_connected():
            connect()
        return register(args.user, args.password)

    if cmd == "list-characters":
        return list_characters()

    if cmd == "create-character":
        return create_character(args.name, args.class_id)

    if cmd == "select-character":
        return select_character(args.char_id)

    if cmd == "delete-character":
        return delete_character(args.char_id)

    if cmd == "state":
        return get_state()

    if cmd == "move":
        return move_to(args.x, args.y)

    if cmd == "battle":
        if args.action == "skill":
            return use_skill(args.skill_id, args.targets or [])
        elif args.action == "item":
            return use_item(args.target)
        elif args.action == "attack":
            return attack(args.target)
        elif args.action == "defend":
            return defend()
        elif args.action == "flee":
            return flee()
        return battle_action(args.action)

    if cmd == "save":
        return save()

    if cmd == "chat":
        return send_chat(args.msg)

    if cmd == "logout":
        return logout()

    return {"success": False, "error": f"Unknown command: {cmd}"}


if __name__ == "__main__":
    main()
