# Frame 5 — Cross-Disciplinary Analogy

*Mining the fields that already solved "change one decision, propagate all consequences"
for structure the program-editing space is missing. Each discipline is examined for its
**unit of editing**, its **localization** mechanism (where a decision lives once), its
**propagation** mechanism (how the machine derives the shrapnel), and the **concrete import**
into program editing — then the analogy's breaking point (why programs are harder).*

## The frame, stated precisely

The reasoning thread established that a program is a structure of *decisions* and that text
**smears** each decision across N coordinated edits, dumping the find-and-coordinate burden
on the human. Frames 1–4 chart this from *inside* the code (program axes, localizing
representations, the mechanical-vs-spawned propagation axis, the empirical diff taxonomy).

This frame looks *outward*. Several mature engineering disciplines are, at their core,
**single-edit-propagates engines** — their entire value proposition is exactly the thing
program editing lacks: you change one thing, and the system *computes and applies* every
downstream consequence. They have had decades (spreadsheets since 1979, relational algebra
since 1970, Make since 1976, CSP/constraint propagation since the 1970s) to evolve the
machinery. The bet of this frame: their solved structure reveals what program editing is
missing, because they have *already paid the design cost* of the propagation engine.

I use the M/S vocabulary from Frame 3 throughout: **M = mechanical shrapnel** (consequences
fully determined by the decision + the artifact, derivable with no new information) and
**S = spawned decisions** (sites the change *forces to exist* but cannot *fill* — they admit
multiple consistent completions and need an oracle). The sharpest cross-disciplinary finding,
stated up front so the rest can be read against it:

> **Every one of these disciplines is a near-pure-M engine, and that is *why* they work. They
> achieved one-edit-propagates not by inventing a better propagator but by engineering their
> representation so that S ≈ 0 inside their domain.** A spreadsheet's recompute, a database's
> view refresh, Bazel's rebuild, Terraform's apply — none of them ever needs an oracle to
> *fill* a forced-but-unspecified slot, because the representation is constrained so that no
> such slot ever arises. The decision *determines* its consequences completely. Programs are
> harder for one reason above all others: **general code has irreducible S** — a changed
> decision routinely forces new behavioral content that nothing in the program determines. The
> disciplines below are existence proofs that the propagation engine is *cheap once S is
> driven to zero*, and a map of the four distinct tricks they use to drive it there.

---

## 1. Spreadsheets — the purest one-edit-propagates system

**Unit of editing.** The **cell**. You edit one cell's value or formula; nothing else.

**Localization.** A fact lives in exactly one cell. Every other place that depends on it holds
a *formula referencing that cell* (`=B2*1.08`), never a copy of the value. This is DRY
enforced by the medium itself — there is no syntactic way to "inline" a value such that it
stops tracking its source. (Users *do* defeat this by pasting literals, which is the
spreadsheet equivalent of copy-paste smear; the engine only propagates through references.)

**Propagation — the actual mechanism.** The sheet maintains a **dependency graph**: edges from
each cell to the cells its formula reads. On an edit, the engine does **dirty-marking +
topological recompute**: mark the edited cell and everything transitively downstream dirty,
then evaluate dirty cells in dependency order (a cell is computed only after its inputs), and
stop. This is *minimal* — only the affected subgraph recomputes, not the whole sheet (modern
engines; early ones recomputed everything, which is why dependency-ordered recalc was a real
advance). Cycles are detected and flagged as errors rather than diverging. The model is
**incremental, demand-or-change-driven dataflow**. (Exact recompute scheduling differs across
Excel/Google Sheets/LibreOffice — Excel's "calculation chain" is the named structure — but
the dirty-mark + topo-order skeleton is common; I'm confident on the skeleton, less on
vendor-specific scheduling details.)

**Concrete import into program editing.** This is the cleanest analogy and it maps *directly*
onto Frame 2's mechanism 1 (DRY) and mechanism-9's "constraint solvers / declarative layout":
treat the program as a **dependency graph of definitions**, and on an edit, *recompute only
the transitive downstream closure*. The importable mechanism is **per-definition dirty-marking
with topological, minimal re-derivation** — which is exactly what an incremental type-checker
or a query-based compiler does (Rust's `rustc` query system, the Salsa framework, Roslyn's
incremental model). The deeper import is the *editing model*, not the recompute: in a
spreadsheet **you never edit a derived value**. The derived cells are read-only outputs of the
formula graph. The program-editing equivalent is the radical move — **make derived code
non-editable**: generated impls, propagated renames, threaded forwarding are *outputs*, and the
only editable surface is the set of "input cells" (the genuine decisions). This is precisely
the projectional-editing / Unison-by-hash idea from Frame 2's adjacent localizers, reframed as
"a program is a spreadsheet whose cells are definitions."

**Where it breaks (why programs are harder).** Three places:
1. **Spreadsheet formulas are pure and total.** A formula is a side-effect-free function of its
   inputs; recompute is safe to run any time, any order (within topo order), any number of
   times — *idempotent and referentially transparent*. Program "recompute" includes effects,
   IO, mutation, and non-termination; you cannot just re-evaluate the downstream closure.
2. **S ≈ 0 by construction.** A cell's formula *fully determines* its value. There is never a
   "the engine knows this cell must change but cannot know to what" — that situation is
   impossible in the model. Program edits routinely produce exactly that (add an enum case →
   the new match arm's *behavior* is undetermined). The spreadsheet has no concept of a spawned
   decision because its representation forbids one.
3. **The dependency graph is explicit and machine-authored.** You write `=B2`; the edge exists
   because you declared it. In a program the dependency graph (who-calls-whom, who-reads-this-
   type) must be *recovered* by static analysis and is undecidable in the presence of dynamic
   dispatch, reflection, and `eval`. The spreadsheet's graph is a given; the program's must be
   inferred and is incomplete.

---

## 2. Parametric / feature-based CAD — the "design intent" model

**Unit of editing.** The **parameter** (a named dimension/value: `hole_diameter = 8mm`) or a
**feature** in the feature tree (extrude, fillet, pattern, constraint). You edit one parameter
or one feature's definition.

**Localization.** This is the discipline's signature idea and the one most missing from program
editing: **design intent is stored, not just the resulting geometry.** A parametric CAD model
(SolidWorks, Fusion 360, CATIA, FreeCAD, the Onshape/Parasolid/OpenCascade kernels) is not a
bag of triangles — it is a **feature history** (an ordered program of modeling operations) plus
a **constraint system** (geometric/dimensional relations: "these two edges are parallel," "this
hole is centered," "this wall is 2mm from that one"). The decision "the bracket is 80mm wide"
lives in *one dimension parameter*; the decision "these faces stay flush" lives in *one
constraint*. The final geometry is *derived*, never authored directly.

**Propagation — the actual mechanism.** Two coupled engines:
- **Regeneration / replay.** Change a parameter and the kernel **re-executes the feature tree**
  from the point of change downward, regenerating geometry. This is literally "replay the
  decision log with one decision altered" — the same structure as database migrations (Frame 2
  mechanism 8) and event-sourcing replay.
- **Constraint solving.** A **geometric constraint solver** (typically degrees-of-freedom
  analysis + iterative numeric solving, e.g. Newton-Raphson on the constraint residuals; some
  use graph-based decomposition into solvable clusters) re-derives all dependent geometry so
  every constraint holds simultaneously. Change one dimension and a hundred coordinates move so
  that "parallel," "tangent," "concentric," "centered" all remain true. *The constraints are
  the invariants; the solver propagates the edit so the invariants are preserved.*

**Concrete import into program editing.** Two distinct imports, both strong:
1. **Store the modeling history as the artifact** — the *feature tree is the source of truth and
   the geometry is a projection*. The program-editing analogue: keep the **ordered log of
   semantic operations** that built the code (not the text diff log — the *decision* log:
   "introduce abstraction X," "split type Y," "add field Z"), and *regenerate* the code by
   replaying it. Editing-the-decision then means *editing a node in the history and replaying* —
   which is exactly the reasoning thread's goal. This reframes refactoring tools as
   "history-edit-and-replay" rather than "mutate text in place."
2. **Constraints as first-class, solver-maintained invariants.** Frame 1's axis L (invariants)
   and Frame 2's frontier item 1 (semantic invariants have no localizer) are *exactly* what CAD
   solves for geometry. The import: represent program invariants ("these two functions must
   stay in sync," "this constant is half that one," "this enum and that DB column must match") as
   **declared constraints**, and have a solver *propagate edits to maintain them* rather than a
   linter merely *flagging* violations. CAD does **propagate-to-restore**; program linters only
   **detect-and-report**. That gap — restore vs report — is a concrete, importable capability.

**Where it breaks (why programs are harder).**
1. **CAD constraints are over a continuous, metric domain** (coordinates in ℝ³) where numeric
   solvers converge. Program invariants are over a discrete, symbolic, often-undecidable domain;
   there is no Newton-Raphson for "make this match arm correct." The solver's *power* comes from
   the domain's continuity, which programs lack.
2. **Regeneration in CAD is total and deterministic** — replaying the feature tree always yields
   the same geometry (modulo solver non-convergence, which CAD users *do* hit as "rebuild
   errors" / "dangling references" when a feature's referenced geometry vanished — notably the
   *same* fragile-reference failure as AOP's fragile pointcuts in Frame 2). Replaying a program
   decision log is not deterministic in the presence of effects and is far more prone to a
   downstream feature losing its anchor.
3. **CAD has no S inside geometry** — a parameter change never forces "new geometry whose shape
   is undetermined." Program edits do. CAD's spawned-decision-free-ness is, again, a property of
   the constrained representation.

---

## 3. Relational databases — normalization, views, transactions

**Unit of editing.** Two scales, deliberately separated: the **tuple/row** (one `UPDATE` to one
fact) at runtime, and the **schema/constraint** (one `ALTER`/migration) at evolution time.

**Localization.** The defining technique is **normalization** (Codd's normal forms): structure
the schema so that **every fact is stored exactly once**. A customer's address lives in one row
of one table; orders *reference* it by foreign key. This is DRY raised to a formal theory —
3NF/BCNF are *precisely* "no non-key fact is derivable from or duplicated by another," i.e. the
schema is designed so that *no decision is smeared across multiple rows*. Update anomalies (the
thing normalization eliminates) **are exactly the relational name for decision-smear**: if an
address is copied into every order, changing it requires N coordinated edits and risks
inconsistency. Normalization is the deliberate, theorized elimination of that smear.

**Propagation — three distinct mechanisms:**
- **Foreign-key references.** A normalized fact is referenced, not copied, so a single `UPDATE`
  to the canonical row is *seen* by every reader through the join — propagation by reference,
  identical in spirit to a spreadsheet cell reference or a program constant.
- **Views and materialized views.** A **view** is a *derived* relation defined by a query; it
  is the relational analogue of a derived spreadsheet cell or generated code — *read-mostly,
  recomputed from its sources*. A **materialized view** caches the result and must be
  *maintained* on base-table change; **incremental view maintenance (IVM)** computes the delta
  to the view from the delta to the base tables rather than recomputing from scratch — this is
  the database's *incremental propagation engine*, the direct cousin of spreadsheet
  dirty-recompute and Bazel's minimal rebuild. (IVM is well-developed in research and in some
  engines — e.g. Materialize, and to varying degrees in PostgreSQL extensions, Oracle, SQL
  Server indexed views; general IVM for arbitrary SQL is hard and not universally available.
  I'm confident IVM exists and is the right analogy; I'm flagging that "every DB does it
  automatically" would be an overstatement.)
- **Transactions (ACID).** A decision that *must* touch multiple sites at once (move money from
  account A to B; rename across linked tables) is wrapped in a **transaction** so the multi-site
  change is **atomic** — all-or-nothing, isolated from concurrent observers. This is the
  database's answer to "a single decision that intrinsically spans N sites": don't pretend it's
  one site, but make the N-site change *indivisible and consistent*.

**Concrete import into program editing.** Three:
1. **Normalization-as-discipline with a formal smear detector.** The deepest import here is that
   relational theory gives a *formal, checkable criterion* for "is this decision stored once?" —
   functional dependencies and normal forms. Program editing has no equivalent formal theory of
   "this fact is duplicated and should be normalized." Importing FD-style analysis to code would
   mean a tool that *detects denormalized decisions* (the same value/policy independently
   asserted in multiple definitions) and proposes the normalizing factor-out. Crucially,
   normalization also tells you **when not to** (the incidental-duplication trap from Frame 2 is
   a denormalization that is *correct* because the facts are genuinely independent — relational
   theory's "no spurious functional dependency" is exactly this distinction made formal).
2. **Atomic multi-site edits.** Frame 2's hardest band (schema migrations, item 8 distributed
   contracts) is about edits that *cannot* be one deploy because shared state is read
   concurrently. Transactions are the proven mechanism: **make the smeared edit atomic** even
   when you can't make it singular. The editing import is a "transactional refactor" — apply all
   N shrapnel edits or none, with nothing observing an intermediate inconsistent state. (Modern
   refactoring tools do this within one repo's filesystem; the DB lesson is to extend atomicity
   across the *deployed, running* boundary, via expand/contract — which is itself a known
   pattern the DB world formalized.)
3. **Materialized views ⇒ checked-in generated code.** The "materialize or recompute?" decision
   in databases is *exactly* the "check in generated code or build it?" decision in Frame 2's
   codegen limits. IVM is the answer the DB world refined: when you materialize, maintain
   *incrementally* from source deltas. Program codegen that recomputed only the affected
   generated units from the changed definitions (rather than full regen) would be importing IVM.

**Where it breaks (why programs are harder).**
1. **The relational model is closed and total.** Everything is a relation; every operation is
   relational algebra over relations; the result of any query is again a relation. This closure
   is why normalization and views compose so cleanly. Programs have no such closed algebra —
   their "values" include functions, effects, and unbounded control flow.
2. **A database fact has no behavior.** An address is data; updating it has no "new behavioral
   content" to supply. S ≈ 0 *again*, for the same reason as spreadsheets and CAD: the unit of
   change carries no undetermined behavior. The relational world's hardest cases are precisely
   the ones where behavior creeps in — stored procedures, triggers — which are *exactly where DB
   change starts to smear like code* (a trigger is action-at-a-distance, the DB's AOP). The
   analogy breaks at exactly the boundary where the database stops being data and starts being a
   program. **This is a sharp, telling fact: the discipline's clean propagation ends precisely
   where behavior begins — which is *all* of general program editing.**

---

## 4. Build systems — minimal rebuild of dependents

**Unit of editing.** A **source file** or a **build rule** (a target + its inputs + its recipe).

**Localization.** The build graph localizes the decision "what depends on what" into explicit
**rule declarations**. Each target names its inputs; the decision "this artifact is built from
those sources by this command" lives in one rule.

**Propagation — the actual mechanism.** A **dependency DAG** + change detection drives a
**minimal rebuild**: only targets transitively downstream of a changed input are rebuilt, in
topological order. The change-detection criterion is the key axis of evolution:
- **Make:** timestamp-based (`mtime` of input newer than output ⇒ rebuild). Coarse, fooled by
  clock skew and touch; over- and under-builds.
- **Bazel / Buck / modern systems:** **content-hash-based** ("hermetic" builds). A target is
  identified by the hash of *all* its inputs (sources, tools, flags, transitively). If the hash
  is unchanged, the output is reused — fetched from a **cache** (even a *shared remote* cache:
  someone else's identical build is your output). This is **content-addressed, hermetic,
  cacheable, distributable** building — the same content-addressing as Unison code (Frame 2) and
  Git blobs.

**Concrete import into program editing.** Two:
1. **Content-addressed incremental recompute, keyed on semantic inputs.** Bazel's "rebuild iff
   the input hash changed, else reuse cached output" is the propagation engine program editing
   wants for *derivation*: re-derive a piece of shrapnel (a generated impl, a regenerated client
   stub) iff the *decision it depends on* changed, and key the cache on the decision's content,
   not a timestamp or a file's bytes. The import is **hash-keyed minimal re-derivation over the
   decision graph** — strictly the spreadsheet/IVM idea, but with content-addressing making it
   distributable and shareable across machines (and across a team).
2. **Hermeticity as the enabler.** Bazel's superpower is not the DAG (Make had that) — it's
   **hermeticity**: a build action is a *pure function of its declared inputs* with no hidden
   dependencies, so its output is *cacheable and reproducible*. The import into program editing
   is the demand that each derivation step be a **pure function of its declared decision-inputs**
   — which is precisely the condition under which propagation can be cached, replayed, and
   trusted. This connects directly to the ecosystem's "prefer data over code at a seam" and
   "determinism is a hard invariant" principles.

**Where it breaks (why programs are harder).**
1. **Build systems propagate *re-execution*, not *content change*.** Make/Bazel decide *whether*
   to rebuild and then run an *opaque recipe* (the compiler). They never *derive what the new
   output should be* — they delegate that to the tool the rule names. So a build system solves
   the *scheduling/minimality* half of propagation and punts the *content* half entirely. In
   program editing, the content half (what does the new match arm *do*) is exactly the hard part
   (the S half). A build system would happily *re-run* a step that produces a hole; it has no
   notion of a hole.
2. **The recipe is hand-authored and the graph is hand-declared.** `BUILD` files and `Makefile`
   rules are written by humans; Bazel does not *discover* dependencies (it requires them
   declared, and *enforces* hermeticity by sandboxing to catch undeclared ones). Program
   dependency graphs must be *inferred* and are incomplete (same break as spreadsheets, item 3).
3. **S = 0 once more** — at the granularity the build system operates (whole-artifact), there is
   no undetermined behavioral slot; the recipe is fixed. The build system is another near-pure-M
   engine. Its lesson is about *minimality and caching of M*, not about S.

---

## 5. Infrastructure-as-code / config management — declarative desired-state + reconciler

**Unit of editing.** A **declared resource** in desired-state config (a Terraform resource block,
a Kubernetes manifest, an Ansible task). You edit the *desired end state*, not the steps.

**Localization.** The signature idea, and the one that most differs from everything above:
**you declare the desired state, never the transition.** The decision "there should be 5
replicas / this S3 bucket should be private / this DNS record should point here" lives in one
declaration of *what should be true*. You do **not** write "add 2 replicas" — you write "5," and
the system figures out it's currently 3.

**Propagation — the actual mechanism.** A **reconciler** computes the diff between **desired
state** (your config) and **observed/actual state** (reality, or a recorded state file) and
**derives the minimal set of actions** to converge actual → desired:
- **Terraform:** `plan` reads the **state file** (its record of what it last created) + refreshes
  actual cloud state, diffs against the config, and prints the action set (create/update/delete/
  replace). `apply` executes it. The decision (edit the config) propagates as a *computed plan*,
  not hand-written imperative steps. **Drift** (reality changed out-of-band) is detected as a
  diff against actual and reconciled.
- **Kubernetes:** **controllers run a continuous control loop** — observe actual, compare to the
  declared spec, act to reduce the difference, forever. This is **continuous reconciliation**:
  the desired state is *standing*, and the reconciler *perpetually* propagates any divergence
  (a crashed pod, a drifted replica count) back to desired. Convergence is an *ongoing invariant*,
  not a one-shot apply.

**Concrete import into program editing.** This is the most *conceptually* novel import:
1. **Declare the desired program-state; let a reconciler compute the edit diff.** Every other
   discipline above propagates *forward* from a change. IaC inverts it: you **state the
   destination** and the machine **derives the transition** (the shrapnel) by diffing against
   where you are. The program-editing import is profound and underexploited: instead of
   *performing* a refactor (a sequence of edits), **declare the target shape of the code/decision
   structure** and let a tool compute the minimal edit set to reach it. "The codebase should have
   exactly these public APIs / this module boundary / this type structure" → reconciler emits the
   diff. This is *desired-state editing*, and it is qualitatively different from forward
   propagation: it makes the **goal** the unit of editing, with the entire transition derived.
2. **Continuous reconciliation against drift.** Kubernetes' standing control loop maps onto
   "**keep the code converged to the declared invariants forever**" — not a one-time codegen, but
   a daemon that *continuously* re-derives generated/propagated artifacts whenever a source
   decision drifts (a developer hand-edits a derived file → reconciler reverts or regenerates).
   This is the answer to Frame 2's "stale generated code" failure: don't generate once, *reconcile
   continuously*, so drift is impossible by construction. The ecosystem's own `sync-skills.sh
   --check` drift guard and `propagate-*.sh` scripts are *exactly* a hand-built reconciler over
   the docs/skills decision — this frame's analogy says: that pattern is the IaC reconciler, and
   it generalizes.

**Where it breaks (why programs are harder).**
1. **Resources are independent and idempotently settable.** "Set replicas to 5" can be *applied*
   directly; the resource is a settable knob. Program structure is not a set of independently
   settable knobs — you cannot "set the type structure to X" without supplying the *behavior* the
   new structure requires (S again). The reconciler can compute *that* the type must split; it
   cannot compute the *content* of the split functions. IaC works because its resources have **no
   undetermined behavioral content** — the same S=0 property *yet again*, now visible as "a cloud
   resource is data-shaped, not behavior-shaped."
2. **Desired-state requires a *total, faithful model of actual state*.** Terraform's state file is
   the linchpin and its biggest failure mode (state drift, lost state, manual changes it can't
   see). The program analogue — a faithful model of the *current* decision structure of the code —
   is exactly what's missing and hard to recover (the inference problem again). Reconciliation is
   only as good as the actual-state read.
3. **Convergence assumes the desired state is *consistent and reachable*.** A reconciler loops
   forever if the goal is unsatisfiable. Programs routinely have desired structures that are
   under-specified (the goal doesn't pin down behavior) — so the reconciler would converge to a
   *hole*, not a working program.

---

## 6. Automated reasoning / constraint propagation — solver re-derives

**Unit of editing.** A **constraint** (a clause, an equation, a relation among variables) added,
removed, or changed in a constraint store / model.

**Localization.** A fact about the solution space lives as **one constraint**. "x ≠ y," "this
cell is in [1..9]," "A implies B," "the sum of these is ≤ 10." The decision is the constraint;
the *solution* (the variable assignment) is entirely derived. This is the limit case of "the
decision is localized and the entire artifact is a projection" — in a pure constraint model
*nothing* is authored except constraints; the solver produces everything else.

**Propagation — the actual mechanism.** This discipline has the most *sophisticated* propagation
engine of the six, and it is the closest to what program editing actually needs because it is the
only one that natively reasons about *logical* (discrete, symbolic) consequence:
- **Constraint propagation / arc consistency (CSP).** Adding a constraint **prunes domains**: AC-3
  and successors propagate "x can't be 3" through every constraint touching x, shrinking other
  variables' domains, cascading until a fixpoint. One added constraint ⇒ a wave of derived
  domain reductions. This *is* shrapnel propagation, done by fixpoint iteration.
- **Unit propagation / BCP in SAT solvers (DPLL/CDCL).** Setting one literal forces every clause
  it appears in to re-evaluate; clauses with one remaining unassigned literal *force* that
  literal (a "unit"), which cascades. **Boolean Constraint Propagation** is the engine's hot loop
  — one decision (a variable assignment) propagates a cascade of *forced* assignments.
- **Conflict-driven clause learning (CDCL) — the deepest mechanism of all six.** When propagation
  hits a contradiction, the solver does *not* just backtrack — it **analyzes the conflict, derives
  a new constraint (a learned clause) that explains why this path failed, and adds it** so the
  same dead end is never re-entered. The system **learns the shrapnel of its own failures and
  stores it as new localized constraints.** Modern SMT solvers (Z3, CVC5) lift this to rich
  theories (arithmetic, arrays, bitvectors, strings).

**Concrete import into program editing.** Two, one of which is the deepest in this whole frame:
1. **Treat the propagation engine as a fixpoint over constraints, not a one-pass rewrite.** Every
   other discipline's propagation is a DAG walk (acyclic, one pass). The constraint world handles
   *cyclic, mutually-constraining* decisions via **fixpoint iteration to consistency**. Program
   decisions are mutually constraining (a type change forces a signature change forces a call-site
   change that may force another type change). The import: propagate program edits by **iterating
   to a fixpoint** — apply the derivable consequences, which surface new under-determined sites,
   re-derive, repeat until stable — which is *exactly* the recursive worklist loop Frame 3
   describes (machine derives M, enumerates S, oracle fills S, fill re-enters as a new decision,
   recurse). **Frame 3's editing loop is literally a constraint-propagation fixpoint with an
   oracle at the leaves.** This frame names the engine that loop already is.
2. **Conflict-driven learning of localized invariants.** CDCL is the one mechanism here that
   *manufactures new localized facts from the consequences of a change*. The import into program
   editing: when a propagated edit causes a downstream failure (a test breaks, a type won't check),
   *learn a constraint that localizes the lesson* and store it so the failure class can't recur —
   the editing analogue of a learned clause is a newly-introduced type/invariant/test that
   prevents the whole *class* of smear next time. The ecosystem's own "rules are added when a
   failure mode is observed repeatedly" (the CLAUDE.md meta-rule) is, structurally, **CDCL for the
   development process**: don't just fix the conflict, learn the clause.

**Where it breaks (why programs are harder).**
1. **The solver's domain is decidable (or semi-decidable with good heuristics).** SAT is
   NP-complete but practically tractable; CSP/SMT have theories engineered for propagation.
   General program semantics is *undecidable* (Rice's theorem) — you cannot in general derive the
   consequences of a behavioral change by sound propagation, because the relevant properties
   aren't computable. The solver works because its constraints are in a logic it can reason over;
   most program decisions are not expressible in such a logic.
2. **The solver fills the solution — but program "solutions" include behavior the solver has no
   theory for.** A SAT solver *can* fill its holes (assign the variables) because the model
   *defines* what a valid fill is. Program spawned-decisions (what the new match arm *does*) have
   no such defining model — there is no constraint that pins the *intended* behavior, only the
   author's intent. This is the unbridgeable break, and it is the same break as every discipline
   above, now seen at its most fundamental: **S is irreducible in programs precisely because the
   intended behavior is information that exists only in the author's head, expressible by no
   constraint the machine holds.** The solver localizes and propagates *given a complete
   constraint set*; the defining feature of program editing is that the constraint set is
   *intentionally incomplete* — the program is where you *write down* the behavior, so it cannot
   already be a derivable consequence of constraints you've stated.

---

## Synthesis

### Per-discipline transferable mechanism (the table)

| Discipline | Unit of editing | Localization | Propagation mechanism | Importable mechanism |
|---|---|---|---|---|
| **Spreadsheet** | cell | fact in one cell; deps are references | dirty-mark + topological minimal recompute over an explicit dataflow DAG | per-definition dirty-marking + topo minimal re-derivation; **derived code is read-only output** |
| **Parametric CAD** | parameter / feature | design *intent* stored as feature-history + constraints; geometry derived | replay feature tree from change-point + numeric constraint solver restores all invariants | **store the decision/modeling history and replay it**; constraints that the solver *restores*, not merely reports |
| **Relational DB** | row (runtime) / migration (schema) | normalization — every fact stored once (FDs/normal forms = formal smear theory) | FK references; (incremental) materialized-view maintenance; ACID transactions for atomic multi-site change | formal denormalization detector; **transactional / atomic multi-site refactor**; IVM ⇒ incremental codegen |
| **Build system** | source file / rule | explicit dependency rules | content-hash minimal rebuild over a DAG; hermetic + cacheable + distributable | **hash-keyed minimal re-derivation over the decision graph**; hermeticity = each derivation a pure fn of declared decision-inputs |
| **IaC / config** | declared desired resource | declare *desired state*, not the transition | reconciler diffs desired vs actual, derives minimal converging action set; continuous control loop | **desired-state editing**: declare target code/decision shape, machine derives the edit diff; continuous reconciliation kills drift |
| **Constraint solver** | constraint / clause | one constraint; the whole solution is derived | fixpoint propagation (arc-consistency / unit-propagation) + **conflict-driven clause learning** | **propagate edits as a fixpoint loop**, not one-pass; **CDCL-style: learn a localized invariant from each failure** |

### The single deepest import

**Desired-state editing with a fixpoint reconciler that has an oracle at the leaves** — the
fusion of IaC's inversion (edit the *goal*, machine derives the *transition*) with the constraint
solver's *fixpoint-to-consistency* engine and CDCL's *learn-from-conflict*.

Stated as one mechanism: **the editor of the future is a reconciler.** You edit the *desired
decision structure* (a goal, a declared invariant, a target type/module shape — IaC's move). A
fixpoint engine (the constraint-propagation move) computes the diff against the current decision
structure and **derives every consequence it can** (the M shrapnel — spreadsheet/Bazel/IVM
minimal-recompute machinery), surfacing the residue of *forced-but-undetermined* sites (the S
holes) as a worklist. An **oracle fills only the holes** (Frame 3's leaves), and each fill
re-enters as a new declared decision, re-triggering propagation — iterating to a fixpoint. When a
fill causes a conflict, the engine **learns a localized constraint** (CDCL) so that class of smear
cannot recur. Derived artifacts are **read-only projections** (the spreadsheet/CAD/view discipline)
maintained by **continuous reconciliation** (Kubernetes), so drift and stale generation are
impossible by construction.

Every piece of that machine *already exists and is battle-tested in some discipline*. None of it
exists, assembled, for program editing. That is the frame's central claim: **the propagation
engine program editing needs is not unbuilt physics — it is six mature engines that have never
been composed into one, because no single discipline faced all of programs' difficulties at once.**

### What the cross-disciplinary frames reveal that the code-internal frames cannot

1. **S=0 is an *engineered property of the representation*, not a fact about the domain — and the
   four distinct tricks to achieve it.** The code-internal frames (1–4) take the program's
   representation as roughly given and ask which decisions happen to localize. Seeing six external
   disciplines that *all* drove S to ≈0 reveals that low-S is something you *design for*, and
   exposes the **four orthogonal tricks**: (a) **purity/totality** — make the unit a
   side-effect-free function of its inputs so re-derivation is always safe (spreadsheets, Bazel
   hermeticity); (b) **data-not-behavior** — make the unit of change carry no undetermined behavior
   (DB rows, IaC resources, CAD geometry); (c) **closed algebra** — make every operation's result
   stay inside a domain with a complete theory (relational algebra, constraint logics); (d)
   **derived-is-read-only** — forbid editing the projection so the source/derived split is
   enforced by the medium (spreadsheet cells, views, generated geometry). Frame 2's "localizing
   representations" lists program-side mechanisms; this frame supplies the *meta-recipe* for why
   they work and what a representation must satisfy to make a band of decisions low-S. **The
   program-editing project is, precisely, the project of pushing as much of code as possible into
   regions where one of these four tricks applies, and accepting irreducible-S only where none can.**

2. **Desired-state (backward) propagation is a whole mode the code-internal frames never
   consider.** Frames 1–4 are entirely *forward*: you change a decision, consequences flow
   downstream. IaC reveals an orthogonal, arguably superior mode — **declare the destination,
   derive the transition**. This is invisible from inside the code because code editing is
   habitually imperative-forward; only an outside discipline that made desired-state its entire
   paradigm surfaces it. It reframes "refactoring" from *a sequence of moves* to *a diff toward a
   declared target*, which is a different and more powerful unit of editing than any frame proposed.

3. **The Frame-3 editing loop has a name and a mature engine: it is constraint propagation with
   CDCL.** The code-internal frames *described* the worklist/oracle loop correctly but treated it
   as a novel construction. The constraint-reasoning discipline reveals it is a 50-year-old,
   heavily-optimized engine (fixpoint propagation + conflict-driven learning) — meaning the
   editing loop should *borrow that engine's hard-won structure* (watched-literals-style efficient
   re-propagation, learned-clause minimization, restart heuristics) rather than reinvent it
   naively. And it reveals the loop should **learn from its conflicts** (CDCL), which no
   code-internal frame proposed — turning each smear-causing failure into a new localized invariant.

4. **The analogy breaks at *exactly one* place, and it is the same place every time — which
   *locates* the irreducible core of the problem.** Across all six disciplines the break is
   identical: **the unit of change carries no undetermined behavior, so S≈0**, and the propagation
   engine is therefore "merely" a minimal-recompute scheduler over a derivable graph. Programs are
   harder for one reason and one reason only: **general code contains irreducible S — intended
   behavior that exists only in the author's intent and is expressible by no constraint the machine
   holds, because the program is the very place that behavior gets written down.** This is the same
   conclusion Frame 3 reached from inside (the M/S boundary), Frame 2 reached at its frontier
   (semantic invariants have no localizer), and Frame 1's effects/concurrency axes circled — but
   the cross-disciplinary view *proves* it by exhaustion: six independent, mature, unrelated fields
   each solved one-edit-propagates **completely**, and each did so by *never admitting an S*. The
   thing they all avoided is the thing program editing cannot avoid. **Therefore the achievable
   goal is not "eliminate S" (impossible — it is the definition of programming) but "drive M to
   fully-automatic and isolate S to a minimal, machine-enumerated, oracle-fillable worklist" — which
   is precisely the division of labor Frame 3 named, now underwritten by six existence proofs that
   the M-engine is cheap and well-understood once S is cordoned off.**
