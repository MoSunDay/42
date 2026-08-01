//! Per-session reliable UDP layer.
//!
//! Every session owns an independent outbound seq space (responses never echo
//! client seqs), an ack mask over recently received client packets, a send
//! buffer with 500ms x5 retries, a 5s heartbeat and a 30s idle timeout.

use std::collections::HashMap;
use std::net::{SocketAddr, UdpSocket};

use crate::constants::{
    msg, CONNECTION_TIMEOUT_MS, HEARTBEAT_INTERVAL_MS, MAX_RETRIES, RECV_WINDOW_SIZE,
    RETRY_TIMEOUT_MS,
};
use crate::packet::{
    build_ack_packet, build_heartbeat_packet, needs_ack, pack_packet, unpack_packet, Packet,
};

/// An unacknowledged outbound packet.
#[derive(Clone, Debug)]
pub struct Pending {
    pub packet: Packet,
    pub retries: u32,
    pub last_send_ms: u64,
}

/// Server-side session bound to one client address.
#[derive(Clone, Debug)]
#[allow(dead_code)]
pub struct Session {
    pub addr: SocketAddr,
    pub next_seq: u32,
    pub remote_seq: u32,
    pub send_buffer: HashMap<u32, Pending>,
    pub recv_window: HashMap<u32, Packet>,
    pub last_recv_ms: u64,
    pub last_send_ms: u64,
    pub username: Option<String>,
    pub character_id: Option<String>,
}

/// All live sessions, keyed by client address.
pub struct Manager {
    pub sessions: HashMap<SocketAddr, Session>,
}

pub fn manager_new() -> Manager {
    Manager {
        sessions: HashMap::new(),
    }
}

pub fn session_new(addr: SocketAddr, now_ms: u64) -> Session {
    Session {
        addr,
        next_seq: 1,
        remote_seq: 0,
        send_buffer: HashMap::new(),
        recv_window: HashMap::new(),
        last_recv_ms: now_ms,
        last_send_ms: now_ms,
        username: None,
        character_id: None,
    }
}

/// Allocate the next outbound seq (32-bit wrap).
fn alloc_seq(s: &mut Session) -> u32 {
    let seq = s.next_seq;
    s.next_seq = seq.wrapping_add(1);
    seq
}

/// ack = highest contiguous client seq seen; ack_mask bit i covers seq ack-i-1.
fn ack_mask_for(s: &Session) -> (u32, u8) {
    let ack = s.remote_seq;
    let mut mask: u32 = 0;
    for &seq in s.recv_window.keys() {
        let diff = ack.wrapping_sub(seq);
        if diff > 0 && diff <= 32 {
            mask |= 1u32 << (diff - 1);
        }
    }
    (ack, mask as u8)
}

/// Remove acknowledged entries from the send buffer.
fn process_acks(s: &mut Session, ack: u32, ack_mask: u8) {
    if ack == 0 {
        return;
    }
    let mask = ack_mask as u32;
    let mut done: Vec<u32> = Vec::new();
    for (&seq, _) in s.send_buffer.iter() {
        if seq == ack {
            done.push(seq);
        } else {
            let diff = ack.wrapping_sub(seq);
            if diff > 0 && diff <= 32 && (mask & (1u32 << (diff - 1))) != 0 {
                done.push(seq);
            }
        }
    }
    for seq in done {
        s.send_buffer.remove(&seq);
    }
}

fn clean_recv_window(s: &mut Session) {
    let threshold = s.remote_seq.wrapping_sub(RECV_WINDOW_SIZE as u32);
    s.recv_window.retain(|&seq, _| seq > threshold);
}

fn send_raw(sock: &UdpSocket, addr: SocketAddr, pkt: &Packet) -> bool {
    sock.send_to(&pack_packet(pkt), addr).is_ok()
}

/// Process an inbound datagram. Returns the dispatchable packet (None for
/// ACK/HEARTBEAT/duplicates). Creates a session on first contact; ACK and
/// HEARTBEAT never create sessions. Sends an immediate ACK for reliable
/// packets and answers HEARTBEAT with ACK.
pub fn recv_packet(
    m: &mut Manager,
    sock: &UdpSocket,
    addr: SocketAddr,
    data: &[u8],
    now_ms: u64,
) -> Option<Packet> {
    let pkt = unpack_packet(data)?;

    if pkt.msg_type == msg::HEARTBEAT {
        if let Some(s) = m.sessions.get_mut(&addr) {
            s.last_recv_ms = now_ms;
        }
        let ack = build_ack_packet(pkt.seq, 0);
        send_raw(sock, addr, &ack);
        return None;
    }

    if pkt.msg_type == msg::ACK {
        if let Some(s) = m.sessions.get_mut(&addr) {
            s.last_recv_ms = now_ms;
            process_acks(s, pkt.ack, pkt.ack_mask);
        }
        return None;
    }

    m.sessions.entry(addr).or_insert_with(|| session_new(addr, now_ms));
    let s = m.sessions.get_mut(&addr)?;
    s.last_recv_ms = now_ms;
    process_acks(s, pkt.ack, pkt.ack_mask);

    if pkt.seq > 0 {
        let remote = s.remote_seq;
        if pkt.seq <= remote {
            let diff = remote - pkt.seq;
            if diff < RECV_WINDOW_SIZE as u32 {
                return None; // duplicate or stale
            }
        } else {
            s.remote_seq = pkt.seq;
        }
        s.recv_window.insert(pkt.seq, pkt.clone());
        clean_recv_window(s);
    }

    if needs_ack(&pkt) {
        let (_ack, ack_mask) = ack_mask_for(s);
        let ackpkt = build_ack_packet(pkt.seq, ack_mask);
        send_raw(sock, addr, &ackpkt);
    }
    Some(pkt)
}

/// Send a reliable packet in the session's own seq space and buffer it.
/// Returns false when the session does not exist.
pub fn send_reliable(
    m: &mut Manager,
    sock: &UdpSocket,
    addr: SocketAddr,
    pkt: &Packet,
    now_ms: u64,
) -> bool {
    let Some(s) = m.sessions.get_mut(&addr) else {
        return false;
    };
    let seq = alloc_seq(s);
    s.last_send_ms = now_ms;
    let (ack, ack_mask) = ack_mask_for(s);
    let mut out = pkt.clone();
    out.seq = seq;
    out.ack = ack;
    out.ack_mask = ack_mask;
    let ok = send_raw(sock, addr, &out);
    if needs_ack(&out) {
        s.send_buffer.insert(
            seq,
            Pending {
                packet: out,
                retries: 0,
                last_send_ms: now_ms,
            },
        );
    }
    ok
}

/// Send the same packet to every session except the excluded address.
pub fn broadcast(
    m: &mut Manager,
    sock: &UdpSocket,
    pkt: &Packet,
    exclude: Option<SocketAddr>,
    now_ms: u64,
) {
    let targets: Vec<SocketAddr> = m
        .sessions
        .keys()
        .copied()
        .filter(|a| Some(*a) != exclude)
        .collect();
    for addr in targets {
        send_reliable(m, sock, addr, pkt, now_ms);
    }
}

pub fn remove_session(m: &mut Manager, addr: &SocketAddr) {
    m.sessions.remove(addr);
}

/// Find the address of another session that has selected the same character.
pub fn find_duplicate_session(
    m: &Manager,
    username: &str,
    character_id: &str,
    except: SocketAddr,
) -> Option<SocketAddr> {
    m.sessions.iter().find_map(|(addr, s)| {
        if *addr != except
            && s.username.as_deref() == Some(username)
            && s.character_id.as_deref() == Some(character_id)
        {
            Some(*addr)
        } else {
            None
        }
    })
}

/// Retry pending sends, emit heartbeats, drop timed-out sessions.
pub fn update_all(m: &mut Manager, sock: &UdpSocket, now_ms: u64) {
    let mut expired: Vec<SocketAddr> = Vec::new();
    for (addr, s) in m.sessions.iter_mut() {
        let (ack, ack_mask) = ack_mask_for(s);
        let mut dropped: Vec<u32> = Vec::new();
        for (&seq, pending) in s.send_buffer.iter_mut() {
            if now_ms.saturating_sub(pending.last_send_ms) < RETRY_TIMEOUT_MS {
                continue;
            }
            if pending.retries >= MAX_RETRIES {
                dropped.push(seq);
            } else {
                pending.retries += 1;
                pending.last_send_ms = now_ms;
                let mut pkt = pending.packet.clone();
                pkt.ack = ack;
                pkt.ack_mask = ack_mask;
                send_raw(sock, *addr, &pkt);
                s.last_send_ms = now_ms;
            }
        }
        for seq in dropped {
            s.send_buffer.remove(&seq);
        }
        if now_ms.saturating_sub(s.last_send_ms) >= HEARTBEAT_INTERVAL_MS {
            let hb = build_heartbeat_packet(ack, ack_mask);
            send_raw(sock, *addr, &hb);
            s.last_send_ms = now_ms;
        }
        if now_ms.saturating_sub(s.last_recv_ms) >= CONNECTION_TIMEOUT_MS {
            expired.push(*addr);
        }
    }
    for addr in expired {
        m.sessions.remove(&addr);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sockets() -> (UdpSocket, UdpSocket) {
        let server = UdpSocket::bind("127.0.0.1:0").expect("bind server");
        let client = UdpSocket::bind("127.0.0.1:0").expect("bind client");
        (server, client)
    }

    #[test]
    fn reliable_send_uses_own_seq_space() {
        let (sock, client) = sockets();
        let addr = client.local_addr().unwrap();
        let mut m = manager_new();
        let now = 1_000;
        m.sessions.insert(addr, session_new(addr, now));
        let pkt = crate::packet::packet_new(msg::LOGIN, None);
        send_reliable(&mut m, &sock, addr, &pkt, now);
        send_reliable(&mut m, &sock, addr, &pkt, now);
        let s = m.sessions.get(&addr).unwrap();
        assert_eq!(s.next_seq, 3);
        assert_eq!(s.send_buffer.len(), 2);
        let mut seqs: Vec<u32> = s.send_buffer.keys().copied().collect();
        seqs.sort_unstable();
        assert_eq!(seqs, vec![1, 2]);
    }

    #[test]
    fn ack_clears_send_buffer() {
        let (sock, client) = sockets();
        let addr = client.local_addr().unwrap();
        let mut m = manager_new();
        let now = 1_000;
        m.sessions.insert(addr, session_new(addr, now));
        let pkt = crate::packet::packet_new(msg::LOGIN, None);
        send_reliable(&mut m, &sock, addr, &pkt, now);
        assert_eq!(m.sessions.get(&addr).unwrap().send_buffer.len(), 1);
        // client ACKs seq 1
        let ack = build_ack_packet(1, 0);
        recv_packet(&mut m, &sock, addr, &pack_packet(&ack), now + 10);
        assert!(m.sessions.get(&addr).unwrap().send_buffer.is_empty());
    }

    #[test]
    fn duplicate_seq_is_dropped() {
        let (sock, client) = sockets();
        let addr = client.local_addr().unwrap();
        let mut m = manager_new();
        let now = 1_000;
        m.sessions.insert(addr, session_new(addr, now));
        let pkt = crate::packet::packet_new(msg::LOGIN, None);
        let mut req = pkt.clone();
        req.seq = 7;
        let data = pack_packet(&req);
        assert!(recv_packet(&mut m, &sock, addr, &data, now).is_some());
        assert!(recv_packet(&mut m, &sock, addr, &data, now + 10).is_none());
    }

    #[test]
    fn retry_then_drop_after_max() {
        let (sock, client) = sockets();
        let addr = client.local_addr().unwrap();
        let mut m = manager_new();
        let now = 1_000;
        m.sessions.insert(addr, session_new(addr, now));
        let pkt = crate::packet::packet_new(msg::LOGIN, None);
        send_reliable(&mut m, &sock, addr, &pkt, now);
        for i in 0..MAX_RETRIES {
            let next = m.sessions.get(&addr).unwrap().send_buffer.len();
            assert!(next >= 1);
            update_all(&mut m, &sock, now + 600 + i as u64 * 600);
        }
        // one more update drops the entry entirely
        update_all(&mut m, &sock, now + 600 + MAX_RETRIES as u64 * 600);
        assert!(m.sessions.get(&addr).unwrap().send_buffer.is_empty());
    }

    #[test]
    fn heartbeat_and_timeout() {
        let (sock, client) = sockets();
        let addr = client.local_addr().unwrap();
        let mut m = manager_new();
        let now = 1_000;
        m.sessions.insert(addr, session_new(addr, now));
        let mut saw_hb = false;
        for i in 1..10 {
            let t = now + i * 6000;
            update_all(&mut m, &sock, t);
            if let Some(s) = m.sessions.get(&addr) {
                saw_hb = saw_hb || s.last_send_ms == t;
            }
        }
        assert!(saw_hb);
        // idle beyond 30s removes the session
        update_all(&mut m, &sock, now + 40_000);
        assert!(!m.sessions.contains_key(&addr));
    }
}
