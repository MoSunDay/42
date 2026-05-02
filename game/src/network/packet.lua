local constants = require("network.constants")
local bit = require("bit")

local packet = {}

local function pack_u16(value)
    return string.char(
        math.floor(value / 256) % 256,
        value % 256
    )
end

local function pack_u8(value)
    return string.char(value % 256)
end

local function pack_u32(value)
    return string.char(
        math.floor(value / 16777216) % 256,
        math.floor(value / 65536) % 256,
        math.floor(value / 256) % 256,
        value % 256
    )
end

local function unpack_u16(data, offset)
    local b1 = data:byte(offset)
    local b2 = data:byte(offset + 1)
    return b1 * 256 + b2
end

local function unpack_u8(data, offset)
    return data:byte(offset)
end

local function unpack_u32(data, offset)
    local b1 = data:byte(offset)
    local b2 = data:byte(offset + 1)
    local b3 = data:byte(offset + 2)
    local b4 = data:byte(offset + 3)
    return b1 * 16777216 + b2 * 65536 + b3 * 256 + b4
end

function packet.create(msg_type, seq, ack, ack_mask, payload, flags)
    return {
        msg_type = msg_type or 0,
        seq = seq or 0,
        ack = ack or 0,
        ack_mask = ack_mask or 0,
        payload = payload or "",
        flags = flags or 0,
        timestamp = 0,
    }
end

packet.new = packet.create

function packet.is_reliable(pkt)
    if constants.ReliableTypes[pkt.msg_type] then
        return true
    end
    return bit.band(pkt.flags, 0x01) ~= 0
end

function packet.needs_ack(pkt)
    return packet.is_reliable(pkt) and pkt.msg_type ~= constants.PacketType.ACK
end

function packet.pack(pkt)
    local total_len = constants.HEADER_SIZE + #pkt.payload
    
    local header = pack_u16(total_len)
        .. pack_u8(pkt.msg_type)
        .. pack_u8(pkt.flags)
        .. pack_u32(pkt.seq)
        .. pack_u32(pkt.ack)
        .. pack_u8(pkt.ack_mask)
    
    return header .. pkt.payload
end

function packet.unpack(data)
    if #data < 8 then
        return nil, "Packet too short"
    end
    
    local total_len = unpack_u16(data, 1)
    local msg_type = unpack_u8(data, 3)
    local flags = unpack_u8(data, 4)
    local seq = unpack_u32(data, 5)
    
    local ack, ack_mask = 0, 0
    if #data >= 13 then
        ack = unpack_u32(data, 9)
        ack_mask = unpack_u8(data, 13)
    end
    
    local payload = ""
    if total_len > 13 then
        payload = data:sub(14, total_len)
    end
    
    return packet.create(msg_type, seq, ack, ack_mask, payload, flags)
end

function packet.set_payload_json(pkt, data)
    local json = require("lib.json")
    pkt.payload = json.encode(data)
end

function packet.get_payload_json(pkt)
    if not pkt.payload or #pkt.payload == 0 then
        return nil
    end
    local json = require("lib.json")
    local ok, result = pcall(json.decode, pkt.payload)
    if ok then
        return result
    end
    return nil
end

return packet
