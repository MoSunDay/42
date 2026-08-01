#!/bin/bash
# Start the RUDP game server (Rust, wire-compatible with the Lua client).
# Usage: ./start.sh [port]   (default 9000; env GAME_PORT also honored)
set -e
cd "$(dirname "$0")"

if ! command -v cargo >/dev/null 2>&1; then
    echo "Error: cargo is not installed"
    exit 1
fi

if [ ! -f target/release/game-server ]; then
    echo "Building release binary..."
    cargo build --release
fi

echo "=========================================="
echo "Game Account API Server (Rust RUDP)"
echo "Port: ${1:-9000}   Accounts: $(pwd)/data/accounts.json"
echo "=========================================="
exec target/release/game-server "$@"
