# Use Cases

What kinds of projects benefit from Rhizome? This is both a guide and a wishlist - some of these work today, some are aspirational.

## Overarching Goals

These are the north stars. The specific use-cases below serve these larger goals.

### Subsume Virtually All Computer Interaction

The absurd moonshot. Not that it'll happen, but: what would it look like?

- Stop switching between apps for different tasks
- Unified substrate where everything composes
- Tools that share context (what you're doing in one place is available in another)
- Reduce "I want to do X, now I need to find/learn tool Y" friction

**What we have:** Pieces. Moss for code, Resin for procgen, Spore for scripting. Each is a domain. They can compose (Spore can call Moss, etc.) but there's no unified environment yet.

**What's missing:** The glue. A workspace where these come together. Canopy was meant to be this - user-defined projections onto any data source. Currently conceptual.

---

### Objects, Not Documents

Things that live, not sit. Active, not passive.

- Notes that come to *you* (triggers, reminders, awareness)
- Data with behavior, not just content
- Things that connect and relate, not isolated files

**What we have:** Lotus (in Flora) explores this - object graphs with state, behavior, connections. Spore provides the runtime for objects to have behavior (Lua scripting).

**What's missing:** A usable frontend. The object graph exists but there's no good way to interact with it yet. Also: proving this is actually better than files, not just different.

---

### Social With Artifacts

Not ephemeral posting. Building together, things persist.

- Collaborative worldbuilding (SCP energy, but interactive)
- Shared spaces where creations accumulate
- "Here's a thing I made" not "here's what I'm thinking"

**What we have:** Hypha for federation (your server, connected to others). Lotus for persistent objects. The philosophy is clear.

**What's missing:** An actual deployed thing people can use. The MOO-ish experience where you build together and stumble on things others made months ago. Needs Hypha + Lotus + frontend + community.

---

### First Creative Step Trivially Easy

Low floor, high ceiling, ownership.

- Start with a fragment, not blank canvas
- Constraints as permission to be imperfect
- Tiny first step produces something real

**What we have:** Resin primitives let you tweak and see results. Spore makes scripting accessible. The intent is there.

**What's missing:** The onboarding. "Describe a room → it exists" isn't built yet. The low-floor entry point that lets someone create something in minutes without learning a whole system.

---

### Personal Creative Spaces, Connected to Others

Early web spirit.

- You own what you make
- Not rented from a platform
- Connected but not centralized

**What we have:** Hypha's federation model. Self-hostable by design. No platform dependency.

**What's missing:** Making it easy enough that non-technical people can actually run their own instance. The "install WordPress and go" level of accessibility.

---

## By Persona

Real workflows, real problems.

### "I'm a writer"

**Your pain:** Notes apps are paper on a screen. Documents sit there. You have ideas scattered across files, no connections, nothing that comes to you. Exporting to different formats means hunting for converters or praying your app supports it.

**What Rhizome wants to offer:**
- Objects, not documents. Your notes have behavior, connections, triggers.
- rescribe for format conversion that preserves structure (not just visual appearance).
- A living system where ideas connect and surface when relevant.

**What exists today:** rescribe is in progress. Lotus (object graphs) is in development. Honestly, not much usable for writers yet.

---

### "I'm an artist"

**Your pain:** Procedural tools are locked in expensive software (Houdini, Substance). Creative coding requires learning a whole stack. Generative art is either code-heavy or template-constrained.

**What Rhizome wants to offer:**
- Resin for procedural generation - textures, patterns, meshes, audio.
- Dew as a simple expression language for defining transforms.
- Deterministic output: same seed = same result, shareable as recipes.

**What exists today:** Resin has 40+ crates of primitives. Dew is early. No friendly frontend yet - currently code-level access only.

---

### "I keep using five different tools to convert one file"

**Your pain:** Photoshop → Upscayl → some exotic webp converter → ezgif.com → pray nothing broke. Each tool is a separate download, separate UI, separate mental model. Format conversion is a scavenger hunt.

**What Rhizome wants to offer:**
- Cambium: unified pipelines. Define your conversion once, run it on anything.
- Type-driven: the types tell you what conversions are possible.
- Composable: chain transforms without leaving the system.

**What exists today:** Cambium exists but is early. rescribe handles documents. ooxml parses Office formats. The unified "convert anything" experience isn't there yet.

---

### "I'm a game developer"

**Your pain:** Closed engines, limited modding, centralized multiplayer, procedural content requires building from scratch or expensive middleware.

**What Rhizome wants to offer:**
- Spore for scriptable everything (Lua runtime with plugins).
- Resin for procedural content (terrain, textures, audio, meshes).
- Frond for game primitives (inventory, dialogue, quests).
- Hypha for federated multiplayer (your server, connected to others).

**What exists today:** Spore works. Resin has many primitives. Frond and Hypha are early.

---

## Specific Use-Cases

These serve the goals above. Some work today, some are aspirational.

---

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

Things we want to enable but aren't there yet.

### Collaboration

- **Collaboration primitives, cross-ecosystem** - Not just JS. Yjs for browser, yrs for Rust, Lua bindings via Spore. The bridge to humans should work across languages, not lock you into one ecosystem. `sharedRef()` energy but polyglot.
- **Social with artifacts** - Not ephemeral posting. Building things together that persist.

### Interface & Access

- **Universal UI client** (Canopy) - User-defined projections onto any data source. Escape from WIMP by making the paradigm user-defined.
- **Multiple interfaces, same backend** - CLI on desktop, mobile-native on phone, same context/state. Tailscale works. SSH works. But a terminal on phone is miserable. The tool shouldn't be locked to one interface - different projections of the same thing. Sometimes the glue exists: Claude's Agent SDK exposes Claude Code as a library - same tools, same context, you build the UI. Mobile frontend to your agent session becomes feasible without reimplementing everything.
- **Inspectable software** - See how things work while they're working. Smalltalk/MOO energy.

### Creative Entry Points

- **Low-floor creative tools** - Start with a fragment, not a blank canvas. Constraints as permission to be imperfect.
- **Interactive learning infrastructure** - Between quiz platforms and game engines. Primitives for challenges, progression, feedback.

### AI Agents

- **Agent orchestration layer** - Built on Claude's Agent SDK. Non-terminal interface, multi-agent coordination (spawn to different repos, track, coordinate), smarter context management (not linear), configurable autonomy, meta-analysis, automatic refinement loops. Addresses Claude Code's weaknesses while using its core capabilities. Tailscale-friendly - access your agents from anywhere.

---

## See Also

- [Vision](/vision) - Why Rhizome exists
- [Projects](/projects/) - What exists today
- [Philosophy](/about#philosophy) - Design principles
