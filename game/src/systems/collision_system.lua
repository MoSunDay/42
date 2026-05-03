-- collision_system.lua - Collision detection system
-- 碰撞检测系统

local CollisionSystem = {}

function CollisionSystem.create(map)
    local state = {}

    state.map = map

    return state
end

-- Check if a point is walkable
function CollisionSystem.is_walkable(state, x, y)
    -- Check map boundaries
    if x < 0 or x > state.map.width or y < 0 or y > state.map.height then
        return false
    end

    -- Check buildings collision
    if CollisionSystem.check_building_collision(state, x, y) then
        return false
    end

    -- Check collision map if exists
    if state.map.collisionMap and #state.map.collisionMap > 0 then
        local tileX = math.floor(x / state.map.tileSize)
        local tileY = math.floor(y / state.map.tileSize)

        if state.map.collisionMap[tileY] and state.map.collisionMap[tileY][tileX] then
            return false
        end
    end

    return true
end

-- Check collision with buildings
function CollisionSystem.check_building_collision(state, x, y, radius)
    radius = radius or 16  -- Default player radius

    for _, building in ipairs(state.map.buildings or {}) do
        -- Check if point is inside building (with radius)
        if x + radius > building.x and
           x - radius < building.x + building.width and
           y + radius > building.y and
           y - radius < building.y + building.height then
            return true
        end
    end

    return false
end

-- Check if a rectangle collides with buildings
function CollisionSystem.check_rect_collision(state, x, y, width, height)
    for _, building in ipairs(state.map.buildings or {}) do
        -- AABB collision detection
        if x < building.x + building.width and
           x + width > building.x and
           y < building.y + building.height and
           y + height > building.y then
            return true
        end
    end

    return false
end

-- Get valid position (adjust position if colliding)
function CollisionSystem.get_valid_position(state, x, y, radius)
    radius = radius or 16

    -- Check map boundaries
    x = math.max(radius, math.min(x, state.map.width - radius))
    y = math.max(radius, math.min(y, state.map.height - radius))

    -- If position is valid, return it
    if CollisionSystem.is_walkable(state, x, y) then
        return x, y
    end

    -- Check if inside a building, if so teleport to building edge
    local building = CollisionSystem.get_building_at(state, x, y)
    if building then
        return CollisionSystem.teleport_to_building_edge(state, x, y, building, radius)
    end

    -- Try to find nearby valid position
    local searchRadius = 32
    local step = 8

    for r = step, searchRadius, step do
        for angle = 0, math.pi * 2, math.pi / 8 do
            local testX = x + math.cos(angle) * r
            local testY = y + math.sin(angle) * r

            if CollisionSystem.is_walkable(state, testX, testY) then
                return testX, testY
            end
        end
    end

    -- If no valid position found, return original (clamped to boundaries)
    return x, y
end

-- Check if movement from (x1, y1) to (x2, y2) is valid
function CollisionSystem.can_move(state, x1, y1, x2, y2, radius)
    radius = radius or 16

    -- Check destination
    if not CollisionSystem.is_walkable(state, x2, y2) then
        return false, x1, y1
    end

    -- Simple raycast check (sample points along the path)
    local dx = x2 - x1
    local dy = y2 - y1
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < 1 then
        return true, x2, y2
    end

    local steps = math.ceil(distance / 8)  -- Check every 8 pixels

    for i = 0, steps do
        local t = i / steps
        local checkX = x1 + dx * t
        local checkY = y1 + dy * t

        if not CollisionSystem.is_walkable(state, checkX, checkY) then
            -- Find last valid position
            if i > 0 then
                t = (i - 1) / steps
                return false, x1 + dx * t, y1 + dy * t
            else
                return false, x1, y1
            end
        end
    end

    return true, x2, y2
end

-- Get closest walkable position to target
function CollisionSystem.get_closest_walkable(state, targetX, targetY, fromX, fromY, radius)
    radius = radius or 16

    -- If target is walkable, return it
    if CollisionSystem.is_walkable(state, targetX, targetY) then
        return targetX, targetY
    end

    -- Find closest walkable position
    local dx = targetX - fromX
    local dy = targetY - fromY
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < 1 then
        return fromX, fromY
    end

    -- Binary search along the line
    local low = 0
    local high = 1
    local bestT = 0

    for i = 1, 10 do  -- 10 iterations should be enough
        local mid = (low + high) / 2
        local testX = fromX + dx * mid
        local testY = fromY + dy * mid

        if CollisionSystem.is_walkable(state, testX, testY) then
            bestT = mid
            low = mid
        else
            high = mid
        end
    end

    return fromX + dx * bestT, fromY + dy * bestT
end

-- Check if a circle collides with any obstacle
function CollisionSystem.check_circle_collision(state, x, y, radius)
    -- Check map boundaries
    if x - radius < 0 or x + radius > state.map.width or
       y - radius < 0 or y + radius > state.map.height then
        return true
    end

    -- Check buildings
    for _, building in ipairs(state.map.buildings or {}) do
        -- Find closest point on rectangle to circle center
        local closestX = math.max(building.x, math.min(x, building.x + building.width))
        local closestY = math.max(building.y, math.min(y, building.y + building.height))

        -- Calculate distance
        local dx = x - closestX
        local dy = y - closestY
        local distanceSquared = dx * dx + dy * dy

        if distanceSquared < radius * radius then
            return true
        end
    end

    return false
end

-- Update map reference
function CollisionSystem.set_map(state, map)
    state.map = map
end

-- Get building at position
function CollisionSystem.get_building_at(state, x, y)
    if not state.map.buildings then
        return nil
    end

    for _, building in ipairs(state.map.buildings) do
        if x >= building.x and x <= building.x + building.width and
           y >= building.y and y <= building.y + building.height then
            return building
        end
    end

    return nil
end

-- Teleport to building edge (find closest edge position)
function CollisionSystem.teleport_to_building_edge(state, x, y, building, radius)
    radius = radius or 16
    local margin = radius + 5  -- Extra margin from building edge

    -- Calculate positions at each edge
    local edges = {
        {x = building.x - margin, y = y, name = "left"},  -- Left edge
        {x = building.x + building.width + margin, y = y, name = "right"},  -- Right edge
        {x = x, y = building.y - margin, name = "top"},  -- Top edge
        {x = x, y = building.y + building.height + margin, name = "bottom"},  -- Bottom edge
    }

    -- Find closest valid edge
    local closestDist = math.huge
    local closestPos = {x = x, y = y}

    for _, edge in ipairs(edges) do
        -- Check if edge position is walkable
        if CollisionSystem.is_walkable(state, edge.x, edge.y) then
            local dist = math.sqrt((edge.x - x)^2 + (edge.y - y)^2)
            if dist < closestDist then
                closestDist = dist
                closestPos = {x = edge.x, y = edge.y}
            end
        end
    end


    return closestPos.x, closestPos.y
end

return CollisionSystem
