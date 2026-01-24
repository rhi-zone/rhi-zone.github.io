# Zone

rhi ecosystem monorepo: Lua-based tools, scaffolds, and orchestration.

**Repository:** [github.com/rhi-zone/zone](https://github.com/rhi-zone/zone)

## Overview

Zone is a monorepo containing:
- **Lua projects**: Standalone tools run via moonlet
- **Seeds**: Project templates for myenv scaffolding
- **Documentation**: VitePress docs

## Projects

| Project | Description |
|---------|-------------|
| agent | Autonomous task execution with LLM + normalize |

## Seeds

Zone provides seed templates for myenv scaffolding:

| Seed | Description |
|------|-------------|
| `creation` | New project from scratch |
| `archaeology` | Lift a legacy game with resurrect + dew |
| `lab` | Full ecosystem sandbox with all tools |

### Using Seeds

```bash
# Scaffold a new project
myenv new my-project --seed zone:creation
```

## Agent

The agent project implements autonomous task execution:

- **State machine**: Role-based execution (investigator, refactorer, etc.)
- **Risk assessment**: Automatic approval for low-risk operations
- **Session management**: Checkpoints, logs, memory persistence
- **Context building**: Smart context for different task types

### Running the Agent

```bash
# Run via moonlet
moonlet zone/agent --task "Implement feature X"
```

## Key Integrations

- **myenv**: Reads seeds from zone for project scaffolding
- **moonlet**: Runs Lua projects with LLM integration
- **normalize**: Provides code intelligence via moonlet-normalize

## Links

- [GitHub](https://github.com/rhi-zone/zone)
- [Myenv](/projects/myenv) - Uses zone seeds
- [Moonlet](/projects/moonlet) - Runs zone projects
