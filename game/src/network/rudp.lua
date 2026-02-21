local constants = require("network.constants")
local Packet = require("network.packet")
local bit = require("bit")

local rudp = {}
rudp.__index = rudp

function rudp.new(send_func)
    local self = setmetatable({}, rudp)
    self.send_func = send_func
    self.next_seq = 1
    self.remote_seq = 0
    self.send_buffer = {}
    self.recv_window = {}
    self.ack_mask = 0
    self.last_recv_time = 0
    self.last_send_time = 0
    self.connected = true
    self:reset_time()
    return self
end

function rudp:reset_time()
    local now = love.timer.getTime() * 1000
    self.last_recv_time = now
    self.last_send_time = now
end

function rudp:_now_ms()
    return love.timer.getTime() * 1000
end

function rudp:_next_sequence()
    local seq = self.next_seq
    self.next_seq = bit.band(self.next_seq + 1, 0xFFFFFFFF)
    return seq
end

function rudp:_calculate_ack_mask()
    local ack = self.remote_seq
    local ack_mask = 0
    
    for seq, _ in pairs(self.recv_window) do
        local diff = ack - seq
        if diff > 0 and diff <= 32 then
            ack_mask = bit.bor(ack_mask, bit.lshift(1, diff - 1))
        end
    end
    
    return ack, ack_mask
end

function rudp:send(pkt)
    local now = self:_now_ms()
    self.last_send_time = now
    
    if pkt.seq == 0 then
        pkt.seq = self:_next_sequence()
    end
    
    local ack, ack_mask = self:_calculate_ack_mask()
    pkt.ack = ack
    pkt.ack_mask = ack_mask
    
    local data = pkt:pack()
    self.send_func(data)
    
    if pkt:needs_ack() then
        self.send_buffer[pkt.seq] = {
            packet = pkt,
            send_time = now,
            retries = 0,
            last_send = now,
        }
    end
    
    return true
end

function rudp:send_immediate(pkt)
    local now = self:_now_ms()
    self.last_send_time = now
    
    local ack, ack_mask = self:_calculate_ack_mask()
    pkt.ack = ack
    pkt.ack_mask = ack_mask
    
    self.send_func(pkt:pack())
end

function rudp:recv(pkt)
    local now = self:_now_ms()
    self.last_recv_time = now
    
    self:_process_acks(pkt.ack, pkt.ack_mask)
    
    if pkt.msg_type == constants.PacketType.ACK then
        return nil
    end
    
    if pkt.seq > 0 then
        if pkt.seq <= self.remote_seq then
            local diff = self.remote_seq - pkt.seq
            if diff < constants.RECV_WINDOW_SIZE then
                return nil
            end
        elseif pkt.seq > self.remote_seq then
            self.remote_seq = pkt.seq
        end
        
        self.recv_window[pkt.seq] = pkt
        self:_clean_recv_window()
    end
    
    if pkt:needs_ack() then
        local ack, ack_mask = self:_calculate_ack_mask()
        local ack_packet = Packet.new(constants.PacketType.ACK, 0, pkt.seq, ack_mask)
        self:send_immediate(ack_packet)
    end
    
    return pkt
end

function rudp:_process_acks(ack, ack_mask)
    local to_remove = {}
    
    for seq, pending in pairs(self.send_buffer) do
        if seq == ack then
            table.insert(to_remove, seq)
        else
            local diff = ack - seq
            if diff > 0 and diff <= 32 then
                if bit.band(ack_mask, bit.lshift(1, diff - 1)) ~= 0 then
                    table.insert(to_remove, seq)
                end
            end
        end
    end
    
    for _, seq in ipairs(to_remove) do
        self.send_buffer[seq] = nil
    end
end

function rudp:_clean_recv_window()
    local threshold = self.remote_seq - constants.RECV_WINDOW_SIZE
    local to_remove = {}
    
    for seq, _ in pairs(self.recv_window) do
        if seq <= threshold then
            table.insert(to_remove, seq)
        end
    end
    
    for _, seq in ipairs(to_remove) do
        self.recv_window[seq] = nil
    end
end

function rudp:update()
    local now = self:_now_ms()
    local timeout_ms = constants.RETRY_TIMEOUT_MS
    
    local failed = {}
    local to_remove = {}
    
    for seq, pending in pairs(self.send_buffer) do
        local elapsed = now - pending.last_send
        
        if elapsed >= timeout_ms then
            if pending.retries >= constants.MAX_RETRIES then
                table.insert(failed, pending.packet)
                table.insert(to_remove, seq)
            else
                pending.retries = pending.retries + 1
                pending.last_send = now
                
                local ack, ack_mask = self:_calculate_ack_mask()
                pending.packet.ack = ack
                pending.packet.ack_mask = ack_mask
                
                self.send_func(pending.packet:pack())
            end
        end
    end
    
    for _, seq in ipairs(to_remove) do
        self.send_buffer[seq] = nil
    end
    
    return failed
end

function rudp:is_timed_out()
    local elapsed = self:_now_ms() - self.last_recv_time
    return elapsed >= constants.CONNECTION_TIMEOUT_MS
end

function rudp:needs_heartbeat()
    local elapsed = self:_now_ms() - self.last_send_time
    return elapsed >= constants.HEARTBEAT_INTERVAL_MS
end

function rudp:get_pending_count()
    local count = 0
    for _ in pairs(self.send_buffer) do
        count = count + 1
    end
    return count
end

return rudp
