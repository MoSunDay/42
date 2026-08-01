//! RUDP game server entry point.
//!
//! UDP loop on 0.0.0.0:9000 (override with GAME_PORT or argv[1]), 10ms tick:
//! drain inbound datagrams, dispatch handlers, apply outbound actions, run
//! RUDP retries/heartbeats/timeouts, flush the JSON store when dirty.

mod accounts;
mod constants;
mod handlers;
mod packet;
mod rudp;
mod storage;

use std::net::UdpSocket;
use std::sync::atomic::{AtomicBool, Ordering};
use std::thread;
use std::time::Duration;

use constants::{ACCOUNTS_FILE, BUFFER_SIZE, DEFAULT_PORT, TICK_MS};
use handlers::{kick_packet, Action};
use rudp::{broadcast, manager_new, recv_packet, remove_session, send_reliable, update_all};
use storage::Store;

static STOPPING: AtomicBool = AtomicBool::new(false);

extern "C" fn handle_stop(_: libc::c_int) {
    STOPPING.store(true, Ordering::SeqCst);
}

fn install_signal_handlers() {
    unsafe {
        libc::signal(libc::SIGINT, handle_stop as *const () as libc::sighandler_t);
        libc::signal(libc::SIGTERM, handle_stop as *const () as libc::sighandler_t);
    }
}

fn now_ms() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as u64
}

fn resolve_port() -> u16 {
    if let Some(arg) = std::env::args().nth(1) {
        if let Ok(p) = arg.parse() {
            return p;
        }
    }
    if let Ok(v) = std::env::var("GAME_PORT") {
        if let Ok(p) = v.parse() {
            return p;
        }
    }
    DEFAULT_PORT
}

fn apply_actions(
    store: &mut Store,
    manager: &mut rudp::Manager,
    sock: &UdpSocket,
    actions: Vec<Action>,
    now: u64,
) {
    for action in actions {
        match action {
            Action::SendTo(addr, pkt) => {
                send_reliable(manager, sock, addr, &pkt, now);
            }
            Action::Broadcast(pkt, exclude) => {
                broadcast(manager, sock, &pkt, exclude, now);
            }
            Action::Kick(addr) => {
                let pkt = kick_packet();
                send_reliable(manager, sock, addr, &pkt, now);
                remove_session(manager, &addr);
                println!("Session kicked (duplicate login): {}", addr);
            }
        }
    }
    if store.dirty {
        storage::save(store, ACCOUNTS_FILE);
    }
}

fn handle_datagram(
    store: &mut Store,
    manager: &mut rudp::Manager,
    sock: &UdpSocket,
    src: std::net::SocketAddr,
    data: &[u8],
    now: u64,
) {
    let Some(pkt) = recv_packet(manager, sock, src, data, now) else {
        return;
    };
    let actions = handlers::dispatch(store, manager, src, pkt);
    apply_actions(store, manager, sock, actions, now);
}

fn main() {
    let port = resolve_port();
    let bind_addr = format!("0.0.0.0:{}", port);
    let sock = match UdpSocket::bind(&bind_addr) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Failed to bind {}: {}", bind_addr, e);
            std::process::exit(1);
        }
    };
    sock.set_nonblocking(true).expect("set nonblocking");

    let store = storage::load(ACCOUNTS_FILE);
    let mut store = store;
    let mut manager = manager_new();
    if store.dirty {
        storage::save(&store, ACCOUNTS_FILE);
    }

    install_signal_handlers();

    println!("================================================");
    println!("Game UDP Server (Rust)");
    println!("================================================");
    println!("Listening on {}", bind_addr);
    println!("Protocol: RUDP (Reliable UDP), header {} bytes", constants::HEADER_SIZE);
    println!("Accounts: {} loaded from {}", store.accounts.len(), ACCOUNTS_FILE);
    println!("Test accounts: test/123, admin/admin, player/pass");
    println!("Press Ctrl-C to stop");

    let mut buf = [0u8; BUFFER_SIZE];
    while !STOPPING.load(Ordering::SeqCst) {
        loop {
            match sock.recv_from(&mut buf) {
                Ok((n, src)) => {
                    let now = now_ms();
                    handle_datagram(&mut store, &mut manager, &sock, src, &buf[..n], now);
                }
                Err(ref e) if e.kind() == std::io::ErrorKind::WouldBlock => break,
                Err(e) => {
                    eprintln!("recv error: {}", e);
                    break;
                }
            }
        }
        let now = now_ms();
        update_all(&mut manager, &sock, now);
        if store.dirty {
            storage::save(&store, ACCOUNTS_FILE);
        }
        thread::sleep(Duration::from_millis(TICK_MS));
    }
    storage::save(&store, ACCOUNTS_FILE);
    println!("Server stopped");
}

#[cfg(test)]
mod tests;
