# Systems Module Summary

> Last updated: 2026-02-21 - Class & Skill System

## Purpose
Game systems for battle, party, chat, inventory, equipment, collision, audio, companions, spirit crystals, and skills.

## Files

| File | Description |
|------|-------------|
| `appearance_system.lua` | Character visual appearance |
| `audio_system.lua` | BGM and SFX management with file loading and procedural fallback |
| `chat_system.lua` | Chat box + speech bubbles |
| `collision_system.lua` | Tile-based walkability |
| `companion_system.lua` | Companion/pet management with 6 templates, leveling, battle AI |
| `dungeon_system.lua` | Dungeon instance management, area progression, rewards |
| `equipment_system.lua` | Equipment slots, stat bonuses, set bonuses, enhancement |
| `spirit_crystal_system.lua` | Spirit crystal collection, 4 tiers for equipment enhancement |
| `skill_system.lua` | Skill unlock/upgrade/use, infinite leveling with Spirit Crystals |
| `tutorial_system.lua` | Tutorial flow management, 5 tutorial types, skip/complete tracking |
| `input_system.lua` | Keyboard/mouse input handling |
| `inventory_system.lua` | Item storage and management |
| `item_database.lua` | Item definitions with stats |
| `party_system.lua` | Party management (max 5 members) |
| `pet_system.lua` | Pet companion system |
| `render_system.lua` | Rendering coordination |
| `sprite_animator.lua` | Sprite sheet animation |
| `tile_animator.lua` | Animated tiles (water, etc.) |
| `enhanced_audio.lua` | Extended audio features (procedural BGM generation) |
| `battle/` | Battle system subdirectory |

## Key APIs

### audio_system.lua
- `AudioSystem:loadSoundFiles()` - Load .ogg/.wav files from assets/sounds/
- `AudioSystem:playSFX(name)` - Play sound effect (attack, hit, victory, etc.)
- `AudioSystem:playBGM(mode)` - Play BGM (exploration, battle, spring/summer/autumn/winter)
- `AudioSystem:generateFallbackSounds()` - Generate procedural sounds if files missing
- `AudioSystem:setMusicVolume(vol)` / `setSFXVolume(vol)` - Volume control (0-1)

### companion_system.lua
- `CompanionSystem:createCompanion(templateId)` - Create companion by type
- `CompanionSystem:addCompanion(templateId)` - Add to party (max 9)
- `CompanionSystem:removeCompanion(id)` - Remove from party
- `CompanionSystem:gainExperience(id, xp)` - Level up companions
- `CompanionSystem:getBattleParty()` - Get party for combat
- `CompanionSystem.MAX_COMPANIONS = 9`
- Templates: warrior, berserker, guardian, assassin, mage, paladin

### spirit_crystal_system.lua
- `SpiritCrystalSystem:addCrystal(tier, amount)` - Add crystal by tier
- `SpiritCrystalSystem:addCrystalValue(value)` - Add by total value
- `SpiritCrystalSystem:getCrystalCount(tier)` - Get count for tier
- `SpiritCrystalSystem:getTotalValue()` - Get total crystal value
- `SpiritCrystalSystem:spendValue(cost)` - Spend crystals
- `SpiritCrystalSystem:canEnhance(currentLevel)` - Check if can enhance
- `SpiritCrystalSystem:enhance(currentLevel)` - Enhance equipment
- `SpiritCrystalSystem.generateDrop(enemyTier)` - Generate random drop
- Tiers: 1=碎片(10点), 2=晶体(50点), 3=宝石(200点), 4=核心(1000点)

### collision_system.lua
- `CollisionSystem:isWalkable(x, y)` - Check if position walkable
- `CollisionSystem:canMove(fromX, fromY, toX, toY, radius)` - Check movement

### inventory_system.lua
- `InventorySystem:addItem(itemId)` - Add item
- `InventorySystem:removeItem(index)` - Remove item
- `InventorySystem:serialize()` / `deserialize(data)` - Save/load

### equipment_system.lua
- `EquipmentSystem:equip(slot, itemId)` - Equip item
- `EquipmentSystem:unequip(slot)` - Remove equipment
- `EquipmentSystem:getTotalStats()` - Get stat bonuses
- `EquipmentSystem:getDefensePercent()` - Get damage reduction %
- `EquipmentSystem:enhance(slot)` - Upgrade equipment
- `EquipmentSystem:getSetBonus(setName)` - Check set bonuses
- Slots: weapon, armor, helmet, accessory, boots, gloves

### party_system.lua
- `PartySystem:addMember(memberData)` - Add member
- `PartySystem:removeMember(id)` - Remove member
- `PartySystem.MAX_MEMBERS` = 5

### dungeon_system.lua
- `DungeonSystem.new(player, spiritCrystalSystem)` - Create dungeon manager
- `DungeonSystem:loadDungeon(dungeonId)` - Load dungeon data
- `DungeonSystem:startDungeon()` - Begin dungeon run
- `DungeonSystem:advanceToNextArea()` - Move to next area
- `DungeonSystem:checkAreaProgress()` - Check if area cleared
- `DungeonSystem:claimRewards()` - Claim pending rewards
- `DungeonSystem:getProgress()` - Get current progress info
- `DungeonSystem:isDungeonComplete()` - Check completion status

### tutorial_system.lua
- `TutorialSystem.new()` - Create tutorial manager
- `TutorialSystem:startTutorial(tutorialId)` - Start tutorial
- `TutorialSystem:nextPage()` / `prevPage()` - Navigate pages
- `TutorialSystem:skipTutorial()` - Skip current tutorial
- `TutorialSystem:completeTutorial()` - Mark complete
- `TutorialSystem:isCompleted(tutorialId)` - Check completion
- Tutorial IDs: basic_combat, defense_mechanic, spirit_crystal_system, multi_enemy_strategy, boss_battle

### skill_system.lua
- `SkillSystem.initPlayerSkills(player, classId)` - Initialize skills for new character
- `SkillSystem.getPlayerSkill(player, skillId)` - Get player's skill data
- `SkillSystem.isSkillUnlocked(player, skillId)` - Check if skill unlocked
- `SkillSystem.getSkillLevel(player, skillId)` - Get skill level (0 if locked)
- `SkillSystem.canUnlockSkill(player, skillId)` - Check unlock requirements
- `SkillSystem.unlockSkill(player, skillId)` - Unlock skill (costs Spirit Crystals)
- `SkillSystem.canUpgradeSkill(player, skillId)` - Check upgrade requirements
- `SkillSystem.upgradeSkill(player, skillId)` - Upgrade skill level
- `SkillSystem.addSkillCrystals(player, amount)` - Add currency
- `SkillSystem.getAvailableSkills(player)` - Get all unlocked skills
- `SkillSystem.getLockedSkills(player)` - Get all locked skills
- `SkillSystem.canUseSkill(player, skillId)` - Check MP cost
- `SkillSystem.useSkill(player, skillId)` - Execute skill in battle
- `SkillSystem.getSkillInfo(player, skillId)` - Get detailed skill info
- Unlock costs: Tier1=0, Tier2=100, Tier3=250 Spirit Crystals
- Upgrade formula: `cost = 40 × level × (1 + 0.08 × level)`
- Effect bonus: +3% per level

## Sound Effect Files

| Category | Sounds |
|----------|--------|
| Combat | attack, hit, critical, block, dodge, skill, victory, defeat |
| UI | click, hover, open, close, pickup, equip, levelup |
| Character | hurt, death |

## BGM Themes

| Theme | Description |
|-------|-------------|
| exploration | Main world exploration |
| battle | Combat music |
| town | Village/town ambient |
| spring/summer/autumn/winter | Seasonal variations |
