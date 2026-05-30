# Throughlines

A synthesis over the ADR corpus. ADR-0001 plus 284 atomic records were mined from
~39 repos and the introspection logs; this document reads them *collectively* — the
corpus thesis applied recursively to the ecosystem's own decisions. It looks for the
principles that recur across repos and domains (not restatements of single ADRs), the
places where decisions pull against each other, the throughlines crisp enough to feed
back into shared philosophy, and what the synthesis cannot see.

Claims here are framed as observations over the recorded decisions, not certainties.
A throughline is listed only where decisions in two or more repos or domains support it.
Citations point at ADR numbers; follow them to the records for the full reasoning.

---

## 1. Throughlines

### T1 — Data, not code, at every seam

The most pervasive pattern in the corpus: when something could be a closure, a
program, a hardcoded category, or a privileged schema field, the ecosystem makes it
**serializable, inspectable data** instead. The justification recurs almost verbatim
across unrelated repos — *closures can't be serialized, so caching / checkpoint /
replay / transport / diffing / GPU-JIT compilation become impossible.*

- Tasks are serializable structs, not closures, because the entire feature set
  (cache, checkpoint, replay, audit) depends on it (ADR-0185, nanites).
- Transforms are a serializable expression AST, not Rust closures, so graphs compile
  to WGSL/Cranelift/Lua (ADR-0274, unshape).
- Dusklight actions are data plus a transport function, not closures (ADR-0046).
- Rules/handlers are JSON ASTs, not source text, so one world file runs unmodified on
  Rust and TypeScript runtimes (ADR-0098, defocus).
- Marinada expressions are JSON arrays, not a bespoke syntax (ADR-0108, dusklight).
- World-pack actions are declarative `when`/`do`, not Turing-complete scripting, so
  packs stay serializable/diffable/replayable and loadable from untrusted sources
  (ADR-0077, aspect).
- Hologram logic is restricted JS boolean expressions, deliberately not a DSL or a
  scripting sandbox (ADR-0131).

The same instinct extends to the substrate layer: the knowledge corpus rejects a
triple *store* but keeps the triple *model*, and the document *is* the substrate —
git-diffable, human- and LLM-authorable (ADR-0001 §5–6). What recurs is a refusal to
let behavior hide inside opaque runtime objects when it could be a value you can save,
send, diff, and re-run.

### T2 — Open extensible models over closed enumerations

Closely related but distinct: where a model must absorb constructs not known in
advance, the ecosystem chooses **open, string-keyed extensibility** and pushes the
cost (loss of compile-time exhaustiveness) onto convention and validation.

- rescribe's IR is open string-keyed node kinds with property bags, explicitly against
  Pandoc's closed Block/Inline ADT that silently drops what doesn't fit (ADR-0238).
- concord unifies bounds/constraints/modifiers into one extensible `kind: String`
  annotation, no fixed enum (ADR-0090); HTTP and FFI are expressed as ordinary types,
  no dedicated protocol layers (ADR-0093).
- hologram is entity-everything: no type hierarchy, type emerges from facts (ADR-0124).
- software-taxonomy asserts kind via `instance_of`, not a per-record schema type
  (ADR-0253); concord makes the parallel move — well-known types are Refs to names,
  not enum variants (ADR-0092).
- The corpus format blesses no metadata: `rank`/`lens`/`sources` are unblessed open-bag
  keys on the statement, none named or special-cased by the format (ADR-0001 §5).
- reincarnate's builtins (including arithmetic) are ordinary FuncIds, no BuiltinOp enum,
  no namespace-prefix dispatch (ADR-0224).

The recurring tell: "no special-cased X" appears as a design slogan in concord
(ADR-0092/0093), the corpus (no blessed metadata), tiltshift (no format knowledge,
ADR-0264), and normalize (no hardcoded extensions, ADR-0040). The ecosystem reaches
for an open model and a graceful-ignore-on-unknown rule rather than predicting the
full set of cases up front.

### T3 — Library-first, thin generated surfaces

A project is a typed library; its CLI/HTTP/MCP/JSON surfaces are **generated
projections** of that library, never the other way around.

- normalize is "an API that happens to have a CLI": every command returns a typed
  Report struct, and `--json`/`--jsonl`/`--jq`/MCP/HTTP come for free from serde +
  generated layers (ADR-0192); returning `String` is named an anti-pattern.
- paraphase is library-first with a ~100-line CLI wrapper, because a library can wrap a
  CLI but a CLI cannot cleanly unwrap into a library (ADR-0058).
- server-less is *a projection system, not a framework* — plain Rust methods projected
  onto many protocols, explicitly modeled on Serde's derive-as-projection (ADR-0240).
- Iris emits markdown and owns no publishing step (ADR-0067); the corpus reader is a
  Dusklight config, not a codebase (ADR-0001 §8).

This is the same shape as T1/T2 one level up: the library is the single definition;
every consumer surface is a derived view. "Projection from one definition" is arguably
*the* organizing metaphor of the ecosystem — it appears as the corpus thesis (surfaces
are projections of data), as server-less's identity, as normalize's architecture, and
as Dusklight's whole reason for existing.

### T4 — Independent tools, shared pattern, no shared codebase

The ecosystem is deliberately *not* a platform. Projects share a solution pattern
(find the abstraction, unify the domain) but not a codebase, and coupling is
aggressively refused even when code looks reusable.

- Projects share a solution pattern, not a codebase; no deep technical integration,
  to avoid both exit and entry friction (ADR-0019).
- No path dependencies in Cargo.toml; crates publish independently (ADR-0016).
- Crates use no shared prefix — bare names — because the projects are independent tools,
  not a branded suite (ADR-0018).
- nanites reimplements unshape's patterns independently; if shared code is ever
  warranted it must be a *third* crate both depend on, never one depending on the other
  — and the right time for shared abstraction is *after* both discover their real
  shapes (ADR-0056).
- crescent reimplements the nanites substrate in pure Lua with no dependency on the
  Rust crate (ADR-0057); two independent implementations are accepted as the cost.
- The corpus explicitly aligns *vocabulary* with aspect but does not couple *code*,
  and dissolves the would-be shared "engine" entirely (ADR-0001 §7, §10).
- rescribe format crates expose no rescribe IR types; integration is isolated in capped
  ~300-line adapter crates (ADR-0235); paraphase's hand-rolled parsers live in
  standalone crates with no paraphase dependency (ADR-0060).

The deep reasoning, made explicit in ADR-0056: shared abstraction extracted too early
forces one party to carry the other's baggage (unshape is synchronous 60fps; nanites is
async seconds-per-LLM-call). Decoupling is treated as cheaper than premature unification
— a recurring bet that *two correct implementations beat one coupled one.*

### T5 — Zero-dependency / runtime-loadable / air-gapped substrates

Several substrates carry a hard self-containment constraint, and the corpus shows the
constraint being *sharpened under pressure* into an unusually strict form.

- crescent stdlib has zero external dependencies; vendored packages are stopgaps
  (ADR-0007); there is no `dep/` directory — everything is under `lib/`, no path
  rewriting ever (ADR-0008); no build step, ever (ADR-0149).
- No online resources anywhere in the loop; a bare clone on an air-gapped machine is
  the supported configuration (ADR-0012).
- "Zero-dependency" is redefined to *include runtime-loadability*: an FFI dep that
  can't be loaded at runtime is a violation, full stop, and Nix `buildInputs` do not
  satisfy it (ADR-0033, ecosystem; ADR-0151, the repo-local twin). This was locked only
  after four sessions cycled through buildInputs/bundling/vendoring fixes — the
  constraint got *stricter* on contact with reality, not looser.
- crescent apps vendor all dependencies into self-contained tarballs (ADR-0150).
- portals biases toward portability over power; "when in doubt, leave it out" (ADR-0210).

This is narrower than T4 (it's a property of specific substrates, chiefly crescent and
portals, not the whole ecosystem) but it's a genuine recurring stance: *own your
dependencies end-to-end, and prefer the small knowable thing.*

### T6 — Capability security: hosts grant, code attenuates, nothing forges

Where untrusted code runs, the security model is uniform and capability-based:
resources are **granted by the trusted host**, never acquired by name, and recipients
can only *narrow* what they're given.

- moonlet: capabilities are injected by the host from a policy file; scripts can't
  construct them, only attenuate (ADR-0180).
- portals: interfaces never acquire resources by path/name; they receive pre-opened
  handles, enforced by a checklist for every new interface (ADR-0205).
- defocus: Refs are attenuable capabilities carrying verb subsets, not bare ID strings;
  attenuation can't be upgraded by the recipient (ADR-0097).
- crescent: app security is explicit capability grants at load time, which is what makes
  shipping source in PNGs acceptable (ADR-0150); the browser realm is an allow-list
  sandbox (new TC39 features absent *by construction*), not a deny-list (ADR-0010).
- interconnect: clients send intent, authorities compute results — trusting client
  state is refused by construction, eliminating whole attack classes (ADR-0135).

The shared insight, stated most sharply in moonlet (ADR-0180): letting code request its
own capabilities "is only namespacing, not security." And the allow-list framing
(ADR-0010) generalizes the same instinct as T2's open models inverted: *deny-lists rot
as the world ships new features; allow-lists make the dangerous surface absent by
construction.*

### T7 — Determinism is a contract; the LLM is an oracle, never the loop

A strikingly consistent boundary: **the LLM generates at the leaves; deterministic
machinery owns control flow, state, and truth.** And determinism is enforced as a hard,
testable invariant wherever replay matters.

- nanites is general orchestration, *not* LLM-specific; LLMs are one node type among
  many, and the thesis is that LLMs "fall away at the leaves as problems become
  well-defined" (ADR-0054).
- matrix-gen: agents are profile-driven state machines; the LLM is an oracle consulted
  for generation, it does not drive the loop (ADR-0171).
- hologram: conditions and randomness are evaluated by the *system* before/around the
  LLM call; the LLM never sees the probability (ADR-0129).
- existence: all RNG through one seeded PRNG, no `Math.random`/`Date.now` in simulation;
  same seed + same actions = same world (ADR-0111); prose-generation RNG is even
  separated from mechanical-outcome RNG (ADR-0165); prose is generated offline, no LLM
  calls during gameplay (ADR-0144).
- defocus: EventLog is canonical; state is deterministic replay, so anything
  nondeterministic (notably LLM calls) must be *logged* to be replayable (ADR-0094).
- The corpus's hardest constraint: no per-query LLM inference — LLM judgment happens
  once at build time and is stamped into the data (ADR-0001 §2).

The corollary is a distrust of letting the model self-direct or self-attest. iris keeps
the LLM to a single stateless call with no RAG baseline (ADR-0066); annotated-law and
the corpus require the model's claims to be bound to evidence (see T8). The ecosystem
treats the LLM as a powerful but unreliable generator to be *fenced* by deterministic
structure, not as an agent to be trusted.

### T8 — Trust comes from verifiable evidence, not authority or governance

Wherever an LLM (or a human author) makes factual claims, trust is rebuilt from
**verbatim, checkable provenance** rather than review processes or bare references.

- The `snippet` (a verbatim source excerpt that must be present in the fetched revision)
  is *the* anti-confabulation primitive; a bare source id doesn't bind claim to evidence
  (ADR-0064, software-taxonomy).
- annotated-law: citation rigor replaces human-review governance as the trust mechanism;
  every claim traces to an IR node and is verification-checked (ADR-0068).
- statosphere-guide: pin to a fixed upstream commit and cite every nontrivial claim with
  a permalink, because a moving HEAD lets claims silently drift (ADR-0258).
- The corpus's whole annotation layer is claim→node citation with construction-time
  verification, and an `unknown` sentinel when no source exists (ADR-0001 §4, §2).

The same anti-confabulation reflex governs the AI-collaboration layer: handoff plans
require *freshness* checks, not just correctness checks, because authoritative-looking
artifacts get trusted uncritically and amplify errors across sessions (ADR-0043), and
auto-memory is banned because it is "unversioned, invisible, undiffable, unbackupable"
(ADR-0044). *Anything that looks authoritative must earn it by being checkable.*

### T9 — The orchestrator/delegation collaboration model

A whole sub-corpus (mined largely from CLAUDE.md and the introspection logs) records a
distinctive human–AI working model that crystallized over months.

- The main session is an orchestrator; all exploration and implementation delegates to
  fresh subagents, justified by *separation of concerns* (context pollution), not
  throughput (ADR-0015), and enforced by a hook.
- Tiered model delegation: cheap models for mechanical work, the main agent for
  architecture (ADR-0037).
- Plan-mode handoff to fresh context is the default for long work; one `cache_create`
  beats accumulating 50K-token `cache_read` per turn near the limit (ADR-0035).
- Handoff was promoted from plan-mode to a `/handoff` skill; plans communicate *intent*,
  not authoritative directives (ADR-0029); plans stay lean — next tasks only (ADR-0045).
- Subagents may not modify shared infrastructure without explicit permission (ADR-0032);
  project-specific context is injected per-session, never put in global config
  (ADR-0025).

### T10 — CLAUDE.md as a control surface, governed by observed failure

The AI-collaboration ruleset is itself treated as a versioned **specification**, with
an explicit governance discipline for what may enter it.

- CLAUDE.md is a control surface / living specification of what each project *is* and its
  invariants, not descriptive documentation of an ideal (ADR-0042).
- Every correction encodes a missing rule: don't just fix the output, encode the
  violated principle and apply it everywhere (ADR-0039).
- But the gate is high: rules are added only on *repeated* observed failures, not
  one-off corrections (ADR-0017) — and project worlds carry "no extra rails": if a rule
  isn't already written down, it doesn't apply, and inventing constraints mid-response
  is forbidden (ADR-0061, postmortem).

ADR-0017 and ADR-0039 are in productive tension (encode every correction vs. only
repeated failures); the corpus resolves it as *every correction is a candidate, only
recurrence promotes it.* All agent state must be versioned and visible — the same
principle that bans auto-memory (ADR-0044) and drives fuwafuwa's emotional state into
git history (ADR-0120).

### T11 — Retire, don't deprecate; collapse asymmetries

On reaching stability, the move is to **tighten the surface**, not to grow or to carry
compatibility debt.

- Backward-compat aliases are retired as technical debt at stability, not kept as
  adoption cost — "no back compat please" generalized across the ecosystem
  (ADR-0048, spanning hologram and unshape).
- normalize collapsed its kg CLI from 11 verbs to 3 primitives (read/write/walk), with
  jq covering composition — an explicit asymmetry-elimination refactor (ADR-0026); and a
  top-level subcommand must *unify a domain via a trait* or it's a grab-bag to dissolve
  (`analyze` dissolves toward zero, ADR-0199).
- chub-stage-factory: composition strictly dominates frameworks; every named thing is a
  primitive or a pattern, and a candidate that reduces to composition is *permanently*
  excluded, not parked (ADR-0081, ADR-0083).
- Version bumps gate on *audit resolution*, not feature completion (ADR-0047).

The shared aesthetic: a small set of irreducible primitives, asymmetries collapsed,
and no accreted compatibility layer — the API equivalent of T5's "prefer the small
knowable thing."

### T12 — Build it twice and check they agree (redundancy as rigor)

For substrates everything else depends on, correctness is established by **independent
re-implementation and parity checking**, not by a single validation pass.

- crescent's typechecker v5 runs its normative specs against two independent
  interpreters; correctness is "building the thing twice and checking they agree"
  (ADR-0162).
- crescent's tiered libraries ship a complete pure-Lua reference *before* any FFI tier,
  with parity tests asserting byte-for-byte identical output (ADR-0005).
- rescribe's `parse()` must *not* be `events().collect()` — two materialization paths
  kept behaviorally equivalent, guarded by round-trip fuzzing (ADR-0233).
- defocus/aspect run the same JSON world unmodified on Rust and TypeScript runtimes —
  cross-runtime agreement is the spec (ADR-0098, ADR-0094).

This is the same instinct the design-it-twice skill encodes, applied to verification:
divergence between two independent encodings of the same intent is the signal.

### T13 — Validate against reality, and let tests/fixtures be the spec

"Done" is defined against the messy real distribution, and documentation is *derived
from* what is actually tested rather than authored alongside it.

- Production readiness is corpus-validated (e.g. the 330 GiB govdocs1 corpus), not
  test-suite-passing (ADR-0036).
- Tests/fixtures *are* the specification; COVERAGE.md is derived, parser limitations
  made explicit and testable rather than silently broken (ADR-0156, rescribe).
- tiltshift validates discovered grammars only by self-consistency (decode coverage,
  jump-target validity) — no external reference oracle, which is what makes
  unknown-format discovery tractable (ADR-0267).

This connects to T8 (don't trust unchecked claims) and T12 (don't trust a single
validation) — a consistent epistemic stance that *the artifact must be checkable
against something real and external to its own assertions.*

### T14 — Hidden state, emergent surface: the prose-as-readout pattern

Across the worldbuilding/simulation cluster, a sharp recurring rule: **simulate ground
truth as hidden structured state; the surface is an emergent readout that never
announces the mechanism.**

- existence: no visible stats — prose tone is the only UI, and the text difference *is*
  the interface (ADR-0113); simulate ground truth, not perception (ADR-0112); qualities
  emerge from parameter interaction, never declared by flags (ADR-0116); a scalar
  standing in for structured state is a named debt (ADR-0115).
- fuwafuwa: emotional state runs underneath, prose is the readout never the announcement
  (ADR-0119) — and the model is the *same* existence core with the biological substrate
  stripped (ADR-0123), an explicit instance of T4 (reimplement the relevant core, don't
  couple).
- hologram: facts are prose, not structured data, so the LLM reads meaning directly
  (ADR-0130) — the inverse choice, but the same "prose is the natural medium" instinct.

This sits alongside a sibling content discipline — *in-world documents, no omniscient
narrator* — that recurs across divergence (ADR-0101), legacy (ADR-0167), and postmortem
(ADR-0213). The throughline is a refusal to break the fourth wall: state shows, never
tells; the world is voiced from inside, never explained from outside.

### T15 — Defer to existing solutions; don't hand-roll the solved

A standing rule against reinventing what a maintained standard already does — and its
mirror, knowing where the boundary of "solved" is.

- "Don't hand-roll what a library does; use crates for standards" — promoted to a rule
  after bespoke parsers/template-engines were repeatedly torn out (hologram→Nunjucks,
  reincarnate's Pratt parser→oxc_parser) (ADR-0034).
- portals defers to ecosystem consensus (serde, clap, url, regex) instead of wrapping
  solved domains (ADR-0207).
- noncanon wraps git rather than building a custom sync protocol, *because* git already
  makes divergence first-class (ADR-0187).
- Manifest parsing delegates to the language's own runtime (evaluation-based parsing)
  rather than maintaining a tree-sitter grammar per format (ADR-0038).

The tension with T5 (zero-dependency) is real and is taken up below — the ecosystem
hand-rolls *exactly* in the substrates that have declared self-containment a value, and
defers everywhere else.

---

## 2. Tensions & contradictions

These are the most load-bearing findings: places where the recorded decisions genuinely
pull against each other, or where the same problem was answered differently in different
repos. They are surfaced, not manufactured.

### X1 — "Don't hand-roll the solved" vs. "zero external dependencies"

The flat contradiction in the corpus. ADR-0034 (ecosystem) prohibits reimplementing
what a maintained library does; ADR-0207 (portals) refuses to wrap serde/clap/url/regex.
But ADR-0007 (crescent) mandates writing JSON parsing *from scratch* rather than using
vendored `lunajson`, and ADR-0151/0033 reject even a Nix-provided native lib. Both are
defensible — they optimize different values (reach maintained correctness fast vs. own
the whole stack for air-gap legibility) — but an implementer reading the corpus cold
gets opposite guidance. The implicit resolution is *domain-scoped*: crescent and portals
have **declared self-containment a first-class product value**, so hand-rolling is the
point there; everywhere else, defer. This boundary is real but never stated as such in
one place — it's only inferable by reading T5 and T15 against each other.

### X2 — Triple store deleted in the corpus, re-adopted in software-taxonomy

ADR-0001 §6 deletes the EAV triple *store* (`@thi.ng/rstream-query`) as incidental
complexity that "earns no keep" and finds zero other users in `~/git`. Yet ADR-0252
(software-taxonomy, Phase 4.0) decides to *load the full corpus into an in-process EAV
TripleStore* using the very same `@thi.ng/rstream-query`. These are reconcilable on
close reading — ADR-0001 deletes the store as a *persisted serialization layer* while
keeping the model, and ADR-0252 uses it as an *ephemeral in-process query index* — and
ADR-0001 §10 names software-taxonomy as the eventual refactor *target*, so the two are
sequenced, not simultaneous. But as written they cite the same library on opposite sides
of a "does it earn its keep" verdict, and the corpus refactor of software-taxonomy
(ADR-0001 §5) implies ADR-0252's architecture is slated to change. This is the single
most important place to watch for the corpus thesis actually landing.

### X3 — Open string-keyed IR vs. "no untyped escape hatch" rigor

rescribe (ADR-0238), concord (ADR-0090/0093), hologram (ADR-0124), and the corpus
(no-blessed-metadata) all choose *open, string-keyed* models and accept the loss of
compile-time exhaustiveness — pushing correctness onto convention, fidelity tracking,
and runtime validation. This sits in tension with the ecosystem's strong typed-surface
discipline (normalize's typed Reports, ADR-0192; unshape's fixed-enum `Value` chosen
over `dyn Trait`, ADR-0272; wick's type-homogeneous expressions, ADR-0284). The line the
corpus actually draws: **openness at the data/IR layer that must absorb unknown
constructs, strong typing at the API/value layer that executes.** Coherent, but it means
"prefer the type system" and "prefer the open bag" are both true depending on which seam
you're standing at — and the corpus never names the discriminator explicitly.

### X4 — Persistent-daemon convenience vs. air-gapped/standalone self-sufficiency

normalize (ADR-0031) and interconnect (ADR-0132) both adopt a **persistent daemon owns
state, thin client talks over a socket** model, and interconnect's CLI fails immediately
if the daemon isn't running (ADR-0132). This couples usability to a running background
process — mild friction against the ecosystem's recurring "works standalone, bare clone,
no runtime services" instinct (crescent's air-gap, ADR-0012; iris core needs no external
infrastructure, ADR-0066; myenv tools work standalone, ADR-0051). Not a contradiction —
these are different projects with different latency constraints — but the corpus contains
both "no background services required" and "a background daemon is mandatory" as virtues,
and which applies is per-project rather than principled.

### X5 — Plugin/extension contracts: four different answers

"How does third-party code extend this substrate?" is answered repeatedly and
*differently*: unshape defines only the contract and makes the *host* own loading
(ADR-0277); moonlet uses raw Lua C-API modules via `require` with no central registry
(ADR-0181); paraphase uses C-ABI dynamic libraries (ADR-0203); dusklight resolves
plugins to ES modules via npm/jsr/URL with no custom registry (ADR-0103); crescent vendors
everything and grants capabilities at load (ADR-0150). Each fits its host's trust and
language model, and the *shared* meta-principle (no bespoke central registry; the host
owns loading/trust) is consistent. But there is no shared plugin substrate — which is
itself T4 (no shared codebase) operating as designed. The tension is latent: five
independent plugin models is the predicted cost of the no-coupling stance.

### X6 — "Premise carries no extra rails" vs. "every correction encodes a missing rule"

ADR-0061 (postmortem) forbids inventing constraints that aren't already written down;
ADR-0039 treats every correction as evidence of a *missing* rule to encode. ADR-0017
mediates (only *repeated* failures promote to rules), but the two impulses — minimize the
rule surface vs. accrete rules from failures — are a genuine standing tension in how the
collaboration model governs itself. The corpus is self-aware about this: it's the same
tension as T10's own resolution.

---

## 3. Candidate ecosystem principles

Throughlines crisp and load-bearing enough that they could feed back into the shared
CLAUDE.md / org philosophy. Marked by whether they already appear in CLAUDE.md. (This
section proposes only — it does not edit CLAUDE.md.)

| # | Candidate principle | Status in CLAUDE.md |
|---|---|---|
| P1 | **Independent tools, shared pattern not codebase; no path deps; bare crate names.** (T4) | **Encoded** — Crate Naming, no-path-deps, "shared pattern not codebase" all present. |
| P2 | **The orchestrator/delegation model and the handoff/no-auto-memory discipline.** (T9) | **Encoded** — Delegation, Hard Constraints, Model Tiers. |
| P3 | **CLAUDE.md is a control surface; rules added only on repeated observed failures; all agent state versioned and visible.** (T10) | **Encoded** — "Rules are added when a failure mode is observed repeatedly"; no-auto-memory. |
| P4 | **Prefer data over code at every seam — serializable AST/struct/JSON over closures, DSLs, and source text** — so artifacts can be cached, replayed, transported, and diffed. (T1) | **New** — recurs in 6+ repos but is nowhere a stated ecosystem rule. Strong candidate. |
| P5 | **Library-first / projection-from-one-definition: typed library is the source of truth; CLI/HTTP/MCP/JSON are generated projections, never hand-rolled.** (T3) | **New** at ecosystem scope (lives in per-repo docs). Arguably the ecosystem's central metaphor; worth promoting. |
| P6 | **Capability security: hosts grant pre-opened handles; code only attenuates; nothing forges; allow-list over deny-list.** (T6) | **New** — consistent across moonlet/portals/defocus/crescent/interconnect; a candidate cross-repo security convention. |
| P7 | **The LLM is an oracle at the leaves, never the control loop; determinism (seeded RNG, event-log replay, build-time-only inference) is a hard invariant.** (T7) | **New** — strongly cross-cutting; the corpus's deepest stance on what AI is *for*. |
| P8 | **Trust comes from verifiable evidence (verbatim snippets, pinned-commit permalinks, claim→node citation), not authority, governance, or bare references.** (T8) | **New** — the anti-confabulation primitive; generalizes cleanly. |
| P9 | **Retire don't deprecate; collapse asymmetries to irreducible primitives; gate version bumps on audit resolution.** (T11) | **Partially** — conventional-commits and audit discipline are present; "retire backcompat" / "collapse to primitives" is not stated as a rule. |
| P10 | **For load-bearing substrates, build it twice and check they agree; validate against real corpora; let tests be the spec.** (T12, T13) | **New** — the design-it-twice *skill* exists; the *verification* form (parity, corpus-validation, tests-as-spec) is not a stated principle. |
| P11 | **Open extensible models at the data/IR layer (string-keyed, graceful-ignore-on-unknown); strong types at the executing API layer.** (T2, X3) | **New** — and valuable precisely because the discriminator (which seam gets which) is currently only implicit. |

P4, P5, P7, and P8 are the strongest genuinely-new candidates: each is supported by 5+
repos, each is currently *practiced but unstated*, and each would resolve real ambiguity
for a fresh implementer.

---

## 4. Coverage caveats

What this synthesis can and cannot see; stated honestly because the corpus thesis applies
to its own limits too.

- **Decisions never recorded.** The corpus is mined from CLAUDE.md, design docs, READMEs,
  TODOs, and introspection logs. Decisions made in conversation and never written down are
  structurally invisible — the same gap ADR-0021 names (the ecosystem lacks a baselined
  quality timeseries) and ADR-0044 names (auto-memory was an *unaudited* state store).
  Throughlines are biased toward repos that *document*, and toward decisions contentious
  enough to write up. A silent, universally-agreed practice may be a stronger throughline
  than anything listed here and leave no trace.

- **Mining asymmetry across repos.** Repos with rich design docs (crescent, normalize,
  reincarnate, nanites, paraphase, interconnect, existence) contribute many ADRs;
  thinner-documented or younger repos contribute one or two. The *count* of ADRs per repo
  reflects documentation density, not decision density — so a throughline that looks
  crescent-heavy (T5, T12) may simply be where the writing is, not where the thinking is.

- **Single-source and single-domain claims.** T5 (zero-dep/air-gap) leans heavily on
  crescent and portals; T14 (hidden-state prose) lives almost entirely in the
  paragarden/fuwafuwa cluster. These are real *within their domain* but are weaker as
  *ecosystem-wide* throughlines than, say, T1/T4/T6, which span developer-tool,
  worldbuilding, and data domains. Confidence is tiered accordingly: highest for
  T1/T3/T4/T6/T7/T8 (cross-domain, multi-repo), moderate for T5/T11/T12/T13, domain-bounded
  for T14.

- **Introspection-derived ADRs carry their own framing.** ADRs 0015, 0021–0023,
  0026–0029, 0031, 0035–0045, 0149–0166 are distilled from the introspection logs, which
  are themselves a synthesis layer. They are a synthesis of a synthesis — high-signal for
  the collaboration model (T9/T10) but one interpretive step further from the primary
  decision than a design-doc-derived ADR.

- **The corpus is a single-day backfill.** ADRs 0002–0285 share a 2026-05-29 date: they
  record decisions made over months but were *written* in one pass. Cross-cutting
  consistency may partly reflect a single distiller's voice and framing, not only genuine
  convergence in the underlying work. Where the same slogan appears verbatim across repos
  ("no special-cased X", "not a framework", "build it twice"), some of that echo is the
  ecosystem genuinely thinking alike — and some may be the backfill author hearing the
  same tune everywhere. The tensions in §2 are partial evidence the convergence is real:
  a single voice smoothing everything would not have left X1–X6 standing.

- **ADR-0001 weights heavily.** As an 11-part composite it touches more throughlines than
  any atomic ADR (T1, T2, T3, T4, T7, T8 all cite it). Several throughlines lean on it as a
  load-bearing source; if the corpus design shifts, those throughlines move with it.
