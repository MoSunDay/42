# Game Account API Server

Simple HTTP API server using Python Sanic framework for managing game accounts and character data.

## Features

- ✅ Account registration
- ✅ Account login with password hashing
- ✅ Character data management
- ✅ Persistent storage (JSON file)
- ✅ RESTful API design
- ✅ Auto-reload in development mode

## Installation

### 1. Install Python Dependencies

```bash
cd game/server
pip install -r requirements.txt
```

### 2. Run the Server

```bash
python app.py
```

The server will start on `http://localhost:8000`

## API Endpoints

### 1. Health Check

**GET** `/api/health`

Check if the server is running.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-11T10:30:00",
  "accounts_count": 2
}
```

### 2. Register Account

**POST** `/api/register`

Create a new account.

**Request Body:**
```json
{
  "username": "player1",
  "password": "mypassword",
  "characterName": "Warrior",
  "avatarColor": [1.0, 0.5, 0.2]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Account created successfully",
  "username": "player1"
}
```

### 3. Login

**POST** `/api/login`

Login to an existing account.

**Request Body:**
```json
{
  "username": "test",
  "password": "123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "character": {
    "characterName": "Hero",
    "level": 5,
    "exp": 50,
    "gold": 500,
    "hp": 150,
    "maxHp": 150,
    "attack": 25,
    "defense": 10,
    "speed": 6,
    "x": 1000,
    "y": 1200,
    "mapId": "town_01",
    "avatarColor": [0.2, 0.6, 1.0]
  }
}
```

### 4. Get Account Info

**GET** `/api/account/<username>`

Get account information.

**Response:**
```json
{
  "success": true,
  "account": {
    "username": "test",
    "character": {...},
    "created_at": "2025-10-11T10:00:00",
    "last_login": "2025-10-11T10:30:00"
  }
}
```

### 5. Update Account

**PUT** `/api/account/<username>`

Update character data.

**Request Body:**
```json
{
  "character": {
    "characterName": "Hero",
    "level": 6,
    "exp": 75,
    "gold": 650,
    "hp": 180,
    "maxHp": 180,
    "attack": 28,
    "defense": 12,
    "speed": 6,
    "x": 1500,
    "y": 1800,
    "mapId": "town_01",
    "avatarColor": [0.2, 0.6, 1.0]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Account updated successfully"
}
```

### 6. List All Accounts

**GET** `/api/accounts`

List all accounts (admin endpoint).

**Response:**
```json
{
  "success": true,
  "count": 2,
  "accounts": [
    {
      "username": "test",
      "level": 5,
      "gold": 500,
      "created_at": "2025-10-11T10:00:00",
      "last_login": "2025-10-11T10:30:00"
    },
    {
      "username": "admin",
      "level": 10,
      "gold": 9999,
      "created_at": "2025-10-11T10:00:00",
      "last_login": null
    }
  ]
}
```

## Default Accounts

The server comes with two default accounts:

| Username | Password | Level | Gold |
|----------|----------|-------|------|
| test     | 123      | 5     | 500  |
| admin    | admin    | 10    | 9999 |

## Data Storage

Account data is stored in `server/data/accounts.json`.

**Example:**
```json
{
  "test": {
    "username": "test",
    "password_hash": "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3",
    "character": {
      "characterName": "Hero",
      "level": 5,
      "exp": 50,
      "gold": 500,
      "hp": 150,
      "maxHp": 150,
      "attack": 25,
      "defense": 10,
      "speed": 6,
      "x": 1000,
      "y": 1200,
      "mapId": "town_01",
      "avatarColor": [0.2, 0.6, 1.0]
    },
    "created_at": "2025-10-11T10:00:00",
    "last_login": "2025-10-11T10:30:00"
  }
}
```

## Testing with curl

### Register
```bash
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"player1","password":"pass123","characterName":"Warrior"}'
```

### Login
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123"}'
```

### Get Account
```bash
curl http://localhost:8000/api/account/test
```

### Update Account
```bash
curl -X PUT http://localhost:8000/api/account/test \
  -H "Content-Type: application/json" \
  -d '{"character":{"characterName":"Hero","level":6,"exp":75,"gold":650,"hp":180,"maxHp":180,"attack":28,"defense":12,"speed":6,"x":1500,"y":1800,"mapId":"town_01","avatarColor":[0.2,0.6,1.0]}}'
```

### List Accounts
```bash
curl http://localhost:8000/api/accounts
```

## Security Notes

⚠️ **This is a simple implementation for development/learning purposes.**

For production use, you should add:
- JWT authentication tokens
- HTTPS/TLS encryption
- Rate limiting
- Input validation and sanitization
- SQL database instead of JSON file
- Password complexity requirements
- Account lockout after failed attempts
- CORS configuration
- Logging and monitoring

## Integration with Game Client

The game client can use HTTP requests to communicate with this API:

```lua
-- Example: Login (requires HTTP library)
local http = require("socket.http")
local json = require("json")

local response = http.request{
    url = "http://localhost:8000/api/login",
    method = "POST",
    headers = {
        ["Content-Type"] = "application/json"
    },
    source = ltn12.source.string(json.encode({
        username = "test",
        password = "123"
    }))
}
```

## Development

### Auto-reload

The server runs in debug mode with auto-reload enabled. Any changes to `app.py` will automatically restart the server.

### Adding New Endpoints

1. Add a new route function:
```python
@app.route("/api/myendpoint", methods=["GET"])
async def my_endpoint(request: Request):
    return json_response({"message": "Hello!"})
```

2. The server will auto-reload and the endpoint will be available.

## Troubleshooting

### Port Already in Use

If port 8000 is already in use, change the port in `app.py`:
```python
app.run(host="0.0.0.0", port=8001, debug=True)
```

### Module Not Found

Make sure you've installed the requirements:
```bash
pip install -r requirements.txt
```

### Permission Denied

Make sure the script is executable:
```bash
chmod +x app.py
```

## License

MIT License - Feel free to use and modify for your projects.

