# Protocol Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Reliable UDP (RUDP) protocol for game communication.

## Files

| File | Description |
|------|-------------|
| `packet.py` | Packet structure and serialization |
| `rudp.py` | Reliable UDP with ACK/retry |
| `constants.py` | Protocol constants |

## Key APIs

### packet.py - Packet
- `Packet(msg_type, seq, payload)` - Create packet
- `Packet.unpack(data)` - Parse from bytes
- `packet.pack()` - Serialize to bytes
- `PacketBuilder.login(username, password)` - Build login packet
- `PacketBuilder.ack(seq, ack_seq)` - Build ACK

### rudp.py - ConnectionManager
- `ConnectionManager.create_connection(addr, send_func)` - New connection
- `ConnectionManager.get_connection(session_id)` - Get by ID
- `ConnectionManager.broadcast(packet, exclude)` - Broadcast to all
- `ConnectionManager.update_all()` - Process timeouts

### rudp.py - ReliableChannel
- `ReliableChannel.send(packet)` - Send with reliability
- `ReliableChannel.recv(packet)` - Process received
- `ReliableChannel.needs_heartbeat()` - Check heartbeat needed

## Packet Structure

```
+--------+--------+--------+------------------+
| Type   | Seq    | Ack    | Payload          |
| 1 byte | 4 bytes| 4 bytes| variable         |
+--------+--------+--------+------------------+
```

## Packet Types

| Type | Value | Description |
|------|-------|-------------|
| LOGIN | 1 | Login request |
| REGISTER | 2 | Register request |
| LOGOUT | 3 | Logout request |
| ACK | 4 | Acknowledgment |
| HEARTBEAT | 5 | Keepalive |
| GET_CHARACTER | 6 | Load character |
| SAVE_CHARACTER | 7 | Save character |
| CREATE_CHARACTER | 8 | New character |
| POSITION_UPDATE | 9 | Position sync |
| CHAT_MESSAGE | 10 | Chat message |
| BATTLE_ACTION | 11 | Battle action |
