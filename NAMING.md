# Naming Audit

Tracking potential project renames before crates.io publication.

**NOTE:** This document serves as historical reference for naming decisions. If we pivot to a different theme/approach, we'll keep this file and create a new one to track the new direction.

## Status Key
- ✅ **Locked** - Name finalized, no changes planned
- 🔄 **Semi-locked** - Keep for now, but open to better suggestions
- ⚠️ **Needs rename** - Actively seeking replacement
- 🤔 **Under review** - Evaluating whether rename needed

## Projects

### ✅ Locked (Strong Names)

| Project | Rationale |
|---------|-----------|
| **rescribe** | Document format conversion library. "Re-scribe" = writing again/differently, perfect for lossless document IR and format translation. Clear verb, professional tone, evocative without being metaphorical. 8 letters, immediately understandable, available on crates.io. |
| **server-less** | Derive macros for multi-protocol implementations. Literal description of what it does (one impl → many protocols, no server boilerplate). Punchy 10 letters, plays on "serverless" trend but distinct meaning. Available namespace, immediately clear to potential users. |
| **concord** | API bindings IR and codegen. Establishing harmony/agreement between your code and external APIs. Perfect "first contact" vibe - collaborative, not othering. When you generate bindings, you're reaching concord with the API spec. 7 letters, clear meaning, available on crates.io. |

**Previously considered strong but reconsidered for full clarity pivot:**
- Moss, Resin, Nursery, Flora, Liana - botanical names, moving to clarity over metaphor
- Siphon - functional but could be clearer

### ✅ Locked (Keeping Current Name)

#### **Dew** (kept)
- **Status**: Expression language (no user-defined functions, pure expressions)
- **Rationale**: Short (3 letters), cute aesthetic, available, established in codebase
- **Context**: Originally wanted "Sap" (lifeblood/flow metaphor) but friend owns the crate. Dew's metaphor is weaker but nothing clearly better emerged.
- **Extensive alternatives explored**: gem, essence, mana, pearl, axiom, verve, vis, neat, formula (all taken or not clearly better)
- **Decision**: Keep Dew - good enough and available beats perfect but unavailable

### ⚠️ Needs Rename (High Priority)

#### **Moss → normalize**
- **Current**: Structural code intelligence (98 languages, sessions, packages, tools)
- **Issues**: Botanical, meaning unclear ("moss grows on code"?), taken on crates.io
- **What it unifies**:
  - Language support (98 languages → unified AST)
  - AI session logs (Claude Code, Gemini, OpenAI → unified Session type)
  - Package ecosystems (apt, brew, npm, crates → unified traits)
  - Development tools (linters, formatters, type checkers → unified interface)
- **Alternatives considered**:
  - codeview, codemap, astview, inspect (too narrow or collision-prone)
  - devkit, cognition (available but don't capture unification)
  - rein (connection iffy - "reining in" complexity)
  - **normalize** - ✓ available, exactly what it does (normalizing fragmentation), 9 letters, works perfectly with crate structure (normalize-sessions, normalize-tools, normalize-packages, normalize-languages), precedent: serde/tokio/clap took general names
- **Requirements**: Should convey unified dev intelligence, normalization of fragmentation
- **Status**: normalize is strong leading candidate
- **Rationale**: The entire purpose of Moss is normalizing fragmentation across development tools. 98 languages → unified AST. Different session formats → unified type. Multiple package ecosystems → unified traits. That's normalization. The crate structure writes itself: normalize-languages, normalize-sessions, normalize-tools, normalize-packages. It's a general word, but so are serde/tokio/clap - and they work because they do exactly what the name says.

#### **Siphon → resurrect**
- **Current**: Legacy software lifting framework
- **Issues**: Functional but could be clearer (siphon = extract/transfer, but not resurrection)
- **What it does**: Flash, Java applets, obsolete VMs → modern web runtimes
- **Alternatives considered**:
  - reincarnate (too long at 11 letters)
  - **resurrect** - ✓ available, bringing dead software back to life, immediately clear, 9 letters, theatrical but fitting
- **Requirements**: Should convey legacy revival/transformation
- **Status**: resurrect is strong candidate
- **Rationale**: Flash is dead. Java applets are dead. Obsolete VMs are dead. Resurrect brings them back to life in modern web runtimes. It's theatrical, but that fits - this is genuinely bringing extinct software back from the dead. The word is immediately clear: you know what it does before reading documentation. "Siphon" requires explanation; "resurrect" doesn't.

#### **Liana → concord**
- **Current**: API bindings IR and codegen (plus pre-generated bindings collection)
- **Issues**: Botanical (vines), obscure, taken on crates.io
- **What it unifies**: OpenAPI, gRPC, headers, Thrift → one IR, generate bindings
- **Alternatives considered**:
  - foreign, alien, extern, bindings (taken or derogatory/othering)
  - accord, envoy, atlas, treaty, conduit, parley (all taken but had right collaborative vibe)
  - handshake (yanked, TCP association)
  - covenant (Contributor Covenant collision)
  - attune (viable but less clear)
  - resonate (music/sound association misleading)
  - **concord** - ✓ available, establishing harmony/agreement between systems, perfect "first contact" collaborative vibe (not othering), 7 letters, clear meaning
- **Requirements**: Should convey API bindings with collaborative/discovery tone, not derogatory
- **Status**: concord is the decision
- **Rationale**: When you generate bindings for an external API, you're establishing concord - reaching agreement between your code and their specification. Has that diplomatic "first contact" feeling without framing external services as foreign/alien. Works perfectly: "reaching concord with external APIs."

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
  - **polymorphine** (from Noita transformation potion) - ✓ available, captures transformation/many forms, alchemical creative vibe, 11 letters - BUT arcane/esoteric = intimidating
  - **manyfold** - ✓ available, multiple transformations/variations, mathematical feel, 8 letters, exotic but evocative - more approachable but still not obviously playful/gentle
- **Status**: Leaning back towards manyfold, but neither is perfect
- **Rationale**: Resin is fundamentally about transformation through composition. You build procedural primitives (Fields) and compose them into infinite variations. This is a creative/generative tool (human-facing layer) so warmth/gentleness matters. Polymorphine is too arcane/intimidating despite creative vibe. Manyfold is more approachable but still not obviously playful. Per naming gradient: human-facing tools should prioritize gentleness. May need third option that's both warm AND clearly compositional.

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
- **Rationale**: Lua is the moon (Portuguese). Moonlet is a small moon - an actual astronomical term for small natural satellites. Perfect metaphor for a batteries-included Lua runtime: small but complete. The name immediately signals "this is Lua-based" without being too literal (luakit/luabox). Also tempers expectations appropriately - it's not trying to be the full moon, just a friendly little moonlet for scripting integration.

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
- **Rationale**: Hypha is a beautiful metaphor (fungal networks connecting everything) but nobody knows the word. Interconnect says exactly what it does: connecting persistent worlds through federation, potentially expanding to collaborative editing (CRDT). Plain English, immediately understandable, covers both federation protocol and future collaboration features. The word itself embodies the purpose - making connections between separate systems.

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
- **Rationale**: Pith (core/essence) doesn't convey "interface to capabilities." Portals does: they're entry points to access capabilities. Has precedent in XDG Desktop Portal (capability-based desktop integration). Humble tone - not claiming to be "the standard" like WASI, just providing portals to capabilities for runtime integration. The name emphasizes what matters: gateways to controlled access, not authoritative definitions.

### 🔄 Semi-locked

#### **Flora → zone**
- **Current**: Lua-based tools, scaffolds, and orchestration monorepo
- **Issues**: Botanical naming if moving away from that theme
- **Key aspects**: Monorepo for full-stack/integrated projects using multiple rhi tools, doesn't need its own crate
- **Alternatives considered**:
  - examples, showcase, apps, demos, gallery (too generic or boring)
  - **zone** - ✓ available (rhizone/rhi-zone on crates), matches rhi.zone domain perfectly, "the zone" = where integrated projects live, 4 letters, clean branding
- **Status**: Basically locked in - perfect match with org/domain branding
- **Rationale**: Flora (botanical) doesn't fit the clarity pivot. Zone is perfect: matches rhi.zone domain exactly, short (4 letters), "the zone" is where integrated full-stack projects live. It's the monorepo for showcasing tools working together. Clean branding alignment across org name, domain, and this monorepo. Sometimes the obvious choice is obvious for good reason.

### 🤔 Under Review

#### **Nursery**
- **Current**: Ecosystem orchestrator via rhizome.toml manifests
- **Issues**: Taken on crates.io, botanical
- **Key aspects**:
  - Tool/package management (stow/Nix replacement)
  - Type-safe schema-validated configs (vs Nix's untyped configs)
  - All configs in one file (nursery.toml)
  - Central gathering place for tool configuration
  - Dehydrated configs that expand/hydrate into full setup
- **Alternatives considered**:
  - depot, central, vault (taken or not clear about storing things)
  - seedbox, spawn (too generic or game-coded)
  - catalog, schematic, declare, uniconf (wrong angle or taken)
  - caddy (web server collision), toolcase (configs aren't tools)
  - binder, dossier, folio (taken or yanked)
  - ledger (implies history not config)
  - rc (taken), runcom (wrong concept - commands not config)
  - allrc, unirc, metarc, mainrc (all kinda jank)
  - **typedrc** - ✓ available, type-safe rc file (vs Nix untyped), unified config tradition, 7 letters, emphasizes key value prop - BUT cognitively clear, emotionally cold
  - **nursery** (original name) - emotionally warm, semantically vague
  - saferc (potential safer-compiler collision)
- **Requirements**: Should evoke unified config management, type safety, not commands/history
- **Status**: Real tension between clarity and warmth for user-facing tool
- **Rationale**: This is a user-facing tool (you interact with it directly) so per naming gradient, gentleness matters. But there's genuine tension: typedrc = cognitively clear but cold (infrastructure vibes), nursery = emotionally warm but semantically vague (what does it DO?). The core value proposition is type-safe unified config management. Typedrc emphasizes the key differentiator (typed) while connecting to rc file tradition. Nursery conveys care/tending but doesn't say "config management." Need to decide: does warmth or clarity win for user-facing config tool? Or find third option that's both warm AND clear?

#### **Lotus → habitat**
- **Current**: Object store with scripting, MUD/MOO-like but generalized (in Flora/zone monorepo)
- **Issues**: Name conflict with existing `lotus` crate, botanical naming
- **Key aspects**:
  - Schemaless object store (intentionally flexible, not limited)
  - Scriptable/programmable objects
  - Persistent interactive world (MUD/MOO spirit)
  - Any kind of object (notes, calendar, timers, game entities, whatever)
  - Not progression-based, not goal-oriented - a place to inhabit
  - Digital habitat: "a place you live in, not progress through"
- **Alternatives considered**:
  - freeform, looseleaf (only capture schemaless aspect)
  - scriptbox, codex, vault (only capture programmable/storage aspect)
  - realm, world, space (too generic)
  - workshop, studio, lab (wrong vibe)
  - activestore, livedb (corporate/technical, miss the living world aspect)
  - colony (available but less evocative)
  - **habitat** - ✓ available, digital habitat for persistent scriptable objects, "place you inhabit not progress through", captures MUD/MOO spirit without game-coding, ontology not objectives, 7 letters
- **Requirements**: Should evoke persistent living world, programmable objects, schemaless flexibility, not database-coded or game-coded
- **Status**: habitat is the decision
- **Rationale**: Lotus is taken and botanical. What this project really is: a digital habitat - a place you inhabit, not progress through. Not a database (too static/sterile), not a game (too goal-oriented), but a persistent computational environment where scriptable objects live and interact. Captures the MUD/MOO spirit (ontology not objectives, emergence not design) without game-coding it. The schemaless flexibility isn't a limitation, it's the point - habitats support diverse life, not rigid schemas. 7 letters, immediately evocative, perfectly describes "a place where computational things inhabit."

#### **Canopy**
- **Current**: Universal UI client with control plane for any data source
- **Issues**: Covering/view metaphor weak, botanical
- **Key aspects**: Frontend architecture/pattern (not specific implementation), universal data source client, control plane (view + control), similar to Postman/Wireshark/imhex universality
- **Alternatives considered**:
  - dashboard, panel, console (don't convey universality)
  - cartographer (too passive, just mapping)
  - lens, prism, optic (FP optics collision)
  - refractor (taken), refractory (wrong connotation)
  - monocle, spyglass (viewing only, no control)
  - **polarizer** - ✓ available, filters/orients light (controls presentation), 9 letters - BUT wrong framing: control instrument, not exploration interface
  - diffractor (available but more passive, 10 letters)
- **Requirements**: Should evoke universal viewing + gentle exploration + world interaction, NOT control/manipulation
- **Status**: polarizer probably wrong metaphor
- **Rationale**: This is a human-facing tool (exploration/interaction) so per naming gradient, gentleness and approachability matter most. Polarizer frames it as a "control instrument" - filtering, orienting, manipulating. But the actual purpose is more like: gentle universal viewing, exploration interface, world interaction agent (like Postman/Wireshark but approachable). Polarizer emphasizes control/technical precision when we want gentle exploration. Need metaphor that conveys "gentle universal viewing/interaction" not "precise optical control." Canopy (covering/view) was too passive. What's in between?

#### **Frond**
- **Current**: Game design primitives library (state machines, controllers, common patterns)
- **Issues**: Leaf → game design has no connection, unclear what it even is ("game logic pieces in general")
- **Alternatives considered**:
  - playbook, gamekit, mechanics (probably taken)
  - **playmate** - ✓ available, play + mate (companion), friendly/itch.io vibe, 8 letters
- **Requirements**: Should evoke game development patterns, itch.io-adjacent casual tone okay
- **Status**: playmate is leading candidate (Playboy association not a concern in game dev context)
- **Rationale**: Frond (leaf) has zero connection to game design primitives. Playmate works: it's your companion for play/game development. The library provides reusable patterns (state machines, controllers) so you don't reinvent them every project. Friendly, approachable tone fits the itch.io indie game dev audience. The Playboy magazine association isn't a concern in game development context where "play" is the primary semantic anchor.

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
- **Rationale**: Cambium (growth layer) doesn't connect to pipeline orchestration. Reformer is clear: re-forming data from one format into another. Type-driven routing means the data types determine how reformation happens. Not too generic (unlike "pipeline" or "transform") because it emphasizes the format conversion aspect specifically. Neutral tone works for a tool that handles archival, composition, stream manipulation - general data transformation without being ETL-coded.

#### **Canopy**
- **Current**: Universal UI client with control plane
- **Issues**: Covering/view metaphor is weak for "universal client"
- **Alternatives considered**:
  - Lens (viewing)
  - View (too generic)
  - Portal (access point)
- **Requirements**: Should evoke unified access/viewing

## Naming Principles

### Naming Gradient Principle

**Naming should follow proximity to human experience.**

Not rigid rules, but a gradient/tolerance model:

- **Substrate layers** prioritize semantic clarity and structural legibility
  - Far from direct human interaction
  - Semantic clarity can take priority over gentleness
  - Gentleness is desirable when natural, not required when it conflicts with legibility
  - Examples: normalize, rescribe, resurrect, concord, interconnect, reformer, portals
  - Like: serde, tokio, git, nix, unix

- **System layers** balance clarity with approachability
  - Middle distance from interaction
  - Semantic + some warmth when possible

- **Human-facing layers** prioritize gentleness and emotional tone
  - Direct interaction points
  - Warmth, playfulness, approachability matter most
  - Examples: moonlet, habitat, playmate, zone, dew, inferia
  - Like: bubbletea, lipgloss, glow

**Key points:**
- This is a **design heuristic**, not dogma
- We don't aestheticize infrastructure by force
- If a gentle name naturally fits infra, we use it
- If it doesn't, semantic clarity wins
- Gentleness is a goal, not a constraint; clarity is a requirement

**Why this works:**
- Distance from interaction determines naming softness
- Substrate exists to enable experience, not be experience
- Infrastructure can AFFORD to be semantic (not MUST be)
- Allows exceptions, evolution, discovery - avoids rigidity

**The litmus test:**
Can you mentally model the system from the names alone? Infrastructure should tell you what it DOES. User tools can be more expressive.

### Legacy Principles (Still Valid)

1. **Evocative over literal** - rescribe not "document-converter"
2. **Domain-specific, not transformation-specific** - "prism" could describe half the ecosystem
3. **Short and punchy** - Match serde/clap/anyhow aesthetic (3-6 letters ideal)
4. **Pronounceable** - Avoid pronunciation ambiguity
5. **Available** - Check crates.io before committing

## Historical Context

- **Dew**: Originally "Sap" (lifeblood of plants → expression flow), but friend owns `sap` crate
- **Trellis → server-less**: Botanical metaphor unclear, new name is literal and available
- **rescribe**: Moved from Related to main projects, kept descriptive name

## Moving Projects Into Org

**Decision:** Bring these projects into rhi-zone org (follow unification pattern):
- **ooxml** - Office format parsing (ooxml crate taken, use different crate names like rhi-ooxml-core)
- **burn-models** - Model zoo/inference (needs rename first - see below)

**Keep External:**
- **claude-code-hub** - Development meta-tooling

### burn-models → terrarium

- **Current**: burn-models (too tied to Burn framework name)
- **Context**: Burn is the framework, this is the model zoo that uses it (like PyTorch vs diffusers/transformers)
- **Requirements**: One-stop-shop for AI inference, ComfyUI/SwarmUI/Forge/InvokeAI adjacent, framework-agnostic name, gentle/cozy for user-facing tool
- **Alternatives considered**:
  - ember (taken)
  - easyml, quickml, simpleai (available but maybe too simple-sounding)
  - modelkit (bland, two words conceptually)
  - foundry (not obviously ML-coded)
  - ark (taken)
  - menagerie (available, fun, expressive, model-zoo literal - but circus-y)
  - inferia (infer + ia, subtle Burn/fire connection) - BUT sounds infernal/demonic, wrong vibe
  - gallery (available, art collection, curated)
  - vivarium (available, contained environment, obscure)
  - **terrarium** - ✓ available, contained plant ecosystem, gentle/soft/cozy, pastel-friendly, 9 letters
- **Status**: terrarium is the decision
- **Rationale**: This is a user-facing tool so per naming gradient, gentleness matters. Inferia sounded too infernal/demonic (wrong for pastel-cute). Terrarium is a contained ecosystem metaphor (models living in their habitat) - semantic connection to "model zoo" isn't super clear but it's gentle, cozy, immediately recognizable, and has soft pastel-green vibes. A little greenhouse where your models live. Sometimes perfect semantic fit + perfect vibe is impossible; this optimizes for approachability.

## Execution Checklist

When ready to execute the full ecosystem rename (rhizome → rhi, all project renames):

### Documentation Updates
- [ ] Rename all docs in this repo (~/git/rhizome-lab-github-io)
  - [ ] docs/about.md, docs/projects/*, README.md, CLAUDE.md
  - [ ] .vitepress/config.ts navigation
- [ ] Rename all docs in ~/git/rhizome-lab-github/
- [ ] Update ~/.claude/projects/ directory names (EXCEPT rhizome-lab-github-io)

### Repository Moves
- [ ] Move all ~/git/ directories to new names (EXCEPT rhizome-lab-github-io - we're in it)
  - moss, resin→polymorphine/manyfold, dew, etc.
- [ ] Execute `gh repo rename` for all repos in rhi-zone org
- [ ] Update git remote origin for all repos

### Code Updates (Per Repo)
- [ ] Update Cargo.toml crate names (rhizome- → rhi- prefix where needed)
- [ ] Update internal imports/references
- [ ] Update git dependencies in Cargo.toml (repo URLs)
- [ ] Grep validate: search for "rhizome-lab", "rhizome-", old project names
- [ ] Update CLAUDE.md if present
- [ ] Update README.md

### Verification
- [ ] All repos build successfully
- [ ] Git remotes point to rhi-zone org
- [ ] No stray references to old names (grep across ecosystem)
- [ ] Docs site deploys correctly

## Process

Before publishing to crates.io:
1. Finalize all ⚠️ renames (high priority)
2. Make final call on 🔄 semi-locked names
3. Decide on 🤔 under review cases
4. Check all names for crates.io availability
5. Update all repos/docs/branding simultaneously
6. Execute as part of rhizome → rhi migration
