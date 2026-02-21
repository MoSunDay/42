local json = {}

local function skip_whitespace(str, pos)
    while pos <= #str do
        local c = str:sub(pos, pos)
        if c == " " or c == "\t" or c == "\n" or c == "\r" then
            pos = pos + 1
        else
            break
        end
    end
    return pos
end

local function parse_value(str, pos)
    pos = skip_whitespace(str, pos)
    
    if pos > #str then
        return nil, "unexpected end of input"
    end
    
    local c = str:sub(pos, pos)
    
    if c == "n" then
        if str:sub(pos, pos + 3) == "null" then
            return nil, pos + 4
        end
    elseif c == "t" then
        if str:sub(pos, pos + 3) == "true" then
            return true, pos + 4
        end
    elseif c == "f" then
        if str:sub(pos, pos + 4) == "false" then
            return false, pos + 5
        end
    elseif c == '"' then
        local result = {}
        pos = pos + 1
        while pos <= #str do
            local ch = str:sub(pos, pos)
            if ch == '"' then
                return table.concat(result), pos + 1
            elseif ch == "\\" then
                pos = pos + 1
                local escape = str:sub(pos, pos)
                if escape == "n" then
                    table.insert(result, "\n")
                elseif escape == "t" then
                    table.insert(result, "\t")
                elseif escape == "r" then
                    table.insert(result, "\r")
                elseif escape == '"' then
                    table.insert(result, '"')
                elseif escape == "\\" then
                    table.insert(result, "\\")
                else
                    table.insert(result, escape)
                end
            else
                table.insert(result, ch)
            end
            pos = pos + 1
        end
        return nil, "unterminated string"
    elseif c == "[" then
        local arr = {}
        pos = pos + 1
        pos = skip_whitespace(str, pos)
        if str:sub(pos, pos) == "]" then
            return arr, pos + 1
        end
        while true do
            local val
            val, pos = parse_value(str, pos)
            table.insert(arr, val)
            pos = skip_whitespace(str, pos)
            local next_char = str:sub(pos, pos)
            if next_char == "]" then
                return arr, pos + 1
            elseif next_char == "," then
                pos = pos + 1
            else
                return nil, "expected ',' or ']'"
            end
        end
    elseif c == "{" then
        local obj = {}
        pos = pos + 1
        pos = skip_whitespace(str, pos)
        if str:sub(pos, pos) == "}" then
            return obj, pos + 1
        end
        while true do
            pos = skip_whitespace(str, pos)
            if str:sub(pos, pos) ~= '"' then
                return nil, "expected string key"
            end
            local key
            key, pos = parse_value(str, pos)
            pos = skip_whitespace(str, pos)
            if str:sub(pos, pos) ~= ":" then
                return nil, "expected ':'"
            end
            pos = pos + 1
            local val
            val, pos = parse_value(str, pos)
            obj[key] = val
            pos = skip_whitespace(str, pos)
            local next_char = str:sub(pos, pos)
            if next_char == "}" then
                return obj, pos + 1
            elseif next_char == "," then
                pos = pos + 1
            else
                return nil, "expected ',' or '}'"
            end
        end
    elseif c == "-" or (c >= "0" and c <= "9") then
        local num_start = pos
        if c == "-" then
            pos = pos + 1
        end
        while pos <= #str do
            local digit = str:sub(pos, pos)
            if (digit >= "0" and digit <= "9") or digit == "." or 
               digit == "e" or digit == "E" or digit == "+" or digit == "-" then
                pos = pos + 1
            else
                break
            end
        end
        local num_str = str:sub(num_start, pos - 1)
        return tonumber(num_str), pos
    end
    
    return nil, "unexpected character: " .. c
end

function json.decode(str)
    local result, pos = parse_value(str, 1)
    return result
end

local function encode_value(val, indent)
    local t = type(val)
    
    if val == nil then
        return "null"
    elseif t == "boolean" then
        return val and "true" or "false"
    elseif t == "number" then
        if val ~= val then
            return "null"
        elseif val >= math.huge then
            return "1e309"
        elseif val <= -math.huge then
            return "-1e309"
        end
        return tostring(val)
    elseif t == "string" then
        local result = {'"'}
        for i = 1, #val do
            local c = val:sub(i, i)
            if c == '"' then
                table.insert(result, '\\"')
            elseif c == "\\" then
                table.insert(result, "\\\\")
            elseif c == "\n" then
                table.insert(result, "\\n")
            elseif c == "\r" then
                table.insert(result, "\\r")
            elseif c == "\t" then
                table.insert(result, "\\t")
            else
                table.insert(result, c)
            end
        end
        table.insert(result, '"')
        return table.concat(result)
    elseif t == "table" then
        local is_array = true
        local max_idx = 0
        for k, _ in pairs(val) do
            if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
                is_array = false
                break
            end
            if k > max_idx then
                max_idx = k
            end
        end
        
        if is_array and max_idx > 0 then
            local parts = {}
            for i = 1, max_idx do
                table.insert(parts, encode_value(val[i], indent))
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for k, v in pairs(val) do
                local key_str = encode_value(tostring(k), indent)
                local val_str = encode_value(v, indent)
                table.insert(parts, key_str .. ":" .. val_str)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end
    
    return "null"
end

function json.encode(val)
    return encode_value(val, 0)
end

return json
