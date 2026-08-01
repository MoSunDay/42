//! Request handlers: pure dispatch from packet type to store/session mutations
//! and a list of outbound actions applied by the main loop.
//!
//! Response conventions (matching the Lua client):
//! - LOGIN and REGISTER both answer with a LOGIN-typed `{success, characters}`
//! - SELECT/CREATE/DELETE/SAVE answer with their own type + `{success, ...}`
//! - BATTLE_ACTION answers the sender and broadcasts to other sessions
//! - CHAT_MESSAGE broadcasts to all sessions
//! - POSITION_UPDATE is persisted and never answered

use std::net::SocketAddr;

use serde_json::{json, Value};

use crate::constants::{msg, FLAG_FORCE_RELIABLE, MAX_CHAT_LENGTH};
use crate::packet::{json_payload, payload_json, Packet};
use crate::rudp::{find_duplicate_session, Manager};
use crate::storage::Store;

/// Outbound action produced by a handler.
pub enum Action {
    /// Reliably deliver to a specific session.
    SendTo(SocketAddr, Packet),
    /// Reliably deliver to every session except the optional address.
    Broadcast(Packet, Option<SocketAddr>),
    /// Send ERROR 409 (force-reliable) and drop the old duplicate session.
    Kick(SocketAddr),
}

fn reply(sender: SocketAddr, msg_type: u8, body: Value) -> Vec<Action> {
    vec![Action::SendTo(
        sender,
        Packet {
            msg_type,
            seq: 0,
            ack: 0,
            ack_mask: 0,
            flags: 0,
            payload: json_payload(&body),
        },
    )]
}

fn payload_of(pkt: &Packet) -> Value {
    payload_json(pkt).unwrap_or_else(|| json!({}))
}

fn str_of(v: &Value, key: &str) -> String {
    v.get(key).and_then(|x| x.as_str()).unwrap_or("").to_string()
}

/// Route one decoded packet to its handler.
pub fn dispatch(
    store: &mut Store,
    manager: &mut Manager,
    sender: SocketAddr,
    pkt: Packet,
) -> Vec<Action> {
    match pkt.msg_type {
        msg::LOGIN => handle_login(store, manager, sender, &pkt),
        msg::REGISTER => handle_register(store, manager, sender, &pkt),
        msg::LOGOUT => handle_logout(manager, sender, &pkt),
        msg::LIST_CHARACTERS => handle_list_characters(store, sender, &pkt),
        msg::GET_CHARACTER => handle_get_character(store, sender, &pkt),
        msg::SELECT_CHARACTER => handle_select_character(store, manager, sender, &pkt),
        msg::CREATE_CHARACTER => handle_create_character(store, sender, &pkt),
        msg::DELETE_CHARACTER => handle_delete_character(store, sender, &pkt),
        msg::SAVE_CHARACTER => handle_save_character(store, sender, &pkt),
        msg::POSITION_UPDATE => handle_position_update(store, manager, sender, &pkt),
        msg::BATTLE_ACTION => handle_battle_action(manager, sender, &pkt),
        msg::CHAT_MESSAGE => handle_chat_message(manager, sender, &pkt),
        _ => Vec::new(),
    }
}

fn handle_login(store: &mut Store, manager: &mut Manager, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let password = str_of(&payload, "password");
    if username.is_empty() || password.is_empty() {
        return reply(sender, msg::LOGIN, json!({"success": false, "error": "Missing credentials"}));
    }
    match crate::accounts::verify_login(store, &username, &password) {
        Some(characters) => {
            crate::accounts::note_login(store, &username);
            if let Some(s) = manager.sessions.get_mut(&sender) {
                s.username = Some(username.clone());
                s.character_id = None;
            }
            reply(
                sender,
                msg::LOGIN,
                json!({"success": true, "characters": characters}),
            )
        }
        None => {
            if let Some(s) = manager.sessions.get_mut(&sender) {
                s.username = None;
                s.character_id = None;
            }
            reply(
                sender,
                msg::LOGIN,
                json!({"success": false, "error": "Invalid username or password"}),
            )
        }
    }
}

fn handle_register(store: &mut Store, manager: &mut Manager, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let password = str_of(&payload, "password");
    if username.is_empty() || password.is_empty() {
        return reply(sender, msg::LOGIN, json!({"success": false, "error": "Missing credentials"}));
    }
    let char_name = payload.get("characterName").and_then(|v| v.as_str());
    match crate::accounts::create_account(store, &username, &password, char_name) {
        Ok(characters) => {
            if let Some(s) = manager.sessions.get_mut(&sender) {
                s.username = Some(username);
                s.character_id = None;
            }
            reply(
                sender,
                msg::LOGIN,
                json!({"success": true, "characters": characters}),
            )
        }
        Err(e) => reply(sender, msg::LOGIN, json!({"success": false, "error": e})),
    }
}

fn handle_logout(manager: &mut Manager, sender: SocketAddr, _pkt: &Packet) -> Vec<Action> {
    if let Some(s) = manager.sessions.get_mut(&sender) {
        s.username = None;
        s.character_id = None;
    }
    reply(sender, msg::LOGOUT, json!({"success": true}))
}

fn handle_list_characters(store: &Store, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    if username.is_empty() {
        return reply(sender, msg::LIST_CHARACTERS, json!({"error": "Missing username"}));
    }
    let characters = crate::accounts::get_characters(store, &username).unwrap_or_default();
    reply(sender, msg::LIST_CHARACTERS, json!({"characters": characters}))
}

fn handle_get_character(store: &Store, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let character = crate::accounts::get_characters(store, &username)
        .and_then(|c| c.into_iter().next());
    match character {
        Some(ch) => reply(sender, msg::GET_CHARACTER, json!({"success": true, "character": ch})),
        None => reply(
            sender,
            msg::GET_CHARACTER,
            json!({"success": false, "error": "Character not found"}),
        ),
    }
}

fn handle_select_character(
    store: &Store,
    manager: &mut Manager,
    sender: SocketAddr,
    pkt: &Packet,
) -> Vec<Action> {
    let payload = payload_of(pkt);
    let mut username = str_of(&payload, "username");
    let character_id = str_of(&payload, "characterId");
    if character_id.is_empty() {
        return reply(
            sender,
            msg::SELECT_CHARACTER,
            json!({"success": false, "error": "Missing characterId"}),
        );
    }
    if username.is_empty() {
        if let Some(s) = manager.sessions.get(&sender) {
            if let Some(u) = &s.username {
                username = u.clone();
            }
        }
    }
    if username.is_empty() {
        return reply(
            sender,
            msg::SELECT_CHARACTER,
            json!({"success": false, "error": "Not logged in"}),
        );
    }
    let character = crate::accounts::get_character_by_id(store, &username, &character_id);
    let Some(ch) = character else {
        return reply(
            sender,
            msg::SELECT_CHARACTER,
            json!({"success": false, "error": "Character not found"}),
        );
    };
    let mut actions = Vec::new();
    if let Some(old) = find_duplicate_session(manager, &username, &character_id, sender) {
        actions.push(Action::Kick(old));
    }
    if let Some(s) = manager.sessions.get_mut(&sender) {
        s.username = Some(username);
        s.character_id = Some(character_id);
    }
    actions.push(Action::SendTo(
        sender,
        Packet {
            msg_type: msg::SELECT_CHARACTER,
            seq: 0,
            ack: 0,
            ack_mask: 0,
            flags: 0,
            payload: json_payload(&json!({"success": true, "character": ch})),
        },
    ));
    actions
}

fn handle_create_character(store: &mut Store, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let character = payload.get("character").cloned().unwrap_or_else(|| json!({}));
    if username.is_empty() || character.is_null() {
        return reply(
            sender,
            msg::CREATE_CHARACTER,
            json!({"success": false, "error": "Missing character data"}),
        );
    }
    match crate::accounts::create_character(store, &username, &character) {
        Ok(ch) => reply(
            sender,
            msg::CREATE_CHARACTER,
            json!({"success": true, "character": ch}),
        ),
        Err(e) => reply(sender, msg::CREATE_CHARACTER, json!({"success": false, "error": e})),
    }
}

fn handle_delete_character(store: &mut Store, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let character_id = str_of(&payload, "characterId");
    if username.is_empty() || character_id.is_empty() {
        return reply(
            sender,
            msg::DELETE_CHARACTER,
            json!({"success": false, "error": "Missing character data"}),
        );
    }
    match crate::accounts::delete_character(store, &username, &character_id) {
        Ok(()) => reply(sender, msg::DELETE_CHARACTER, json!({"success": true})),
        Err(e) => reply(
            sender,
            msg::DELETE_CHARACTER,
            json!({"success": false, "error": e}),
        ),
    }
}

fn handle_save_character(store: &mut Store, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let character = payload.get("character").cloned().unwrap_or_else(|| json!({}));
    if username.is_empty() || character.is_null() {
        return reply(
            sender,
            msg::SAVE_CHARACTER,
            json!({"success": false, "error": "Missing character data"}),
        );
    }
    match crate::accounts::save_character(store, &username, &character) {
        Ok(()) => reply(
            sender,
            msg::SAVE_CHARACTER,
            json!({"success": true, "message": "Character saved"}),
        ),
        Err(e) => reply(sender, msg::SAVE_CHARACTER, json!({"success": false, "error": e})),
    }
}

fn handle_position_update(
    store: &mut Store,
    manager: &Manager,
    sender: SocketAddr,
    pkt: &Packet,
) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let x = payload.get("x").and_then(|v| v.as_f64()).unwrap_or(0.0);
    let y = payload.get("y").and_then(|v| v.as_f64()).unwrap_or(0.0);
    let map_id = str_of(&payload, "mapId");
    if username.is_empty() {
        return Vec::new();
    }
    let character_id = manager
        .sessions
        .get(&sender)
        .and_then(|s| s.character_id.clone());
    crate::accounts::update_position(store, &username, character_id.as_deref(), x, y, &map_id);
    Vec::new()
}

fn handle_battle_action(_manager: &Manager, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let action = str_of(&payload, "action");
    if username.is_empty() || action.is_empty() {
        return reply(
            sender,
            msg::BATTLE_ACTION,
            json!({"success": false, "error": "Missing action data"}),
        );
    }
    let data = payload.get("data").cloned().unwrap_or_else(|| json!({}));
    let body = json!({"success": true, "action": action, "username": username, "data": data});
    vec![
        Action::SendTo(
            sender,
            Packet {
                msg_type: msg::BATTLE_ACTION,
                seq: 0,
                ack: 0,
                ack_mask: 0,
                flags: 0,
                payload: json_payload(&body),
            },
        ),
        Action::Broadcast(
            Packet {
                msg_type: msg::BATTLE_ACTION,
                seq: 0,
                ack: 0,
                ack_mask: 0,
                flags: 0,
                payload: json_payload(&body),
            },
            Some(sender),
        ),
    ]
}

fn handle_chat_message(_manager: &Manager, sender: SocketAddr, pkt: &Packet) -> Vec<Action> {
    let payload = payload_of(pkt);
    let username = str_of(&payload, "username");
    let message = str_of(&payload, "message");
    if username.is_empty() || message.is_empty() {
        return reply(
            sender,
            msg::CHAT_MESSAGE,
            json!({"success": false, "error": "Missing chat data"}),
        );
    }
    if message.chars().count() > MAX_CHAT_LENGTH {
        return reply(
            sender,
            msg::CHAT_MESSAGE,
            json!({"success": false, "error": "Message too long"}),
        );
    }
    let body = json!({"username": username, "message": message});
    vec![Action::Broadcast(
        Packet {
            msg_type: msg::CHAT_MESSAGE,
            seq: 0,
            ack: 0,
            ack_mask: 0,
            flags: 0,
            payload: json_payload(&body),
        },
        None,
    )]
}

/// Build the ERROR 409 kick packet (force-reliable so the victim reliably
/// receives the kick even though ERROR is normally fire-and-forget).
pub fn kick_packet() -> Packet {
    Packet {
        msg_type: msg::ERROR,
        seq: 0,
        ack: 0,
        ack_mask: 0,
        flags: FLAG_FORCE_RELIABLE,
        payload: json_payload(&json!({"code": 409, "message": "Kicked: Logged in from another location"})),
    }
}
