# Spore

Agentic AI framework with Lua scripting—spun out from [Moss](/projects/moss).

**Repository:** [github.com/rhizome-lab/spore](https://github.com/rhizome-lab/spore)

## Overview

Spore provides infrastructure for building AI coding agents:

- **Multi-provider LLM client** - Anthropic, OpenAI, Gemini, and 10 more via rig-core
- **Memory store** - SQLite-backed persistent context with metadata queries
- **Agent scripts** - Lua-based state machine with planner/explorer/evaluator roles

## Philosophy

**Spore** = agency/execution (LLM calls, memory, running agents)
**Moss** = intelligence (code analysis, session parsing, understanding)

The projects are intentionally not hard-linked. Moss can optionally extend Spore via a plugin architecture (dynamic library adding commands to Spore's Lua runtime).

## Crates

| Crate | Description |
|-------|-------------|
| `rhizome-spore-core` | LLM client and memory store infrastructure |
| `rhizome-spore-lua` | Lua runtime with Integration trait for plugins |

### Integrations

| Crate | Description |
|-------|-------------|
| `rhizome-spore-moss` | [Moss](/projects/moss) code intelligence integration |
| `rhizome-spore-lotus` | [Lotus](/projects/lotus) world state integration |

## LLM Providers

Spore supports 13 LLM providers via rig-core:

- Anthropic, OpenAI, Azure, Gemini, Cohere, DeepSeek
- Groq, Mistral, Ollama, OpenRouter, Perplexity, Together, XAI

## Agent Architecture

The Lua agent scripts implement a state machine:

```
planner → explorer → evaluator (cycle)
```

Features:
- Shadow worktree mode for safe editing
- Checkpoint/resume for interrupted sessions
- Loop detection and max-turn safeguards
- Risk assessment for proposed changes

## Usage

```rust
use rhizome_spore_core::{LlmClient, MemoryStore};
use rhizome_spore_lua::Runtime;

// Create LLM client
let client = LlmClient::new("anthropic", Some("claude-sonnet-4-5"))?;
let response = client.complete(None, "Explain this code...", Some(1000))?;

// Persistent memory
let memory = MemoryStore::open(&project_root)?;
memory.store("context", Some("agent"), 1.0, json!({}))?;

// Run agent with moss integration
use rhizome_spore_moss::MossIntegration;
let runtime = Runtime::new()?;
runtime.register(&MossIntegration::new("."))?;
runtime.run_file(Path::new("scripts/agent.lua"))?;
```

## Links

- [GitHub](https://github.com/rhizome-lab/spore)
- [Documentation](https://rhizome-lab.github.io/spore/)
