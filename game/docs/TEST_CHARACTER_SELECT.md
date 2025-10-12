# 角色选择界面测试指南

## 🐛 问题修复

### 发现的问题
在 `main.lua` 中，`love.mousepressed` 函数被定义了**两次**：
- 第68行：第一次定义
- 第100行：第二次定义（覆盖了第一次）

第二次定义中**缺少**对 `character_select` 模式的处理，导致角色选择界面无法响应鼠标点击。

### 修复方案
合并两个 `love.mousepressed` 函数，添加对所有模式的处理：

```lua
function love.mousepressed(x, y, button)
    -- Handle mouse input based on game mode
    if game.state and game.state:getMode() == "login" then
        game.state:mousepressed(x, y, button)
    elseif game.state and game.state:getMode() == "character_select" then
        game.state:mousepressed(x, y, button)  -- ✅ 添加这一行
    elseif game.inputSystem then
        game.inputSystem:mousepressed(x, y, button)
    end
end
```

## ✅ 测试步骤

### 1. 启动游戏
```bash
cd game
love .
```

### 2. 登录账号
使用测试账号登录：
- **用户名**: `admin`
- **密码**: `admin`

这个账号有2个角色，适合测试。

### 3. 测试键盘交互

#### 测试 ↑↓ 键选择角色
```
✅ 按 ↓ 键 → 选中第2个角色（Warrior）
✅ 按 ↑ 键 → 选中第1个角色（Admin）
✅ 选中的角色应该有高亮背景（蓝色半透明）
```

#### 测试 ENTER 键确认
```
✅ 选中第1个角色
✅ 按 ENTER 键
✅ 应该进入游戏世界
```

### 4. 测试鼠标交互

#### 测试点击角色面板
```
✅ 点击第1个角色面板 → 角色被选中（高亮）
✅ 再次点击同一个角色 → 进入游戏
✅ 或点击第2个角色 → 第2个角色被选中
```

#### 测试点击按钮
```
✅ 点击 "Select" 按钮 → 进入游戏（使用当前选中的角色）
✅ 点击 "Create New" 按钮 → 进入角色创建界面
```

### 5. 测试角色创建界面

#### 测试点击输入框
```
✅ 点击名字输入框 → 输入框激活（蓝色边框）
✅ 输入框显示闪烁光标
✅ 可以输入文字
```

#### 测试点击外观选择
```
✅ 点击任意外观格子 → 外观被选中（蓝色高亮）
✅ 显示外观预览（彩色圆圈）
```

#### 测试创建角色
```
✅ 输入角色名（至少3个字符）
✅ 选择外观
✅ 点击 "Create" 按钮 → 创建成功，返回选择界面
✅ 新角色出现在列表中
```

#### 测试取消创建
```
✅ 点击 "Cancel" 按钮 → 返回选择界面
✅ 输入的内容被清空
```

### 6. 测试键盘输入（创建界面）

#### 测试方向键选择外观
```
✅ 按 ← → 键 → 左右选择外观
✅ 按 ↑ ↓ 键 → 上下选择外观（每行4个）
```

#### 测试文字输入
```
✅ 点击输入框激活
✅ 输入字母和数字
✅ 按 BACKSPACE → 删除字符
✅ 按 ENTER → 关闭输入框
✅ 按 ESC → 关闭输入框
```

## 📊 测试清单

### 角色选择界面
- [ ] 角色列表正确显示
- [ ] 角色信息完整（名字、等级、HP、金币）
- [ ] 角色头像正确显示
- [ ] ↑↓ 键可以选择角色
- [ ] 选中的角色有高亮效果
- [ ] 按 ENTER 可以进入游戏
- [ ] 点击角色面板可以选择
- [ ] 点击 "Select" 按钮可以进入游戏
- [ ] 点击 "Create New" 按钮进入创建界面

### 角色创建界面
- [ ] 输入框可以点击激活
- [ ] 输入框显示闪烁光标
- [ ] 可以输入文字
- [ ] BACKSPACE 可以删除字符
- [ ] 外观格子可以点击选择
- [ ] 选中的外观有高亮效果
- [ ] 方向键可以选择外观
- [ ] 点击 "Create" 创建角色
- [ ] 点击 "Cancel" 返回
- [ ] 创建成功后新角色出现在列表

### 错误处理
- [ ] 名字为空时显示错误提示
- [ ] 名字少于3个字符时显示错误提示
- [ ] 名字重复时显示错误提示

## 🎮 完整测试流程

### 流程1：选择已有角色
```
1. 启动游戏
2. 登录 admin/admin
3. 看到2个角色：Admin (Lv.10) 和 Warrior (Lv.8)
4. 点击 Admin 角色面板
5. Admin 被选中（蓝色高亮）
6. 再次点击 Admin 或点击 "Select" 按钮
7. 进入游戏世界
8. 看到角色在地图上
9. 左侧显示组队UI（Admin 作为队长）
10. 左下角显示聊天框
```

### 流程2：创建新角色
```
1. 启动游戏
2. 登录 test/123
3. 看到1个角色：Test Hero (Lv.5)
4. 点击 "Create New" 按钮
5. 进入创建界面
6. 点击输入框
7. 输入 "NewHero"
8. 点击 "Green Ranger" 外观
9. 点击 "Create" 按钮
10. 返回选择界面
11. 看到2个角色：Test Hero 和 NewHero
12. 点击 NewHero
13. 进入游戏
```

### 流程3：测试错误处理
```
1. 进入创建界面
2. 不输入名字，直接点击 "Create"
3. 显示错误："Name cannot be empty!"
4. 输入 "AB"（只有2个字符）
5. 点击 "Create"
6. 显示错误："Name must be at least 3 characters!"
7. 输入已存在的角色名
8. 点击 "Create"
9. 显示错误："Name already taken!"
```

## 🔍 调试信息

如果遇到问题，检查以下内容：

### 1. 检查控制台输出
```bash
# 启动游戏时应该看到：
Loading accounts from memory...
Created 3 default accounts:
  - test/123 (Level 5)
  - admin/admin (Level 10)
  - player/pass (Level 1)
Account system initialized
```

### 2. 检查角色数据
在 `game_state.lua` 中添加调试输出：
```lua
-- 在 mousepressed 中添加
elseif self.mode == GAME_MODE.CHARACTER_SELECT then
    print("Character select mouse click:", x, y, button)
    local character = self.characterSelectUI:mousepressed(x, y, button, AccountManager, self.currentUsername)
    if character then
        print("Selected character:", character.characterName)
        -- ...
    end
end
```

### 3. 检查事件路由
在 `main.lua` 中添加调试输出：
```lua
function love.mousepressed(x, y, button)
    print("Mouse pressed:", x, y, button, "Mode:", game.state:getMode())
    -- ...
end
```

## 📝 已知问题和解决方案

### 问题1: 点击无响应
**原因**: `love.mousepressed` 函数重复定义
**解决**: 已修复，合并为一个函数

### 问题2: 角色不显示
**原因**: 字段名不匹配（`name` vs `characterName`）
**解决**: 已修复，使用 `characterName`

### 问题3: 外观不显示
**原因**: `AppearanceSystem` 未正确加载
**解决**: 检查 `appearance_system.lua` 是否存在

## ✅ 验证成功标准

所有以下功能都正常工作：
- ✅ 角色列表显示
- ✅ 键盘选择角色
- ✅ 鼠标点击角色
- ✅ 按钮点击响应
- ✅ 创建新角色
- ✅ 输入框交互
- ✅ 外观选择
- ✅ 错误提示

## 🎯 下一步

测试通过后，可以继续测试：
1. 游戏内功能（移动、战斗）
2. 组队系统
3. 聊天系统
4. 全屏地图

---

**祝测试顺利！** 🎮✨

