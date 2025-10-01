#!/bin/bash
# RUN_GAME.sh - Quick script to run the game

echo "=========================================="
echo "  Top-Down Combat Game - MVP v1.1"
echo "=========================================="
echo ""
echo "Starting game..."
echo ""
echo "Controls:"
echo "  - Left Click: Move character"
echo "  - ESC: Quit game"
echo ""
echo "Features:"
echo "  ✓ Knight character sprite"
echo "  ✓ Town map with roads"
echo "  ✓ Map boundary restrictions"
echo "  ✓ Position display"
echo "  ✓ Minimap"
echo ""
echo "=========================================="
echo ""

# Check if Love2D is installed
if ! command -v love &> /dev/null; then
    echo "ERROR: Love2D is not installed!"
    echo ""
    echo "Install Love2D:"
    echo "  macOS:   brew install love"
    echo "  Windows: https://love2d.org/"
    echo "  Linux:   sudo apt-get install love"
    echo ""
    exit 1
fi

# Get Love2D version
LOVE_VERSION=$(love --version | head -1)
echo "Using: $LOVE_VERSION"
echo ""

# Run the game
cd "$(dirname "$0")"
love .

echo ""
echo "Game closed. Thanks for playing!"

