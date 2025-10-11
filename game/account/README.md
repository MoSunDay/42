# Account System - 账号系统

## 目录结构

```
account/
├── README.md           # 本文档
├── account_manager.lua # 账号管理器
├── character_data.lua  # 角色数据结构
├── login_ui.lua        # 登录界面
└── data/               # 账号数据存储
    └── accounts.json   # 账号数据文件
```

## 功能

- **账号管理**：创建、登录、保存账号
- **角色数据**：气血、防御、攻击等属性
- **登录界面**：账号密码输入
- **数据持久化**：保存到本地文件

## 使用方法

```lua
local AccountManager = require("account.account_manager")

-- 登录
local success, character = AccountManager.login("username", "password")

-- 获取当前角色
local character = AccountManager.getCurrentCharacter()

-- 保存数据
AccountManager.saveCharacter()
```

