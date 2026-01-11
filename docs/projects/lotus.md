# Lotus

Entity/capability storage layer.

**Repository:** [github.com/rhizome-lab/lotus](https://github.com/rhizome-lab/lotus)

## Overview

Lotus provides persistent storage for entities with capability-based authorization:

- **Entities** - Objects with properties and prototype chains
- **Verbs** - Executable code attached to entities (stored as S-expression JSON)
- **Capabilities** - Authorization tokens for fine-grained permissions
- **Storage** - libsql-backed persistence

## Crates

| Crate | Description |
|-------|-------------|
| `rhizome-lotus-core` | Entity system, capabilities, storage, scheduler |

## Usage

```rust
use rhizome_lotus_core::{WorldStorage, Entity, Capability};

// Open world database
let storage = WorldStorage::open("world.sqlite").await?;

// Create an entity
let entity_id = storage.create_entity(None, serde_json::json!({
    "name": "Room",
    "description": "A quiet room"
})).await?;

// Query entities
let entity = storage.get_entity(entity_id).await?;
```

## Design Notes

Lotus is intentionally minimal - just storage and data structures. Execution (Lua runtime, transpilation) lives in Spore. Federation lives in Hypha.

## Links

- [GitHub](https://github.com/rhizome-lab/lotus)
