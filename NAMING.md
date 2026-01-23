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
| **rescribe** | Clear, professional, available namespace |
| **server-less** | Literal, punchy, available |

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

#### **Moss**
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

#### **Siphon**
- **Current**: Legacy software lifting framework
- **Issues**: Functional but could be clearer (siphon = extract/transfer, but not resurrection)
- **What it does**: Flash, Java applets, obsolete VMs → modern web runtimes
- **Alternatives considered**:
  - reincarnate (too long at 11 letters)
  - **resurrect** - ✓ available, bringing dead software back to life, immediately clear, 9 letters, theatrical but fitting
- **Requirements**: Should convey legacy revival/transformation
- **Status**: resurrect is strong candidate

#### **Liana**
- **Current**: API bindings IR and codegen
- **Issues**: Botanical (vines), obscure, taken on crates.io
- **What it unifies**: OpenAPI, gRPC, headers, Thrift → one IR, generate bindings
- **Requirements**: Should convey API bindings, cross-language, code generation
- **Status**: Need alternatives for clarity pivot

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

### 🔄 Semi-locked

#### **Flora → zone**
- **Current**: Lua-based tools, scaffolds, and orchestration monorepo
- **Issues**: Botanical naming if moving away from that theme
- **Key aspects**: Monorepo for full-stack/integrated projects using multiple rhi tools, doesn't need its own crate
- **Alternatives considered**:
  - examples, showcase, apps, demos, gallery (too generic or boring)
  - **zone** - ✓ available (rhizone/rhi-zone on crates), matches rhi.zone domain perfectly, "the zone" = where integrated projects live, 4 letters, clean branding
- **Status**: Basically locked in - perfect match with org/domain branding

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
  - **typedrc** - ✓ available, type-safe rc file (vs Nix untyped), unified config tradition, 7 letters, emphasizes key value prop
  - saferc (potential safer-compiler collision)
- **Requirements**: Should evoke unified config management, type safety, not commands/history
- **Status**: typedrc captures the "type-safe unified config" value prop

#### **Lotus**
- **Current**: Object store with scripting, MUD/MOO-like but generalized (in Flora monorepo)
- **Issues**: Name conflict with existing `lotus` crate
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
- **Status**: habitat perfectly captures the digital habitat philosophy
- **Rationale**: Not a database (too static), not a game (too goal-driven), but a persistent environment where scriptable objects inhabit and interact - a computational world with memory, history, and emergence

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
  - **polarizer** - ✓ available, filters/orients light (controls presentation), active manipulation + viewing, familiar optical term, 9 letters
  - diffractor (available but more passive, 10 letters)
- **Requirements**: Should evoke universal viewing + control, frontend-agnostic architecture
- **Status**: polarizer is strong leading candidate

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

## Moving Projects Into Org

**Decision:** Bring these projects into rhi-zone org (follow unification pattern):
- **ooxml** - Office format parsing (ooxml crate taken, use different crate names like rhi-ooxml-core)
- **burn-models** - Model zoo/inference (needs rename first - see below)

**Keep External:**
- **claude-code-hub** - Development meta-tooling

### burn-models Renaming

- **Current**: burn-models (too tied to Burn framework name)
- **Context**: Burn is the framework, this is the model zoo that uses it (like PyTorch vs diffusers/transformers)
- **Requirements**: One-stop-shop for AI inference, ComfyUI/SwarmUI/Forge/InvokeAI adjacent, framework-agnostic name
- **Alternatives considered**:
  - ember (taken)
  - easyml, quickml, simpleai (available but maybe too simple-sounding)
  - modelkit (bland, two words conceptually)
  - foundry (not obviously ML-coded)
- **Status**: Need better name before moving to org

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
