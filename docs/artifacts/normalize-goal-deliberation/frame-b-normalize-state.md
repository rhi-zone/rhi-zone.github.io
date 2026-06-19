# Frame B — What `normalize` actually is, and where it's heading

Repo: `/home/me/git/rhizone/normalize`. Evidence-based map of stated intent vs
current reality vs inference. Sources cited inline (file + section/line).

The VERIFIED FACTS handed in (text-canonical; 5-organ capability map; identity =
name/path lookup with name-independent *similarity* wired only for query) are
taken as given and corroborated below where the docs touch them — they are not
re-derived.

---

## 1. Stated purpose & direction (in its own words)

**Headline self-definition** — consistent across three docs:

- README.md:3 — *"Fast code intelligence CLI. Structural awareness of codebases
  through AST-based analysis."*
- SUMMARY.md:1 — *"Normalize is a structural code intelligence CLI: index symbols
  and calls, enforce rules, track complexity — across any language."*
- docs/philosophy.md:8 — *"Normalize is **structural code intelligence as a
  platform**. It provides tools for understanding, navigating, and modifying code
  at a structural level (AST, control flow, dependencies) rather than treating
  code as text."*

**Architectural self-conception** — ARCHITECTURE.md:56: *"normalize is **an API
that happens to have a CLI**."* Every command runs `data extraction → typed
Report struct → OutputFormatter / server-less`, and *"JSON, JSONL, jq filtering,
and JSON Schema introspection come for free"* (ARCHITECTURE.md:64). The `#[cli]`
service macro projects each method simultaneously into a CLI subcommand, an MCP
tool, an HTTP endpoint, and a JSON-Schema entry (ARCHITECTURE.md:80-85) — this is
the ecosystem's *library-first / projection-from-one-definition* principle made
literal, via the sibling `server-less` macro repo.

**The flagship goal — stated twice, unambiguously:**

- TODO.md:53-56 (`## Goal`): *"Production-grade refactoring across all ~98
  languages. Goal: rename, find-references, extract, inline, move — correct,
  **without LSPs, without false positives**."*
- TODO.md:60-66 (`## 0.4`): *"a working LSP server exposing Find Usages, Rename,
  Safe Delete, Extract Method/Variable, Inline, Change Signature across all ~98
  supported languages — without LSP delegation, without false positives.
  **JetBrains-parity for refactoring is the bar**; an LSP surface is how we make
  it observable and usable from editors."*

So the *current* identity is "structural code-intelligence CLI/platform"; the
*intended* identity is "the cross-language refactoring engine that needs no
per-language LSP" — surfaced through an LSP server of its own.

**Stated non-goals / boundaries** (ARCHITECTURE.md §6, "Anti-patterns"):
shelling out where a Rust crate exists (use `gix` not `git`); stub/fabricated
semantic structure to "fill in" a Language method the grammar doesn't model
(ARCHITECTURE.md:589-592 — *"Returning None / empty is only correct when the
concept genuinely doesn't exist in that language"*); roadmaps under `docs/`
(those go in TODO.md — `docs/` is stable reference only). Network-when-local-
data-exists is an anti-pattern: the whole stack is **local-first, remote-
fallback** (ARCHITECTURE.md §5).

---

## 2. What KIND of thing it is, and who it's for

**It is all of the following at once, by deliberate construction** — one typed
definition projected onto many surfaces (ARCHITECTURE.md:80-85, philosophy.md:10-16):

| Surface | Evidence |
|---|---|
| **CLI** | ~22 top-level subcommands, ~150-command nested tree (TODO.md:297); the everyday face |
| **Library** | ~45 published crates; binary is *"consumer-of-the-ecosystem, not home-of-reusable-logic"* (ARCHITECTURE.md:16-17) |
| **MCP server** | every `#[cli]` method is auto-exposed via `normalize serve mcp` — *"There is no separate MCP wiring"* (ARCHITECTURE.md:760-763) |
| **HTTP server** | `normalize serve http` — same projection |
| **LSP server** | `normalize serve lsp` exists today but is shallow; the *real* LSP is the 0.4 target (philosophy.md:17 calls LSP "a future direction"; TODO.md:60, 1212) |
| **Daemon** | Unix background process caching index/rule/context state, pushing LSP-style diagnostic deltas over a Unix socket — *"an optimisation, not a dependency"* (ARCHITECTURE.md §4.3, SUMMARY.md:13) |

So: **a code-intelligence library with a projection engine on top** (server-less),
whose primary face is a CLI but which is equally an agent/editor substrate.

**Who it's for — explicitly four audiences** (philosophy.md:10-16 table): the
human Developer (CLI, explore unfamiliar code), CI/CD (quality gates), the Tool
Builder (library, build on structural primitives), and the **Agent** (CLI + JSON,
"code intelligence for LLMs and automated workflows"). Agent-facing intent is not
incidental — it pervades the design: a token-efficient default text format with
opt-in `--json` (LLMS.md:37 — *"Plain text is token-efficient"*), `normalize docs`
exists specifically to *"patch training-cutoff blind spots"* by fetching upstream
symbol docs into LLM context (README.md:133-135), an entire `sessions` subsystem
analyzes Claude Code / agent logs (README.md:226, SUMMARY.md), and the design
tenet *"Put smarts in the tool, not the schema. Tool definitions cost context"*
(philosophy.md:125) is reasoning about *agent context budgets*, not human UX.

**Inference:** the center of gravity is shifting from human-developer toward
**AI-agent and editor substrate**. The stated audiences are co-equal on paper,
but the active investment (sessions analytics, docs-into-context, MCP-for-free,
the RLM-inspired "recursive investigation" backlog at TODO.md:1254) is
disproportionately agent-facing. This is consistent with the handed-in fact that
identity is name/path-based and history is git-snapshot — normalize models *the
code as it is on disk right now for a consumer that re-reads it*, which is exactly
the agent/editor read pattern.

---

## 3. Strong / mature  vs  thin / aspirational

### Genuinely strong (shipped, broad, validated)

- **Locate / structural indexing** (corroborates the handed-in "Locate = mature"):
  ~335 `.scm` query files across 84 languages × 5 query types; CFG queries for 76
  languages with **all 4 phases complete and shipped** — structural CFG, liveness,
  effect capture, type-refined exception flow, each with its own `analyze`
  subcommand and SQLite schema (now v15) (SUMMARY.md:5, TODO.md:13-36). This is
  real, tested-against-fixtures depth, not scaffolding.
- **Cross-file name resolution (Phase 0)** — `ModuleResolver` for **26+ languages
  wired into the rebuild pipeline**, with `find_references` tagged
  `confidence: "resolved" | "heuristic"` (SUMMARY.md:7). Corroborates the
  handed-in "resolved-vs-heuristic confidence" fact.
- **The rules stack** — four engines (syntax/tree-sitter, fact/Datalog-via-ascent,
  native/Rust, external-SARIF), 95+ builtin syntax rules across 13 language
  groups, incremental Datalog evaluation, a unified `normalize ci` gate
  (SUMMARY.md:8-9, ARCHITECTURE.md §3.4). Mature and load-bearing (dogfooded:
  SUMMARY.md enforcement at `severity=error` in pre-commit).
- **The projection architecture itself** — library-first / `#[cli]` /
  Report-struct discipline is real and enforced (`assert_output_formatter`
  compile-time checks; ARCHITECTURE.md:296). One definition genuinely fans out to
  CLI/JSON/MCP/HTTP. This is the most-mature *structural* property of the project.
- **Tooling/packaging operational maturity** — 24h-cached ecosystem queries with
  stale-fallback, musl-static NixOS-correct builds, rkyv daemon IPC, WAL/single-
  txn findings cache (~12× cold-run speedup), per-target grammar builds
  (SUMMARY.md throughout). This is a project that has been *operated*, not just
  written.

### Partial (real but incomplete — matches the handed-in capability map)

- **Edit-as-decision** — the `normalize-refactor` recipes are real and
  semantically grounded (extract-function does liveness-based parameter/return
  inference with effect + exception boundary checks; SUMMARY.md:6), but per-
  language synthesis is delegated to a hardcoded `RefactorCodeGen` Rust trait +
  `<lang>.refactor.scm` queries, supported only for ~19 languages with
  *"lisp/ML/pattern-equation and logic/array languages deferred"* (SUMMARY.md:6).
  This corroborates the handed-in "real refactors but hardcoded Rust functions,
  NOT transformation-as-data/recipes."
- **Propagate** — cross-file rename is checked done (TODO.md:1250), but
  `find-references --cross-file` and rename-via-resolved-references are still
  **open 0.4.0 blockers** (TODO.md:115-116). No fixpoint / incremental recompute
  engine is claimed anywhere — corroborates "single-pass, NO fixpoint."

### Thin / aspirational (stated direction, little or no substrate yet)

- **The real LSP** — `serve lsp` exists but the JetBrains-parity refactoring LSP
  is entirely 0.4-and-beyond (philosophy.md:17 explicitly: *"it's not a current
  interface"*; the core LSP methods sit under "Aspirational" at TODO.md:1212-1216).
- **Store-as-decision / persisted name-independent identity** — *absent*, and the
  docs confirm why: the facts index is governed by *"Don't store anything here you
  can't regenerate from disk"* (ARCHITECTURE.md:410) — text-canonical by
  constitution. The structural clone-hash exists only for `analyze duplicates`,
  never as a persisted identity key (corroborates the handed-in identity fact).
- **Structured-metadata symbol search** — a *design*, not an implementation
  (TODO.md:227-273). The embedding-based search was **removed in 0.3.0**
  (`normalize-semantic` is published standalone but no longer wired into the
  binary — SUMMARY.md:19); the replacement (per-symbol nested typed metadata docs
  + BM25/FTS5) is sketched but unbuilt.
- **Inter-procedural dataflow / taint (CodeQL/Semgrep deep mode)** — flagged the
  *"highest-value next direction"* (TODO.md:1225, and commit cbfba906
  *"flag dataflow/taint and structural rewrite as highest-value next
  directions"*), but explicitly *"What's missing is inter-procedural reaching-
  definitions and source→sink taint relations in the fact schema"* — i.e. not yet
  built, though the substrate (CFG, Datalog, call/import facts) is claimed ready.
- **Fill-spawned-decisions / synthesis+verification** — *absent*. The "Agent
  Future" backlog (test-selection, task-decomposition, partial-success, human-in-
  loop, RLM recursive investigation) is nearly all unchecked (TODO.md:1243-1259).
  Corroborates the handed-in "Fill = absent."
- **Translation** — `normalize translate` is shipped surface (README.md:205) but
  given the absence of synthesis+verification it is best read as thin relative to
  the correctness bar the project sets for refactoring.

---

## 4. What the trajectory optimizes for

Reading the `## Goal`, the `## 0.4` phases, the Aspirational section, and the
recent commit stream together, the trajectory is optimizing for, in priority
order:

1. **Correct cross-language semantic refactoring without per-language LSPs — the
   defining bet.** Stated twice as *the* goal (TODO.md:53, 60). Everything
   structural feeds it: Phase 0 resolution (so references are real, not grep),
   CFG+liveness+effects+exceptions (so extract/inline are *safe*, not textual),
   confidence-tagging (so it can refuse rather than emit false positives). The
   discriminator vs ripgrep/ctags is **"correct, without false positives"** — the
   project would rather skip a language than fabricate (ARCHITECTURE.md:589-592).
   *This is the through-line that unifies otherwise-scattered analysis features.*

2. **Richer structural intelligence over text — depth, not breadth-of-languages.**
   Language *count* is already near-saturated (~98); the active frontier is making
   each language *deeper*: per-language `refactor.scm` codegen (the dominant theme
   of the last ~15 language commits: 9214d630…3ba878d0), CFG phases, module
   resolvers. The next named depth target is inter-procedural dataflow/taint
   (TODO.md:1225) — turning the existing CFG+Datalog substrate into CodeQL-class
   analysis "with no new infrastructure required."

3. **Being an agent/editor substrate, not just a human CLI.** Projection-for-free
   (MCP/HTTP/LSP from `#[cli]`), token-aware output defaults, `docs`-into-context,
   the whole `sessions` analytics subsystem, and the RLM-inspired recursive-
   investigation backlog all point at *the consumer increasingly being an LLM
   agent or an editor*, with the CLI as one projection among several. The LSP is
   how this reaches editors; MCP is how it reaches agents.

4. **Operational/UX coherence as a standing discipline.** The most-recent commits
   are overwhelmingly *consolidation*: the `rank` house-style migration (a dozen
   commits), server-less 0.5.0 `--manual` adoption for the ~150-command tree
   (TODO.md:294), grammar-loading-loudness, killing `grammar_name ==` dispatch in
   favor of `.scm`/trait dispatch. The project is actively paying down its own
   sprawl — consistent with its meta-tenet *"Generalize, Don't Multiply"*
   (philosophy.md:52) and the ecosystem's "finish migrations before building on
   top" principle.

**One-line trajectory:** *normalize is converging from "broad structural-analysis
CLI" toward "the correctness-obsessed, language-agnostic semantic-refactoring
engine — surfaced as an LSP for editors and an MCP/library substrate for agents —
built on ever-deeper structural intelligence (CFG → dataflow/taint) over
text-canonical source."*

### Tension worth flagging for the deliberation

The flagship goal (JetBrains-parity *refactoring*, i.e. **edit-as-decision** at
scale) sits on top of two organs the handed-in map calls *absent/partial*:
**Store-as-decision is absent by constitution** (text-canonical;
"regenerate-from-disk" forbids persisted identity), and **Propagate has no
fixpoint engine**. Correct cross-language rename/extract/inline at JetBrains
parity is hard to reconcile with a name/path identity model and single-pass
propagation — the project's own 0.4 blockers (cross-file rename, dataflow facts)
are exactly the seams where "text-canonical + name-based identity" meets "must be
semantically correct, no false positives." That gap — stated-goal vs
identity/propagation substrate — is the most decision-relevant finding here.
