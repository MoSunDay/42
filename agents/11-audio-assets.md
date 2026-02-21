# Audio Asset Specifications

## 音效系统概述

游戏支持两种音效来源：
1. **文件加载**: 从 `assets/sounds/` 加载 .ogg/.wav 文件
2. **程序化生成**: 当文件不存在时自动生成后备音效

## 目录结构

```
game/assets/sounds/
├── bgm/                       # 背景音乐
│   ├── exploration.ogg        # 探索/主世界
│   ├── battle.ogg             # 战斗
│   ├── town.ogg               # 城镇
│   └── seasonal/              # 季节音乐
│       ├── spring.ogg
│       ├── summer.ogg
│       ├── autumn.ogg
│       └── winter.ogg
└── sfx/                       # 音效
    ├── combat/                # 战斗
    │   ├── attack.ogg
    │   ├── hit.ogg
    │   ├── critical.ogg
    │   ├── block.ogg
    │   ├── dodge.ogg
    │   ├── skill.ogg
    │   ├── victory.ogg
    │   └── defeat.ogg
    ├── ui/                    # 界面
    │   ├── click.ogg
    │   ├── hover.ogg
    │   ├── open.ogg
    │   ├── close.ogg
    │   ├── pickup.ogg
    │   ├── equip.ogg
    │   └── levelup.ogg
    └── character/             # 角色
        ├── hurt.ogg
        └── death.ogg
```

## 音效规格

| 类型 | 格式 | 采样率 | 声道 | 时长 |
|------|------|--------|------|------|
| SFX | OGG/WAV | 44100 Hz | 单声道 | 0.05-0.5s |
| BGM | OGG | 44100 Hz | 立体声 | 循环 |

## SFX 清单

### 战斗音效 (sfx/combat/)

| 文件名 | 用途 | 建议时长 |
|--------|------|----------|
| attack.ogg | 普通攻击 | 0.1-0.2s |
| hit.ogg | 命中伤害 | 0.08-0.15s |
| critical.ogg | 暴击 | 0.15-0.25s |
| block.ogg | 格挡 | 0.1-0.15s |
| dodge.ogg | 闪避 | 0.08-0.12s |
| skill.ogg | 技能释放 | 0.2-0.4s |
| victory.ogg | 胜利 | 0.3-0.5s |
| defeat.ogg | 失败 | 0.4-0.6s |

### UI音效 (sfx/ui/)

| 文件名 | 用途 | 建议时长 |
|--------|------|----------|
| click.ogg | 按钮点击 | 0.05-0.1s |
| hover.ogg | 悬停 | 0.03-0.05s |
| open.ogg | 菜单打开 | 0.1-0.15s |
| close.ogg | 菜单关闭 | 0.08-0.12s |
| pickup.ogg | 拾取物品 | 0.1-0.15s |
| equip.ogg | 装备穿戴 | 0.1-0.2s |
| levelup.ogg | 升级 | 0.3-0.5s |

### 角色音效 (sfx/character/)

| 文件名 | 用途 | 建议时长 |
|--------|------|----------|
| hurt.ogg | 受伤 | 0.1-0.2s |
| death.ogg | 死亡 | 0.3-0.5s |

## BGM 清单

| 文件名 | 场景 | 情绪 |
|--------|------|------|
| exploration.ogg | 主世界探索 | 轻松、冒险 |
| battle.ogg | 战斗 | 紧张、激烈 |
| town.ogg | 城镇 | 平静、温暖 |
| spring.ogg | 春季 | 明亮、希望 |
| summer.ogg | 夏季 | 热情、活力 |
| autumn.ogg | 秋季 | 忧郁、沉思 |
| winter.ogg | 冬季 | 神秘、寂静 |

## 获取音效素材

### 推荐音效库 (CC0/免费)

| 网站 | URL | 说明 |
|------|-----|------|
| Kenney.nl | https://kenney.nl/assets | 高质量游戏音效包 |
| OpenGameArt | https://opengameart.org | 社区贡献 |
| Freesound | https://freesound.org | 大型数据库 |
| Mixkit | https://mixkit.co/free-sound-effects/game/ | 免费游戏音效 |

### 下载占位符音效

```bash
# 生成程序化占位符音效 (WAV格式)
python scripts/download_sounds.py

# 转换为OGG (需要ffmpeg)
find game/assets/sounds -name '*.wav' -exec sh -c 'ffmpeg -y -i "$1" "${1%.wav}.ogg"' _ {} \;
```

## 代码使用

### 播放音效

```lua
local audioSystem = AudioSystem.new()

-- 播放SFX
audioSystem:playSFX("attack")
audioSystem:playSFX("victory")

-- 播放BGM
audioSystem:playBGM("exploration")
audioSystem:playBGM("battle")
audioSystem:playBGM("spring")  -- 季节

-- 音量控制
audioSystem:setMusicVolume(0.3)  -- 0-1
audioSystem:setSFXVolume(0.7)    -- 0-1

-- 停止BGM
audioSystem:stopBGM()
```

### 添加新音效

1. 将音效文件放入对应目录
2. 在 `audio_system.lua` 的 `SFX_PATHS` 或 `BGM_PATHS` 添加路径
3. 系统会自动加载，文件不存在时使用程序化后备

## 后备音效

当音效文件不存在时，系统会自动生成程序化音效：

| 音效 | 频率 | 类型 |
|------|------|------|
| attack | 440 Hz | sine |
| hit | 220 Hz | sine |
| victory | 523 Hz | major chord |
| defeat | 165 Hz | minor chord |
| click | 600 Hz | sine |
| levelup | 880 Hz | arpeggio |

这确保游戏始终有音效可用，便于开发调试。
