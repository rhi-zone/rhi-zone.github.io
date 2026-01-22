# About Rhizome

Rhizome is an ecosystem of tools unified by a single pattern: **finding common abstractions across fragmented domains**.

## Philosophy

### Unification Through Abstraction

Fragmentation is the default state of software:
- 98 programming languages with incompatible tooling
- Dozens of API specification formats (OpenAPI, gRPC, GraphQL, headers)
- Hundreds of document and media formats
- Incompatible protocols for the same purposes
- Different capability interfaces across every language runtime

Most tools pick one variant and ignore the rest, or build specialized solutions for each. Rhizome projects find the common abstraction and unify the domain.

| Domain | Fragmentation | Unified Abstraction |
|--------|--------------|---------------------|
| **Language support** | 98 languages with different parsers/tooling | **Moss**: Unified `Language` trait and AST interface |
| **AI session logs** | Claude Code, Gemini, OpenAI Codex (JSONL, JSON) | **Moss**: Unified `Session` type across agent formats |
| **Package ecosystems** | apt, brew, npm, crates.io, pip (different APIs) | **Moss**: Unified `Ecosystem` and `PackageIndex` traits |
| **Development tools** | Different linters, formatters, type checkers | **Moss**: Unified tool interface with SARIF/JSON output |
| **Media generation** | Separate APIs for textures, audio, meshes | **Resin**: `Field<I, O>` trait for any continuous domain |
| **Expression languages** | WGSL, Cranelift, Lua, shader languages | **Dew**: Single AST compiles to all backends |
| **API specifications** | OpenAPI, gRPC, headers, Thrift | **Liana**: One IR, generate bindings for all |
| **Format conversion** | Hunt for exotic tools per format pair | **Cambium**: Type-driven route planning |
| **Document formats** | Lossy pandoc conversions | **rescribe**: Lossless IR preserves round-trip fidelity |
| **Service protocols** | Rewrite for HTTP, CLI, MCP, WebSocket | **server-less**: Write impl once, derive all protocols |
| **Data sources** | Different UIs for every API/database | **Canopy**: Universal client with control plane |
| **Runtime interfaces** | Every language has different stdlib | **Pith**: Capability interfaces on WASI foundation |
| **Game patterns** | Reinvent state machines every project | **Frond**: Common patterns as reusable primitives |
| **Distributed worlds** | Incompatible server architectures | **Hypha**: Federation protocol for handoff |
| **Tool configuration** | Every tool has different config format | **Nursery**: Schema-validated manifests |
| **Legacy runtimes** | Flash, Java applets, obsolete VMs | **Siphon**: Lift to modern web runtimes |

This is why the projects don't need deep technical integration—each unifies its own domain. They share a solution pattern, not a codebase.

### Principles That Follow

The unification principle drives other design decisions:

**Structure Over Text**
Unification requires finding common structure. Text requires parsing; structure composes. Code (AST), files (directories), entities (graphs), media (node graphs)—work on the structure directly.

**Lazy by Default**
Unified abstractions shouldn't pay for what they don't use. Build descriptions, evaluate on demand:
- **Resin**: Procedural fields materialize only when rendered
- **Moss**: Skeleton views extract structure without loading entire files
- **Spore**: Plugins load on demand

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

Rhizome's approach: **make the world structured, don't force interpretation.**

The specs already exist—OpenAPI, headers, WASI, ASTs. The structure is there. Rhizome projects make it accessible through unified abstractions.

**Compose With What Exists**
Tools should fit your infrastructure, not replace it. Vendor lock-in is framed as exit friction, but it's also *entry* friction—you have to adopt their whole stack to try one thing.

Rhizome projects are tools, not platforms. Use them with whatever else you have. No parallel universes of state.

## The Name

A rhizome is a root system that grows horizontally, sending out shoots at intervals. Unlike trees with a single trunk, rhizomes form interconnected networks where any point can connect to any other.

Our projects are designed the same way: independent tools that compose well together, each useful alone but more powerful in combination.

## Projects

### Code Intelligence

| Project | Key Idea |
|---------|----------|
| [Moss](/projects/moss) | AST-aware navigation and editing across 98 languages |

### Generation

| Project | Key Idea |
|---------|----------|
| [Resin](/projects/resin) | Composable procedural primitives for meshes, audio, textures |
| [Dew](/projects/dew) | Minimal expression language (WGSL, Cranelift, Lua) |

### Games & Worlds

| Project | Key Idea |
|---------|----------|
| [Frond](/projects/frond) | State machines, controllers, common gameplay patterns |
| [Hypha](/projects/hypha) | Authoritative handoff protocol for persistent worlds |

### Data Transformation

| Project | Key Idea |
|---------|----------|
| [Cambium](/projects/cambium) | Type-driven route planning for data conversion |
| [rescribe](/projects/rescribe) | Lossless document IR for format translation |
| [Liana](/projects/liana) | IR and codegen for cross-language bindings |
| [Siphon](/projects/siphon) | Legacy software lifting from obsolete runtimes |

### Runtime & Interface

| Project | Key Idea |
|---------|----------|
| [Spore](/projects/spore) | Lua runtime with plugin system for ecosystem integration |
| [Canopy](/projects/canopy) | Universal client with control plane for any data source |

### Infrastructure

| Project | Key Idea |
|---------|----------|
| [Nursery](/projects/nursery) | Unified tool config and project scaffolding from seeds |
| [Pith](/projects/pith) | Capability-based interfaces inspired by WASI |
| [Flora](/projects/flora) | Lua-based tools, scaffolds, and orchestration |
| [server-less](/projects/server-less) | Derive macros: one impl → many protocols |

## Composition

The projects are independent tools that can compose when useful:

**Actual integrations:**
- **Resin** uses **Dew** for procedural expressions (library dependency)
- **Spore** has plugins for **Moss** (runtime bindings)
- **Spore** uses **Pith** capability interfaces (shared trait definitions)

**Potential compositions:**
- **Nursery** could coordinate tool configs via manifests
- **Canopy** could provide UIs for any structured data source
- **Cambium** could orchestrate conversions between any unified formats
- **Liana** could generate bindings for Rhizome project APIs
- **Moss** could analyze any project's codebase

These projects don't form a deeply integrated technical ecosystem. They're independent solutions to different fragmentation problems. The commonality is the pattern: find the abstraction, unify the domain.

Use any project standalone. Compose them when it makes sense. No vendor lock-in.

## Related Projects

Other projects that follow the unification pattern:

| Project | Domain | Unification |
|---------|--------|-------------|
| [burn-models](https://github.com/pterror/burn-models) | ML inference | Pure Rust ML unifies backends (CPU, GPU, WebGPU) |
| [ooxml](https://github.com/pterror/ooxml) | Office formats | Structural parsing unifies docx/xlsx/pptx handling |

## Special Thanks

Rhizome builds on the shoulders of giants. We're grateful to these projects and communities:

### Core Technologies
- [Rust](https://www.rust-lang.org/) - The language that makes safe systems programming practical
- [LuaJIT](https://luajit.org/) - Lightning-fast scripting runtime powering Spore
- [tree-sitter](https://tree-sitter.github.io/) - Incremental parsing powering Moss

### Infrastructure
- [VitePress](https://vitepress.dev/) - Modern documentation framework
- [Nix](https://nixos.org/) - Reproducible development environments
- [GitHub Actions](https://github.com/features/actions) - CI/CD infrastructure

### Rust Ecosystem
- [Axum](https://github.com/tokio-rs/axum) - Ergonomic web framework
- [wgpu](https://wgpu.rs/) - Cross-platform GPU API for Resin
- [Burn](https://burn.dev/) - Deep learning framework
- [serde](https://serde.rs/) - Serialization framework
- [clap](https://docs.rs/clap/) - Command-line argument parsing
- And countless other crates that make Rust development delightful

### Inspiration
- [Pandoc](https://pandoc.org/) - Universal document converter inspiring rescribe
- [WASI](https://wasi.dev/) - Capability-based interfaces inspiring Pith
- The broader open source community for showing us what's possible
