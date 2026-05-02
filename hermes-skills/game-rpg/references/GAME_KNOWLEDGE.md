# Game Knowledge Reference

## 1. Game Overview

| Property | Value |
|----------|-------|
| Resolution | 1280×720 |
| Frame Rate | 60 FPS, VSync |
| Engine | LOVE2D 11.4 (Lua) |
| Server | Python Sanic 23.12.1 |
| Exploration | Top-down 2D |
| Battle | Turn-based |

**State Flow:** `login → character_select → exploration → battle`

## 2. Classes

6 classes in 2 categories (Warrior / Mage).

### Warrior

| Class | Role | Passive Bonuses |
|-------|------|-----------------|
| Dual Blade | Physical AOE + single target hybrid | +15% SPD, +10% CRIT |
| Great Sword | Single target physical burst | +20% ATK, +5% CRIT |
| Blade Master | Physical AOE tank | +30% MaxHP, +20% DEF |

### Mage

| Class | Role | Passive Bonuses |
|-------|------|-----------------|
| Sealer | Control mage | +25% DEF, +20% MaxHP, +15% SPD |
| Healer | Healing support | +20% DEF, +25% MaxHP, +10% SPD |
| Elementalist | AOE magic | +25% MATK, -20% SPD |

## 3. Skills

18 total skills (3 per class).

### Dual Blade

| Skill | Tier | Type | Effect | Targets | MP Cost |
|-------|------|------|--------|---------|---------|
| Whirlwind | 1 | AOE | 120% ATK | 2-3 | 15 |
| Shadow Blade | 2 | AOE | 150% ATK +10% CRIT | 2-3 | 25 |
| Phantom Slash | 2 | Single | 200% ATK | 1 | 20 |
| Storm Blade | 3 | AOE | 180% ATK +20% SPD | 2-3 | 35 |

### Great Sword

| Skill | Tier | Type | Effect | Targets | MP Cost |
|-------|------|------|--------|---------|---------|
| Heavy Strike | 1 | Single | 150% ATK | 1 | 12 |
| Mountain Breaker | 2 | Single | 220% ATK -15% DEF | 1 | 25 |
| World Slash | 3 | Single | 350% ATK +25% CRIT | 1 | 45 |

### Blade Master

| Skill | Tier | Type | Effect | Targets | MP Cost |
|-------|------|------|--------|---------|---------|
| Sweep | 1 | AOE | 100% ATK | 3 | 18 |
| Sword Aura | 2 | AOE | 130% ATK | 3 | 28 |
| Heaven Blade | 3 | AOE | 180% ATK +10% DEF | 3 | 40 |

### Sealer

| Skill | Tier | Type | Effect | Targets | MP Cost |
|-------|------|------|--------|---------|---------|
| Bind Curse | 1 | Seal | Cannot act 1 turn | 1 | 20 |
| Silence | 2 | Seal | No skills 2 turns | 1 | 25 |
| Confusion | 3 | Seal | Random targeting 2 turns | 1 | 35 |

### Healer

| Skill | Tier | Type | Effect | Targets | MP Cost |
|-------|------|------|--------|---------|---------|
| Heal | 1 | Heal | 30% MaxHP | Self | 15 |
| Group Heal | 2 | Heal | 20% MaxHP | All allies | 30 |
| Revival Light | 3 | Heal | 50% HP + cleanse | Self | 45 |

### Elementalist

| Skill | Tier | Type | Effect | Targets | MP Cost |
|-------|------|------|--------|---------|---------|
| Fire Storm | 1 | AOE | 140% MATK, burn 2 turns | 3-4 | 30 |
| Ice Fall | 2 | AOE | 120% MATK, -20% SPD | 3-4 | 28 |
| Thunder Strike | 3 | AOE | 160% MATK, 30% stun | 3-4 | 40 |

## 4. Skill Upgrade System

| Tier | Unlock Cost |
|------|-------------|
| 1 | Free |
| 2 | 100 Spirit Crystals |
| 3 | 250 Spirit Crystals |

- **Level-up cost formula:** `40 × level × (1 + 0.08 × level)`
- **Effectiveness per level:** +3%
- **Multiplier formula:** `base × (1 + 0.03 × (level - 1))`

## 5. Maps

| ID | Name | Theme | Level Range | Notes |
|----|------|-------|-------------|-------|
| trial_of_awakening | 觉醒者试炼 | ruins | Lv 1-3 | Dungeon / tutorial |
| generated_01_woods | Whispering Woods | forest | Lv 1-5 | |
| generated_02_desert | Scorching Dunes | desert | Lv 5-10 | |
| generated_03_snow | Frozen Peaks | snow | Lv 10-15 | |
| generated_04_volcanic | Ember Caldera | volcanic | Lv 15-20 | |
| generated_05_cave | Crystal Depths | cave | Lv 20-25 | |
| generated_06_sky | Celestial Gardens | sky | Lv 25-30 | |
| generated_07_swamp | Murkmire Marsh | swamp | Lv 30-35 | |
| generated_08_crystal | Prism Cavern | crystal | Lv 35-40 | |
| generated_09_ruins | Ancient Citadel | ruins | Lv 40-45 | |
| generated_10_realm | Dreamweaver's Realm | mystical | Lv 50 | |

## 6. Monsters by Region

### BASIC (Trial / Woods)

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Slime | 30 | 5 | 2 | 3 | N | — |
| Goblin | 50 | 8 | 3 | 5 | Y | — |
| Skeleton | 40 | 10 | 1 | 4 | Y | — |
| Orc | 80 | 12 | 5 | 3 | Y | — |
| Wolf | 45 | 9 | 2 | 7 | Y | — |
| Bat | 25 | 6 | 1 | 8 | N | — |

### DESERT

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Scorpion | 55 | 12 | 4 | 5 | Y | — |
| Sandworm | 80 | 15 | 6 | 4 | Y | — |
| Mummy | 70 | 14 | 8 | 3 | Y | — |

### SNOW

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Ice Wolf | 60 | 12 | 4 | 7 | Y | — |
| Yeti | 120 | 20 | 10 | 4 | Y | — |
| Frost Giant | 180 | 25 | 15 | 3 | Y | — |

### VOLCANIC

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Fire Bat | 40 | 10 | 2 | 9 | Y | — |
| Lava Elemental | 100 | 22 | 12 | 3 | Y | — |
| Demon | 150 | 28 | 14 | 5 | Y | — |

### CAVE

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Cave Spider | 45 | 11 | 3 | 6 | Y | — |
| Rock Golem | 130 | 18 | 20 | 2 | N | — |

### SKY

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Harpy | 70 | 16 | 5 | 8 | Y | — |
| Cloud Spirit | 55 | 14 | 3 | 7 | N | — |
| Fallen Angel | 160 | 26 | 12 | 6 | Y | — |

### SWAMP

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Swamp Creature | 75 | 15 | 8 | 3 | Y | — |
| Giant Mosquito | 35 | 8 | 1 | 9 | Y | — |
| Swamp Troll | 140 | 22 | 10 | 4 | Y | — |

### CRYSTAL

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Crystal Golem | 120 | 20 | 18 | 2 | N | — |
| Elemental | 90 | 24 | 6 | 5 | Y | — |
| Shadow | 65 | 18 | 2 | 8 | Y | — |

### RUINS

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Ghost | 50 | 14 | 1 | 6 | Y | — |
| Cursed Warrior | 110 | 24 | 14 | 4 | Y | — |

### MYSTICAL

| Name | HP | ATK | DEF | SPD | Aggressive | Drops |
|------|-----|-----|-----|-----|------------|-------|
| Void Creature | 100 | 28 | 8 | 7 | Y | — |
| Phantom | 80 | 22 | 3 | 8 | Y | — |
| Eldritch Horror | 200 | 35 | 15 | 5 | Y | — |

## 7. Bosses

| Name | HP | ATK | DEF | SPD | Tier | Abilities | Notes |
|------|-----|-----|-----|-----|------|-----------|-------|
| Trial Guardian | 350 | 20 | 8 | 4 | T1 | Heavy Strike, Guardian Shield | Tutorial boss |
| Forest Guardian | 200 | 18 | 8 | 5 | — | Vine Whip, Nature's Wrath, Healing Roots | |
| Sand King | 350 | 32 | 15 | 4 | — | Sandstorm, Quicksand, Dune Crusher | |
| Frost Titan | 400 | 35 | 25 | 3 | — | Glacial Crush, Blizzard, Frozen Tomb | |
| Dreamweaver | 500 | 40 | 20 | 6 | — | Dream Weave, Reality Rift, Mind Shatter, Eternal Slumber | |

## 8. Equipment System

**Slots:** weapon, hat, clothes, shoes, necklace

**Equipment Tiers:** 4 tiers

**Enhancement:** up to +10

| Enhancement Level | Cost (Spirit Crystals) |
|-------------------|------------------------|
| +1 | 100 |
| +2 | 200 |
| +3 | 400 |
| +4 | 700 |
| +5 | 1000 |
| +6 | 1500 |
| +7 | 2000 |
| +8 | 3000 |
| +9 | 4000 |
| +10 | 5000 |

**Spirit Crystal → Slot Mapping:**

| Crystal Type | Slot |
|--------------|------|
| Crimson | weapon |
| Azure | hat |
| Emerald | clothes |
| Golden | shoes |
| Violet | necklace |

## 9. Spirit Crystal Economy

| Tier | Value (units) |
|------|---------------|
| Shard | 10 |
| Crystal | 50 |
| Gem | 200 |
| Core | 1000 |

**Sources:** monster drops, quests, boss kills

**Uses:** skill unlock/upgrade, equipment enhancement

## 10. Inventory

- **Capacity:** 30 slots
- **Item Types:** equipment, consumables
- **Consumables:** Potions (Small / Medium / Large)

## 11. NPCs

| NPC | Role | Details |
|-----|------|---------|
| Elder Adrian | Quest giver | Trial intro quest |
| Spirit Guide Lina | Tutorial | Spirit crystals explanation |
| Town Guard | Info | — |
| Weapon Merchant | Shop | Iron Sword 100cr, Steel Shield 150cr, Leather Armor 80cr |
| Healer | Restore HP | 10 crystals per heal |
| Innkeeper | Rest + save | 20 crystals per rest |

## 12. Protocol

### PacketType Enum

| Type | ID | Description |
|------|----|-------------|
| LOGIN | 1 | — |
| REGISTER | 2 | — |
| LOGOUT | 3 | — |
| GET_CHARACTER | 10 | — |
| SAVE_CHARACTER | 11 | — |
| CREATE_CHARACTER | 12 | — |
| LIST_CHARACTERS | 13 | — |
| SELECT_CHARACTER | 14 | — |
| DELETE_CHARACTER | 15 | — |
| POSITION_UPDATE | 20 | — |
| BATTLE_ACTION | 21 | — |
| CHAT_MESSAGE | 30 | — |
| HEARTBEAT | 50 | — |
| ACK | 51 | — |
| NACK | 52 | — |
| ERROR | 100 | — |

### Binary Packet Header

**Size:** 13 bytes

**Format:** `!HBBIIBBB`

| Offset | Size | Type | Field |
|--------|------|------|-------|
| 0 | 2 | u16 | total_len |
| 2 | 1 | u8 | msg_type |
| 3 | 1 | u8 | flags |
| 4 | 4 | u32 | seq |
| 8 | 4 | u32 | ack |
| 12 | 1 | u8 | ack_mask |

**Payload:** JSON (after header)
