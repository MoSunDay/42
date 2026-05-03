# MCP Configuration

项目已配置 Pixellab MCP 用于 AI 生成像素艺术素材。

## 配置文件 (.mcp.json)

配置文件位于项目根目录，格式如下：

```json
{
  "mcpServers": {
    "pixellab": {
      "url": "https://api.pixellab.ai/mcp",
      "transport": "http",
      "headers": {
        "Authorization": "Bearer <YOUR_API_KEY>"
      }
    }
  }
}
```

**注意**: API Key 是敏感信息，请勿提交到版本控制。获取 API Key 请访问 [Pixellab](https://pixellab.ai)。

## 可用工具

| 工具名称 | 功能 | 用途 |
|---------|------|------|
| `generate-pixel-art` | 生成像素艺术图像 | 角色、敌人、NPC、瓦片等 |
| `edit-pixel-art` | 编辑现有像素图像 | 调整、修改已生成的素材 |
| `list-styles` | 列出可用美术风格 | 查看支持的画风选项 |
| `list-presets` | 列出预设配置 | 查看尺寸、调色板预设 |

## 批量生成脚本

UI 素材批量生成使用 `game/tools/generate_all_ui.py`，基于 Pixellab API v2。

- `pixellab_client.py`: API 客户端（异步任务提交+轮询+下载）
- `generate_all_ui.py`: 108 个 UI 素材的完整 manifest，分 5 个 phase

脚本自动跳过已存在的文件。`--replace` 参数会备份旧文件为 `.bak` 后重新生成。

## 使用流程

1. **确定素材规格**: 参考 "Art Asset Specifications" 选择合适的尺寸和帧数
2. **构建提示词**: 使用提示词模板，填入具体描述
3. **调用生成工具**: 通过 MCP 工具生成素材
4. **保存素材**: 将生成的图像保存到 `game/assets/images/` 对应目录

## 常用生成示例

### 角色精灵 (48x48, 8方向)
```
生成战士角色南方向行走动画第1帧:
- 尺寸: 48x48
- 描述: warrior character, heavy armor, holding greatsword, walking pose
- 风格: simple geometric
- 方向: south
- 帧数: 1/6
```

### 敌人精灵 (48x48)
```
生成史莱姆敌人:
- 尺寸: 48x48
- 描述: green slime enemy, blob shape, bouncing idle pose
- 风格: simple geometric
- 主色: #2ecc71
```

### 地图瓦片 (32x32)
```
生成草地瓦片:
- 尺寸: 32x32
- 描述: grass terrain tile, seamless pattern
- 风格: simple geometric
- 主色: #2d5a27, #4a7c59
```

### UI 图标 (24x24)
```
生成技能图标:
- 尺寸: 24x24
- 描述: fire spell icon, flame symbol
- 风格: simple geometric
- 主色: #e94560, #ff6b6b
```

## 批量生成建议

为保持风格一致性，批量生成时：
- 使用相同的风格参数 (simple geometric)
- 限制调色板为 32 色以内
- 保持统一的线条粗细和轮廓风格
- 按类型分组生成（先完成所有角色，再做敌人）
