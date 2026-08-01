//! Protocol and runtime constants for the RUDP game server.
#![allow(dead_code)]

pub const PROTOCOL_VERSION: u32 = 1;
pub const DEFAULT_PORT: u16 = 9000;
pub const BUFFER_SIZE: usize = 4096;
pub const HEADER_SIZE: usize = 13;
pub const MAX_RETRIES: u32 = 5;
pub const RETRY_TIMEOUT_MS: u64 = 500;
pub const HEARTBEAT_INTERVAL_MS: u64 = 5000;
pub const CONNECTION_TIMEOUT_MS: u64 = 30_000;
pub const RECV_WINDOW_SIZE: u64 = 64;
pub const MAX_CHARACTERS_PER_ACCOUNT: usize = 10;
pub const MAX_CHAT_LENGTH: usize = 200;
pub const TICK_MS: u64 = 10;

/// flags bit 0x01 forces reliability even for normally-unreliable packet types.
pub const FLAG_FORCE_RELIABLE: u8 = 0x01;

pub const DATA_DIR: &str = "data";
pub const ACCOUNTS_FILE: &str = "data/accounts.json";

/// Packet type ids (mirror the Lua `PacketType` enum and legacy Python constants).
pub mod msg {
    pub const NONE: u8 = 0;
    pub const LOGIN: u8 = 1;
    pub const REGISTER: u8 = 2;
    pub const LOGOUT: u8 = 3;
    pub const GET_CHARACTER: u8 = 10;
    pub const SAVE_CHARACTER: u8 = 11;
    pub const CREATE_CHARACTER: u8 = 12;
    pub const LIST_CHARACTERS: u8 = 13;
    pub const SELECT_CHARACTER: u8 = 14;
    pub const DELETE_CHARACTER: u8 = 15;
    pub const POSITION_UPDATE: u8 = 20;
    pub const BATTLE_ACTION: u8 = 21;
    pub const CHAT_MESSAGE: u8 = 30;
    pub const HEARTBEAT: u8 = 50;
    pub const ACK: u8 = 51;
    pub const NACK: u8 = 52;
    pub const ERROR: u8 = 100;
}

/// True for request/response packet types that must be acknowledged.
pub fn msg_is_reliable(t: u8) -> bool {
    matches!(
        t,
        msg::LOGIN
            | msg::REGISTER
            | msg::LOGOUT
            | msg::GET_CHARACTER
            | msg::SAVE_CHARACTER
            | msg::CREATE_CHARACTER
            | msg::LIST_CHARACTERS
            | msg::SELECT_CHARACTER
            | msg::DELETE_CHARACTER
            | msg::BATTLE_ACTION
            | msg::CHAT_MESSAGE
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reliability_table_matches_lua_client() {
        assert!(msg_is_reliable(msg::LOGIN));
        assert!(msg_is_reliable(msg::REGISTER));
        assert!(msg_is_reliable(msg::SAVE_CHARACTER));
        assert!(msg_is_reliable(msg::CHAT_MESSAGE));
        assert!(!msg_is_reliable(msg::POSITION_UPDATE));
        assert!(!msg_is_reliable(msg::HEARTBEAT));
        assert!(!msg_is_reliable(msg::ACK));
        assert!(!msg_is_reliable(msg::ERROR));
    }
}
