-- battle_state.lua - Battle state management
-- Defines and manages battle states

local BattleState = {}

-- Battle states
BattleState.INTRO = "intro"           -- Battle start animation
BattleState.PLAYER_TURN = "player"    -- Player's turn
BattleState.EXECUTING = "executing"   -- Executing player action
BattleState.ENEMY_TURN = "enemy"      -- Enemy's turn
BattleState.VICTORY = "victory"       -- Player won
BattleState.DEFEAT = "defeat"         -- Player lost
BattleState.ESCAPED = "escaped"       -- Player escaped

return BattleState

