# Art Asset Specifications

## 美术风格

**风格**: 简约几何风格 (Simple Geometric)
**特点**: 简洁几何形状, 清晰轮廓, 统一线条粗细, 现代极简美学

## 调色板 (32色)

```
主色调:
- 背景: #1a1a2e, #16213e, #0f3460
- 前景: #e8e8e8, #c8c8c8, #a0a0a0
- 强调: #e94560, #ff6b6b, #4ecdc4, #45b7d1
- 自然: #2d5a27, #4a7c59, #8b7355, #d4a574
- 魔法: #9b59b6, #3498db, #1abc9c, #f39c12
```

## 素材规格

| 类型 | 尺寸 | 帧数 | 方向 | 说明 |
|------|------|------|------|------|
| 玩家角色精灵 | 48x48 | 行走6帧 + 待机4帧 | 8方向 | 支持多职业外观 |
| 玩家头像 | 64x64 | 1帧 | 1 | 角色选择/状态显示 |
| 组队头像 | 32x32 | 1帧 | 1 | 队伍成员显示 |
| 敌人精灵 | 48x48 | 待机4帧 | 4方向 | 15种敌人类型 |
| NPC精灵 | 48x48 | 待机4帧 | 4方向 | 6种NPC类型 |
| 地图瓦片 | 32x32 | 1帧 | 1 | 地形/物体 |
| UI面板 | 可变 | - | - | 按钮/边框/背景 |
| UI图标 | 24x24 | 1帧 | 1 | 技能/物品/状态 |

## 目录结构

```
game/assets/
├── images/
│   ├── characters/
│   │   ├── warrior/           # 战士
│   │   │   ├── rotations/     # 8方向静态图
│   │   │   │   ├── north.png
│   │   │   │   ├── south.png
│   │   │   │   └── ...
│   │   │   └── animations/
│   │   │       ├── walking/   # 行走动画
│   │   │       └── breathing-idle/  # 待机动画
│   │   ├── mage/              # 法师
│   │   ├── archer/            # 弓箭手
│   │   ├── rogue/             # 盗贼
│   │   ├── cleric/            # 牧师
│   │   ├── knight/            # 骑士
│   │   ├── wizard/            # 巫师
│   │   ├── rangers/           # 游侠
│   │   ├── enemies/           # 敌人精灵
│   │   └── npcs/              # NPC精灵
│   ├── portraits/
│   │   ├── large/             # 64x64 头像
│   │   └── small/             # 32x32 组队头像
│   ├── ui/
│   │   ├── panels/            # 面板背景
│   │   ├── buttons/           # 按钮
│   │   ├── icons/             # 图标
│   │   ├── borders/           # 边框
│   │   ├── login/             # 登录界面
│   │   ├── character_select/  # 角色选择
│   │   ├── chat/              # 聊天框
│   │   └── menu/              # 菜单
│   └── tilesets/
│       ├── terrain/           # 地形瓦片
│       └── objects/           # 物体瓦片
├── fonts/
│   └── (TTF/OTF 字体文件)
└── sounds/
    ├── bgm/                   # 背景音乐
    └── sfx/                   # 音效
```

## 角色职业列表

| ID | 名称 | 主色调 | 特点 |
|----|------|--------|------|
| warrior | 战士 | #c0392b | 重甲, 大剑 |
| mage | 法师 | #9b59b6 | 长袍, 法杖 |
| archer | 弓箭手 | #27ae60 | 轻甲, 弓箭 |
| rogue | 盗贼 | #34495e | 皮甲, 匕首 |
| cleric | 牧师 | #f1c40f | 白袍, 圣光 |
| knight | 骑士 | #2980b9 | 板甲, 盾牌 |
| wizard | 巫师 | #8e44ad | 法师帽, 魔法书 |
| ranger | 游侠 | #16a085 | 斗篷, 双刀 |

## 敌人类型列表

| 层级 | ID | 名称 | 主色调 |
|------|----|------|--------|
| Tier 1 | slime | 史莱姆 | #2ecc71 |
| Tier 1 | goblin | 哥布林 | #8b4513 |
| Tier 1 | skeleton | 骷髅 | #f5f5f5 |
| Tier 1 | bat | 蝙蝠 | #4a0080 |
| Tier 2 | orc_warrior | 兽人战士 | #556b2f |
| Tier 2 | skeleton_knight | 骷髅骑士 | #a0a0c0 |
| Tier 2 | wolf | 恶狼 | #696969 |
| Tier 2 | dark_mage | 黑暗法师 | #4b0082 |
| Tier 3 | orc_chieftain | 兽人酋长 | #2f4f2f |
| Tier 3 | vampire | 吸血鬼 | #8b0000 |
| Tier 3 | golem | 石像鬼 | #808080 |
| Tier 3 | demon | 恶魔 | #dc143c |
| Tier 4 | ancient_dragon | 远古巨龙 | #cd853f |
| Tier 4 | lich_king | 巫妖王 | #1a1a2e |
| Tier 4 | chaos_serpent | 混沌巨蛇 | #8b008b |

## NPC类型列表

| ID | 名称 | 主色调 | 功能 |
|----|------|--------|------|
| villager | 村民 | #d4a574 | 对话 |
| merchant | 商人 | #f39c12 | 交易 |
| healer | 治疗师 | #2ecc71 | 治疗 |
| guard | 守卫 | #3498db | 信息 |
| quest_giver | 任务NPC | #9b59b6 | 任务 |
| elder | 长者 | #e8e8e8 | 剧情 |

## UI元素规格

| 元素 | 尺寸 | 说明 |
|------|------|------|
| 登录面板 | 400x300 | 居中显示 |
| 角色选择面板 | 600x400 | 显示角色列表 |
| 聊天框 | 350x150 | 半透明背景 |
| 菜单面板 | 200x250 | 选项按钮 |
| 技能图标 | 48x48 | 技能栏 |
| 状态图标 | 24x24 | buff/debuff |
| HP/MP条 | 可变宽度x20 | 血条/蓝条 |

## 生成素材时的提示词模板

```
Simple geometric pixel art, 48x48 pixels, [subject], 
clean outlines, limited color palette (max 32 colors),
view direction: [north/south/east/west],
animation frame: [1-6],
style: minimalist geometric shapes, flat colors,
game asset, transparent background
```
