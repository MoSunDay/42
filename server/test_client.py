#!/usr/bin/env python3
"""Live integration tests against a running RUDP server (default 127.0.0.1:9000).

Requires the server to be started first:  ./start.sh
"""

import sys
import os
import time
import random
import string

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from headless_client.client import (
    connect, disconnect, login, register, create_character,
    select_character, delete_character, get_state, move_to,
)

HOST = os.environ.get("SERVER_HOST", "127.0.0.1")
PORT = int(os.environ.get("SERVER_PORT", "9000"))

PASS = 0


def check(name, cond, detail=""):
    global PASS
    if not cond:
        raise AssertionError(f"FAIL: {name} {detail}")
    PASS += 1
    print(f"  ok: {name}")


def rand_name(prefix):
    return prefix + "_" + "".join(random.choices(string.ascii_lowercase, k=8))


def main():
    print(f"connecting to {HOST}:{PORT}")
    r = connect(HOST, PORT)
    check("connect", r.get("success") is True, str(r))

    r = login("test", "123")
    check("login test/123", r.get("success") is True and "characters" in r, str(r))
    check("default char present", len(r.get("characters", [])) >= 1)
    chars = r.get("characters", [])
    default_id = chars[0]["id"] if chars else None
    state = get_state()
    check("state entered character select", state.get("mode") == "character_select", str(state))

    r = login("test", "wrong-password")
    check("bad login rejected", r.get("success") is False and r.get("error"), str(r))

    user = rand_name("u")
    r = register(user, "pass123")
    check("register new account", r.get("success") is True, str(r))
    check("register answers with LOGIN-typed success + characters", "characters" in r, str(r))
    check("new account gets first character", len(r.get("characters", [])) == 1, str(r))
    check("first char named after username", r["characters"][0]["characterName"] == user, str(r))

    cname = rand_name("hero")
    r = create_character(cname, "warrior", {"avatarColor": [0.2, 0.6, 1.0]})
    check("create character", r.get("success") is True, str(r))
    cid = r.get("character", {}).get("id")
    check("created char has id", bool(cid), str(r))

    r = select_character(cid)
    check("select character", r.get("success") is True, str(r))
    state = get_state()
    check("state entered exploration", state.get("mode") == "exploration", str(state))

    r = move_to(12.5, 34.0)
    check("position update sent", r.get("success") is True, str(r))

    r = select_character(cid)  # re-select to confirm server still tracks session
    check("reselect character", r.get("success") is True, str(r))

    r = delete_character(cid)
    check("delete character", r.get("success") is True, str(r))

    disconnect()
    print(f"\n{PASS} checks passed")


if __name__ == "__main__":
    main()
