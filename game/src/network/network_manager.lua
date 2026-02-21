local constants = require("network.constants")
local Packet = require("network.packet")

local network_manager = {}
network_manager.__index = network_manager

function network_manager.new()
    local self = setmetatable({}, network_manager)
    self.socket = nil
    self.host = constants.DEFAULT_HOST
    self.port = constants.DEFAULT_PORT
    self.connected = false
    self.rudp = nil
    self.handlers = {}
    self.username = nil
    self.character = nil
    self.message_queue = {}
    self._last_update = 0
    return self
end

function network_manager:connect(host, port)
    host = host or self.host
    port = port or self.port
    
    self.host = host
    self.port = port
    
    if not self.socket then
        self.socket = require("socket").udp()
        self.socket:settimeout(0)
        self.socket:setpeername(host, port)
    end
    
    self.connected = true
    self.rudp = require("network.rudp").new(function(data)
        self:_raw_send(data)
    end)
    
    print("Network: Connected to " .. host .. ":" .. port)
    return true
end

function network_manager:disconnect()
    if self.socket then
        self.socket:close()
        self.socket = nil
    end
    self.connected = false
    self.rudp = nil
    self.username = nil
    self.character = nil
    print("Network: Disconnected")
end

function network_manager:_raw_send(data)
    if self.socket then
        self.socket:send(data)
    end
end

function network_manager:send(pkt)
    if self.rudp then
        return self.rudp:send(pkt)
    end
    return false
end

function network_manager:update()
    if not self.connected or not self.socket then
        return
    end
    
    local now = love.timer.getTime()
    if now - self._last_update < 0.016 then
        return
    end
    self._last_update = now
    
    while true do
        local data = self.socket:receive()
        if not data then
            break
        end
        
        local pkt, err = Packet.unpack(data)
        if pkt and self.rudp then
            local processed = self.rudp:recv(pkt)
            if processed then
                self:_handle_packet(processed)
            end
        end
    end
    
    if self.rudp then
        local failed = self.rudp:update()
        for _, pkt in ipairs(failed) do
            print("Network: Packet delivery failed: " .. pkt.msg_type)
        end
        
        if self.rudp:needs_heartbeat() then
            local hb = Packet.new(constants.PacketType.HEARTBEAT)
            self.rudp:send_immediate(hb)
        end
        
        if self.rudp:is_timed_out() then
            print("Network: Connection timed out")
            self:disconnect()
        end
    end
end

function network_manager:_handle_packet(pkt)
    local data = pkt:get_payload_json()
    
    local handler = self.handlers[pkt.msg_type]
    if handler then
        handler(data, pkt)
    else
        print("Network: Unhandled packet type: " .. pkt.msg_type)
    end
end

function network_manager:on(msg_type, handler)
    self.handlers[msg_type] = handler
end

function network_manager:login(username, password, callback)
    self.on_login_callback = callback
    self.username = username
    
    local pkt = Packet.new(constants.PacketType.LOGIN)
    pkt:set_payload_json({
        username = username,
        password = password,
    })
    
    self:send(pkt)
end

function network_manager:register(username, password, character_name, callback)
    self.on_login_callback = callback
    self.username = username
    
    local pkt = Packet.new(constants.PacketType.REGISTER)
    pkt:set_payload_json({
        username = username,
        password = password,
        characterName = character_name,
    })
    
    self:send(pkt)
end

function network_manager:logout()
    local pkt = Packet.new(constants.PacketType.LOGOUT)
    pkt:set_payload_json({
        username = self.username,
    })
    
    self:send(pkt)
    self:disconnect()
end

function network_manager:save_character(character, callback)
    if not self.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.SAVE_CHARACTER)
    pkt:set_payload_json({
        username = self.username,
        character = character,
    })
    
    self.on_save_callback = callback
    self:send(pkt)
    return true
end

function network_manager:send_position(x, y, map_id)
    local pkt = Packet.new(constants.PacketType.POSITION_UPDATE)
    pkt:set_payload_json({
        username = self.username,
        x = x,
        y = y,
        mapId = map_id,
    })
    
    if self.rudp then
        self.rudp:send_immediate(pkt)
    end
end

function network_manager:send_battle_action(action, data)
    local pkt = Packet.new(constants.PacketType.BATTLE_ACTION)
    pkt:set_payload_json({
        username = self.username,
        action = action,
        data = data or {},
    })
    
    self:send(pkt)
end

function network_manager:send_chat(message)
    local pkt = Packet.new(constants.PacketType.CHAT_MESSAGE)
    pkt:set_payload_json({
        username = self.username,
        message = message,
    })
    
    self:send(pkt)
end

function network_manager:set_character(character)
    self.character = character
end

function network_manager:get_character()
    return self.character
end

function network_manager:is_connected()
    return self.connected and self.rudp ~= nil
end

function network_manager:list_characters(callback)
    if not self.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.LIST_CHARACTERS)
    pkt:set_payload_json({
        username = self.username,
    })
    
    self.on_list_characters_callback = callback
    self:send(pkt)
    return true
end

function network_manager:select_character(character_id, callback)
    if not self.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.SELECT_CHARACTER)
    pkt:set_payload_json({
        username = self.username,
        characterId = character_id,
    })
    
    self.on_select_character_callback = callback
    self:send(pkt)
    return true
end

function network_manager:create_character(character_data, callback)
    if not self.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.CREATE_CHARACTER)
    pkt:set_payload_json({
        username = self.username,
        character = character_data,
    })
    
    self.on_create_character_callback = callback
    self:send(pkt)
    return true
end

function network_manager:delete_character(character_id, callback)
    if not self.username then
        return false
    end
    
    local pkt = Packet.new(constants.PacketType.DELETE_CHARACTER)
    pkt:set_payload_json({
        username = self.username,
        characterId = character_id,
    })
    
    self.on_delete_character_callback = callback
    self:send(pkt)
    return true
end

return network_manager
