# Network Module Summary

> Last updated: 0b5db5a - UI components + NPC expansion

## Purpose
Client-side network communication using reliable UDP (RUDP).

## Files

| File | Description |
|------|-------------|
| `network_manager.lua` | Main network coordinator |
| `packet.lua` | Packet serialization/parsing |
| `rudp.lua` | Reliable UDP implementation |
| `constants.lua` | Network constants |

## Key APIs

### network_manager.lua
- `NetworkManager.new()` - Create manager
- `NetworkManager:connect(host, port)` - Connect to server
- `NetworkManager:send(packet)` - Send packet
- `NetworkManager:update(dt)` - Process incoming packets
- `NetworkManager:disconnect()` - Close connection

### packet.lua
- `Packet.new(msgType, payload)` - Create packet
- `Packet:pack()` - Serialize to bytes
- `Packet.unpack(data)` - Parse from bytes

### rudp.lua
- `ReliableChannel.new(sendFunc)` - Create reliable channel
- `ReliableChannel:send(packet)` - Send with ACK retry
- `ReliableChannel:recv(packet)` - Process received packet
- `ReliableChannel:update(dt)` - Handle timeouts

## Packet Types

| Type | Direction | Description |
|------|-----------|-------------|
| LOGIN | C->S | Login request |
| REGISTER | C->S | Account creation |
| GET_CHARACTER | C->S | Request character data |
| SAVE_CHARACTER | C->S | Save character progress |
| POSITION_UPDATE | C<->S | Player position sync |
| CHAT_MESSAGE | C<->S | Chat messages |
| HEARTBEAT | C<->S | Keepalive |
