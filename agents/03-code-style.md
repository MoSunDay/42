# Code Style Guidelines

## Lua (Game Client)

### Module Pattern (Pure Functional)

All modules follow pure functional style — **no `setmetatable`**, **no `__index`**, **no `self`**, **no colon syntax**.

```lua
local Dependency = require("path.to.dependency")

local ModuleName = {}

local CONSTANT_NAME = 100

function ModuleName.create(param)
    return {
        property = param or defaultValue
    }
end

function ModuleName.method(state, arg)
    -- access state.property instead of self.property
end

function ModuleName.staticMethod(arg)
    -- no state parameter needed
end

return ModuleName
```

**Rules:**
- Constructor is `.create()` — returns a plain table, never uses metatables
- Instance methods take `state` as first parameter (the data table)
- Always call with dot syntax: `Module.method(state, ...)`, never `state:method(...)`
- Static methods have no `state` parameter

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Modules | PascalCase | `BattleSystem`, `Player` |
| Functions | snake_case | `take_damage`, `move_to` |
| Variables | snake_case | `player_hp`, `current_map` |
| Constants | SCREAMING_SNAKE | `MAX_PARTY_SIZE`, `GAME_MODE` |
| Private fields | prefix with _ | `_internalState` |
| Boolean properties | is/has prefix | `isMoving`, `isActive` |

### Import Style

```lua
-- Add to package.path at top of main.lua or entry files
package.path = package.path .. ";src/?.lua;src/core/?.lua;src/entities/?.lua"

-- Import order: external -> core -> entities -> systems -> ui
local ExternalLib = require("lib.external")
local CoreModule = require("core.core_module")
local Entity = require("entities.entity")
local System = require("systems.system")
local UI = require("ui.component")
```

### Error Handling

```lua
-- Use assert for critical operations
assert(value, "Error message")

-- Use pcall for recoverable operations
local success, result = pcall(riskyFunction, arg)
if not success then
    print("Error: " .. tostring(result))
    -- Handle error gracefully
end

-- Validate parameters
function Module.method(state, required, optional)
    assert(required ~= nil, "required parameter is missing")
    optional = optional or defaultValue
end
```

### Comments

```lua
-- Single line comments for brief explanations

--[[
Multi-line comments for:
- Complex algorithms
- API documentation
- Important notes
]]

-- Section headers (use consistent format)
-- ============================================
-- SECTION NAME
-- ============================================
```

### File Organization

- Keep files under 400 lines
- One module per file
- Group related files in directories (battle/, ui/, entities/)
- Use `local` for all functions unless truly global

## Python (Server)

### Style Guidelines

```python
#!/usr/bin/env python3
"""Module docstring describing purpose."""

from library import Thing
from local_module import local_function

# Constants at module level
CONSTANT_NAME = "value"

# Type hints for all functions
async def function_name(param: str) -> dict:
    """Brief description of function."""
    pass

# Class naming
class ClassName:
    """Class docstring."""
    
    def __init__(self, param: str):
        self.property = param
    
    def method_name(self, arg: int) -> bool:
        """Method description."""
        return True
```

### Error Handling

```python
# Validate input early
if not data or "required_field" not in data:
    return json_response({
        "success": False,
        "error": "Missing required field"
    }, status=400)

# Use specific HTTP status codes
# 200 - Success
# 201 - Created
# 400 - Bad Request
# 401 - Unauthorized
# 404 - Not Found
# 409 - Conflict
```
