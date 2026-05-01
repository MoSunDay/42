# AGENTS.md - Coding Agent Guidelines

This document provides guidelines for AI coding agents working on this codebase.

## 文档索引

详细指南请参考 `agents/` 目录下的模块化文档：

| 文档 | 说明 |
|------|------|
| [01-overview.md](agents/01-overview.md) | 项目概述 |
| [02-build-and-run.md](agents/02-build-and-run.md) | 构建运行命令与测试 |
| [03-code-style.md](agents/03-code-style.md) | 代码风格指南 (Lua/Python) |
| [04-project-structure.md](agents/04-project-structure.md) | 项目结构 |
| [05-architecture.md](agents/05-architecture.md) | 架构说明 |
| [06-common-tasks.md](agents/06-common-tasks.md) | 常见开发任务 |
| [07-documentation.md](agents/07-documentation.md) | 模块文档指南 |
| [08-constraints.md](agents/08-constraints.md) | 重要约束 |
| [09-mcp-configuration.md](agents/09-mcp-configuration.md) | MCP 素材工具配置 |
| [10-art-assets.md](agents/10-art-assets.md) | 美术素材规格 |
| [11-audio-assets.md](agents/11-audio-assets.md) | 音效素材规格 |
| [12-battle-simulator.md](agents/12-battle-simulator.md) | 战斗模拟器 |

## 最近更新 (2026-02-21)

新增职业和技能系统：
- **6个职业**: 双刀流/巨剑士/侠客/封印师/治愈师/元素师
- **18个技能**: 每个职业3-4个技能
- **无限升级**: 灵晶消耗曲线，效果每级+3%
- **角色创建**: 3步流程（名字→职业→外观）
- **战斗技能**: 战斗中选择并释放技能

详见 [docs/CLASS_SKILL_SYSTEM.md](game/docs/CLASS_SKILL_SYSTEM.md)。
