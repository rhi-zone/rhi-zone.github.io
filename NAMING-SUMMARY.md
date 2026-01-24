# Ecosystem Naming - Final Summary

Complete naming decisions for the rhi ecosystem, resolved January 2026.

## Core Framework: Naming Gradient Principle

**Not rigid rules, but a gradient/tolerance model:**

Naming should follow proximity to human experience.

- **Substrate layers** prioritize semantic clarity and structural legibility
  - Far from direct human interaction
  - Semantic clarity can take priority over gentleness
  - Gentleness is desirable when natural, not required when it conflicts with legibility

- **System layers** balance clarity with approachability
  - Middle distance from interaction

- **Human-facing layers** prioritize gentleness and emotional tone
  - Direct interaction points
  - Warmth, playfulness, approachability matter most

**Key principle:** Gentleness is a goal, not a constraint; clarity is a requirement.

This is a design heuristic, not dogma. We don't aestheticize infrastructure by force - if a gentle name naturally fits, we use it. If it doesn't, semantic clarity wins.

## Complete Ecosystem Naming

### Infrastructure Layer (Semantic/Clear)

| Project | New Name | Rationale |
|---------|----------|-----------|
| Moss | **normalize** | Normalizing fragmentation across dev tools (98 languages → unified AST, sessions, packages, tools) |
| - | **rescribe** | Re-scribe = lossless document conversion, clear verb |
| Siphon | **resurrect** | Bringing dead software (Flash, applets) back to life, immediately clear |
| Liana | **concord** | Establishing harmony/agreement between code and external APIs, first-contact collaborative vibe |
| Hypha | **interconnect** | Federation + collaboration, plain English for connecting distributed systems |
| Cambium | **paraphase** | para+phase, intentionally hijacking "paraphrase" - re-expressing data in different formats while preserving meaning |
| Pith | **portals** | Entry points to capabilities, XDG Desktop Portal precedent, humble not authoritative |

### User-Facing Layer (Warm/Approachable)

| Project | New Name | Rationale |
|---------|----------|-----------|
| Canopy | **dusklight** | THE foundational interface - visibility without intensity, gentle twilight exploration |
| Spore | **moonlet** | Small moon (Lua connection), batteries-included, friendly approachable runtime |
| Lotus | **habitat** | Digital habitat for persistent scriptable objects, place you inhabit not progress through |
| Frond | **playmate** | Companion for game development patterns, friendly itch.io vibe |
| Flora | **zone** | Matches rhi.zone domain, where integrated projects live |
| - | **dew** | Gentle expression language, morning moisture, kept from original |
| burn-models | **sketchpad** | Gentle creative sketching space, intentional expectation management (sketch = rough/imperfect), follows -pad pattern (mikupad) |
| Nursery | **myenv** | Personal unified environment setup, warm (my) + clear (env), direnv precedent |
| Resin | **unshape** | Liberating creative composition, releasing from fixed forms, Houdini/Pure Data/modular synth context |
| Trellis | **server-less** | Literal - one impl → many protocols, kept from previous decision |

## Key Naming Decisions Explained

### dusklight (THE Foundational Interface)

**Critical insight:** This isn't just "a UI tool" - it's THE primary interaction layer for the entire ecosystem.

**Semantic reading:**
- dusk = transition, softness, slowing down (not harsh/demanding)
- light = perception, visibility, legibility, approachability
- **dusklight = visibility without intensity**

Perfect for gentle exploration: calm, approachable, weightless soft bright feeling. Captures both feel (freedom, weightless, gentle) AND purpose (visibility/interface) through poetic resonance.

### sketchpad (Model Zoo)

**Intentional positioning:** "sketch" = lower quality/rough drafts, deliberately downplays AI hype.

Sets appropriate expectations about genAI capabilities, doesn't oversell utility, respects skeptics' concerns. Follows -pad pattern (mikupad precedent). The "sketch = rough/imperfect" connotation is a feature, not a bug - it's about managing expectations responsibly.

### myenv (Config Management)

**Solves clarity vs warmth tension:**
- "my" = personal, warm, approachable
- "env" = environment/setup (modern, clear)
- Precedent: direnv (environment management beyond just env vars)

The "-rc" suffix is antiquated Unix tradition. "env" is modern and has established precedent in dev tooling.

### paraphase (Data Pipeline Orchestrator)

**Fundamental insight:** Type-driven routing/pathfinding - you define start and end, it figures out the path.

**Intentionally hijacks paraphrase:**
- Paraphrase = re-express meaning in different words
- Paraphase = re-express data in different formats

Para (alongside/parallel) + phase (state transformation). Gentler than "reformer" (too mechanical/industrial) through phase transition metaphor (like matter changing states).

### unshape (Procedural Generation)

**Context:** Houdini (procedural 3D), Pure Data (audio patching), modular synths.

**Metaphor:** Releasing from fixed/rigid forms → fluid compositional creation. Not destructive (deshape) but liberating (unfurl, unfold energy). Infinite variations through composition, not bound by constraints.

Leans creative/expressive rather than substrate/technical, but that's appropriate for a creative tool.

### normalize (Code Intelligence)

**Purpose:** Normalizing fragmentation across dev tools.
- 98 languages → unified AST
- Different session formats → unified type
- Multiple package ecosystems → unified traits

The crate structure writes itself: normalize-languages, normalize-sessions, normalize-tools, normalize-packages.

It's a general word, but so are serde/tokio/clap - they work because they do exactly what the name says.

### resurrect (Legacy Software Lifting)

Flash is dead. Java applets are dead. Obsolete VMs are dead. Resurrect brings them back to life in modern web runtimes.

Theatrical, but fitting - this is genuinely bringing extinct software back from the dead. The word is immediately clear.

### concord (API Bindings)

**"First contact" collaborative vibe, not othering.**

When you generate bindings for an external API, you're establishing concord - reaching agreement between your code and their specification. Has that diplomatic feeling without framing external services as foreign/alien.

### interconnect (Federation Protocol)

Plain English for connecting persistent worlds through federation, potentially expanding to collaborative editing (CRDT). The word itself embodies the purpose - making connections between separate systems.

### portals (Capability Interfaces)

Entry points to capabilities. Precedent: XDG Desktop Portal (capability-based desktop integration).

Humble tone - not claiming to be "the standard" like WASI, just providing portals to capabilities for runtime integration.

## Why This Naming System Works

### Layered Coherence

The ecosystem has natural layers:
- **Infrastructure** far from interaction → can afford semantic clarity
- **User tools** close to interaction → need warmth and approachability

We don't force one style everywhere. Each layer gets what it needs.

### Cultural Coherence

User-facing names share qualities:
- Personal/warm (myenv, moonlet, habitat, playmate)
- Gentle/soft (dusklight, dew, unshape, sketchpad)
- Approachable/friendly (zone, concord)

Infrastructure names share qualities:
- Clear operators (normalize, resurrect, paraphase)
- Semantic precision (interconnect, portals)
- Structural legibility (rescribe, concord)

### Vision Alignment

Every name embodies the ecosystem values:
- **Approachable** (dusklight, myenv, sketchpad)
- **Permission to be imperfect** (sketch = rough drafts)
- **Gentle processes** (dusklight = visibility without intensity)
- **Unification** (normalize, concord, paraphase)
- **Small-scale, human-sized** (moonlet, habitat)

## Historical Note

See NAMING.md for full exploration history including all alternatives considered and the reasoning behind rejections.

This document represents the final resolved state as of the ecosystem rename (rhizome → rhi).
