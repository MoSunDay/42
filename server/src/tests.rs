//! Integration tests across storage + handlers + rudp (no network I/O).

use std::net::SocketAddr;

use serde_json::json;

use crate::constants::msg;
use crate::handlers::{dispatch, Action};
use crate::packet::{packet_new, payload_json, Packet};
use crate::rudp::{manager_new, session_new, Manager};
use crate::storage::{load, Store};

fn test_store() -> Store {
    let p = std::env::temp_dir().join(format!("dispatch_test_{}", std::process::id()));
    let _ = std::fs::remove_file(&p);
    load(p.to_str().unwrap())
}

fn addr(n: u16) -> SocketAddr {
    format!("127.0.0.1:{}", 20_000 + n).parse().unwrap()
}

fn session_with(m: &mut Manager, a: SocketAddr, user: &str, char_id: Option<&str>, now: u64) {
    let mut s = session_new(a, now);
    s.username = Some(user.into());
    s.character_id = char_id.map(|c| c.into());
    m.sessions.insert(a, s);
}

fn login_pkt(user: &str, pass: &str) -> Packet {
    packet_new(msg::LOGIN, Some(json!({"username": user, "password": pass})))
}

#[test]
fn login_returns_characters_and_marks_session() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a = addr(1);
    session_with(&mut m, a, "", None, _now);
    let actions = dispatch(&mut store, &mut m, a, login_pkt("test", "123"));
    assert_eq!(actions.len(), 1);
    match &actions[0] {
        Action::SendTo(target, p) => {
            assert_eq!(*target, a);
            assert_eq!(p.msg_type, msg::LOGIN);
            let body = payload_json(p).unwrap();
            assert_eq!(body["success"], true);
            assert_eq!(body["characters"][0]["characterName"], "Test Hero");
            assert_eq!(body["characters"][0]["level"], 5);
        }
        _ => panic!("expected SendTo"),
    }
    assert_eq!(m.sessions.get(&a).unwrap().username.as_deref(), Some("test"));
}

#[test]
fn bad_login_rejects() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a = addr(2);
    session_with(&mut m, a, "", None, _now);
    let actions = dispatch(&mut store, &mut m, a, login_pkt("test", "nope"));
    let body = match &actions[0] {
        Action::SendTo(_, p) => payload_json(p).unwrap(),
        _ => panic!("expected SendTo"),
    };
    assert_eq!(body["success"], false);
    assert!(body["error"].as_str().is_some());
    assert!(m.sessions.get(&a).unwrap().username.is_none());
}

#[test]
fn register_answers_with_login_type() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a = addr(3);
    session_with(&mut m, a, "", None, _now);
    let pkt = packet_new(
        msg::REGISTER,
        Some(json!({"username": "newbie", "password": "pwdpwd", "characterName": "Nova"})),
    );
    let actions = dispatch(&mut store, &mut m, a, pkt);
    match &actions[0] {
        Action::SendTo(target, p) => {
            assert_eq!(*target, a);
            assert_eq!(p.msg_type, msg::LOGIN); // register replies LOGIN-typed
            let body = payload_json(p).unwrap();
            assert_eq!(body["success"], true);
            assert_eq!(body["characters"][0]["characterName"], "Nova");
        }
        _ => panic!("expected SendTo"),
    }
    assert!(crate::accounts::verify_login(&store, "newbie", "pwdpwd").is_some());
}

#[test]
fn select_character_kicks_duplicate_session() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a1 = addr(4);
    let a2 = addr(5);
    session_with(&mut m, a1, "test", Some("char_test_default"), _now);
    session_with(&mut m, a2, "test", None, _now);
    let pkt = packet_new(
        msg::SELECT_CHARACTER,
        Some(json!({"username": "test", "characterId": "char_test_default"})),
    );
    let actions = dispatch(&mut store, &mut m, a2, pkt);
    assert!(actions
        .iter()
        .any(|x| matches!(x, Action::Kick(addr) if *addr == a1)));
    assert!(actions
        .iter()
        .any(|x| matches!(x, Action::SendTo(t, p) if *t == a2 && p.msg_type == msg::SELECT_CHARACTER)));
    assert_eq!(
        m.sessions.get(&a2).unwrap().character_id.as_deref(),
        Some("char_test_default")
    );
}

#[test]
fn save_character_is_lenient() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a = addr(6);
    session_with(&mut m, a, "test", Some("char_test_default"), _now);
    let pkt = packet_new(
        msg::SAVE_CHARACTER,
        Some(json!({
            "username": "test",
            "character": {"id": "char_test_default", "hp": 42, "maxHp": 150}
        })),
    );
    let actions = dispatch(&mut store, &mut m, a, pkt);
    let body = match &actions[0] {
        Action::SendTo(_, p) => payload_json(p).unwrap(),
        _ => panic!("expected SendTo"),
    };
    assert_eq!(body["success"], true); // no level/exp required
    let chars = crate::accounts::verify_login(&store, "test", "123").unwrap();
    assert_eq!(chars[0]["hp"], 42);
    assert_eq!(chars[0]["level"], 5); // server-side field preserved
}

#[test]
fn battle_replies_sender_and_broadcasts_others() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a1 = addr(7);
    let a2 = addr(8);
    session_with(&mut m, a1, "test", Some("char_test_default"), _now);
    session_with(&mut m, a2, "admin", Some("char_admin_default"), _now);
    let pkt = packet_new(
        msg::BATTLE_ACTION,
        Some(json!({"username": "test", "action": "attack", "data": {"targetId": "slime"}})),
    );
    let actions = dispatch(&mut store, &mut m, a1, pkt);
    assert!(actions.iter().any(|x| matches!(x, Action::SendTo(t, _) if *t == a1)));
    assert!(actions
        .iter()
        .any(|x| matches!(x, Action::Broadcast(_, Some(ex)) if *ex == a1)));
}

#[test]
fn chat_broadcasts_to_everyone_including_sender() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a1 = addr(9);
    let a2 = addr(10);
    session_with(&mut m, a1, "test", None, _now);
    session_with(&mut m, a2, "admin", None, _now);
    let pkt = packet_new(
        msg::CHAT_MESSAGE,
        Some(json!({"username": "test", "message": "hello world"})),
    );
    let actions = dispatch(&mut store, &mut m, a1, pkt);
    assert_eq!(actions.len(), 1);
    match &actions[0] {
        Action::Broadcast(p, None) => {
            assert_eq!(p.msg_type, msg::CHAT_MESSAGE);
            let body = payload_json(p).unwrap();
            assert_eq!(body["message"], "hello world");
        }
        _ => panic!("expected plain broadcast"),
    }
}

#[test]
fn position_update_persists_without_reply() {
    let mut store = test_store();
    let mut m = manager_new();
    let _now = 1000;
    let a = addr(11);
    session_with(&mut m, a, "test", Some("char_test_default"), _now);
    let pkt = packet_new(
        msg::POSITION_UPDATE,
        Some(json!({"username": "test", "x": 123.0, "y": 456.0, "mapId": "town_01"})),
    );
    let actions = dispatch(&mut store, &mut m, a, pkt);
    assert!(actions.is_empty());
    let chars = crate::accounts::verify_login(&store, "test", "123").unwrap();
    assert_eq!(chars[0]["x"], 123.0);
    assert_eq!(chars[0]["mapId"], "town_01");
}

#[test]
fn kick_packet_is_force_reliable_error() {
    let pkt = crate::handlers::kick_packet();
    assert_eq!(pkt.msg_type, msg::ERROR);
    assert_eq!(pkt.flags, crate::constants::FLAG_FORCE_RELIABLE);
    let body = payload_json(&pkt).unwrap();
    assert_eq!(body["code"], 409);
    let bytes = crate::packet::pack_packet(&pkt);
    assert_eq!(bytes.len(), 13 + pkt.payload.len());
}
