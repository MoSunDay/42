#!/bin/bash
# One-click startup script for game client and server

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$PROJECT_ROOT/server"
GAME_DIR="$PROJECT_ROOT/game"

echo "=========================================="
echo "  Game Launcher"
echo "=========================================="

# Start server in background
echo "[1/2] Starting server..."
cd "$SERVER_DIR"

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
pip install -q -r requirements.txt

# Run server in background
python app.py &
SERVER_PID=$!
echo "Server started (PID: $SERVER_PID)"

# Wait briefly for server to start
sleep 1

# Check if server is running
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "Error: Server failed to start"
    exit 1
fi

# Start game client
echo "[2/2] Starting game client..."
cd "$GAME_DIR"
love .

# When game exits, stop the server
echo "Game closed. Stopping server..."
kill $SERVER_PID 2>/dev/null
echo "Done."
