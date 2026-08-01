//! RUDP packet: 13-byte big-endian header + JSON payload.
//!
//! Wire layout (identical to the Lua client and the legacy Python server):
//! ```text
//! 0..1  total_len u16 BE   (13 + payload length)
//! 2     msg_type  u8
//! 3     flags     u8       (bit 0x01 = force reliable)
//! 4..7  seq       u32 BE
//! 8..11 ack       u32 BE
//! 12    ack_mask  u8
//! 13..  payload   JSON UTF-8
//! ```

use crate::constants::{msg, msg_is_reliable, FLAG_FORCE_RELIABLE, HEADER_SIZE};

#[derive(Clone, Debug)]
pub struct Packet {
    pub msg_type: u8,
    pub seq: u32,
    pub ack: u32,
    pub ack_mask: u8,
    pub flags: u8,
    pub payload: Vec<u8>,
}

/// Build a packet carrying a JSON payload (or empty payload for None).
#[allow(dead_code)]
pub fn packet_new(msg_type: u8, payload: Option<serde_json::Value>) -> Packet {
    let bytes = match payload {
        Some(v) => json_payload(&v),
        None => Vec::new(),
    };
    Packet {
        msg_type,
        seq: 0,
        ack: 0,
        ack_mask: 0,
        flags: 0,
        payload: bytes,
    }
}

/// Serialize a packet to its wire representation.
pub fn pack_packet(p: &Packet) -> Vec<u8> {
    let total_len = (HEADER_SIZE + p.payload.len()) as u16;
    let mut out = Vec::with_capacity(total_len as usize);
    out.extend_from_slice(&total_len.to_be_bytes());
    out.push(p.msg_type);
    out.push(p.flags);
    out.extend_from_slice(&p.seq.to_be_bytes());
    out.extend_from_slice(&p.ack.to_be_bytes());
    out.push(p.ack_mask);
    out.extend_from_slice(&p.payload);
    out
}

/// Parse a packet from raw datagram bytes. Returns None for malformed input
/// (short header, length mismatch). Tolerates 8-byte headers without ack fields.
pub fn unpack_packet(data: &[u8]) -> Option<Packet> {
    if data.len() < 8 {
        return None;
    }
    let total_len = u16::from_be_bytes([data[0], data[1]]) as usize;
    let msg_type = data[2];
    let flags = data[3];
    let seq = u32::from_be_bytes([data[4], data[5], data[6], data[7]]);
    let mut ack = 0u32;
    let mut ack_mask = 0u8;
    if data.len() >= HEADER_SIZE {
        if total_len != data.len() {
            return None;
        }
        ack = u32::from_be_bytes([data[8], data[9], data[10], data[11]]);
        ack_mask = data[12];
    }
    let payload = if total_len > HEADER_SIZE {
        data[HEADER_SIZE..total_len].to_vec()
    } else {
        Vec::new()
    };
    Some(Packet {
        msg_type,
        seq,
        ack,
        ack_mask,
        flags,
        payload,
    })
}

/// A packet must be acknowledged when its type is reliable or the force flag
/// is set; ACK packets themselves are never acknowledged.
pub fn needs_ack(p: &Packet) -> bool {
    (msg_is_reliable(p.msg_type) || (p.flags & FLAG_FORCE_RELIABLE) != 0)
        && p.msg_type != msg::ACK
}

/// Decode the JSON payload (None when empty or malformed).
pub fn payload_json(p: &Packet) -> Option<serde_json::Value> {
    if p.payload.is_empty() {
        return None;
    }
    serde_json::from_slice(&p.payload).ok()
}

/// Encode a JSON value as payload bytes.
pub fn json_payload(v: &serde_json::Value) -> Vec<u8> {
    serde_json::to_vec(v).unwrap_or_default()
}

/// ACK packet: seq 0, ack = the sequence being acknowledged.
pub fn build_ack_packet(ack: u32, ack_mask: u8) -> Packet {
    Packet {
        msg_type: msg::ACK,
        seq: 0,
        ack,
        ack_mask,
        flags: 0,
        payload: Vec::new(),
    }
}

/// Server heartbeat: seq 0 (own seq space never collides with responses).
pub fn build_heartbeat_packet(ack: u32, ack_mask: u8) -> Packet {
    Packet {
        msg_type: msg::HEARTBEAT,
        seq: 0,
        ack,
        ack_mask,
        flags: 0,
        payload: Vec::new(),
    }
}

/// ERROR packet (used for session kicks; caller may set the force-reliable flag).
#[allow(dead_code)]
pub fn build_error_packet(code: u16, message: &str, flags: u8) -> Packet {
    let body = serde_json::json!({ "code": code, "message": message });
    let mut p = packet_new(msg::ERROR, Some(body));
    p.flags = flags;
    p
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pack_unpack_roundtrip() {
        let body = serde_json::json!({ "username": "test", "password": "123" });
        let p = packet_new(msg::LOGIN, Some(body));
        let data = pack_packet(&p);
        assert_eq!(data.len(), 13 + p.payload.len());
        let q = unpack_packet(&data).expect("unpack");
        assert_eq!(q.msg_type, msg::LOGIN);
        assert_eq!(q.seq, 0);
        assert_eq!(q.flags, 0);
        let payload = payload_json(&q).expect("json");
        assert_eq!(payload["username"], "test");
        assert_eq!(payload["password"], "123");
    }

    #[test]
    fn header_layout_is_13_bytes_big_endian() {
        let mut p = packet_new(msg::LOGIN, None);
        p.seq = 0x01020304;
        p.ack = 0x0A0B0C0D;
        p.ack_mask = 0xAB;
        p.flags = 0x01;
        let data = pack_packet(&p);
        assert_eq!(data.len(), 13);
        assert_eq!(&data[0..2], &[0, 13]);
        assert_eq!(data[2], msg::LOGIN);
        assert_eq!(data[3], 0x01);
        assert_eq!(&data[4..8], &[1, 2, 3, 4]);
        assert_eq!(&data[8..12], &[10, 11, 12, 13]);
        assert_eq!(data[12], 0xAB);
    }

    #[test]
    fn unpack_rejects_short_and_mismatched() {
        assert!(unpack_packet(&[0, 13, 1, 0]).is_none());
        assert!(unpack_packet(&[0, 20, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]).is_none());
    }

    #[test]
    fn ack_rules() {
        assert!(needs_ack(&packet_new(msg::LOGIN, None)));
        assert!(needs_ack(&packet_new(msg::CHAT_MESSAGE, None)));
        assert!(!needs_ack(&packet_new(msg::POSITION_UPDATE, None)));
        assert!(!needs_ack(&packet_new(msg::ACK, None)));
        let mut err = packet_new(msg::ERROR, None);
        err.flags = FLAG_FORCE_RELIABLE;
        assert!(needs_ack(&err));
    }
}
