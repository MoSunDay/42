local constants = require("network.constants")
local Packet = require("network.packet")
local bit = require("bit")

local rudp = {}

function rudp.create(send_func)
    local state = {
        send_func = send_func,
        next_seq = 1,
        remote_seq = 0,
        send_buffer = {},
        recv_window = {},
        ack_mask = 0,
        last_recv_time = 0,
        last_send_time = 0,
        connected = true,
    }
    rudp.reset_time(state)
    return state
end

function rudp.reset_time(state)
    local now = love.timer.getTime() * 1000
    state.last_recv_time = now
    state.last_send_time = now
end

function rudp._now_ms()
    return love.timer.getTime() * 1000
end

function rudp._next_sequence(state)
    local seq = state.next_seq
    state.next_seq = bit.band(state.next_seq + 1, 0xFFFFFFFF)
    return seq
end

function rudp._calculate_ack_mask(state)
    local ack = state.remote_seq
    local ack_mask = 0
    
    for seq, _ in pairs(state.recv_window) do
        local diff = ack - seq
        if diff > 0 and diff <= 32 then
            ack_mask = bit.bor(ack_mask, bit.lshift(1, diff - 1))
        end
    end
    
    return ack, ack_mask
end

function rudp.send(state, pkt)
    local now = rudp._now_ms()
    state.last_send_time = now
    
    if pkt.seq == 0 then
        pkt.seq = rudp._next_sequence(state)
    end
    
    local ack, ack_mask = rudp._calculate_ack_mask(state)
    pkt.ack = ack
    pkt.ack_mask = ack_mask
    
    local data = Packet.pack(pkt)
    state.send_func(data)
    
    if Packet.needs_ack(pkt) then
        state.send_buffer[pkt.seq] = {
            packet = pkt,
            send_time = now,
            retries = 0,
            last_send = now,
        }
    end
    
    return true
end

function rudp.send_immediate(state, pkt)
    local now = rudp._now_ms()
    state.last_send_time = now
    
    local ack, ack_mask = rudp._calculate_ack_mask(state)
    pkt.ack = ack
    pkt.ack_mask = ack_mask
    
    state.send_func(Packet.pack(pkt))
end

function rudp.recv(state, pkt)
    local now = rudp._now_ms()
    state.last_recv_time = now
    
    rudp._process_acks(state, pkt.ack, pkt.ack_mask)
    
    if pkt.msg_type == constants.PacketType.ACK then
        return nil
    end
    
    if pkt.seq > 0 then
        if pkt.seq <= state.remote_seq then
            local diff = state.remote_seq - pkt.seq
            if diff < constants.RECV_WINDOW_SIZE then
                return nil
            end
        elseif pkt.seq > state.remote_seq then
            state.remote_seq = pkt.seq
        end
        
        state.recv_window[pkt.seq] = pkt
        rudp._clean_recv_window(state)
    end
    
    if Packet.needs_ack(pkt) then
        local ack, ack_mask = rudp._calculate_ack_mask(state)
        local ack_packet = Packet.new(constants.PacketType.ACK, 0, pkt.seq, ack_mask)
        rudp.send_immediate(state, ack_packet)
    end
    
    return pkt
end

function rudp._process_acks(state, ack, ack_mask)
    local to_remove = {}
    
    for seq, pending in pairs(state.send_buffer) do
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
        state.send_buffer[seq] = nil
    end
end

function rudp._clean_recv_window(state)
    local threshold = state.remote_seq - constants.RECV_WINDOW_SIZE
    local to_remove = {}
    
    for seq, _ in pairs(state.recv_window) do
        if seq <= threshold then
            table.insert(to_remove, seq)
        end
    end
    
    for _, seq in ipairs(to_remove) do
        state.recv_window[seq] = nil
    end
end

function rudp.update(state)
    local now = rudp._now_ms()
    local timeout_ms = constants.RETRY_TIMEOUT_MS
    
    local failed = {}
    local to_remove = {}
    
    for seq, pending in pairs(state.send_buffer) do
        local elapsed = now - pending.last_send
        
        if elapsed >= timeout_ms then
            if pending.retries >= constants.MAX_RETRIES then
                table.insert(failed, pending.packet)
                table.insert(to_remove, seq)
            else
                pending.retries = pending.retries + 1
                pending.last_send = now
                
                local ack, ack_mask = rudp._calculate_ack_mask(state)
                pending.packet.ack = ack
                pending.packet.ack_mask = ack_mask
                
                state.send_func(Packet.pack(pending.packet))
            end
        end
    end
    
    for _, seq in ipairs(to_remove) do
        state.send_buffer[seq] = nil
    end
    
    return failed
end

function rudp.is_timed_out(state)
    local elapsed = rudp._now_ms() - state.last_recv_time
    return elapsed >= constants.CONNECTION_TIMEOUT_MS
end

function rudp.needs_heartbeat(state)
    local elapsed = rudp._now_ms() - state.last_send_time
    return elapsed >= constants.HEARTBEAT_INTERVAL_MS
end

function rudp.get_pending_count(state)
    local count = 0
    for _ in pairs(state.send_buffer) do
        count = count + 1
    end
    return count
end

return rudp
