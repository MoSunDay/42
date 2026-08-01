# Project Overview

This is a turn-based RPG game built with:
- **Game Client**: LÖVE 2D (Lua) - 2D top-down exploration with turn-based combat
- **Server**: Rust RUDP over UDP/9000 - account/character sync + battle logic (wire-compatible with the Lua client; legacy Python server archived in `server/legacy_python/`)
