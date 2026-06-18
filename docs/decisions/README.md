# Decisions (ADRs)

Architecture Decision Records for the rhi ecosystem.

## What an ADR is here

A short, durable record of one architecturally significant decision: the context
that forced it, what was decided, the alternatives that lost (and why), and the
consequences. ADRs are append-only history — once accepted, a decision is not
edited away; it is superseded by a later ADR that cites it.

## Numbering

ADRs are numbered sequentially, zero-padded to four digits, with a kebab-case
slug: `NNNN-short-slug.md`. Numbers are never reused.

## Partition

ADRs are partitioned by scope across directories:

- `ecosystem/NNNN-<slug>.md` — ecosystem-significant decisions: those that affect
  two or more repos, set a cross-repo convention/protocol/org-placement principle,
  or concern the knowledge-corpus / introspection / AI-collaboration model.
- `repo-local/<repo>/NNNN-<slug>.md` — decisions scoped to a single repo's internals.
- `README.md` and `0001-knowledge-corpus-foundations.md` live at the root by exception.

**INVARIANT:** there is one *global* ADR-number sequence across all partitions.
Numbers are never reused. Promoting a decision from repo-local to ecosystem keeps
its number (`git mv` into the new partition).

**Classification tie-break:** a decision that *could* generalize but currently
lives in one repo is repo-local (and promotable later).

## ADR-0001 is intentionally composite

`0001-knowledge-corpus-foundations.md` records the foundational decisions for the
omnimedia knowledge-corpus effort as a single composite ADR. These decisions are
tightly interlinked — the substrate choice, the dissolution of the "engine," the
annotation layer, and the projection layer only make sense relative to one
another — so they are recorded together to preserve the narrative. This is a
deliberate exception. **Future decisions get atomic ADRs:** one decision per
record.

## Scope: ecosystem vs corpus-specific

Ecosystem-level decisions live here. Decisions specific to the knowledge corpus
itself may move to the corpus repo (`github:pterror`) once that repo exists. Until
then, the corpus's foundational decisions are recorded here in ADR-0001.

## Synthesis

[`throughlines.md`](throughlines.md) meta-mines the corpus for cross-cutting
principles, tensions between decisions, and candidate ecosystem principles — the
corpus thesis applied to the ecosystem's own decisions. It is a reading *of* the
ADRs below, not itself an ADR.

## Index

### Ecosystem

- ADR-0014 — Canonical skill location is in-repo with symlink; never write to ~/.claude directly
- ADR-0015 — The main Claude session is an orchestrator; all exploration and implementation delegates to subagents
- ADR-0016 — No path dependencies in Cargo.toml; crates publish independently
- ADR-0017 — Rules are added only on repeated observed failures, not from one-off corrections
- ADR-0018 — Rust crates use no project prefix; names reserved on crates.io
- ADR-0019 — Projects share a solution pattern, not a codebase; no deep technical integration
- ADR-0020 — New repos copy git from a template repo; never git init
- ADR-0021 — Model-quality questions must be answered with cache-independent signals, not aggregate cost/token metrics
- ADR-0022 — Back up Claude Code session JSONL to /mnt/ssd before 30-day deletion
- ADR-0023 — CLAUDE.md triggers vs invocable skills: split by always-on need
- ADR-0025 — Project-specific agent context injected per-session via `normalize context --condition`, never global CLAUDE.md
- ADR-0027 — Ecosystem prose convention: frame claims as observations, not certainties
- ADR-0029 — Handoff promoted from plan mode to a skill; plans communicate intent, not directives
- ADR-0030 — Marinada module resolution: pluggable resolver interface, exported by Marinada, implemented by hosts
- ADR-0032 — Subagents may not modify shared infrastructure files without explicit permission
- ADR-0033 — Zero-dependency means runtime-loadable: unloadable FFI deps are violations
- ADR-0034 — Don't hand-roll what a library does; use crates for standards
- ADR-0035 — Plan-mode handoff to fresh context as the default strategy for long-running sessions
- ADR-0036 — Production readiness is corpus-validated, not test-suite-passing
- ADR-0037 — Tiered model delegation: Haiku for mechanical work, main agent for architecture
- ADR-0039 — Every correction encodes a missing rule (CLAUDE.md as living constitution)
- ADR-0040 — Never hardcode file extensions; type dispatch must be language-agnostic
- ADR-0041 — Autonomous agent behavior is measured under isolation, not directed
- ADR-0042 — CLAUDE.md is a control surface / living specification, not descriptive documentation
- ADR-0043 — Handoff plans require freshness checks, not just correctness checks
- ADR-0044 — No auto-memory: agent state lives in versioned CLAUDE.md, and handoff plans stay lean
- ADR-0045 — Handoff plans contain only next tasks, pending items, and relevant session results
- ADR-0047 — Gate version bumps on audit resolution, not feature completion
- ADR-0048 — Retire backward-compat aliases rather than carry them as adoption cost
- ADR-0050 — Reflective/analytical writing lives on ptera.world; legacy is immersive-only
- ADR-0051 — Invisible manifest: tools read generated native configs, never myenv.toml
- ADR-0052 — Scope boundary: myenv generates config and does not run or version tools
- ADR-0053 — Tools self-describe config via a single `--schema` convention
- ADR-0054 — Nanites is general orchestration, not LLM/AI-specific
- ADR-0055 — Nanites and moonlet are orthogonal layers, not competitors
- ADR-0056 — Reimplement unshape's patterns independently — no shared crate, no coupling
- ADR-0057 — Crescent reimplements the substrate in pure Lua, with no dependency on the Rust crate
- ADR-0058 — Library-first design with thin CLI wrapper
- ADR-0059 — Cost/scoring expressions use Dew (rhizome shared expression language)
- ADR-0060 — Hand-rolled format parsers live in standalone crates, paraphase-* is a thin wrapper
- ADR-0064 — Snippet (verbatim source excerpt) as the anti-confabulation primitive
- ADR-0065 — Dual build output: standalone SPA plus externalized embeddable Vue library
- ADR-0066 — Iris core requires no external infrastructure; complexity is opt-in
- ADR-0067 — Iris emits markdown, publishing-agnostic
- ADR-0287 — Skills are canonical in each repo's committed .claude/commands/, fanned out by sync-skills.sh; never ~/.claude
- ADR-0288 — Describe projects by capability and maturity, not volume or activity metrics

### Repo-local

#### annotated-law

- ADR-0068 — Citation rigor replaces human-review governance as the trust mechanism
- ADR-0069 — Event-driven freshness over blind poll-and-diff (deferred to Phase 4)
- ADR-0070 — Liability posture: information not legal advice, never recommendation, on every surface
- ADR-0071 — Single normalized legal IR spans both common-law and civil-law without flattening
- ADR-0072 — TypeScript end-to-end with Astro frontend; explicitly not Svelte

#### ashwren

- ADR-0002 — Preserve session attribution in the knowledge store as load-bearing, not just current phrasing

#### aspect

- ADR-0073 — Interaction model is structure-driven affordances, not language commands or fixed menus
- ADR-0074 — Semantic-neutral core; all meaning lives in declarative world packs
- ADR-0075 — Stay on JS Yjs as CRDT source of truth; defer Yrs/Loro
- ADR-0076 — Projection renders place (phenomenological), never a local graph view
- ADR-0077 — World pack action language is declarative when/do, not Turing-complete scripting
- ADR-0140 — Aspect multiplayer uses Y.js CRDTs instead of in-memory graph + snapshots
- ADR-0141 — Aspect world pack format is JSON with JSONLogic for the Phase 2 predicate language

#### busier

- ADR-0063 — busier dogfood stack: SPA (Lit + rainbow + Bun/Hono), not SSR or a meta-framework

#### chub-mirrorer

- ADR-0078 — Default mirror mode is full-catalog backfill, not incremental top-up
- ADR-0079 — Failures are sticky; never auto-retried without explicit flag
- ADR-0080 — Per-namespace isolation is never relaxed (separate dir, DB, and state)

#### chub-stage-factory

- ADR-0003 — Bounded recent-turns window with summarize-into-state, not naive chat accumulation
- ADR-0004 — Prompts are assembled by ContextAssembler from ContextContributors; string-concatenation is not an exposed mode
- ADR-0081 — Composition strictly dominates monolithic frameworks: every named thing is a primitive or a pattern, never a framework or base class
- ADR-0082 — One repo per Chub stage (factory pattern), not a monorepo or generic template
- ADR-0083 — Supply-driven library: ship what is architecturally distinct, not what an example demands
- ADR-0084 — Deploy fails fast when CHUB_AUTH_TOKEN is unset, rather than gracefully skipping
- ADR-0085 — Introspect-aware UI components use bridged mode (explicit availableVerbs/onVerbInvoke props), not a threaded StageIntrospect
- ADR-0086 — No orphan-button path: every action-surfacing UI component must route clicks through StageIntrospect

#### concord

- ADR-0087 — Confidence-scored generation with flagging, rather than refusing hard cases
- ADR-0088 — Don't split generated modules by default; rely on consumer tree-shaking
- ADR-0089 — Specialcases as version-controlled override files, not hand-edits to generated code
- ADR-0090 — Extensible kind:String annotations instead of a fixed set of bounds/constraints/modifiers
- ADR-0091 — Preserve raw info at parse time; defer mapping decisions to target generators
- ADR-0092 — No special-cased type kinds: well-known types are Refs to names, not enum variants
- ADR-0093 — Unified IR superset: express HTTP and FFI as types, no dedicated protocol layers

#### crescent

- ADR-0005 — Implementation tiers are independent complete implementations selected at load time, not runtime fallbacks
- ADR-0006 — Library functions return (nil, errmsg) on failure with string messages, never error objects/codes
- ADR-0007 — Stdlib has zero external dependencies; vendored third-party packages are stopgaps to be removed
- ADR-0008 — No dep/ directory: all packages (first- and third-party) live under lib/, no path rewriting ever
- ADR-0009 — Browser app rendering: app realm emits virtual structures, host paints (Option B); no DOM in the realm
- ADR-0010 — Browser-side app realm is an allow-list sandbox, not deny-list/SES, with no daemon-side JS parser validation
- ADR-0011 — Browser-side app source format is JS + JSDoc, not TypeScript or mandatory Lua
- ADR-0012 — No online resources in the loop: air-gapped bare clone is the supported configuration
- ADR-0162 — Crescent typechecker v5: dual independent interpreters as correctness mechanism, with structurally-forced spec interleave

#### defocus

- ADR-0094 — EventLog is the canonical source of truth; state is reconstructed by deterministic replay
- ADR-0095 — Perform is the sole mutation boundary; all other Expr forms are pure
- ADR-0096 — Prototype delegation, not class inheritance
- ADR-0097 — Refs are attenuable capabilities, not bare ID strings
- ADR-0098 — Rules are structured data (JSON ASTs), not source text

#### divergence

- ADR-0013 — Divergence and legacy characters stay independent
- ADR-0099 — Character cards as artifacts, not portraits
- ADR-0100 — Place names are descriptive, not commemorative
- ADR-0101 — In-world documents only: no omniscient narrator

#### dusklight

- ADR-0024 — Dusklight/Marinada: reactivity substrate switched from Solid.js to Rainbow
- ADR-0046 — Dusklight actions are serializable data plus a transport function, not closures
- ADR-0102 — Complex UIs composed from layout primitives, not monolithic renderer plugins
- ADR-0103 — No custom plugin registry; plugins resolve to ES modules via npm/jsr/URL/local
- ADR-0104 — Local agent wire format is Cap'n Proto over Unix socket
- ADR-0105 — No read/write asymmetry: all data is local state, renderers receive a ReactiveLens
- ADR-0106 — Renderer dispatch is heuristic/multi-valued, distinct from Marinada's exact match
- ADR-0107 — Fixed, non-extensible primitive set; native behavior via capabilities not new ops
- ADR-0108 — Marinada expressions are JSON arrays, not a custom syntax
- ADR-0109 — Optimizer is a name-agnostic tree-automaton rule engine running once before backends

#### existence

- ADR-0110 — Constitutional conditions roll probabilistically; circumstantial conditions derive deterministically from life history
- ADR-0111 — Deterministic replay: all RNG through a seeded PRNG, no Math.random or Date.now in simulation
- ADR-0112 — Simulate ground truth, not player perception
- ADR-0113 — No visible stats; all simulation state hidden, prose is the only UI
- ADR-0114 — NPCs are live-simulated at dynamic resolution (never zero); labels/archetypes/flavors are banned
- ADR-0115 — Scalars standing in for structured state are debts; domestic state is modeled as objects with histories
- ADR-0116 — Emergence over flags: qualities arise from parameter interaction, never declared
- ADR-0117 — Every system is an interface designed for maximum fidelity; granularity is fixed per-run
- ADR-0143 — Prose honesty: generated game text must reflect backed game state
- ADR-0144 — Existence prose generated offline, no LLM calls during gameplay
- ADR-0163 — Simulation must be physiologically grounded, never arbitrary numbers
- ADR-0164 — Existence: continuous-probability drama model replaces binary cooldown gate
- ADR-0165 — Existence: separate prose-generation RNG from mechanical-outcome RNG

#### fuwafuwa

- ADR-0118 — Asymmetric sentiment evolution: comfort sentiments habituate, discomfort entrenches
- ADR-0119 — Emotional state runs underneath; prose is the readout, never the announcement
- ADR-0120 — Emotional state is version-controlled; the git history is the emotional arc
- ADR-0121 — Events adjust targets, not NT values directly; values approach targets exponentially
- ADR-0122 — Social energy gates behavior, not just tone
- ADR-0123 — Strip the biological substrate from the existence simulation; keep only the relational/emotional core

#### hologram

- ADR-0124 — Entity-everything: no type hierarchy, type emerges from facts
- ADR-0125 — One-directional variable unification between $if and templates
- ADR-0126 — XML tags as structural delimiters in the default template, not markdown headers
- ADR-0127 — Colocation over fragmentation: related facts on one entity, not linked sub-entities
- ADR-0128 — Composable primitive conditions over enum modes
- ADR-0129 — Conditions and randomness are evaluated by the system, not interpreted by the LLM
- ADR-0130 — Facts are prose, not structured data
- ADR-0131 — Logic via restricted JS boolean expressions ($if), not a DSL or full scripting
- ADR-0142 — Hologram message templating migrates to sandboxed Nunjucks, replacing the custom template engine

#### interconnect

- ADR-0132 — Persistent daemon owns connections; CLI is a thin Unix-socket client
- ADR-0133 — Algorithm-agnostic identity: scheme:payload, verification is deployment-specific
- ADR-0134 — Authority over consensus: one authoritative server per room, no state merging
- ADR-0135 — Intent over state: clients send intent, authorities compute results
- ADR-0136 — Minimal protocol, app-defined semantics: application data is opaque bytes
- ADR-0137 — Replication is opt-in and explicit; availability is tied to authority (no automatic replication)
- ADR-0138 — Transport-agnostic core: one protocol semantics, multiple transport bindings

#### introspection

- ADR-0146 — normalize crate boundary: generalist in main binary, specialist in separate crates
- ADR-0147 — Scribble runtimes are intentionally disjoint, not a shared model
- ADR-0148 — reincarnate foundational invariants: semantic fidelity and multi-instance coexistence
- ADR-0149 — Crescent package manager: multi-version directory layout with no build step, ever
- ADR-0150 — Crescent apps vendor all dependencies into self-contained tarballs; security via explicit capability grants, not a package manager
- ADR-0152 — reincarnate type-checking goes only through the CLI check subcommand, never raw tsc/tsgo
- ADR-0153 — redacted-project/private-recipient-a: pedagogical modeling replaces gamification
- ADR-0154 — Connector architecture: Transport trait, fixed to the Discord pattern
- ADR-0155 — Reincarnate core IR holds only frontend-agnostic builtins; operators and backend-varying logic decompose out of core
- ADR-0156 — Tests are the specification; COVERAGE.md is derived, not authored
- ADR-0157 — CCv2 compatibility: dual-write coexistence, not migration
- ADR-0158 — Crescent metadata is a flat key-value primitive, not a hierarchy
- ADR-0159 — Crescent platform tooling is self-referential (editor is a card)
- ADR-0160 — Unshape reframed from CAD-parity tool to a toolkit for any X to X operation on arbitrary media
- ADR-0161 — Crescent: capability risk classification colocated in per-cap modules, with ancestor-aware filesystem path classification

#### legacy

- ADR-0049 — Inhabited heavy content is written via Gemini, not Claude
- ADR-0167 — All content is in-world documents; no omniscient narrator
- ADR-0168 — Document panel format is author-set, never auto-detected
- ADR-0169 — Real-system claims are quiet inline links with no attribution markers

#### matrix-gen

- ADR-0170 — Full pipeline in one repo, not a slim substrate-only repo
- ADR-0171 — LLM as oracle, not as the agent driving the loop
- ADR-0172 — Project named matrix-gen, not matrix
- ADR-0173 — Rust core for the simulation loop, not Python
- ADR-0174 — Homophily-clustered communication, not all-to-all messaging

#### moonlet

- ADR-0175 — Captured vs streaming tool output via separate functions, not one overloaded call
- ADR-0176 — Each moss integration gets its own top-level Lua global, not nesting under moss.*
- ADR-0177 — Missing external tools surface as Lua errors, not status fields
- ADR-0178 — Parallel execution via explicit handles and poll, no hidden global scheduler
- ADR-0179 — Process handles kill their subprocess on drop
- ADR-0180 — Capability security via host injection; scripts cannot construct capabilities
- ADR-0181 — Plugins use the raw Lua C API and require, not a host-owned string capability registry

#### myenv

- ADR-0182 — Cross-platform package resolution via Repology, not a self-maintained registry

#### nanites

- ADR-0183 — Control flow is the graph — no explicit Graph construction API
- ADR-0184 — Streaming is an executor + UI concern, not a graph primitive
- ADR-0185 — Tasks are pure serializable data, not closures
- ADR-0186 — Build the graph dynamically via code, not a visual node editor

#### noncanon

- ADR-0187 — Wrap git, not a custom sync protocol
- ADR-0188 — Rendering and social surface are separate projects, not part of noncanon
- ADR-0189 — Canon membership is implicit: pulling something in makes it canon
- ADR-0190 — Object is the atomic unit; files are representation, not the primitive
- ADR-0191 — Sparse fetch via git's own mechanisms plus optional metadata filtering

#### normalize

- ADR-0026 — Collapsed the normalize kg CLI from 11 verbs to 3 primitives (read/write/walk)
- ADR-0028 — Normalize: discoverability (fewest tool calls) as the organizing purpose
- ADR-0031 — normalize daemon IPC: rkyv binary with first-byte magic protocol detection, LSP-style pull over JSON broadcast
- ADR-0038 — Evaluation-based parsing: delegate manifest parsing to the language runtime
- ADR-0192 — Library-first: service methods return typed Report structs, never String; CLI/JSON/MCP/HTTP are generated
- ADR-0193 — Local-first/remote-fallback uses two single-method traits + coordinator, not one trait with a local_only flag
- ADR-0194 — Command named grep, reversed from the earlier text-search name
- ADR-0195 — Embed large dependencies (ripgrep, jq, gitoxide, tree-sitter) rather than shelling out
- ADR-0196 — Load tree-sitter grammars from external shared libraries at runtime, not bundled at compile time
- ADR-0197 — Multi-repo reports extend the single-repo report with an optional repos field rather than a separate wrapper type
- ADR-0198 — Node classification lives in .scm tree-sitter query files, not in Rust node-kind lists on the Language trait
- ADR-0199 — Top-level CLI subcommands must unify a domain via a trait; analyze dissolves into rank/view

#### paraphase

- ADR-0200 — Conversion-vs-editing scope boundary: normalized options only, no pixel/creative ops
- ADR-0201 — Executor abstraction: resource management as pluggable policy, core stays pure
- ADR-0202 — Named ports with per-port cardinality (cardinality orthogonal to property patterns)
- ADR-0203 — Plugin format: C ABI dynamic libraries
- ADR-0204 — Property bags as the type system (format is just a property)

#### portals

- ADR-0205 — Capability-based design: interfaces never acquire resources by path/name
- ADR-0206 — Default trait receiver is &self, not &mut self
- ADR-0207 — Defer to ecosystem consensus instead of wrapping solved domains
- ADR-0208 — Interfaces/backends split with platform code confined to backends
- ADR-0209 — Manual Display/Error impls instead of thiserror
- ADR-0210 — Portability over power as the governing tradeoff
- ADR-0211 — Small focused capability traits over monolithic traits

#### postmortem

- ADR-0061 — Do not invent additional rules; the premise carries no extra rails
- ADR-0212 — No decay, no archaeology framing: the world is permanently yesterday
- ADR-0213 — No narrator and no second-person address; verbs of state only
- ADR-0214 — Refuse to commit to any explanatory frame for the unchanging world

#### ptera-world

- ADR-0062 — The graph is the primary reading surface; essays become a secondary format behind fragments
- ADR-0139 — All graph edges are directed; A→B and B→A are distinct
- ADR-0215 — Default zoom is a deliberate landscape view; zoom is not the answer to overcrowding
- ADR-0216 — Hybrid layout: hand-placed structural anchors plus globally-aware algorithmic placement
- ADR-0217 — Graph-inspired spatial navigation, not pages and not a literal graph editor

#### rainbow

- ADR-0218 — Identity is explicit in the data model; rainbow omits Unicorn's `dynamic` combinator
- ADR-0219 — No file-based routing or codegen; route tree is nested data with TypeScript inference
- ADR-0220 — Param validation via injectable ParamParser adapter; no validation library in router core
- ADR-0221 — Router owns no cache; SWR is composable on top via rainbow signals
- ADR-0222 — Async is a signal adapter, not a widget combinator
- ADR-0223 — HTML attribute coercion is an Optic boundary adapter, not a bespoke type-tag system

#### reincarnate

- ADR-0145 — Frontend/backend-specific compiler passes isolated, not baked into the shared backend
- ADR-0224 — Runtime library bodies are defined once in IR, not per-backend or in source
- ADR-0225 — Reincarnate is a decompiler (framing 2): emitted source is the mod surface, no IR mutation API
- ADR-0226 — Backends own their AST type; no unified, parameterized, or builder-based core AST
- ADR-0227 — Full recompilation with High-Level Emulation, never interpreter bundling
- ADR-0228 — IR uses block arguments instead of phi nodes; operators are calls, not enum variants
- ADR-0229 — Platform interface exposes low-level 2D primitives, not engine/sprite operations
- ADR-0230 — Three-layer replacement runtime: API shim over a swappable platform interface
- ADR-0231 — Twine frontend targets only SugarCube and Harlowe; Snowman and Chapbook are excluded

#### rescribe

- ADR-0232 — commonmark-fmt wraps pulldown-cmark; superseding it is a non-goal
- ADR-0233 — parse() must not be implemented as events().collect()
- ADR-0234 — Reader primitive is the AST builder; writer primitive is the streaming writer
- ADR-0235 — Standalone format crates expose no rescribe IR types
- ADR-0236 — Three independent reader APIs, not one universal state-machine primitive
- ADR-0237 — Format roundtrip guarantee is tiered, not uniform
- ADR-0238 — Open string-keyed IR instead of a closed enum AST
- ADR-0239 — rescribe operates strictly at the document IR layer

#### server-less

- ADR-0166 — Delegate async runtime to the consumer in server-less
- ADR-0240 — Server-less is a projection system, not a framework
- ADR-0241 — Single protocol-neutral #[app] metadata attribute, superseding per-macro metadata
- ADR-0242 — ServerlessError infers error codes from variant names rather than requiring explicit annotation
- ADR-0243 — Convention-driven inference with a granular escape hatch, never inference when it would surprise
- ADR-0244 — Derive coordination via naming convention, not a shared trait

#### sketchpad

- ADR-0245 — Custom CubeCL Conv3d kernels replace im2col reference implementation
- ADR-0246 — bf16 as default inference precision; f16 rejected for UNet overflow

#### software-taxonomy

- ADR-0247 — Classes are human-pre-curated, never auto-invented during ingest
- ADR-0248 — Namespaced entity ids where namespace denotes type, not ownership
- ADR-0249 — Sentinel values count toward MAX cardinality but NOT MIN
- ADR-0250 — source_required is checked per-statement against the owning lens, with an interpretive escape hatch
- ADR-0251 — Temporal facts use Wikidata rank+qualifier (ADD don't replace), not flattened or split predicates
- ADR-0252 — Validation runs in-process over an EAV TripleStore, not via an external schema layer or subprocess
- ADR-0253 — Kind is asserted via instance_of, not a per-record schema type

#### solarium

- ADR-0254 — Each piece is a self-contained island; no shared universe
- ADR-0255 — Made with intention, not exploratory experimentation
- ADR-0256 — Name 'solarium' chosen over greenhouse/nursery
- ADR-0257 — The site is a neutral host, not an opinionated container

#### statosphere-guide

- ADR-0258 — Pin documentation to a fixed upstream commit and cite every nontrivial claim with a permalink

#### statosphere-studio

- ADR-0259 — Stage configurations are shared as self-contained URLs with no backend
- ADR-0260 — Single recipe-instance canvas replaces the tabbed layout (v2)
- ADR-0261 — JSON deep-cloning uses cloneJson() (JSON round-trip), never structuredClone on reactive data
- ADR-0262 — Onboarding is affordance-only; no tutorials, overlays, or walkthroughs

#### tiltshift

- ADR-0263 — Entry points are supplied by context, not found by scanning every offset
- ADR-0264 — No format knowledge in the discovery signal; grammars are discovered from first principles
- ADR-0265 — Known formats are training/validation data, not a configured analysis mode
- ADR-0266 — Output is reasoning-annotated, not success/failure
- ADR-0267 — Self-consistency is the only validation oracle for discovered grammars
- ADR-0268 — Signals compose by deferral, not duplication (LEB128 defers to VarInt)
- ADR-0269 — tiltshift operates at the structural layer, not the semantic layer

#### unshape

- ADR-0270 — glam for math types; no bevy dependency in core
- ADR-0271 — Graph is just data; evaluation strategy lives behind an Evaluator trait
- ADR-0272 — Expression runtime Value is a fixed enum, not dyn Trait
- ADR-0273 — Ops bind expression variables; expressions never access graph EvalContext
- ADR-0274 — Serializable expression AST replaces closures for transforms
- ADR-0275 — Half-edge as internal mesh representation, indexed on demand for output
- ADR-0276 — Op serialization via type_name + erased_serde, resolved through a registry
- ADR-0277 — Unshape is a library defining the plugin contract; the host handles loading

#### wick

- ADR-0278 — C backend emits expression logic only; user supplies type system and ops
- ADR-0279 — Domain value types are arrays, not named-field structs
- ADR-0280 — Quaternion component order is [x, y, z, w] (scalar-last, GLM/glTF convention)
- ADR-0281 — Rotation API exposes both a function and an operator form
- ADR-0282 — Aggregate value types instead of decomposing vectors into scalar exprs
- ADR-0283 — Core is syntax-only; domain crates own all semantics
- ADR-0284 — Expressions are type-homogeneous; convert at boundaries only
- ADR-0285 — No separate type-inference pass; types propagate during eval/emit in a single pass
