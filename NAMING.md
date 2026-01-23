# Naming Audit

Tracking potential project renames before crates.io publication.

## Status Key
- ✅ **Locked** - Name finalized, no changes planned
- 🔄 **Semi-locked** - Keep for now, but open to better suggestions
- ⚠️ **Needs rename** - Actively seeking replacement
- 🤔 **Under review** - Evaluating whether rename needed

## Projects

### ✅ Locked (Strong Names)

| Project | Rationale |
|---------|-----------|
| **Moss** | Botanical, evocative, clear domain (code intelligence), 4 letters |
| **Resin** | Material/substance metaphor for generation, clear, pronounceable |
| **Nursery** | Orchestration/tending metaphor works, generally understood |
| **Flora** | Collection of tools, simple and appropriate |
| **Liana** | Vines connecting = API bindings, metaphor works |
| **Siphon** | Functional/clear for legacy lifting, no botanical requirement |
| **rescribe** | Clear, professional, available namespace |
| **server-less** | Literal, punchy, available |

### 🔄 Semi-locked

#### **Dew**
- **Current status**: Expression language (no user-defined functions, pure expressions)
- **Strengths**: Short (3 letters), cute aesthetic, available
- **Issues**: Weak metaphor (was originally "Sap" - lifeblood metaphor, but taken)
- **Considered alternatives**:
  - Pip (free, but Python association problematic)
  - Bud (taken)
  - Mist, Glyph, Rune (don't capture the "cute little language" aesthetic)
  - pipline (pipeline metaphor, but misnomer since no user-defined functions)
- **Decision**: Keep for now, but open to perfect alternative

### ⚠️ Needs Rename (High Priority)

#### **Resin**
- **Current**: Composable procedural primitives for meshes, audio, textures
- **Issues**: Taken on crates.io
- **Key aspects to capture**:
  - Procedural generation (procgen)
  - Graph-based / node-based (like Pure Data, Houdini, modular synths)
  - Introspectable and manipulable (full history/provenance)
  - Field<I,O> abstraction (functional transformation)
  - VR/spatial manipulation capability
  - Operations/functions as values
- **Alternatives considered**:
  - amber, forge, cast, weave (all taken)
  - resculpt (tentative, "re-" prefix less obvious fit than rescribe)
  - origami, kirigami (perfect metaphor but taken)
  - synth, fractal (taken)
  - fieldgen (too generic, vague jargon)
  - transmute (taken, plus std::mem::transmute collision)
  - patchwork, patch (taken)
  - **polymorphine** (from Noita transformation potion) - ✓ available, captures transformation/many forms, alchemical creative vibe, 11 letters
  - **manyfold** - ✓ available, multiple transformations/variations, mathematical feel, 8 letters, exotic but evocative
- **Status**: polymorphine and manyfold both strong contenders

### ⚠️ Needs Rename (High Priority)

#### **Spore**
- **Current**: Lua runtime with plugin system, ecosystem orchestrator, capabilities-first
- **Issues**: Infectious/disease connotation for a runtime
- **Key aspects**: Lua runtime, batteries-included, orchestrates rhi ecosystem, needs to temper expectations by being clearly Lua-associated
- **Alternatives considered**:
  - Substrate, soil, loam (too passive)
  - arena (conflict with arena allocator in Rust)
  - maestro, conductor, director (too hierarchical)
  - luakit, luabox, lunar (taken or too literal)
  - Moon deities: kaguya, selene, khonsu (all taken or unpronounceable)
  - moonbase, moonkit, moonbox (functional but uninspired)
  - **moonlet** - ✓ available, small moon (astronomical term), clear Lua reference, friendly/approachable, 7 letters, "small but complete" = batteries-included
- **Requirements**: Should evoke Lua/scripting, active execution, collaborative not hierarchical
- **Status**: moonlet is strong leading candidate

#### **Hypha**
- **Current**: Federation protocol for persistent worlds
- **Potential expansion**: Federation + collaborative editing (CRDT/ydoc-based, cross-language)
- **Issues**: Perfect metaphor (fungal network) but nobody knows the word, pronunciation unclear
- **Alternatives considered**:
  - Mesh, Web, Link (taken or too generic)
  - sync, converge, merge (taken or too narrow)
  - **interconnect** - ✓ available, covers both federation and collaboration, plain English, 12 letters
- **Requirements**: Should evoke distributed networking and potentially collaboration
- **Status**: interconnect is strong leading candidate

#### **Pith**
- **Current**: Capability-based interfaces (WASI-inspired but not compatible, stdlib-like)
- **Issues**: Too obscure, pronunciation unclear, "core → interfaces" connection weak
- **Key aspects**: Interface definitions, capability patterns, for runtime integration (Spore), NOT trying to be authoritative standard
- **Alternatives considered**:
  - Core, base, foundation, bedrock (taken or too authoritative)
  - capabilities, cap-std (taken or misleading re: WASI compatibility)
  - permit, grant, access (too general, not just capabilities)
  - traits (sounds like trait utils)
  - cappy (available but too mascot-like)
  - cap-traits, if-caps, rhi-caps (too generic or prefixed)
  - tokens, handles (wrong connotations or taken)
  - **portals** - entry points to capabilities, precedent in XDP (XDG Desktop Portal), 7 letters, humble/not authoritative
- **Requirements**: Should evoke capability interfaces without claiming to be "the" standard
- **Status**: portals is strong candidate (need to verify availability)

### 🤔 Under Review

#### **Frond**
- **Current**: Game design primitives library (state machines, controllers, common patterns)
- **Issues**: Leaf → game design has no connection, unclear what it even is ("game logic pieces in general")
- **Alternatives considered**:
  - playbook, gamekit, mechanics (probably taken)
  - **playmate** - ✓ available, play + mate (companion), friendly/itch.io vibe, 8 letters
- **Requirements**: Should evoke game development patterns, itch.io-adjacent casual tone okay
- **Status**: playmate is leading candidate (Playboy association not a concern in game dev context)

#### **Cambium**
- **Current**: Pipeline orchestrator for data conversion
- **Issues**: Growth layer → pipelines connection unclear, obscure
- **Key aspects**: Type-driven routing, general data transformation (not just preservation - supports archival, composition, stream manipulation, metadata ops), data → other data
- **Alternatives considered**:
  - pipeline, orchestrate, dataflow, router, dispatch (too generic or ETL-coded)
  - alembic (squatted), crucible, refinery, distill (taken)
  - transmogrify (sounds like uglify)
  - chameleon, shapeshifter (misnomer - tool doesn't disguise itself)
  - forge, mold, craft, reshape (taken or too general)
  - kiln (taken, too industrial/hot)
  - deformer (negative connotation)
  - **reformer** - ✓ available, re-forming data into new formats, clear transformation, 8 letters, neutral tone
- **Requirements**: Should evoke data transformation without being too generic
- **Status**: reformer is strong leading candidate

#### **Canopy**
- **Current**: Universal UI client with control plane
- **Issues**: Covering/view metaphor is weak for "universal client"
- **Alternatives considered**:
  - Lens (viewing)
  - View (too generic)
  - Portal (access point)
- **Requirements**: Should evoke unified access/viewing

## Naming Principles

From our ecosystem philosophy:

1. **Evocative over literal** - rescribe not "document-converter"
2. **Domain-specific, not transformation-specific** - "prism" could describe half the ecosystem
3. **Short and punchy** - Match serde/clap/anyhow aesthetic (3-6 letters ideal)
4. **Pronounceable** - Avoid pronunciation ambiguity
5. **Available** - Check crates.io before committing
6. **Botanical preferred but not required** - Clarity trumps theme consistency

## Historical Context

- **Dew**: Originally "Sap" (lifeblood of plants → expression flow), but friend owns `sap` crate
- **Trellis → server-less**: Botanical metaphor unclear, new name is literal and available
- **rescribe**: Moved from Related to main projects, kept descriptive name

## Process

Before publishing to crates.io:
1. Finalize all ⚠️ renames (high priority)
2. Make final call on 🔄 semi-locked names
3. Decide on 🤔 under review cases
4. Check all names for crates.io availability
5. Update all repos/docs/branding simultaneously
6. Execute as part of rhizome → rhi migration
