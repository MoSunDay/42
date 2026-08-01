//! JSON file storage for accounts and characters (data/accounts.json).
//!
//! The account schema mirrors the legacy Python store, with the legacy
//! `character` (singular) key migrated to `characters`. Characters are kept as
//! opaque JSON values so client fields (classId, skills, equipment, ...)
//! pass through untouched. Default accounts are seeded only when the file is
//! absent; passwords are hashed with sha256 at runtime.

use std::collections::HashMap;
use std::path::Path;
use std::sync::atomic::{AtomicU64, Ordering};

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};


static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Account {
    pub username: String,
    pub password_hash: String,
    #[serde(default)]
    pub characters: Vec<serde_json::Value>,
    #[serde(default)]
    pub created_at: String,
    #[serde(default)]
    pub last_login: Option<String>,
}

/// In-memory store; `dirty` triggers a disk flush by the main loop.
#[derive(Debug)]
pub struct Store {
    pub accounts: HashMap<String, Account>,
    pub dirty: bool,
}

pub fn store_new(accounts: HashMap<String, Account>) -> Store {
    Store {
        accounts,
        dirty: false,
    }
}

/// sha256 hex digest (same scheme as the legacy Python server).
pub fn hash_password(password: &str) -> String {
    format!("{:x}", Sha256::digest(password.as_bytes()))
}

/// Read the store from disk; seeds default accounts when absent, migrates the
/// legacy `character` key, and assigns ids to characters missing one.
pub fn load(path: &str) -> Store {
    if !Path::new(path).exists() {
        return store_new(default_accounts());
    }
    let text = match std::fs::read_to_string(path) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("storage: cannot read {} ({}), seeding defaults", path, e);
            return store_new(default_accounts());
        }
    };
    let root: serde_json::Value = match serde_json::from_str(&text) {
        Ok(v) => v,
        Err(e) => {
            eprintln!("storage: invalid JSON in {} ({}), seeding defaults", path, e);
            return store_new(default_accounts());
        }
    };
    let migrated = migrate_legacy(root);
    let accounts: HashMap<String, Account> =
        serde_json::from_value(migrated).unwrap_or_default();
    store_new(accounts)
}

/// Convert a legacy accounts.json value into the current schema.
pub(crate) fn migrate_legacy(root: serde_json::Value) -> serde_json::Value {
    let mut root = root;
    if let Some(obj) = root.as_object_mut() {
        for acc in obj.values_mut() {
            let Some(acc_obj) = acc.as_object_mut() else { continue };
            if let Some(legacy) = acc_obj.remove("character") {
                if !acc_obj.contains_key("characters") {
                    let chars = if legacy.is_array() {
                        legacy
                    } else {
                        serde_json::json!([legacy])
                    };
                    acc_obj.insert("characters".into(), chars);
                }
            }
            if let Some(chars) = acc_obj.get_mut("characters").and_then(|c| c.as_array_mut()) {
                for ch in chars.iter_mut() {
                    if let Some(o) = ch.as_object_mut() {
                        if !o.contains_key("id") {
                            o.insert("id".into(), serde_json::json!(gen_id("char_")));
                        }
                    }
                }
            }
        }
    }
    root
}

pub fn save(store: &Store, path: &str) {
    if !store.dirty {
        return;
    }
    if let Some(dir) = Path::new(path).parent() {
        let _ = std::fs::create_dir_all(dir);
    }
    let data = serde_json::to_string_pretty(&store.accounts).unwrap_or_default();
    match std::fs::write(path, data) {
        Ok(()) => (),
        Err(e) => eprintln!("storage: save failed: {}", e),
    }
}

/// UTC ISO-8601 timestamp (no external chrono dependency).
pub fn utc_now_iso() -> String {
    let secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    let days = (secs / 86400) as i64;
    let rem = secs % 86400;
    let (y, m, d) = civil_from_days(days);
    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z",
        y,
        m,
        d,
        rem / 3600,
        (rem % 3600) / 60,
        rem % 60
    )
}

/// Howard Hinnant's days-to-civil algorithm.
fn civil_from_days(z: i64) -> (i64, u32, u32) {
    let z = z + 719_468;
    let era = if z >= 0 { z } else { z - 146_096 } / 146_097;
    let doe = (z - era * 146_097) as u64;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = (doy - (153 * mp + 2) / 5 + 1) as u32;
    let m = if mp < 10 { mp + 3 } else { mp - 9 } as u32;
    (if m <= 2 { y + 1 } else { y }, m, d)
}

/// Short unique id (timestamp + process counter), like the legacy char_xxx ids.
pub fn gen_id(prefix: &str) -> String {
    let secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    let n = ID_COUNTER.fetch_add(1, Ordering::Relaxed);
    format!("{}{:08x}{:04x}", prefix, secs, n)
}

/// Default characters per the project README test accounts.
fn default_accounts() -> HashMap<String, Account> {
    let test_pass = std::env::var("GAME_TEST_PASSWORD").unwrap_or_else(|_| "123".into());
    let admin_pass = std::env::var("GAME_ADMIN_PASSWORD").unwrap_or_else(|_| "admin".into());
    let player_pass = std::env::var("GAME_PLAYER_PASSWORD").unwrap_or_else(|_| "pass".into());
    let now = utc_now_iso();
    let mut map = HashMap::new();
    map.insert(
        "test".into(),
        Account {
            username: "test".into(),
            password_hash: hash_password(&test_pass),
            characters: vec![test_hero()],
            created_at: now.clone(),
            last_login: None,
        },
    );
    map.insert(
        "admin".into(),
        Account {
            username: "admin".into(),
            password_hash: hash_password(&admin_pass),
            characters: vec![admin_hero(), admin_alt()],
            created_at: now.clone(),
            last_login: None,
        },
    );
    map.insert(
        "player".into(),
        Account {
            username: "player".into(),
            password_hash: hash_password(&player_pass),
            characters: vec![player_hero()],
            created_at: now,
            last_login: None,
        },
    );
    map
}

pub(crate) fn base_character() -> serde_json::Value {
    serde_json::json!({
        "level": 1, "exp": 0, "gold": 100,
        "hp": 100, "maxHp": 100, "attack": 15, "defense": 5, "speed": 6,
        "x": 1600, "y": 1600, "mapId": "newbie_village",
        "avatarColor": [0.2, 0.6, 1.0],
    })
}

fn test_hero() -> serde_json::Value {
    serde_json::json!({
        "id": "char_test_default", "characterName": "Test Hero",
        "level": 5, "exp": 50, "gold": 500,
        "hp": 150, "maxHp": 150, "attack": 25, "defense": 10, "speed": 6,
        "x": 1600, "y": 1600, "mapId": "newbie_village",
        "avatarColor": [0.3, 0.5, 1.0],
    })
}

fn admin_hero() -> serde_json::Value {
    serde_json::json!({
        "id": "char_admin_default", "characterName": "Admin",
        "level": 10, "exp": 0, "gold": 9999,
        "hp": 300, "maxHp": 300, "attack": 50, "defense": 20, "speed": 8,
        "x": 2400, "y": 2100, "mapId": "four_seasons_city",
        "avatarColor": [1.0, 0.8, 0.2],
    })
}

fn admin_alt() -> serde_json::Value {
    serde_json::json!({
        "id": "char_admin_alt", "characterName": "Admin Alt",
        "level": 8, "exp": 120, "gold": 2500,
        "hp": 240, "maxHp": 240, "attack": 40, "defense": 16, "speed": 9,
        "x": 2400, "y": 2100, "mapId": "four_seasons_city",
        "avatarColor": [0.6, 0.4, 0.9],
    })
}

fn player_hero() -> serde_json::Value {
    serde_json::json!({
        "id": "char_player_default", "characterName": "Player Hero",
        "level": 1, "exp": 0, "gold": 100,
        "hp": 100, "maxHp": 100, "attack": 15, "defense": 5, "speed": 6,
        "x": 1600, "y": 1600, "mapId": "newbie_village",
        "avatarColor": [0.2, 0.6, 1.0],
    })
}
