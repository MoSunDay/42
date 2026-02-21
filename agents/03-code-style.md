# Code Style Guidelines

## Lua (Game Client)

### Module Pattern

```lua
-- module_name.lua - Brief description (EN or CN comments OK)

local Dependency = require("path.to.dependency")

local ModuleName = {}
ModuleName.__index = ModuleName

-- Constants at the top (use local)
local CONSTANT_NAME = 100

function ModuleName.new(param)
    local self = setmetatable({}, ModuleName)
    
    -- Initialize properties
    self.property = param or defaultValue
    
    return self
end

-- Methods use colon syntax
function ModuleName:methodName(arg)
    -- Implementation
end

-- Static methods use dot syntax
function ModuleName.staticMethod(arg)
    -- Implementation
end

return ModuleName
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Modules/Classes | PascalCase | `BattleSystem`, `Player` |
| Functions/Methods | snake_case | `takeDamage`, `move_to` |
| Variables | snake_case | `player_hp`, `currentMap` |
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
function Module:method(required, optional)
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
