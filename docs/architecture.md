# Architecture Overview

How rhi projects are structured and how they relate.

## Project Landscape

```mermaid
graph TB
    subgraph "Code Intelligence"
        M[Normalize]
        M --> |view| AST[AST Navigation]
        M --> |edit| SE[Structural Editing]
        M --> |analyze| AN[Code Analysis]
    end

    subgraph "Runtime"
        L[Lotus]
        L --> ES[Entity System]
        L --> LUA[Lua Scripting]
        L --> PS[Persistence]
    end

    subgraph "Media Generation"
        R[Unshape]
        R --> MESH[Meshes]
        R --> AUD[Audio]
        R --> TEX[Textures]
        R --> VEC[Vector]
        R --> RIG[Rigging]
    end
```

## Normalize Architecture

Structural code intelligence with three primitives:

```mermaid
flowchart LR
    subgraph Input
        CLI[CLI]
        MCP[MCP Server]
        LIB[Library]
    end

    subgraph Core
        GL[Grammar Loader]
        SE[Skeleton Extractor]
        IDX[File Index]
    end

    subgraph Output
        JSON[JSON]
        TEXT[Text]
        SHADOW[Shadow Git]
    end

    CLI --> GL
    MCP --> GL
    LIB --> GL
    GL --> SE
    SE --> IDX
    IDX --> JSON
    IDX --> TEXT
    IDX --> SHADOW
```

Key components:
- **Grammar Loader**: Dynamic `.so` loading for 98 tree-sitter grammars
- **Skeleton Extractor**: AST → structured output (signatures, dependencies, calls)
- **File Index**: SQLite symbol/call graph with background daemon
- **Shadow Git**: Hunk-level edit tracking in `.normalize/.git`

## Lotus Architecture

Persistent multiplayer world runtime:

```mermaid
flowchart TB
    subgraph Frontends
        WEB[Web]
        DISC[Discord]
        TUI[Terminal]
    end

    subgraph Core
        RPC[JSON-RPC]
        ENT[Entity System]
        SCRIPT[Lua Runtime]
        CAP[Capability System]
    end

    subgraph Storage
        SQL[(SQLite)]
        VEC[(Vector Store)]
    end

    WEB --> RPC
    DISC --> RPC
    TUI --> RPC
    RPC --> ENT
    ENT --> SCRIPT
    ENT --> CAP
    ENT --> SQL
    SCRIPT --> CAP
    ENT -.-> VEC
```

Key components:
- **Entity System**: Flexible `props` JSON store for infinite extensibility
- **Lua Runtime**: Sandboxed scripting for object behaviors
- **Capability System**: Fine-grained permissions per entity
- **JSON-RPC**: Headless core, any frontend can connect

## Unshape Architecture

Constructive media generation with lazy evaluation:

```mermaid
flowchart LR
    subgraph Description
        NG[Node Graph]
        EXPR[Expressions]
        FIELD[Field Trait]
    end

    subgraph Domains
        MESH[Mesh]
        AUDIO[Audio]
        TEX[Texture]
        PATH[Vector]
        SKEL[Skeleton]
    end

    subgraph Output
        GPU[GPU Render]
        CPU[CPU Eval]
        WGSL[WGSL Shader]
    end

    NG --> MESH
    NG --> AUDIO
    NG --> TEX
    NG --> PATH
    NG --> SKEL
    EXPR --> FIELD
    FIELD --> GPU
    FIELD --> CPU
    FIELD --> WGSL
```

Key components:
- **Node Graph**: Type-safe connections with topological execution
- **Field Trait**: Lazy evaluation for continuous domains
- **Expression System**: AST with optional JIT compilation
- **Domain Crates**: Independent crates per media type

## Shared Patterns

All projects follow common architectural patterns:

### Plugin Architecture

```mermaid
graph LR
    CORE[Core] --> |trait| PLUGIN[Plugin Interface]
    PLUGIN --> P1[Plugin 1]
    PLUGIN --> P2[Plugin 2]
    PLUGIN --> P3[Plugin 3]
```

Core defines contracts; plugins provide implementations. Built-in features use the same interface as third-party extensions.

### Lazy Evaluation

```mermaid
sequenceDiagram
    participant User
    participant Description
    participant Evaluator
    participant Output

    User->>Description: Build
    Note over Description: No computation yet
    User->>Evaluator: Render/Execute
    Evaluator->>Description: Traverse
    Evaluator->>Output: Materialize
```

Build descriptions, evaluate on demand. Defer computation until needed.

### Graceful Degradation

```mermaid
flowchart TD
    INPUT[Input] --> PARSE{Parse OK?}
    PARSE -->|Yes| STRUCT[Structured]
    PARSE -->|No| TEXT[Text Fallback]
    STRUCT --> PROCESS[Process]
    TEXT --> PROCESS
```

Handle messy real-world data. Fall back gracefully when parsing fails.
