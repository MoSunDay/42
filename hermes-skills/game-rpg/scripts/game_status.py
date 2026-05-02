#!/usr/bin/env python3
import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "server"))
from headless_client import get_state, connect


def main():
    if not connect().get("success"):
        print(json.dumps({"connected": False}))
        return
    print(json.dumps(get_state(), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
