local constants = {}

constants.PROTOCOL_VERSION = 1
constants.DEFAULT_PORT = 9000
constants.DEFAULT_HOST = "127.0.0.1"

constants.BUFFER_SIZE = 4096
constants.HEADER_SIZE = 13

constants.MAX_RETRIES = 5
constants.RETRY_TIMEOUT_MS = 500
constants.ACK_TIMEOUT_MS = 1000
constants.HEARTBEAT_INTERVAL_MS = 5000
constants.CONNECTION_TIMEOUT_MS = 30000

constants.RECV_WINDOW_SIZE = 64
constants.SEND_BUFFER_SIZE = 256
constants.MAX_PACKET_SIZE = 1400

constants.PacketType = {
    NONE = 0,
    LOGIN = 1,
    REGISTER = 2,
    LOGOUT = 3,
    GET_CHARACTER = 10,
    SAVE_CHARACTER = 11,
    CREATE_CHARACTER = 12,
    LIST_CHARACTERS = 13,
    SELECT_CHARACTER = 14,
    DELETE_CHARACTER = 15,
    POSITION_UPDATE = 20,
    BATTLE_ACTION = 21,
    CHAT_MESSAGE = 30,
    HEARTBEAT = 50,
    ACK = 51,
    NACK = 52,
    ERROR = 100,
}

constants.ReliableTypes = {
    [constants.PacketType.LOGIN] = true,
    [constants.PacketType.REGISTER] = true,
    [constants.PacketType.LOGOUT] = true,
    [constants.PacketType.GET_CHARACTER] = true,
    [constants.PacketType.SAVE_CHARACTER] = true,
    [constants.PacketType.CREATE_CHARACTER] = true,
    [constants.PacketType.LIST_CHARACTERS] = true,
    [constants.PacketType.SELECT_CHARACTER] = true,
    [constants.PacketType.DELETE_CHARACTER] = true,
    [constants.PacketType.BATTLE_ACTION] = true,
    [constants.PacketType.CHAT_MESSAGE] = true,
}

return constants
