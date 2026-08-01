//! Account and character CRUD operations on the JSON store.
//!
//! Characters are treated as opaque JSON values: client fields (classId,
//! skills, equipment, ...) pass through untouched. SAVE_CHARACTER is a
//! lenient upsert (no `level`/`exp` requirement; the Lua client schema has none).

use crate::constants::MAX_CHARACTERS_PER_ACCOUNT;
use crate::storage::{base_character, gen_id, hash_password, utc_now_iso, Account, Store};

pub fn verify_login(store: &Store, username: &str, password: &str) -> Option<Vec<serde_json::Value>> {
    let acc = store.accounts.get(username)?;
    if acc.password_hash != hash_password(password) {
        return None;
    }
    Some(acc.characters.clone())
}

pub fn note_login(store: &mut Store, username: &str) {
    if let Some(acc) = store.accounts.get_mut(username) {
        acc.last_login = Some(utc_now_iso());
        store.dirty = true;
    }
}

pub fn get_characters(store: &Store, username: &str) -> Option<Vec<serde_json::Value>> {
    store.accounts.get(username).map(|a| a.characters.clone())
}

pub fn get_character_by_id(
    store: &Store,
    username: &str,
    character_id: &str,
) -> Option<serde_json::Value> {
    store
        .accounts
        .get(username)?
        .characters
        .iter()
        .find(|c| c.get("id").and_then(|v| v.as_str()) == Some(character_id))
        .cloned()
}

fn validate_name(name: &str) -> Result<(), String> {
    if name.is_empty() {
        return Err("Character name is required".into());
    }
    let len = name.chars().count();
    if !(2..=20).contains(&len) {
        return Err("Character name must be 2-20 characters".into());
    }
    Ok(())
}

fn name_taken(store: &Store, name: &str) -> bool {
    let lower = name.to_lowercase();
    store.accounts.values().any(|a| {
        a.characters
            .iter()
            .any(|c| c.get("characterName").and_then(|v| v.as_str()).map(|n| n.to_lowercase() == lower).unwrap_or(false))
    })
}

fn default_new_character(character_name: &str) -> serde_json::Value {
    let mut ch = base_character();
    let obj = ch.as_object_mut().unwrap();
    obj.insert("id".into(), serde_json::json!(gen_id("char_")));
    obj.insert("characterName".into(), serde_json::json!(character_name));
    ch
}

/// Keys copied from client character data into a created character (passthrough).
const PASSTHROUGH_KEYS: &[&str] = &[
    "characterName", "classId", "avatarColor", "appearanceId", "skills",
    "skillCrystals", "critBonus", "equipment", "inventory", "spiritCrystals",
    "companions", "hp", "maxHp", "mp", "maxMp", "attack", "defense", "speed",
    "magicAttack", "level", "exp", "gold", "x", "y", "mapId",
];

pub fn create_account(
    store: &mut Store,
    username: &str,
    password: &str,
    character_name: Option<&str>,
) -> Result<Vec<serde_json::Value>, String> {
    let ulen = username.chars().count();
    if !(2..=20).contains(&ulen) {
        return Err("Username must be 2-20 characters".into());
    }
    if password.chars().count() < 3 {
        return Err("Password too short".into());
    }
    if store.accounts.contains_key(username) {
        return Err("Username already exists".into());
    }
    let name = character_name.unwrap_or(username).to_string();
    validate_name(&name)?;
    if name_taken(store, &name) {
        return Err("Character name already taken".into());
    }
    let mut ch = default_new_character(&name);
    ch.as_object_mut()
        .unwrap()
        .insert("avatarColor".into(), serde_json::json!([0.2, 0.6, 1.0]));
    let acc = Account {
        username: username.into(),
        password_hash: hash_password(password),
        characters: vec![ch],
        created_at: utc_now_iso(),
        last_login: Some(utc_now_iso()),
    };
    store.accounts.insert(username.into(), acc);
    store.dirty = true;
    Ok(store.accounts.get(username).unwrap().characters.clone())
}

pub fn create_character(
    store: &mut Store,
    username: &str,
    data: &serde_json::Value,
) -> Result<serde_json::Value, String> {
    if !store.accounts.contains_key(username) {
        return Err("Account not found".into());
    }
    let name = data
        .get("characterName")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();
    validate_name(&name)?;
    if name_taken(store, &name) {
        return Err("Character name already taken".into());
    }
    let acc = store.accounts.get_mut(username).expect("checked above");
    if acc.characters.len() >= MAX_CHARACTERS_PER_ACCOUNT {
        return Err("Maximum 10 characters allowed".into());
    }
    let mut ch = default_new_character(&name);
    if let Some(obj) = ch.as_object_mut() {
        for key in PASSTHROUGH_KEYS {
            if let Some(v) = data.get(*key) {
                obj.insert((*key).into(), v.clone());
            }
        }
    }
    acc.characters.push(ch.clone());
    store.dirty = true;
    Ok(ch)
}

/// Lenient upsert: no `level`/`exp` requirement (the Lua client schema has none).
/// Merges client fields over the stored character, preserving server fields
/// (id, level, exp, gold) and saving into characters[0] when no id is given.
pub fn save_character(
    store: &mut Store,
    username: &str,
    data: &serde_json::Value,
) -> Result<(), String> {
    let Some(acc) = store.accounts.get_mut(username) else {
        return Err("Account not found".into());
    };
    if acc.characters.is_empty() {
        return Err("No character to save".into());
    }
    let id = data.get("id").and_then(|v| v.as_str());
    let idx = match id {
        Some(cid) => acc
            .characters
            .iter()
            .position(|c| c.get("id").and_then(|v| v.as_str()) == Some(cid))
            .ok_or_else(|| "Character not found".to_string())?,
        None => 0,
    };
    let base = acc.characters[idx].clone();
    let mut merged = base;
    if let Some(src) = data.as_object() {
        if let Some(dst) = merged.as_object_mut() {
            for (k, v) in src {
                if k != "id" {
                    dst.insert(k.clone(), v.clone());
                }
            }
        }
    }
    acc.characters[idx] = merged;
    store.dirty = true;
    Ok(())
}

pub fn delete_character(
    store: &mut Store,
    username: &str,
    character_id: &str,
) -> Result<(), String> {
    let Some(acc) = store.accounts.get_mut(username) else {
        return Err("Account not found".into());
    };
    if acc.characters.len() <= 1 {
        return Err("Cannot delete the last character".into());
    }
    let before = acc.characters.len();
    acc.characters.retain(|c| c.get("id").and_then(|v| v.as_str()) != Some(character_id));
    if acc.characters.len() == before {
        return Err("Character not found".into());
    }
    store.dirty = true;
    Ok(())
}

/// Persist a position update for the session's selected character
/// (falls back to the first character). Returns false when unknown.
pub fn update_position(
    store: &mut Store,
    username: &str,
    character_id: Option<&str>,
    x: f64,
    y: f64,
    map_id: &str,
) -> bool {
    let Some(acc) = store.accounts.get_mut(username) else {
        return false;
    };
    let idx = match character_id {
        Some(cid) => acc
            .characters
            .iter()
            .position(|c| c.get("id").and_then(|v| v.as_str()) == Some(cid)),
        None => None,
    }
    .unwrap_or(0);
    let Some(ch) = acc.characters.get_mut(idx) else {
        return false;
    };
    if let Some(obj) = ch.as_object_mut() {
        obj.insert("x".into(), serde_json::json!(x));
        obj.insert("y".into(), serde_json::json!(y));
        obj.insert("mapId".into(), serde_json::json!(map_id));
    }
    store.dirty = true;
    true
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;
    use crate::storage::{load, migrate_legacy, store_new, Store};

    fn temp_store_path(tag: &str) -> String {
        let dir = std::env::temp_dir().join(format!("game_server_accounts_{}", tag));
        let _ = std::fs::remove_file(&dir);
        dir.to_str().unwrap().to_string()
    }

    #[test]
    fn seeds_documented_default_accounts() {
        let store = load(&temp_store_path("defaults"));
        assert!(verify_login(&store, "test", "123").is_some());
        assert!(verify_login(&store, "admin", "admin").is_some());
        assert!(verify_login(&store, "player", "pass").is_some());
        assert!(verify_login(&store, "test", "wrong").is_none());
        let chars = verify_login(&store, "test", "123").unwrap();
        assert_eq!(chars.len(), 1);
        assert_eq!(chars[0]["characterName"], "Test Hero");
        assert_eq!(chars[0]["level"], 5);
        let admin_chars = verify_login(&store, "admin", "admin").unwrap();
        assert_eq!(admin_chars.len(), 2);
    }

    #[test]
    fn create_account_validations() {
        let mut store = store_new(HashMap::new());
        assert!(create_account(&mut store, "a", "123", None).is_err()); // name too short
        assert!(create_account(&mut store, "okname", "12", None).is_err()); // pw too short
        assert!(create_account(&mut store, "okname", "123", None).is_ok());
        assert!(create_account(&mut store, "okname", "456", None).is_err()); // duplicate
        assert!(verify_login(&store, "okname", "123").is_some());
    }

    #[test]
    fn create_character_rules() {
        let mut store = store_new(HashMap::new());
        create_account(&mut store, "hero", "pwdpwd", None).unwrap();
        let data = serde_json::json!({
            "characterName": "Blade",
            "classId": "duelist",
            "avatarColor": [0.9, 0.1, 0.1],
            "skills": [{"id": "sword_dance", "level": 1, "unlocked": true}],
        });
        let ch = create_character(&mut store, "hero", &data).unwrap();
        assert_eq!(ch["classId"], "duelist");
        assert_eq!(ch["skills"][0]["id"], "sword_dance");
        assert!(create_character(&mut store, "hero", &data).is_err()); // name taken
        assert!(create_character(&mut store, "nobody", &data).is_err()); // no account
    }

    #[test]
    fn save_is_lenient_without_level() {
        let mut store = load(&temp_store_path("lenient"));
        let data = serde_json::json!({
            "id": "char_test_default",
            "characterName": "Test Hero",
            "hp": 90, "maxHp": 150,
            "classId": "warrior",
            "skills": [{"id": "power_slash", "level": 2}],
        });
        assert!(save_character(&mut store, "test", &data).is_ok());
        let chars = verify_login(&store, "test", "123").unwrap();
        assert_eq!(chars[0]["hp"], 90);
        assert_eq!(chars[0]["classId"], "warrior");
        assert_eq!(chars[0]["level"], 5); // server field preserved
        assert_eq!(chars[0]["id"], "char_test_default");
    }

    #[test]
    fn delete_last_character_blocked() {
        let mut store = load(&temp_store_path("delete"));
        assert!(delete_character(&mut store, "test", "char_test_default").is_err());
        let admin = verify_login(&store, "admin", "admin").unwrap();
        let alt_id = admin[1]["id"].as_str().unwrap().to_string();
        assert!(delete_character(&mut store, "admin", &alt_id).is_ok());
        assert_eq!(verify_login(&store, "admin", "admin").unwrap().len(), 1);
    }

    #[test]
    fn migrates_legacy_character_key() {
        let legacy = serde_json::json!({
            "test": {
                "username": "test",
                "password_hash": hash_password("123"),
                "character": {"characterName": "Old Hero", "level": 3},
                "created_at": "", "last_login": null
            }
        });
        let migrated = migrate_legacy(legacy);
        let store: Store = Store {
            accounts: serde_json::from_value(migrated).unwrap(),
            dirty: false,
        };
        let chars = verify_login(&store, "test", "123").unwrap();
        assert_eq!(chars.len(), 1);
        assert_eq!(chars[0]["characterName"], "Old Hero");
        assert!(chars[0].get("id").is_some()); // id assigned
    }

    #[test]
    fn position_update_persists() {
        let mut store = load(&temp_store_path("position"));
        assert!(update_position(
            &mut store,
            "test",
            Some("char_test_default"),
            100.0,
            200.0,
            "town_01"
        ));
        let chars = verify_login(&store, "test", "123").unwrap();
        assert_eq!(chars[0]["x"], 100.0);
        assert_eq!(chars[0]["mapId"], "town_01");
    }

    #[test]
    fn utc_timestamp_format() {
        let t = utc_now_iso();
        assert_eq!(t.len(), 20);
        assert!(t.ends_with('Z'));
    }
}
