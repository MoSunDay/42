local constants = require("network.constants")
local Packet = require("network.packet")

local network_manager = {}

function network_manager.create()
    return {
        socket = nil,
        host = constants.DEFAULT_HOST,
        port = constants.DEFAULT_PORT,
        connected = false,
        rudp = nil,
        handlers = {},
        username = nil,
        character = nil,
        message_queue = {},
        _last_update = 0,
    }
end

function network_manager.connect(state, host, port)
    host = host or state.host
    port = port or state.port
    
    state.host = host
    state.port = port
    
    if not state.socket then
        state.socket = require("socket").udp()
        state.socket:settimeout(0)
        state.socket:setpeername(host, port)
    end
    
    state.connected = true
    state.rudp = require("network.rudp").create(function(data)
        network_manager._raw_send(state, data)
    end)
    
    print("Network: Connected to " .. host .. ":" .. port)
    return true
end

function network_manager.disconnect(state)
    if state.socket then
        state.socket:close()
        state.socket = nil
    end
    state.connected = false
    state.rudp = nil
    state.username = nil
    state.character = nil
    print("Network: Disconnected")
end

function network_manager._raw_send(state, data)
    if state.socket then
        state.socket:send(data)
    end
end

function network_manager.send(state, pkt)
    if state.rudp then
        return require("network.rudp").send(state.rudp, pkt)
    end
    return false
end

function network_manager.update(state)
    if not state.connected or not state.socket then
        return
    end
    
    local now = love.timer.getTime()
    if now - state._last_update < 0.016 then
        return
    end
    state._last_update = now
    
    while true do
        local data = state.socket:receive()
        if not data then
            break
        end
        
        local pkt, err = Packet.unpack(data)
        if pkt and state.rudp then
            local processed = require("network.rudp").recv(state.rudp, pkt)
            if processed then
                network_manager._handle_packet(state, processed)
            end
        end
    end
    
    if state.rudp then
        local failed = require("network.rudp").update(state.rudp)
        for _, pkt in ipairs(failed) do
            print("Network: Packet delivery failed: " .. pkt.msg_type)
        end
        
        if require("network.rudp").needs_heartbeat(state.rudp) then
            local hb = Packet.new(constants.PacketType.HEARTBEAT)
            require("network.rudp").send_immediate(state.rudp, hb)
        end
        
        if require("network.rudp").is_timed_out(state.rudp) then
            print("Network: Connection timed out")
            network_manager.disconnect(state)
        end
    end
end

function network_manager._handle_packet(state, pkt)
    local data = Packet.get_payload_json(pkt)
    
    local handler = state.handlers[pkt.msg_type]
    if handler then
        handler(data, pkt)
    else
        print("Network: Unhandled packet type: " .. pkt.msg_type)
    end
end

function network_manager.on(state, msg_type, handler)
    state.handlers[msg_type] = handler
end

function network_manager.login(state, username, password, callback)
    state.on_login_callback = callback
    state.username = username
    
    local pkt = Packet.new(constants.PacketType.LOGIN)
    Packet.set_payload_json(pkt, {
        username = username,
        password = password,
    })
    
    network_manager.send(state, pkt)
end

function network_manager.register(state, username, password, character_name, callback)
    state.on_login_callback = callback
    state.username = username
    
    local pkt = Packet.new(constants.PacketType.REGISTER)
    Packet.set_payload_json(pkt, {
        username = username,
        password = password,
        characterName = character_name,
    })
    
    network_manager.send(state, pkt)
end

function network_manager.logout(state)
    local pkt = Packet.new(constants.PacketType.LOGOUT)
    Packet.set_payload_json(pkt, {
        username = state.username,
    })
    
    network_manager.send(state, pkt)
    network_manager.disconnect(state)
end

function network_manager.save_character(state, character, callback)
    if not state.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.SAVE_CHARACTER)
    Packet.set_payload_json(pkt, {
        username = state.username,
        character = character,
    })
    
    state.on_save_callback = callback
    network_manager.send(state, pkt)
    return true
end

function network_manager.send_position(state, x, y, map_id)
    local pkt = Packet.new(constants.PacketType.POSITION_UPDATE)
    Packet.set_payload_json(pkt, {
        username = state.username,
        x = x,
        y = y,
        mapId = map_id,
    })
    
    if state.rudp then
        require("network.rudp").send_immediate(state.rudp, pkt)
    end
end

function network_manager.send_battle_action(state, action, data)
    local pkt = Packet.new(constants.PacketType.BATTLE_ACTION)
    Packet.set_payload_json(pkt, {
        username = state.username,
        action = action,
        data = data or {},
    })
    
    network_manager.send(state, pkt)
end

function network_manager.send_chat(state, message)
    local pkt = Packet.new(constants.PacketType.CHAT_MESSAGE)
    Packet.set_payload_json(pkt, {
        username = state.username,
        message = message,
    })
    
    network_manager.send(state, pkt)
end

function network_manager.set_character(state, character)
    state.character = character
end

function network_manager.get_character(state)
    return state.character
end

function network_manager.is_connected(state)
    return state.connected and state.rudp ~= nil
end

function network_manager.list_characters(state, callback)
    if not state.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.LIST_CHARACTERS)
    Packet.set_payload_json(pkt, {
        username = state.username,
    })
    
    state.on_list_characters_callback = callback
    network_manager.send(state, pkt)
    return true
end

function network_manager.select_character(state, character_id, callback)
    if not state.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.SELECT_CHARACTER)
    Packet.set_payload_json(pkt, {
        username = state.username,
        characterId = character_id,
    })
    
    state.on_select_character_callback = callback
    network_manager.send(state, pkt)
    return true
end

function network_manager.create_character(state, character_data, callback)
    if not state.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.CREATE_CHARACTER)
    Packet.set_payload_json(pkt, {
        username = state.username,
        character = character_data,
    })
    
    state.on_create_character_callback = callback
    network_manager.send(state, pkt)
    return true
end

function network_manager.delete_character(state, character_id, callback)
    if not state.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.DELETE_CHARACTER)
    Packet.set_payload_json(pkt, {
        username = state.username,
        characterId = character_id,
    })
    
    state.on_delete_character_callback = callback
    network_manager.send(state, pkt)
    return true
end

return network_manager
