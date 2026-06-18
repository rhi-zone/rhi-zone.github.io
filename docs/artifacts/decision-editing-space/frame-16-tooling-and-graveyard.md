# Frame 16 — State of the Art + the Graveyard

*A capability survey and a failure autopsy. Two halves, one question. Half A maps every
system already built toward decision-granular editing onto the thread's spine (the
reducible-redundancy / irreducible-decision axis, the M/S split, the compositionality
discriminator, the "editor as reconciler" vision). Half B asks why projectional and
intentional editing — which have existed for 20-40 years — have not won, and separates the
**contingent** failures (fixable by time, tooling, or the arrival of the LLM) from the
**structural** ones (defects the approach cannot shed). The synthesis question the whole
thread routes toward: does the LLM-as-oracle-at-leaves change the calculus that killed the
prior attempts?*

I carry the Frame-3 vocabulary throughout: **M = mechanical shrapnel** (consequences fully
forced by the decision + the artifact, derivable with zero new information) and **S = spawned
decisions** (sites the change *forces to exist* but cannot *fill* — they need an oracle). The
unifying lens from Frames 5/11/14: the disciplines that achieved one-edit-propagates did so by
engineering S → 0 inside their domain; general code has irreducible S, which is exactly the
slot an LLM-oracle is proposed to fill.

> **The one-sentence finding up front.** *Every component of the reconciler vision has been
> built and shipped — semantic site-location (Semgrep/CodeQL/Glean), decision-level edit
> recipes (OpenRewrite/codemods), AST-true storage that kills the parse/merge problem
> (Unison), incremental fixpoint propagation (Salsa/Adapton/differential dataflow), and
> direct decision-node manipulation (MPS/Hazel). None of them has been assembled into one
> loop, and the assembly has been attempted before — that attempt is intentional programming,
> and it lost. The autopsy says it lost for **three contingent reasons** (text-world
> interop, ecosystem bootstrap, editing friction) **and one structural reason** (the
> approach demands that *someone* supply every spawned decision the moment the edit is made,
> and pre-LLM that someone was always the human, which collapses the entire value
> proposition back into manual labor). The LLM changes precisely and only that structural
> reason — it is the first plausible filler of S at the leaves — while leaving the three
> contingent reasons to be solved by engineering. "Is now different" reduces to: is the
> structural blocker the one the LLM removes? It is. That is the whole case, and its
> fragility is that the three contingent blockers are individually hard and have each sunk a
> company.*

---

## PART A — THE SURVEY: what is already built, mapped to the vision

The reconciler vision (from the shared context) has five named organs:

1. **Locate** the decision sites a change touches (semantic, not textual, search).
2. **Edit** at the decision granularity (a recipe / node-edit, not N coordinated text edits).
3. **Store** code so the decision *is* the unit (AST/graph, not smeared text) — so identity,
   diff, and merge happen at decision granularity.
4. **Propagate** the mechanical shrapnel by fixpoint (incremental recompute + conflict learning).
5. **Fill / refuse** spawned decisions — propose discretionary, enumerate forced, refuse to
   invent irreducible bits.

I survey each system against these five, naming which organ it realizes and which it misses.
The brutal pattern: **organs 1-4 are each solved by some shipping system; organ 5 is the one
nobody had a mechanism for, and it is the one the LLM addresses.**

### A.1 — IDE refactorings, LSP rename, code actions (Roslyn, rust-analyzer, IntelliJ)

**How they actually work.** A refactoring like "rename symbol" or "extract method" is a
*verified semantic transformation*: the IDE has a resolved symbol table / name-binding graph,
finds every reference (not every textual match), and rewrites them as one atomic operation
that is *guaranteed behavior-preserving* (modulo reflection / dynamic dispatch escape hatches).
"Extract method", "inline variable", "change signature", "introduce parameter" are each a
canned decision-level edit with machine-derived shrapnel.

**Maps to the vision:** organ 1 (locate — via name resolution, the gold-standard site finder),
organ 2 (edit — the canned refactoring *is* a decision-level edit), and a sliver of organ 4
(the reference rewrites are exactly the mechanical M-shrapnel, derived and applied
automatically). This is the **purest existing proof that decision-granular editing works** —
every working programmer uses it daily and never thinks "I am editing one decision and the
machine is computing the smear." That is precisely the experience the thread wants generalized.

**What it misses:** organs 3 and 5, and the *generality* of organ 2. The catalog is **closed
and finite** — a few dozen hand-built refactorings, each one a human-authored special case with
a hand-proven preservation argument. There is no way to express a novel decision-level edit;
you get the ones JetBrains coded. And critically, refactorings are **defined to produce S = 0**
— "behavior-preserving" *means* "spawns no decisions." The IDE refuses to do anything that
would force a spawned decision, because it cannot fill one. This is the boundary of the
pre-LLM world laid bare: **the existing decision-editor works only on the M-only subset.**
Frame 11's verification-dual is visible here — these are exactly the edits with a cheap total
verifier (the type checker / the preservation proof).

### A.2 — Codemods: jscodeshift, comby, ast-grep

**How they work.** A codemod is a program that transforms an AST (jscodeshift over Babel/ESTree,
ast-grep over tree-sitter) or a near-AST structural pattern (comby's balanced-delimiter
matching, which is grammar-lite rather than a full parse). You write a transform once — "every
call to `oldApi(x)` becomes `newApi({arg: x})`" — and it rewrites the whole codebase. This is
the **decision-as-edit-unit made executable**: the migration decision lives in one transform
script; the thousands of edit sites are derived M-shrapnel.

**Maps to the vision:** organ 2 (the transform *is* a portable decision-level edit, and unlike
A.1 it is **open** — you author arbitrary transforms), and organ 4 for the pure-M case (run
once, all sites updated). ast-grep and comby also do organ 1 (structural site location).

**What it misses:** organs 3 and 5, statefulness, and verification. A codemod is **fire-and-
forget and unverified** — it is a syntactic rewrite with no preservation guarantee; you run it,
then run the tests and eyeball the diff. It has **no model of spawned decisions**: where the
mechanical rewrite is ambiguous, a codemod either bails, guesses, or leaves a `TODO`. It is
**one-shot, not a standing reconciler** — there is no persistent dependency graph that re-fires
when an upstream decision changes; you re-run the script by hand. The code still lives in text;
the codemod is a transient lens over it, not a new storage model.

### A.3 — OpenRewrite (recipes over the LST)

**How it works.** OpenRewrite parses source into a **Lossless Semantic Tree** (LST — an AST
enriched with type attribution *and* enough formatting/whitespace metadata to round-trip back
to byte-identical source). Migrations are **recipes**: composable, parameterized,
type-aware transforms ("upgrade Spring Boot 2 → 3", "migrate JUnit 4 → 5") shipped as a
*catalog* and run idempotently across thousands of repos. This is the **most mature
decision-level-edit-as-data system in industry** — recipes are serialized declarative data
(YAML composing primitives) over a type-attributed tree.

**Maps to the vision:** organ 1 (type-attributed location — strictly better than syntactic),
organ 2 (recipes are *exactly* "a decision serialized as a portable, composable, re-runnable
edit" — this is Frame 5's prefer-data-over-code at the editing seam, realized), organ 4 (the LST
round-trips, recipes compose, runs are idempotent so re-running converges — a real fixpoint
flavor). The LST's whitespace-preservation is the engineering answer to half of organ 3: it
gives AST-true *editing* while keeping text-true *storage*, sidestepping the merge problem (A.7,
B.1) by never leaving text on disk.

**What it misses:** organ 5, and the **authoring economy**. OpenRewrite is M-machinery par
excellence: recipes are written by experts for *known, repeated* migrations where the mapping is
mechanical. It has no answer for the one-off edit (recipe-authoring cost dwarfs the edit) and no
mechanism to fill a spawned decision — recipes that hit genuine ambiguity punt to manual review.
It is the clearest industrial demonstration that **organs 1/2/4 are solved and shipping at
scale**, and equally that the thing left over — the edit whose consequences aren't mechanical —
is the entire residue.

### A.4 — Semantic search: Semgrep, CodeQL, Glean

**How they work.** Semgrep matches semantic patterns over a normalized AST (syntax-aware,
cross-language, lightweight dataflow). CodeQL compiles the codebase into a **relational
database** and lets you *query it in a Datalog-like language* — "find every path from an
untrusted source to a SQL sink" is a recursive query over a code-as-data relation. Glean
(Meta) indexes code into a queryable fact database at monorepo scale for cross-references and
navigation.

**Maps to the vision:** organ 1, **completely and definitively**. The thread's "locate every
site a decision touches" *is* a query over code-as-facts, and CodeQL/Glean prove that
code-as-a-relational-database is not only viable but production-grade at billions of lines.
This is the strongest single existence proof for Frame 12's "behavior is the substrate" and the
prefer-data principle: the program reduced to a fact base you query.

**What it misses:** organs 2-5 entirely. These are **read-only**. They find decision sites with
surgical precision and then hand you a list — locating without editing, the inverse of a
codemod. Semgrep has an autofix mode (a templated rewrite attached to a pattern), which nudges
it toward organ 2, but the fix is a fixed template, not derived shrapnel. The lesson for the
synthesis: **the locator is done.** The reconciler can stand on CodeQL/Glean for organ 1 and
spend no innovation budget there.

### A.5 — Sourcegraph Batch Changes

**How it works.** Find a pattern across thousands of repos (Sourcegraph's cross-repo semantic
search), run a transform (often a codemod or shell script) over each match, and generate a
*fleet of pull requests* that humans review and merge per-repo. The **diff stays the unit of
human approval**; the machine does locate + apply + PR-orchestration.

**Maps to the vision:** organ 1 (cross-repo locate) + organ 2 (apply) + a social/economic organ
the pure-CS framing omits: **it is built around human approval of every derived change, at
diff granularity, in the existing git/PR world.** This is the pragmatic concession the
projectional dreamers refused (B.1): Batch Changes *won adoption* precisely by NOT replacing
text, diff, or the PR — it layers decision-level editing *on top of* the text world rather than
supplanting it.

**What it misses:** 3, 4, 5. No persistent propagation graph (re-run by hand), no storage
change, no spawned-decision handling. But strategically it is the **most important survivor in
the survey** — it is the one large-scale decision-editing product that is *unambiguously
winning in the market*, and it won by being a text-world citizen. Any synthesis that proposes
to replace text must explain why it will beat the thing that succeeded by *not* replacing it.

### A.6 — Projectional / structure / intentional editors (the heart of the graveyard)

This cluster is where the vision was attempted *whole*, decades early. Surveyed here for what
they built; autopsied in Part B for why they lost.

**JetBrains MPS (Meta Programming System).** You edit the **AST directly** through a
projection; there is no parser because there is no text to parse. This unlocks non-textual
notations (tables, diagrams, math) in the same program, language composition without grammar
conflicts, and — the load-bearing point for this thread — **the edit unit IS the
language-concept node, i.e. the decision.** Maps to organs 2+3: decision-as-edit-unit and
AST-as-storage, the two organs every text-based tool above is missing. *Verified*: MPS is real,
shipping, and used in production for DSL-heavy domains — JetBrains' own YouTrack was built with
it; mbeddr (embedded C) is the flagship external case; reported adoption clusters in finance,
healthcare, and embedded/safety-critical software where DSLs pay off. It is **not dead — it is
niche-confined**, which is the precise diagnosis Part B must explain.

**Unison (content-addressed code).** Every definition is identified by the **SHA3 hash of its
(normalized) AST**; names are just metadata pointing at hashes; code lives in a database, not
text files. Consequences that *fall directly out of the architecture*: no dependency-version
conflicts (different versions are different hashes, coexisting), no rebuild of unchanged code
(hash already built), trivial caching, and — crucially for the thread — **renaming is a pure
metadata edit touching zero call sites** because callers reference the hash, not the name. This
is **organ 3 in its strongest published form**: identity at decision granularity, which
*dissolves* a whole class of M-shrapnel (rename) rather than propagating it. *Verified, and a
fresh datapoint that reshapes the "graveyard" framing*: Unison reached **1.0 in November
2025** — the first content-addressed language to declare production status, with its vendor
running cloud orchestration on it, though adoption remains small and the learning curve is
explicitly Haskell-tier. So this organ is *not* in the graveyard; it is freshly alive, which
matters for "is now different."

**Intentional Programming / Intentional Software (Simonyi).** The thesis: capture the
programmer's *intention* as domain-level structure ("intentions" in a tree), edit *that*, and
project to multiple notations and to executable code. The **Domain Workbench** was the most
ambitious whole-vision build — multiple editable projections of one semantic model, execution
integrated with definition. This is essentially organs 2+3+ a partial 4 attempted as a
product, 15 years before the others matured. *Verified, and it is the central corpse in the
autopsy* (B.4): per Martin Fowler's 2009 first-hand assessment, despite "startling potential"
and real maturity, **no system built with the Domain Workbench had gone live**, the tool was
held under restrictive NDA rather than released, and Simonyi's company **pivoted away from
intentional programming to office/collaboration productivity** before Microsoft acquired it in
2017 (employees folded into the Office team; the IP not productized as a programming tool). The
programming-tool thesis was effectively abandoned by its own author. *(Uncertainty flag: the
internal reasons for the pivot are not public; I am inferring abandonment from the pivot + the
no-live-systems datapoint + Fowler, not from a stated post-mortem.)*

**Hazel.** A live functional programming environment built on **typed holes**: every incomplete
program is *still a well-typed, runnable program*, with holes as first-class typed placeholders
that the type checker reasons through and the evaluator runs around. This is the most
theoretically precise relative of the thread's vision: a **hole is exactly a spawned decision
made first-class** — a forced-but-unfilled slot the system tracks, type-constrains, and refuses
to silently invent. Maps to organ 5's *structure* (typed holes = the worklist of forced spawned
decisions) and organ 4 (the type system propagates constraints into holes). What it lacks is
the *filler* — Hazel surfaces and constrains the hole but a human types the content. **Hazel is
the pre-built socket; the LLM is the proposed plug.** This pairing is the single most important
observation in the survey for the synthesis.

**Subtext (Jonathan Edwards), Boxer, naked objects.** Subtext: code-as-direct-manipulation,
explicitly attacking text as the enemy of clear structure; demos of editing the program by
editing its evaluated structure (organ 2+3 as research provocation, never productized). Boxer
(diSessa, the "computational medium" successor to Logo): spatial nested boxes as the program,
aimed at end-users not professionals. Naked objects: the domain object model *is* the UI,
auto-projected — projection-from-one-definition (Frame 5 / the library-first principle) applied
to whole apps. All three are organ-2/3 research artifacts that **demonstrated the editing model
and never crossed into ecosystem viability** — they are evidence the *ideas* recur and *keep
not winning*, which is itself the datum Part B explains.

**Smalltalk / Lisp live images.** The program is a **live object graph / image**, edited in
place while running; redefine a method and every live instance sees it immediately. This is
**organ 4 (propagation) realized as runtime liveness** — change the decision, the running system
reconciles — and it predates all the above. It is also, per Fowler's own "I once thought
Smalltalk was going to be our future," the **archetypal cautionary tale**: a genuinely superior
editing/runtime model that lost to the text-file-plus-Unix-tools world anyway. Smalltalk's
defeat is the load-bearing prior for "superior model, lost to ecosystem" (B.2).

### A.7 — The reconciler engines: Salsa, Adapton, Skip, differential dataflow, tree-sitter

**How they work.** These are **incremental computation** frameworks: define a computation as a
graph of memoized queries (Salsa, which *powers rust-analyzer*), or as self-adjusting
computation (Adapton), or as incremental reactive (Skip), or as incremental dataflow over
changing relations (differential dataflow / Materialize). On an input change they **recompute
only the affected subgraph** via dirty-marking + demand-driven re-evaluation — the exact
"dirty-mark + topological recompute" engine Frame 5 found in spreadsheets, generalized to
arbitrary computations. tree-sitter is the incremental *parser*: re-parse only the edited span.

**Maps to the vision:** organ 4, **fully and at production grade**. The reconciler's fixpoint
propagation engine is not a research gap — Salsa is shipping inside the Rust IDE millions of
developers use; differential dataflow does it at database scale. The CDCL "learn-from-conflict"
half of the vision is equally shipping, in every modern SAT/SMT solver, and the
constraint-propagation half is in every CSP engine (Frame 5).

**What it misses:** nothing in its lane — which is the point. **Organ 4 is done.** The thread's
"machine runs fixpoint propagation, derives mechanical shrapnel" describes Salsa applied to a
decision graph. The missing piece was never the engine; it is *what flows through it* (a
decision representation, organ 3) and *what happens at the leaves where propagation can't
determine the answer* (organ 5).

### A.8 — Survey verdict: the assembled scorecard

| Organ | Solved by | Maturity | Gap |
|---|---|---|---|
| 1 Locate | CodeQL, Glean, Semgrep, name-resolution | Production, billions of LOC | none |
| 2 Edit-as-decision | OpenRewrite, codemods, IDE refactors | Production (M-only) | open authoring of novel edits; no S |
| 3 Decision-as-storage | Unison, MPS, OpenRewrite LST | Unison 1.0 (2025), MPS niche | adoption / text-world interop |
| 4 Propagate (fixpoint) | Salsa, Adapton, diff dataflow, CDCL | Production (in rust-analyzer, DBs) | none |
| 5 Fill / refuse spawned | Hazel (socket only) | research; **no filler existed** | **the filler — this is where the LLM enters** |

**The survey's payload for the synthesis:** four of five organs are not merely prototyped but
*shipping in tools developers use daily*. The vision is not "invent five new things." It is
"assemble four solved things and supply the one missing organ — the filler for spawned
decisions." Every prior whole-vision attempt (A.6) is an attempt to assemble organs 2+3 (+some
4) **with organ 5 left to the human**, which is exactly the configuration Part B shows is fatal.

---

## PART B — THE AUTOPSY: why projectional/intentional editing has not won

Projectional editing is ~40 years old (Cornell Program Synthesizer, early 1980s); intentional
programming ~30 (Simonyi, mid-1990s); MPS ~20 (mid-2000s). The ideas are good, recur
constantly, and *keep not winning*. A serious synthesis has to diagnose this or it is just the
next entry in the graveyard. I separate the failure modes into **contingent** (an artifact of
era/tooling/missing-component, removable) and **structural** (intrinsic to the approach).

### B.1 — FAILURE: text interop / the diff-merge-git problem — *contingent*

The dominant software ecosystem is built on **plain-text files + line-oriented diff + 3-way
merge + git + grep + every CLI tool ever written**. A projectional editor stores an AST/graph,
not text. This breaks the entire toolchain at the storage seam: you cannot `git diff` it
meaningfully, cannot review it in a normal PR, cannot grep it, cannot open it in vim, cannot use
the thousand small tools that assume lines of text. Historically projectional systems either
invented their *own* storage with no accepted interchange format (the search literature flags
"no generally accepted storage representation" as a recurring, often-skipped problem) or
serialized to opaque XML that diffs horribly.

**Why contingent.** This is an *interop* failure, not a *concept* failure, and the survey shows
it is already being solved two independent ways. (1) **OpenRewrite's LST round-trips to
byte-identical text** — AST-true editing, text-true storage, normal git/PR/diff downstream. (2)
**Unison stores hashes but can render canonical text** and is building the diff/merge story at
*decision* granularity (a rename is a no-op merge — strictly better than text merge). And
structurally, **semantic / AST-level diff and merge is provably superior** to line diff (it
doesn't spuriously conflict on reordering or reformatting); the reason text diff won was
maturity and ubiquity, not correctness. Tooling can close this. It is contingent — but note it
has *individually* been hard enough to consume years of effort, so "contingent" ≠ "cheap."

### B.2 — FAILURE: bootstrapping / ecosystem — *contingent but brutal*

Even a strictly-better editor inherits an empty world: no Stack Overflow answers in your
notation, no libraries authored in it, no hireable developers who know it, no blog posts, no
muscle memory, no integration with the IDE features built over text. This is the **Smalltalk
defeat** Fowler invokes ("I once thought Smalltalk was going to be our future") — a genuinely
superior live-image model that lost to text-file-plus-Unix because the *ecosystem* compounded
around text and network effects are nearly impossible to overcome head-on. MPS is confined to
DSL niches (finance, embedded, healthcare) for exactly this reason: in a *greenfield DSL* there
is no incumbent ecosystem to fight, so projectional editing wins locally; in *general-purpose*
programming it must displace an ecosystem with 50 years of compounding, and cannot.

**Why contingent (with a caveat).** Network effects are an *adoption-path* problem, not a defect
in the editing model. The escape hatch is the Sourcegraph-Batch-Changes lesson (A.5): **don't
replace the ecosystem — layer on top of it.** A decision-editor that ingests existing text repos,
edits at decision granularity, and *emits normal diffs/PRs back* (OpenRewrite's posture) never
asks the ecosystem to switch substrates, so it never pays the bootstrap tax. The caveat: this
forces the system to live as a *lens over text* rather than a *replacement for text*, which
caps how much of organ 3 you can claim. Contingent, but it constrains the design.

### B.3 — FAILURE: editing friction vs plain text — *partly structural, mostly contingent*

This is the most cited reason projectional editing "feels worse." When the program is an AST you
manipulate through a projection, ordinary text gestures break: you can't freely select across
node boundaries, you can't type a half-formed expression and fix it later, you can't paste
arbitrary text and clean it up, you can't comment out a syntactically-incomplete fragment.
Editing becomes "navigate the tree and fill slots" rather than "type characters." The 1980s
structure editors were notoriously unusable for this reason; MPS spent enormous UX effort
(grammar cells, side-transformations, smart references) to make AST editing *feel* like text,
and a controlled experiment by Voelter et al. (FSE 2016) found projectional editing in MPS
**competitive overall but task-dependent** — fine or better for tree-shaped/structured edits,
worse for the linear, free-form text gestures developers reflex to. *(Uncertainty flag: I have
the qualitative finding and the citation solidly; I could not extract the exact per-task
percentages from the PDF and am not stating a number I didn't verify.)*

**Why mostly contingent.** Most of the friction was *immature tooling* (the 1980s editors) and
*the human typing every character*. If the human's job shifts from "type the AST" to "approve a
proposed decision-edit and its derived shrapnel," the friction surface shrinks dramatically —
you are reviewing, not keystroking through a tree. The *structural* residue: a projection is a
*lossy, opinionated view* of the AST, and there are edits natural in text (sweeping a selection
across syntactic boundaries; transient ill-formed states during a refactor) that have no clean
projectional analogue. That residue is real but small, and shrinks further if the LLM, not the
human, is the one navigating structure.

### B.4 — FAILURE: the commercial death of Intentional Software — *mixed, and the key corpse*

Simonyi's Intentional Software is the canonical whole-vision attempt and its commercial arc is
the autopsy's centerpiece. *Verified facts*: the Domain Workbench reached real technical
maturity (Fowler, 2009, first-hand: "startling potential," "realness and maturity"); yet **no
system built with it had gone live** as of that assessment; it was kept under restrictive NDA
rather than released; the company **pivoted from intentional programming to office/collaboration
productivity**; Microsoft acquired it in 2017 and folded the people into Office — the
programming-tool thesis was *not* productized. The author of intentional programming, in effect,
**abandoned intentional programming as a business.**

**Contingent vs structural — and this is the subtle one.** The *contingent* reading: wrong era
(no incremental engines, no semantic-search infra, no cloud), a closed go-to-market (NDA-only,
no ecosystem play — B.2 self-inflicted), and a tool that demanded customers re-platform their
entire development model at once. The *structural* reading, which I weight more heavily and
which feeds B.5: the Domain Workbench let you *define* intentions and *project* them, but every
time you introduced a new intention you had to *also author its projection, its semantics, its
editing behavior* — i.e., the system **forced the human to fill an unbounded stream of spawned
decisions** (how does this intention render? how does it edit? what does it compile to?) before
any value came out. The intention-capture was real; the *cost of supplying everything the
captured intention spawned* was the unpriced liability that sank it. Hold that thought.

### B.5 — THE STRUCTURAL FAILURE: nothing could fill the spawned decisions

Strip B.1-B.4 of their contingent layers and one defect remains, common to *every* whole-vision
attempt:

> **The projectional/intentional model makes editing *one decision* cheap and makes the
> *mechanical* shrapnel free — but it offers no help with the *spawned* decisions, and pre-LLM
> the only entity that could supply a spawned decision was the human. So the moment an edit
> spawned decisions (which general-purpose editing constantly does — Frame 3's irreducible S),
> the human had to fill all of them, immediately, by hand. The system had moved the work
> around, not removed it.**

This is the through-line connecting the corpses:

- **Intentional Software (B.4):** every new intention spawned its projection/semantics/editing
  decisions; the human supplied them all; value never exceeded the supply cost.
- **MPS (B.2):** projectional editing wins only in DSL niches because *defining the language*
  front-loads the spawned-decision cost onto a language engineer once, amortized over many users
  — exactly the configuration where a *human can afford* to fill the spawned decisions. In
  general-purpose use, where every edit spawns fresh undetermined content, there is no amortizing
  expert and no filler.
- **Hazel (A.6):** built the *socket* for spawned decisions (typed holes) with mathematical
  precision — and then a human types into the hole. The socket without a plug.
- **IDE refactorings (A.1):** the *only* whole-success in the survey, and they succeed by
  **definitionally restricting themselves to S = 0** — "behavior-preserving" means "spawns
  nothing." The pre-LLM decision-editor *works*, and it works *exactly on the subset with no
  spawned decisions.*

This is structural because it is not about era or tooling: it is intrinsic that a behavior-
*changing* edit (as opposed to a behavior-preserving refactor) routinely forces new content that
*nothing in the existing program determines* (Frame 3's irreducible-bit; Frame 11: no cheap
total verifier exists at that leaf). Pre-LLM, the universe of "things that can supply
undetermined-but-forced behavioral content" had exactly one member: a human programmer. So every
projectional system reduced, on the behavior-changing edits, to "a fancier way for the human to
type the new behavior" — and a fancier-but-different way of doing the thing you already do
fluently in text loses on friction (B.3) every time. **The graveyard is full of systems that
optimized organs 2+3+4 and had no organ 5.**

### B.6 — The "notation is not the problem" critique

A recurring critique (visible across the projectional-editing literature and Fowler's bliki) is
that projectional/intentional editing answers a question developers were not most blocked on.
The pitch is "free yourself from textual notation / express intent directly," but **notation was
never the dominant bottleneck** — developers are fluent at reading and writing text, and the
hard parts of programming are *understanding the system, deciding what to change, and getting
the consequences right.* So projectional editing paid the enormous costs of B.1-B.3 to solve a
problem (notation flexibility) that ranked low on the actual pain list, while leaving the
top-of-list pain (deciding + propagating consequences correctly) largely untouched. This is why
it reads as a solution in search of a problem outside DSL niches.

**This critique is the hinge of the whole frame.** It is *correct about the historical systems*
and it tells you precisely where the real value is: **not in changing the notation, but in
automating the consequence-propagation and consequence-deciding.** The thread's vision is *not*
fundamentally a notation play (despite using a decision representation) — its payload is organs
4+5: derive the mechanical shrapnel, surface and help fill the spawned decisions. If the
synthesis lets itself slide into "edit a nicer notation," the critique kills it. If it stays on
"the machine computes and reconciles the consequences of a decision," the critique *endorses* it
— that is the unaddressed pain.

---

## PART C — IS NOW DIFFERENT? Does the LLM-oracle change the calculus?

Line the failures up against what the LLM provides:

| Failure | Type | Does the LLM remove it? |
|---|---|---|
| B.1 text/diff/merge interop | contingent | No — solved by engineering (OpenRewrite LST, Unison's AST-merge). LLM-orthogonal. |
| B.2 ecosystem bootstrap | contingent | Partly — LLM *reduces* the cost of operating over the existing text ecosystem (translate, ingest, emit normal PRs), easing the "layer on top" path; doesn't erase network effects. |
| B.3 editing friction | mostly contingent | Yes, substantially — if the LLM navigates structure and proposes edits, the human reviews instead of keystroking through an AST; the friction surface collapses. |
| B.4 Intentional commercial death | mixed | The contingent parts (era/infra/GTM) are solved by 2026 infra; the structural part (B.5) is the LLM's actual target. |
| **B.5 nothing could fill spawned decisions** | **structural** | **Yes — this is exactly what the LLM is. The first non-human entity that can supply undetermined-but-forced behavioral content at a leaf.** |
| B.6 notation-not-the-problem | critique | The LLM moves the value from notation (where the critique bites) to consequence-automation (where the critique endorses). |

**The answer, stated precisely.** *Now is different in exactly one structural way, and it is the
decisive one.* Every prior whole-vision attempt died — once you strip the contingent layers — on
the same defect: **organ 5 had no implementation, because filling a spawned decision requires
producing behavioral content that nothing determines, and pre-LLM only a human could do that, so
the system collapsed back into manual labor on precisely the behavior-changing edits that
matter.** The LLM is the first plausible filler of organ 5: an oracle that, at a leaf, proposes
content for a forced-but-undetermined slot. **That is the one thing the graveyard never had.**

The frame's two unifying disciplines bound the claim and keep it honest:

1. **Frame 11's verification-dual / "oracle at a leaf needs a cheap total verifier at that
   leaf."** The LLM does not *prove* the spawned decision correct; it *proposes*. The calculus
   only closes where the proposal can be cheaply checked — by the type system (Hazel's typed
   hole constrains the LLM's output), by tests (Frame 12: behavior is the substrate, tests are
   the spec), by the constraint-propagation that derived the slot in the first place. **The LLM
   fills S; the verifier gates it; the human adjudicates what neither can.** Where no cheap
   verifier exists at the leaf, the system must *refuse to invent* (the vision's own rule) and
   route the slot to the human — which is strictly the pre-LLM behavior, i.e. no regression. So
   the LLM strictly dominates: it removes human work on the verifiable-leaf subset and changes
   nothing on the rest.

2. **The compositionality master-discriminator (shared context).** The LLM helps most where the
   spawned decision is *local and verifiable per-site* (compositional). For the genuinely
   non-compositional global ∀-properties (Frame 13's deletion ∀-claims, intrinsic
   unlocalizability), the LLM is *no more* able to discharge a global proof than a human guessing
   — it proposes, it does not certify. So "now is different" is **bounded to the
   compositional/verifiable-leaf region**, which is exactly the region the whole thread already
   identified as the localizable, machine-reconcilable one. The LLM does not expand the
   *theoretically* editable frontier; it makes the *already-localizable* frontier
   *economically* reachable by supplying the one organ that had no implementation.

**Net.** The autopsy's verdict is not "projectional editing was wrong" — it is "**projectional
editing built four of the five organs and shipped them, then died for want of the fifth, and the
fifth just arrived.**" The contingent blockers (B.1-B.3) remain real engineering and each has
historically sunk a company, so "is now different" is a *necessary-not-sufficient* yes: the
structural blocker is removed, the contingent ones are now-solvable rather than now-solved, and
the design must obey the verification-dual (LLM proposes, verifier gates, refuse-to-invent at
unverifiable leaves) or it will simply re-pollute the codebase with confident-wrong spawned
content — which is the new failure mode the old graveyard never had to worry about, precisely
because it never had a filler at all.

---

## Open threads this frame surfaces

- **The Hazel + LLM pairing is the most concrete buildable instance of the whole vision** —
  typed holes (organ 5 socket) + LLM (organ 5 filler) + type checker (the cheap leaf verifier
  the dual demands). Worth a dedicated frame: does the typed-hole discipline actually constrain
  LLM output enough to make the gate cheap?
- **Sourcegraph's "layer on text, don't replace it" is the only proven adoption path** and
  directly contradicts the projectional instinct to replace text. The synthesis must pick a
  side; design-it-twice candidate.
- **The new failure mode: confident-wrong spawned content.** The graveyard's systems never
  filled S, so they never *mis*-filled it. An LLM filler introduces a risk class the prior art
  was immune to. The refuse-to-invent rule + verifier-gate are the proposed guardrails; their
  adequacy is unproven and is the sharpest risk to the whole program.

---

### Sources (load-bearing external claims; flagged where uncertain)

- Martin Fowler, *bliki: Intentional Software* (2009) — "startling potential / realness and
  maturity," "no system designed using the Intentional Domain Workbench has yet gone live," "I
  once thought Smalltalk was going to be our future." <https://martinfowler.com/bliki/IntentionalSoftware.html>
- Wikipedia, *Intentional Software* — 2002 founding, pivot to productivity, Microsoft acquisition
  May 2017, employees to Office team. <https://en.wikipedia.org/wiki/Intentional_Software>
  (*Uncertainty: internal reasons for the pivot are not public; abandonment inferred, not stated.*)
- Wikipedia, *JetBrains MPS*; JetBrains MPS site — projectional editing over AST, YouTrack as
  first commercial MPS product, mbeddr, DSL-niche adoption (finance/healthcare/embedded).
- Unison — content-addressed (SHA3 of AST), code-in-database, **1.0 reached Nov 25 2025**, first
  content-addressed language at production status, small adoption / Haskell-tier learning curve.
  <https://www.unison-lang.org/> and 1.0 announcement coverage.
- Voelter et al., *Efficiency of Projectional Editing: A Controlled Experiment* (FSE 2016) —
  projectional editing in MPS competitive but task-dependent; structured edits good, free-form
  linear text edits worse. <https://voelter.de/data/pub/fse2016-projEditing.pdf>
  (*Uncertainty: qualitative finding + citation verified; exact per-task percentages NOT
  extracted/verified — no number is asserted.*)
- Projectional-editing literature (Voelter "Towards User-Friendly Projectional Editors" SLE 2014;
  Tomassetti; Fowler *bliki: Projectional Editing*) — "no generally accepted storage
  representation"; friction-vs-text as the chief adoption barrier; the notation-not-the-problem
  critique.
- Tool mechanics (CodeQL relational/Datalog model; Glean; Semgrep; OpenRewrite LST; jscodeshift/
  comby/ast-grep; Salsa powering rust-analyzer; Adapton; differential dataflow; tree-sitter
  incremental parse; Hazel typed holes) — stated from established system design; not novel claims.
