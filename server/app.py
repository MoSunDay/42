#!/usr/bin/env python3
"""
Game Account API Server
Simple HTTP API using Sanic framework for account management
"""

from sanic import Sanic, response
from sanic.request import Request
from sanic.response import json as json_response
import json as json_module
import hashlib
import os
from datetime import datetime

app = Sanic("GameAccountAPI")

# Data file path
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
ACCOUNTS_FILE = os.path.join(DATA_DIR, "accounts.json")

# Ensure data directory exists
os.makedirs(DATA_DIR, exist_ok=True)

# In-memory database (loaded from file)
accounts_db = {}


def load_accounts():
    """Load accounts from JSON file"""
    global accounts_db
    if os.path.exists(ACCOUNTS_FILE):
        with open(ACCOUNTS_FILE, 'r', encoding='utf-8') as f:
            accounts_db = json_module.load(f)
    else:
        # Initialize with default accounts
        accounts_db = {
            "test": {
                "username": "test",
                "password_hash": hashlib.sha256("123".encode()).hexdigest(),
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
                "created_at": datetime.now().isoformat(),
                "last_login": None
            },
            "admin": {
                "username": "admin",
                "password_hash": hashlib.sha256("admin".encode()).hexdigest(),
                "character": {
                    "characterName": "Admin",
                    "level": 10,
                    "exp": 0,
                    "gold": 9999,
                    "hp": 300,
                    "maxHp": 300,
                    "attack": 50,
                    "defense": 20,
                    "speed": 8,
                    "x": 1000,
                    "y": 1200,
                    "mapId": "town_01",
                    "avatarColor": [1.0, 0.2, 0.2]
                },
                "created_at": datetime.now().isoformat(),
                "last_login": None
            }
        }
        save_accounts()


def save_accounts():
    """Save accounts to JSON file"""
    with open(ACCOUNTS_FILE, 'w', encoding='utf-8') as f:
        json_module.dump(accounts_db, f, indent=2, ensure_ascii=False)


def hash_password(password: str) -> str:
    """Hash password using SHA256"""
    return hashlib.sha256(password.encode()).hexdigest()


# Load accounts on startup
load_accounts()


@app.route("/")
async def index(request: Request):
    """API root endpoint"""
    return json_response({
        "name": "Game Account API",
        "version": "1.0.0",
        "endpoints": {
            "POST /api/register": "Register new account",
            "POST /api/login": "Login to account",
            "GET /api/account/<username>": "Get account info",
            "PUT /api/account/<username>": "Update account data",
            "GET /api/accounts": "List all accounts (admin)",
            "GET /api/health": "Health check"
        }
    })


@app.route("/api/health")
async def health(request: Request):
    """Health check endpoint"""
    return json_response({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "accounts_count": len(accounts_db)
    })


@app.route("/api/register", methods=["POST"])
async def register(request: Request):
    """Register a new account"""
    data = request.json
    
    if not data or "username" not in data or "password" not in data:
        return json_response({
            "success": False,
            "error": "Missing username or password"
        }, status=400)
    
    username = data["username"]
    password = data["password"]
    
    # Check if username already exists
    if username in accounts_db:
        return json_response({
            "success": False,
            "error": "Username already exists"
        }, status=409)
    
    # Create new account
    accounts_db[username] = {
        "username": username,
        "password_hash": hash_password(password),
        "character": {
            "characterName": data.get("characterName", username),
            "level": 1,
            "exp": 0,
            "gold": 100,
            "hp": 100,
            "maxHp": 100,
            "attack": 15,
            "defense": 5,
            "speed": 6,
            "x": 1000,
            "y": 1200,
            "mapId": "town_01",
            "avatarColor": data.get("avatarColor", [0.2, 0.6, 1.0])
        },
        "created_at": datetime.now().isoformat(),
        "last_login": None
    }
    
    save_accounts()
    
    return json_response({
        "success": True,
        "message": "Account created successfully",
        "username": username
    }, status=201)


@app.route("/api/login", methods=["POST"])
async def login(request: Request):
    """Login to an account"""
    data = request.json
    
    if not data or "username" not in data or "password" not in data:
        return json_response({
            "success": False,
            "error": "Missing username or password"
        }, status=400)
    
    username = data["username"]
    password = data["password"]
    
    # Check if account exists
    if username not in accounts_db:
        return json_response({
            "success": False,
            "error": "Invalid username or password"
        }, status=401)
    
    account = accounts_db[username]
    
    # Verify password
    if account["password_hash"] != hash_password(password):
        return json_response({
            "success": False,
            "error": "Invalid username or password"
        }, status=401)
    
    # Update last login
    account["last_login"] = datetime.now().isoformat()
    save_accounts()
    
    return json_response({
        "success": True,
        "message": "Login successful",
        "character": account["character"]
    })


@app.route("/api/account/<username>", methods=["GET"])
async def get_account(request: Request, username: str):
    """Get account information"""
    if username not in accounts_db:
        return json_response({
            "success": False,
            "error": "Account not found"
        }, status=404)
    
    account = accounts_db[username]
    
    return json_response({
        "success": True,
        "account": {
            "username": account["username"],
            "character": account["character"],
            "created_at": account["created_at"],
            "last_login": account["last_login"]
        }
    })


@app.route("/api/account/<username>", methods=["PUT"])
async def update_account(request: Request, username: str):
    """Update account data"""
    if username not in accounts_db:
        return json_response({
            "success": False,
            "error": "Account not found"
        }, status=404)
    
    data = request.json
    if not data or "character" not in data:
        return json_response({
            "success": False,
            "error": "Missing character data"
        }, status=400)
    
    # Update character data
    accounts_db[username]["character"] = data["character"]
    save_accounts()
    
    return json_response({
        "success": True,
        "message": "Account updated successfully"
    })


@app.route("/api/accounts", methods=["GET"])
async def list_accounts(request: Request):
    """List all accounts (admin endpoint)"""
    accounts_list = []
    for username, account in accounts_db.items():
        accounts_list.append({
            "username": username,
            "level": account["character"]["level"],
            "gold": account["character"]["gold"],
            "created_at": account["created_at"],
            "last_login": account["last_login"]
        })
    
    return json_response({
        "success": True,
        "count": len(accounts_list),
        "accounts": accounts_list
    })


if __name__ == "__main__":
    print("=" * 60)
    print("Game Account API Server")
    print("=" * 60)
    print("Starting server on http://0.0.0.0:8000")
    print("Press Ctrl+C to stop")
    print("=" * 60)
    
    app.run(host="0.0.0.0", port=8000, debug=True, auto_reload=True)

