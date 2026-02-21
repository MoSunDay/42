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

## 最近更新 (0b5db5a)

新增系统和功能：
- **程序化地图生成**: MapGenerator + 10种主题地图
- **地图注册表**: 解锁进度 + 等级范围管理
- **传送NPC**: 维度向导，支持地图传送
- **UI组件模块**: 9-slice面板、按钮等可复用组件
- **NPC数据库扩展**: Boss/Friendly/Monster 分类

详见各模块文档的 `docs/summary.md`。
