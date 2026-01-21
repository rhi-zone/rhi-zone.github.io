# Use Cases

What kinds of projects benefit from Rhizome? This is both a guide and a wishlist - some of these work today, some are aspirational.

## Developer Tools That Understand Structure

**The problem:** Most dev tools operate on text. Grep doesn't know what a function is. Regex can't refactor safely. You're pattern-matching strings when you want to query structure.

**What Rhizome provides:**
- **Moss** - Structural code intelligence. Parse 100+ languages into ASTs, query them, transform them.
- **moss-openapi**, **moss-jsonschema** - Parse specs, understand their structure.
- **moss-typegen** - Generate types from specs.
- **moss-surface-syntax** - Translate between surface syntaxes while preserving semantics.
- **Liana** - Generate API bindings from specs (OpenAPI, headers) for multiple languages.

**Example projects:**
- A code search tool that understands "find all functions that call X" not "grep for X"
- A binding generator: OpenAPI spec → typed client in Rust, TypeScript, Lua
- A refactoring tool that operates on ASTs, not regex
- Documentation generators that understand code structure
- AI agent tooling that can query codebases structurally

**Status:** Moss exists and works. Liana is in progress. moss-typegen is functional.

---

## Procedural Content Pipelines

**The problem:** Procedural generation is either locked in proprietary tools (Houdini, Substance) or requires building everything from scratch. Results are often non-deterministic, hard to serialize, and don't compose.

**What Rhizome provides:**
- **Resin** - 40+ crates of procedural primitives: noise, meshes, audio, particles, fluids, L-systems, physics.
- **Dew** - Minimal expression language for defining fields and transforms.
- Lazy evaluation: define the recipe, materialize on demand.
- Deterministic: same seed = same output, always.
- Portable: runs on CPU, can target GPU.

**Example projects:**
- Texture generation pipelines for games
- Audio synthesis with reproducible, serializable patches
- Terrain generation from noise → erosion → mesh → export
- Generative art that's deterministic and can be shared as recipes, not just outputs
- VFX systems (particles, fluids) that replay identically

**Status:** Resin core exists. Many primitives implemented. Dew is early. GPU backend is WIP.

---

## Games With Deep Moddable Systems

**The problem:** Most games are closed. Modding requires reverse engineering or limited mod APIs. Multiplayer is centralized. Worlds don't persist meaningfully.

**What Rhizome provides:**
- **Spore** - Lua runtime with plugin system. Scripts can extend everything.
- **Frond** - Game design primitives (inventory, dialogue, quests, etc.)
- **Hypha** - Federation protocol for persistent worlds. Your server, connected to others.
- **Pith** - Standard library interfaces (WASI-style). Capabilities, not ambient authority.

**Example projects:**
- A game where players can script NPCs, items, quests in Lua
- Federated worlds: your server has authority over your zone, players can travel between
- Collaborative worldbuilding: build together, creations persist for others to discover
- Moddable game engines where the mod API is the same as the internal API

**Status:** Spore works. Frond is early. Hypha is designed but not fully implemented.

---

## AI-Integrated Applications

**The problem:** AI gets context through chat history (linear, lossy) or by reading screenshots/docs (interpretation-heavy). There's no structured way to inject world state.

**What Rhizome provides:**
- The "Structure for Agents" philosophy: make systems structured, don't force interpretation.
- **Moss** - AI can query code structure, not just read files.
- **Wisteria** (Flora) - Agent task execution, spun out from Moss. Traditional memory approaches (modifiable context, retrieval).
- **Lotus** (Flora) - Object graph with state, behavior, connections. Persistent world state for interactive/roleplay contexts.
- **Iris** (Flora) - Session analysis.
- RAG-like retrieval for relevant context injection (planned).
- Structured specs everywhere: OpenAPI, JSON Schema, ASTs.

The key insight isn't one specific approach - it's that agents should work with structure, not interpretation. Whether that's querying ASTs, retrieving from embeddings, or injecting world state from an object graph.

**Example projects:**
- AI coding assistants that understand code structurally (not just "here's the file")
- AI roleplay with persistent world state (not just chat log)
- Agents that can query and modify structured data, not just generate text
- Tools with `--schema` flags so agents can discover capabilities

**Status:** Moss works. Flora subprojects (Wisteria, Lotus, Iris) are in various stages of development. The philosophy is baked into everything.

---

## Legacy Software Preservation

**The problem:** Old software dies. Flash is gone. HyperCard is gone. Director projects rot. The artifacts exist but can't run.

**What Rhizome provides:**
- **Siphon** - Lift legacy software into modern web runtimes. Extract structure, not just emulate.
- **Moss** - Understand legacy codebases before rewriting.
- **Cambium** - Convert legacy formats to modern ones.

**Example projects:**
- Lift Flash games to web (without just embedding Ruffle)
- Extract Director/Lingo projects into something maintainable
- Migrate ancient codebases by understanding them structurally first
- Archive interactive media in playable, preservable form

**Status:** Siphon is early research. Cambium exists. Moss can help understand legacy code.

---

## Format Conversion Without Hunting

**The problem:** Converting between formats means hunting for exotic tools, praying they exist, and dealing with lossy conversions that don't preserve structure.

**What Rhizome provides:**
- **Cambium** - Type-driven conversion pipelines. Define the types, compose the transforms.
- **rescribe** (related) - Document conversion with lossless IR.
- **ooxml** (related) - Structural parsing for Office formats.

**Example projects:**
- Convert between document formats while preserving structure (not just visual appearance)
- Asset pipelines for games: source formats → optimized runtime formats
- Data migration between systems with different schemas
- Batch conversion tools that understand what they're converting

**Status:** Cambium exists. rescribe and ooxml are in progress.

---

## The Wishlist

Things we want to enable but aren't there yet:

- **Universal UI client** (Canopy) - User-defined projections onto any data source. Escape from WIMP by making the paradigm user-defined.
- **Low-floor creative tools** - Start with a fragment, not a blank canvas. Constraints as permission to be imperfect.
- **Interactive learning infrastructure** - Between quiz platforms and game engines. Primitives for challenges, progression, feedback.
- **Social with artifacts** - Not ephemeral posting. Building things together that persist.
- **Inspectable software** - See how things work while they're working. Smalltalk/MOO energy.

---

## See Also

- [Vision](/vision) - Why Rhizome exists
- [Projects](/projects/) - What exists today
- [Philosophy](/about#philosophy) - Design principles
