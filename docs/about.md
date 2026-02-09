# About rhi

rhi is an ecosystem of tools unified by a single pattern: **finding common abstractions across fragmented domains**.

See also [exo-place](https://docs.exo.place/about) — biomes built on any substrate (places, identities, worlds).

## Philosophy

### Unification through abstraction

Fragmentation is the default state of software:
- 98 programming languages with incompatible tooling
- Dozens of API specification formats (OpenAPI, gRPC, GraphQL, headers)
- Hundreds of document and media formats
- Incompatible protocols for the same purposes
- Different capability interfaces across every language runtime

Most tools pick one variant and ignore the rest, or build specialized solutions for each. rhi projects find the common abstraction and unify the domain.

| Domain | Fragmentation | Unified Abstraction |
|--------|--------------|---------------------|
| **Mathematical fields** | Siloed disciplines, incompatible notations | **motif**: Structural invariants and cross-field translation |
| **Language support** | 98 languages with different parsers/tooling | **normalize**: Unified `Language` trait and AST interface |
| **Grammar inference** | Hand-write grammars for every new language | **gels**: Detect syntactic traits, synthesize tree-sitter grammars |
| **AI session logs** | Claude Code, Gemini, OpenAI Codex (JSONL, JSON) | **normalize**: Unified `Session` type across agent formats |
| **Package ecosystems** | apt, brew, npm, crates.io, pip (different APIs) | **normalize**: Unified `Ecosystem` and `PackageIndex` traits |
| **Development tools** | Different linters, formatters, type checkers | **normalize**: Unified tool interface with SARIF/JSON output |
| **Media generation** | Separate APIs for textures, audio, meshes | **unshape**: `Field<I, O>` trait for any continuous domain |
| **Expression languages** | WGSL, Cranelift, Lua, shader languages | **wick**: Single AST compiles to all backends |
| **API specifications** | OpenAPI, gRPC, headers, Thrift | **concord**: One IR, generate bindings for all |
| **Format conversion** | Hunt for exotic tools per format pair | **paraphase**: Type-driven route planning |
| **Document formats** | Lossy pandoc conversions | **rescribe**: Lossless IR preserves round-trip fidelity |
| **Service protocols** | Rewrite for HTTP, CLI, MCP, WebSocket | **server-less**: Write impl once, derive all protocols |
| **Data sources** | Different UIs for every API/database | **dusklight**: Universal client with control plane |
| **Runtime interfaces** | Every language has different stdlib | **portals**: Capability interfaces on WASI foundation |
| **Game patterns** | Reinvent state machines every project | **playmate**: Common patterns as reusable primitives |
| **Distributed worlds** | Incompatible server architectures | **interconnect**: Federation protocol for handoff |
| **Tool configuration** | Every tool has different config format | **myenv**: Schema-validated manifests |
| **Legacy runtimes** | Flash, Java applets, obsolete VMs | **reincarnate**: Lift to modern web runtimes |

This is why the projects don't need deep technical integration—each unifies its own domain. They share a solution pattern, not a codebase.

### Principles that follow

The unification principle drives other design decisions:

**Structure Over Text**
Unification requires finding common structure. Text requires parsing; structure composes. Code (AST), files (directories), entities (graphs), media (node graphs)—work on the structure directly.

**Lazy by Default**
Unified abstractions shouldn't pay for what they don't use. Build descriptions, evaluate on demand:
- **unshape**: Procedural fields materialize only when rendered
- **normalize**: Skeleton views extract structure without loading entire files
- **moonlet**: Plugins load on demand

**Works Anywhere**
Unification means handling the messy reality, not imposing constraints:
- Handle legacy systems without requiring refactoring first
- Degrade gracefully when parsing fails
- Support incremental improvement
- Don't force architectural opinions

**Multiple Paradigms**
"One paradigm" is fragmentation. The answer is always "multiple, fluid, user-chosen."

How do you find a friend's apartment? Ask the doorman, check the directory, call them, remember "3rd floor end of hall", wander and look at numbers. Real life gives you spatial, ask, remember, browse, index, shortcut. Filesystem gives you hierarchy + search. That's it.

The poverty isn't "wrong paradigm." It's "only one paradigm."

Same user, different moments: keyboard vs click, tired vs focused, familiar vs exploring. Different users: expert wants density, novice wants guidance. "Know your user" is wrong. "Support multiple modes of being a user" is right.

**Structure for Agents**
"Agent" means anything trying to understand or interact with systems—human or AI.

Current approach forces interpretation of unstructured things: AI reads screenshots, LLMs parse docs, humans hunt for format converters. This is fragile, slow, lossy, requires guessing.

rhi's approach: **make the world structured, don't force interpretation.**

The specs already exist—OpenAPI, headers, WASI, ASTs. The structure is there. rhi projects make it accessible through unified abstractions.

**Compose With What Exists**
Tools should fit your infrastructure, not replace it. Vendor lock-in is framed as exit friction, but it's also *entry* friction—you have to adopt their whole stack to try one thing.

rhi projects are tools, not platforms. Use them with whatever else you have. No parallel universes of state.

## The name

A rhizome is a root system that grows horizontally, sending out shoots at intervals. Unlike trees with a single trunk, rhizomes form interconnected networks where any point can connect to any other.

Our projects are designed the same way: independent tools that compose well together, each useful alone but more powerful in combination.

## Projects

### Code intelligence

| Project | Key Idea |
|---------|----------|
| [normalize](/projects/normalize) | AST-aware navigation and editing across 98 languages |
| [gels](/projects/gels) | Trait-based grammar inference targeting tree-sitter |
| [motif](/projects/motif) | Structural exploration of mathematics across fields |

### Generation

| Project | Key Idea |
|---------|----------|
| [unshape](/projects/unshape) | Composable procedural primitives for meshes, audio, textures |
| [wick](/projects/wick) | Minimal expression language (WGSL, Cranelift, Lua) |

### Games & worlds

| Project | Key Idea |
|---------|----------|
| [playmate](/projects/playmate) | State machines, controllers, common gameplay patterns |
| [interconnect](/projects/interconnect) | Authoritative handoff protocol for persistent worlds |

### Data transformation

| Project | Key Idea |
|---------|----------|
| [paraphase](/projects/paraphase) | Type-driven route planning for data conversion |
| [rescribe](/projects/rescribe) | Lossless document IR for format translation |
| [concord](/projects/concord) | IR and codegen for cross-language bindings |
| [reincarnate](/projects/reincarnate) | Legacy software lifting from obsolete runtimes |

### Runtime & interface

| Project | Key Idea |
|---------|----------|
| [moonlet](/projects/moonlet) | Lua runtime with plugin system for ecosystem integration |
| [dusklight](/projects/dusklight) | Universal client with control plane for any data source |

### Infrastructure

| Project | Key Idea |
|---------|----------|
| [myenv](/projects/myenv) | Unified tool config and project scaffolding from seeds |
| [portals](/projects/portals) | Capability-based interfaces inspired by WASI |
| [zone](/projects/zone) | Lua-based tools, scaffolds, and orchestration |
| [server-less](/projects/server-less) | Derive macros: one impl → many protocols |

## Composition

The projects are independent tools that can compose when useful:

**Actual integrations:**
- **unshape** uses **wick** for procedural expressions (library dependency)
- **moonlet** has plugins for **normalize** (runtime bindings)
- **moonlet** uses **portals** capability interfaces (shared trait definitions)

**Potential compositions:**
- **myenv** could coordinate tool configs via manifests
- **dusklight** could provide UIs for any structured data source
- **paraphase** could orchestrate conversions between any unified formats
- **concord** could generate bindings for rhi project APIs
- **normalize** could analyze any project's codebase

These projects don't form a deeply integrated technical ecosystem. They're independent solutions to different fragmentation problems. The commonality is the pattern: find the abstraction, unify the domain.

Use any project standalone. Compose them when it makes sense. No vendor lock-in.

## Related projects

Other projects that follow the unification pattern:

| Project | Domain | Unification |
|---------|--------|-------------|
| [sketchpad](https://github.com/rhi-zone/sketchpad) | ML inference | Pure Rust ML unifies backends (CPU, GPU, WebGPU) |
| [ooxml](https://github.com/pterror/ooxml) | Office formats | Structural parsing unifies docx/xlsx/pptx handling |

## Special thanks

rhi builds on the shoulders of giants. We're grateful to these projects and communities:

### Core technologies
- [Rust](https://www.rust-lang.org/) - The language that makes safe systems programming practical
- [LuaJIT](https://luajit.org/) - Lightning-fast scripting runtime powering moonlet
- [tree-sitter](https://tree-sitter.github.io/) - Incremental parsing powering normalize
- [Arborium](https://arborium.bearcove.eu/) - Curated tree-sitter grammars

### Development tools
- [Nix](https://nixos.org/) - Reproducible development environments
- [direnv](https://direnv.net/) - Environment switcher for the shell
- [VitePress](https://vitepress.dev/) - Modern documentation framework
- [GitHub Actions](https://github.com/features/actions) - CI/CD infrastructure

### Rust ecosystem core
- [Tokio](https://tokio.rs/) - Async runtime
- [Axum](https://github.com/tokio-rs/axum) - Ergonomic web framework
- [serde](https://serde.rs/) - Serialization framework
- [clap](https://docs.rs/clap/) - Command-line argument parsing
- [thiserror](https://docs.rs/thiserror/) - Error handling
- [mlua](https://github.com/mlua-rs/mlua) - Lua/LuaJIT bindings

### Domain-specific
- [wgpu](https://wgpu.rs/) - Cross-platform GPU API (unshape)
- [Burn](https://burn.dev/) - Deep learning framework
- [libsql](https://github.com/tursodatabase/libsql) - SQLite fork with async support
- [rig](https://github.com/0xPlaygrounds/rig) - LLM application framework
- [ignore](https://docs.rs/ignore/) - gitignore-aware file walking
- [notify](https://docs.rs/notify/) - Cross-platform filesystem watcher
- [nucleo](https://github.com/helix-editor/nucleo) - Fuzzy matching

### Inspiration
- [Pandoc](https://pandoc.org/) - Universal document converter inspiring rescribe
- [WASI](https://wasi.dev/) - Capability-based interfaces inspiring portals
- The broader open source community for showing us what's possible
