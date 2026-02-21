# Module Documentation

This project uses a multi-layer documentation system:
- **AGENTS.md** - Index file with links to modular documentation
- **agents/** - Modular documentation files for different topics
- **docs/summary.md** - Per-module technical documentation
- **.opencode/skills/** - Reusable agent instruction sets

## AGENTS.md Structure

The main `AGENTS.md` is now an index that references modular files in `agents/`:

| File | Content |
|------|---------|
| `agents/01-overview.md` | Project overview |
| `agents/02-build-and-run.md` | Build & run commands |
| `agents/03-code-style.md` | Code style guidelines |
| `agents/04-project-structure.md` | Project structure |
| `agents/05-architecture.md` | Architecture notes |
| `agents/06-common-tasks.md` | Common tasks |
| `agents/07-documentation.md` | Module documentation (this file) |
| `agents/08-constraints.md` | Important constraints |
| `agents/09-mcp-configuration.md` | MCP tool configuration |
| `agents/10-art-assets.md` | Art asset specifications |

## Module Documentation Locations

Each code module has a `docs/summary.md` file that describes:
- Module purpose and functionality
- Main files and their responsibilities
- Key APIs and functions

| Module | docs/summary.md Path |
|--------|---------------------|
| Game Client | `game/docs/summary.md` |
| Core Systems | `game/src/core/docs/summary.md` |
| Entities | `game/src/entities/docs/summary.md` |
| Systems | `game/src/systems/docs/summary.md` |
| Battle System | `game/src/systems/battle/docs/summary.md` |
| UI | `game/src/ui/docs/summary.md` |
| Battle UI | `game/src/ui/battle/docs/summary.md` |
| Animations | `game/src/animations/docs/summary.md` |
| Network | `game/src/network/docs/summary.md` |
| Account | `game/account/docs/summary.md` |
| Map | `game/map/docs/summary.md` |
| NPCs | `game/npcs/docs/summary.md` |
| Server | `server/docs/summary.md` |
| Server Handlers | `server/handlers/docs/summary.md` |
| Server Protocol | `server/protocol/docs/summary.md` |
| Server Storage | `server/storage/docs/summary.md` |
| Tests | `tests/docs/summary.md` |
| Tools | `tools/docs/summary.md` |

## Documentation Guidelines

**Before committing code changes:**
1. Check if changes affect any module's functionality
2. Update the corresponding `docs/summary.md` if:
   - New files are added to the module
   - Key APIs are changed/added/removed
   - Module purpose or architecture changes
3. Update the "Last updated" line with the commit ID

**Pre-commit hook** will remind you to check relevant documentation.

## Agent Skills

Skills are reusable instruction sets stored in `.opencode/skills/<name>/SKILL.md`. They can be loaded on-demand via the `skill` tool.

### Available Skills

| Skill | Description |
|-------|-------------|
| `update-docs` | Update module documentation when code changes are made |

### Using Skills

To use a skill, invoke the skill tool:

```
skill({ name: "update-docs" })
```

### Creating New Skills

Create a new skill by adding a directory and `SKILL.md` file:

```
.opencode/skills/<skill-name>/SKILL.md
```

Required frontmatter:
```yaml
---
name: skill-name
description: Brief description of what this skill does
---
```
