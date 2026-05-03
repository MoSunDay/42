# Network/Account/BattleSim OOP Removal

Commit: 52517ea6b22bcbfa1b3715c779aa93a07263b3ab

## Context
9 Lua files still used OOP patterns (setmetatable, __index, colon methods) despite the codebase convention being pure functional.

## Change Summary
Converted all 9 files to pure functional style:
- **Network** (3 files): `network_manager.lua`, `rudp.lua`, `packet.lua` — removed setmetatable/__index, renamed `.new` to `.create`, converted colon methods to dot methods with `state` param, replaced `self:` internal calls with `Module.call(state, ...)`
- **Account** (3 files): `login_ui.lua`, `character_data.lua`, `character_select_ui.lua` — same transformations; `char:getClassName()` call replaced with `CharacterData.getClassName(char)`
- **Battle Simulator** (3 files): `init.lua`, `simulation_engine.lua`, `sim_combatant.lua` — updated colon calls on units (`unit:isAlive()` → `SimCombatant.isAlive(unit)`, etc.); added missing methods `useMana`, `setDefending`, `decideAction` and `isAlive` field to SimCombatant

## Impact Surface
- All callers of these modules must use dot syntax: `Module.method(state, ...)`
- Packet module: `packet.new` preserved as alias for `packet.create` for backward compat
- LoginUI/CharacterSelectUI: `.new` preserved as alias for `.create`
