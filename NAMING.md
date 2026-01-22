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
- **Current**: Lua runtime with plugin system
- **Issues**: Infectious/disease connotation for a runtime
- **Status**: Actively brainstorming
- **Alternatives considered**:
  - Substrate (what things grow on)
  - Soil (execution environment)
  - Loam (rich soil for growth)
- **Requirements**: Should evoke hosting/execution/environment, botanical or pragmatic

#### **Hypha**
- **Current**: Federation protocol for persistent worlds
- **Issues**: Perfect metaphor (fungal network) but nobody knows the word, pronunciation unclear
- **Alternatives considered**:
  - Mesh (network metaphor)
  - Web (connections)
  - Link (federation)
- **Requirements**: Should evoke distributed networking

#### **Pith**
- **Current**: Capability-based interfaces (WASI-inspired)
- **Issues**: Too obscure, pronunciation unclear, "core → interfaces" connection weak
- **Alternatives considered**:
  - Core (taken)
  - Base (foundation)
  - Cap (capabilities, but too informal)
- **Requirements**: Should evoke foundational interfaces/capabilities

### 🤔 Under Review

#### **Frond**
- **Current**: Game design primitives library
- **Issues**: Leaf → game design has no connection
- **Alternatives considered**:
  - Pattern (too generic)
  - Motif (game design patterns)
  - Play (clear but taken)
- **Requirements**: Should evoke patterns/gameplay/primitives

#### **Cambium**
- **Current**: Pipeline orchestrator for data conversion
- **Issues**: Growth layer → pipelines connection unclear, obscure
- **Alternatives considered**:
  - Flow (data flow)
  - Stream (probably taken)
  - Pipe (too obvious/generic)
- **Requirements**: Should evoke transformation/pipeline/flow

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
