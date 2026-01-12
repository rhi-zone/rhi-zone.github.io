# Flora

Rhizome ecosystem monorepo: Lua-based tools, scaffolds, and orchestration.

**Repository:** [github.com/rhizome-lab/flora](https://github.com/rhizome-lab/flora)

## Overview

Flora is a monorepo containing:
- **Lua projects**: Standalone tools run via spore
- **Seeds**: Project templates for nursery scaffolding
- **Documentation**: VitePress docs

## Projects

| Project | Description |
|---------|-------------|
| agent | Autonomous task execution with LLM + moss |

## Seeds

Flora provides seed templates for nursery scaffolding:

| Seed | Description |
|------|-------------|
| `creation` | New project from scratch |
| `archaeology` | Lift a legacy game with siphon + dew |
| `lab` | Full ecosystem sandbox with all tools |

### Using Seeds

```bash
# Scaffold a new project
nursery new my-project --seed flora:creation
```

## Agent

The agent project implements autonomous task execution:

- **State machine**: Role-based execution (investigator, refactorer, etc.)
- **Risk assessment**: Automatic approval for low-risk operations
- **Session management**: Checkpoints, logs, memory persistence
- **Context building**: Smart context for different task types

### Running the Agent

```bash
# Run via spore
spore flora/agent --task "Implement feature X"
```

## Key Integrations

- **nursery**: Reads seeds from flora for project scaffolding
- **spore**: Runs Lua projects with LLM integration
- **moss**: Provides code intelligence via spore-moss

## Links

- [GitHub](https://github.com/rhizome-lab/flora)
- [Nursery](/projects/nursery) - Uses flora seeds
- [Spore](/projects/spore) - Runs flora projects
