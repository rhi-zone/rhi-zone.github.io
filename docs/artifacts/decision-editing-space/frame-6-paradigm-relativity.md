# Frame 6 — Paradigm Relativity

*Holding the **paradigm** as the variable. The same single decision smears
differently — or not at all — depending on the programming paradigm it is expressed in.
If smear is "what you get when a decision was never given a home" (the convergent claim
this thread is testing), then a paradigm is precisely a **standing offer of homes**: a
fixed set of slots into which certain decision classes drop for free, and a fixed set of
decision classes it has no slot for and therefore scatters. This frame charts which
paradigm is the localizing representation for which decision class, and concludes on
whether smear is an artifact of the imperative-text paradigm specifically.*

## How this frame differs from its siblings

Frames 1–4 chart the decision space along axes that are, implicitly, *paradigm-agnostic
but imperative-default*: program-structure layers (F1), localizing mechanisms (F2 —
DRY, types, effects, AOP, macros, config, schema), the mechanical-vs-spawned propagation
axis (F3), and real diffs (F4). They mostly hold the paradigm fixed (imperative/typed-FP)
and vary the decision or the mechanism.

This frame does the orthogonal thing: **fix the decision, vary the paradigm.** The payoff
is a claim none of the others can make — that several smear classes treated as
"frontier / open" in Frame 2 are *already dissolved*, just in a paradigm that mainstream
imperative practice doesn't reach for. The frontier of Frame 2 is partly a frontier *of
one paradigm*, not of computing.

A note on honesty: a paradigm dissolving a smear class is not free. It almost always
*relocates* the smear to a different class (the "conservation of smear" observation in the
verdict). The matrix below records both the dissolution and, where known, what it costs.

---

## The paradigms, as "offers of homes"

Each paradigm is characterized here by **what it makes implicit** — the plumbing it
removes from the programmer's hands, because removing plumbing is exactly removing the
sites where a decision would otherwise be smeared.

- **Imperative / OO** — explicit statement sequencing, explicit mutable state, explicit
  call graph. Dispatch localized *per object* (vtable) along one axis (the receiver). The
  baseline; smears most because it makes the most explicit.
- **Functional (typed)** — values not state; functions as the unit; ADTs + exhaustive
  `match`; effects pushed toward the type. Removes mutation-ordering plumbing; makes
  data-shape decisions type-checkable.
- **Logic / relational / declarative (Prolog, Datalog, SQL)** — state *relations/facts +
  rules*, not procedures. The engine derives *how* (resolution / query plan / fixpoint).
  Removes control flow and search strategy from the programmer's hands.
- **Array / APL-family (APL, J, K, BQN, dyad of "rank")** — the aggregate, not the
  element, is the unit; iteration is implicit; functions are **rank-polymorphic** (a
  scalar operation auto-lifts over any-rank arrays — verified: the iteration space is
  derived from the data's shape, no loop written). Removes loop/iteration plumbing
  entirely.
- **Dataflow / reactive (spreadsheets, FRP, signals)** — state a **dependency graph of
  values**; the runtime propagates changes in topological order (verified: glitch-free
  recompute via topological traversal). Removes change-propagation and update-ordering
  plumbing — the manual callback/observer wiring.
- **Constraint / synthesis (miniKanren, MiniZinc/CP, SAT/SMT, Sketch, program synthesis)**
  — state *what must hold* (constraints / a spec / a sketch with holes); the solver finds
  values or *the program itself*. Removes the algorithm from the programmer's hands.
- **Aspect-oriented** — not a base paradigm but an overlay: a *second* decomposition
  (pointcut + advice) layered on an imperative/OO base, specifically to localize the
  cross-cutting concern the base scatters. Included because it is the explicit
  "anti-smear bolt-on."

---

## The five fixed decisions

Chosen to span the decision spectrum and to be ones whose smear-profile is known to differ
sharply by paradigm:

- **D1 — Add a case to handle.** A new variant/kind/shape the program must now treat
  (new payment method, new node type, new event).
- **D2 — Change a value's representation.** `int id → UUID`; a flat record → nested; a
  scalar → a collection; cents-as-int → `Money`.
- **D3 — Make this fallible / async.** A computation that was total+synchronous can now
  fail or must await I/O (the "function-coloring" decision).
- **D4 — Add a cross-cutting check.** A concern that must fire at many unrelated sites:
  authorization, logging, an audit, a validation invariant.
- **D5 — Change a dispatch rule.** How the program *selects* which behavior runs: change
  the resolution order, add a dimension to dispatch on, change the matching predicate.

---

## The matrix (qualitative smear, per decision × paradigm)

Legend for smear severity, *for that decision in that paradigm*:
**DISSOLVED** (not a decision the programmer makes — the paradigm absorbs it) ·
**localized** (one edit, machine propagates / enumerates the rest) ·
**moderate** (a few edits, mostly mechanical, paradigm helps you find them) ·
**smeared** (scattered, human carries find-and-coordinate) ·
**badly smeared** (scattered *and* invisible / no tool enumerates it).

### D1 — Add a case to handle

| Paradigm | Smear | Why |
|---|---|---|
| Imperative/OO | **moderate→smeared** | Two sub-modes. The OO "add a *subclass*" path is **localized** (one new class implementing the interface; existing code untouched — the open/closed payoff). But the "add a *case to existing logic*" path (new branch in switch statements scattered across methods) is **smeared** — every `switch`/`if-chain` over the kind is a separate edit, and nothing enumerates them unless the language has exhaustive switch. This is the classic *expression-problem* asymmetry: OO localizes new-cases, smears new-operations. |
| Functional (typed) | **localized** | Add the ADT variant in one place; the exhaustiveness checker turns *every* non-wildcard `match` into a compile error — a complete worklist (Frame 2 §2). The dual of OO: FP localizes new-operations (one new function, total over the type), smears new-cases only as far as "the compiler hands you the list." Mechanical-locate, oracle-fill (Frame 3). |
| Logic/relational | **localized→DISSOLVED** | Add a *fact* or a *clause*: `handles(visa, ...).` Resolution picks it up with zero edits to existing rules — adding a case is monotone (just more facts/clauses). Datalog/Prolog/SQL-rows: a new case is a new row/clause, not a new branch. The dispatch *is* unification over the knowledge base, so cases are data. Among the strongest dissolutions in the matrix. |
| Array/APL | **smeared (mismatched unit)** | "A case" is element-level conditional logic, which the array paradigm expresses awkwardly (masking, `⍣`, guarded scatter). Adding a case forces branchy element code that fights the aggregate grain — APL's worst direction. |
| Dataflow/reactive | **moderate** | A new case = a new node/formula in the graph; downstream dependents recompute automatically (propagation free). But the *routing* to the new node (which upstream feeds it) is manual graph-editing. Localizes propagation, not selection. |
| Constraint/synthesis | **localized** | Add a constraint/clause describing the new case; the solver incorporates it. Like logic programming, cases are declarative additions, not control-flow edits. |
| Aspect-oriented | n/a (base concern) | AOP doesn't address adding ordinary cases; it's about cross-cutting. |

### D2 — Change a value's representation

| Paradigm | Smear | Why |
|---|---|---|
| Imperative/OO | **smeared→localized (encapsulated)** | If the representation was *encapsulated behind an object/accessor*, the change is **localized** (rewrite the class internals; callers use the same methods — the headline OO win). If it leaked (public fields, raw structs passed around), it is **smeared** across every access site. OO's offer is real *only when you paid the encapsulation tax up front.* |
| Functional (typed) | **localized** | Newtype/type-alias change in one place; the type checker enumerates every site that no longer typechecks (Frame 2 §2–3, the `int→UUID` case). Pattern matches on the old shape break loudly. Strong mechanical worklist. |
| Logic/relational | **moderate→smeared** | Relational *normalizes* representation decisions: a value's shape lives in the schema, and well-normalized data resists representation smear (one column, one meaning). But changing a column's type/shape is a **migration** that smears across data-at-rest + every query naming it (Frame 2 §8). SQL has no type checker over queries (stringly), so the worklist is *not* enumerated — you grep. Datalog with typed relations does better. |
| Array/APL | **DISSOLVED→localized** | This is the array paradigm's signature dissolution. *Adding a dimension* to a value (a vector becomes a matrix; one customer becomes N) requires **no code change** to rank-polymorphic operations — verified: the iteration space is derived from the data's shape, so a scalar/lower-rank function auto-lifts. The decision "this is now an array of what was a scalar" — which smears horrifically in imperative code (wrap everything in loops) — is *absorbed by the paradigm*. The limit: changing representation *within* an element (a number → a record) is not absorbed and is awkward (APL prefers flat numeric arrays). |
| Dataflow/reactive | **localized** | Change a cell/signal's type; dependents that consume it recompute (and, if typed signals, mistype loudly). The dependency graph means you can *see* the consumers — the graph is the worklist. |
| Constraint/synthesis | **localized** | Change the domain/type of a decision variable in one place; the solver re-solves. Representation lives in the variable declaration. |
| Aspect-oriented | n/a | Representation isn't a cross-cutting concern. |

### D3 — Make this fallible / async

| Paradigm | Smear | Why |
|---|---|---|
| Imperative/OO | **badly smeared** | The canonical *function-coloring* smear (Frame 2 §4): making one function `async` (or fallible-by-exception-discipline) forces `async/await` up the entire call chain; making it fallible forces every caller to handle/propagate. No structural locus — the decision is threaded through every stack frame. Imperative's *worst* decision class. |
| Functional (typed) | **localized→moderate** | Push the effect into the type: `T → Result<T>` / `T → IO T`. `?` / do-notation thread the plumbing mechanically (Frame 2 §4). The *return type* edit is localized; the propagation up the chain is mechanical (compiler-enumerated). Residual smear: monad-transformer stacking doesn't compose cleanly — combining fallible+async+stateful re-smears in the transformer stack. Algebraic-effect languages (Koka, OCaml 5, Unison) push this to **localized**: the effect is a tag, the discharge a single handler. |
| Logic/relational | **partially DISSOLVED** | Failure *is* the model: a goal that doesn't unify simply **fails** and backtracks — there is no fallibility decision to thread, partiality is the substrate (Prolog). SQL: a query that matches nothing returns empty; "fallible" isn't a per-call color. Async: SQL is set-at-once (no per-row await); the engine handles I/O scheduling. The decision largely *doesn't exist* as something the programmer threads. (Caveat: side-effecting/exceptional failure in real Prolog/SQL still exists; it's *logical* failure that's dissolved.) |
| Array/APL | **mostly DISSOLVED (async) / moderate (fallible)** | There is no call chain to color — operations are whole-array, applied at once. "Async" in the function-coloring sense barely arises; the unit of work is a bulk transform the runtime schedules. Fallibility: handled as data (NaN/fill/error-arrays propagate through operations) rather than as control-flow coloring. The smear that defines D3 in imperative code has *no surface to spread across* here. |
| Dataflow/reactive | **DISSOLVED (async) / localized (fallible)** | The headline reactive dissolution. **Async propagation is the paradigm's job** — verified: the runtime propagates updates through the dependency graph in glitch-free topological order. The imperative "thread the await through every caller" smear *does not exist*: a cell depending on an async source simply recomputes when the source resolves. Function-coloring — Frame 2's marquee cross-cutting *how* — is **absorbed by construction**. Fallibility localizes to the node (an error value flows downstream like any value). This is the single most striking pre-dissolution in the matrix. |
| Constraint/synthesis | **n/a→DISSOLVED** | Solving is one bulk act; there's no caller chain. Failure = unsat, reported once, not threaded. |
| Aspect-oriented | **localized (as a concern)** | "Wrap these methods in retry/timeout/circuit-breaker" is a textbook aspect — one advice, woven at matched join points. AOP can localize the fallibility *policy* even on an imperative base (Spring `@Retryable`). It does *not* dissolve the underlying coloring; it just hides the wrapper. |

### D4 — Add a cross-cutting check

| Paradigm | Smear | Why |
|---|---|---|
| Imperative/OO | **badly smeared** | The defining cross-cutting case: "authorize/log/audit at every service method" touches every method, with no locus (Frame 2 §5, Frame 4 §C). OO mitigates weakly (a base class / template method) but only along the inheritance axis. |
| Functional (typed) | **moderate** | Higher-order functions / a decorator combinator localize the *wrapper* (`withAuth(f)`), but you must still *apply* it at each site — per-site shrapnel, same as config-flag guards (Frame 2 §7). The check is *defined* once, *attached* N times. Effect systems do better: model the check as an effect, discharge in one handler — then **localized**. |
| Logic/relational | **localized** | A cross-cutting invariant is *one rule* over the whole knowledge base: a Datalog rule `violation(X) :- ...` or a SQL `CHECK`/assertion/trigger/row-level-security policy applies to all matching rows by construction. "Every row must satisfy P" is a single declarative statement, not N call-site insertions. RLS in Postgres is exactly "one policy, enforced on every query touching the table" — AOP's dream, but native. |
| Array/APL | **localized** | A check over a whole array is one masking expression applied to the aggregate (`∧/ predicate data`) — cross-cutting *over data* is the native grain. Cross-cutting *over code sites* (different operations) is not addressed. |
| Dataflow/reactive | **localized** | A validation node that depends on the inputs recomputes whenever any input changes; one node enforces the check across all updates. (Spreadsheet conditional formatting / a validation cell is exactly this.) |
| Constraint/synthesis | **localized→DISSOLVED** | A cross-cutting invariant is *the* native unit: add one global constraint and the solver enforces it across all variables/solutions. "This must hold everywhere" is what constraints *are*. The purest fit for D4 in the matrix. |
| Aspect-oriented | **localized (by design)** | This is the decision AOP *exists* for: one pointcut+advice, woven at all join points, auto-applies to future code too (Frame 2 §5). The catch (Frame 2's critique): localized for the *author*, **invisible** to the reader at the join point — action at a distance. It moves the smear from "scattered text" to "scattered invisibility." |

### D5 — Change a dispatch rule

| Paradigm | Smear | Why |
|---|---|---|
| Imperative/OO | **smeared** | Dispatch is wired into structure: single-dispatch vtable keys on the receiver type only. Changing the *rule* (dispatch on a second argument, on a value not a type, on a runtime predicate) means hand-rolling the visitor pattern, double-dispatch, or a strategy registry — scattered, manual. The dispatch policy has *no single home*; it's implicit in the class hierarchy + override placement. |
| Functional (typed) | **moderate** | Dispatch is the `match`/typeclass-instance resolution. Changing match *order* is a local edit to one function (localized) — a real win over OO's scattered overrides. Adding a dispatch *dimension* means changing the matched type (then exhaustiveness re-enumerates) — moderate. Multimethods (CLOS, Clojure `defmulti`/`defmethod`, Julia) make dispatch a **first-class, open, multi-argument** thing: change the dispatch function in one place, add methods independently — **localized**. Julia's whole design is "dispatch rule as the central editable artifact." |
| Logic/relational | **localized→DISSOLVED** | Dispatch *is* unification/resolution over clauses — there is no separate dispatch mechanism to edit. "Change which clause fires" = edit/add a clause or reorder; the matching engine is fixed and the *rules are data*. Multi-argument dispatch on values (not just types) is free — Prolog dispatches on the full term structure of all arguments. This is the cleanest dispatch story in the matrix: the thing OO scatters across a hierarchy is, here, *just the rule set*, edited in one place. |
| Array/APL | **localized (limited)** | Dispatch is mostly by rank/shape (rank operator `⍤`, or shape-driven selection). Changing "apply at this rank" is one glyph. But value/type-predicate dispatch isn't the idiom. |
| Dataflow/reactive | **moderate** | "Which computation feeds this node" is the graph topology; rewiring is a graph edit (localized to the node's dependency declaration) but conditional/dynamic dispatch (switching the source based on a value) needs higher-order signals — workable but not the sweet spot. |
| Constraint/synthesis | **localized** | "Which rule applies when" can be stated as constraints/priorities; the solver selects. In synthesis, dispatch logic can even be *synthesized* from examples — the rule is inferred, not written. |
| Aspect-oriented | **partially** | A pointcut *is* a dispatch rule ("run this advice when this pattern matches"). Changing the pointcut changes dispatch of the advice in one edit — localized for the aspect's own dispatch, but doesn't touch the base program's dispatch. |

---

## Which paradigms pre-dissolve which smear classes

Reading the matrix by *dissolution* (the cells where the decision stops being a decision
the programmer makes) yields the core finding — **the Frame-2 frontier is partly a
frontier of the imperative paradigm specifically:**

- **Function-coloring / async propagation (Frame 2's marquee cross-cutting *how*, D3)** is
  **dissolved by dataflow/reactive** and largely absent in array and logic paradigms. In
  imperative code it is "badly smeared"; in a signal graph the runtime *is* the
  propagation, so the decision has no surface to spread across. The smear is not intrinsic
  to async — it is intrinsic to *expressing async as threaded control flow in a call
  graph.* Change the paradigm, the smear evaporates.

- **Representation-rank changes (scalar→array, D2)** are **dissolved by the array
  paradigm** via rank polymorphism (verified). The imperative "wrap everything in a loop"
  smear is the cost of making iteration explicit; APL never made it explicit, so there is
  nothing to rewrite.

- **Dispatch (D5)** is **dissolved/localized by logic programming** (and by multimethod
  systems, which are FP/OO importing the logic-programming move). The thing OO scatters
  across a class hierarchy is, in Prolog/Datalog, *just the clause set* — dispatch is data.
  This directly answers the thread's prompt: yes, logic programming localizes dispatch that
  imperative scatters.

- **Cross-cutting invariants over data (D4)** are **localized natively by
  logic/relational and constraint paradigms** — a single rule / `CHECK` / RLS policy /
  global constraint. This is *exactly what AOP bolts onto imperative code to recover*, but
  it is native (and *visible*, unlike AOP) in the declarative paradigms. AOP is the
  imperative paradigm reinventing a relational primitive as an overlay.

- **Adding cases (D1)** is **localized by both FP (new operations) and logic/constraint
  (new clauses/facts as data)** — and the expression problem says no *single* paradigm
  localizes both new-cases and new-operations cheaply; OO and FP each dissolve one axis and
  smear the other. Logic/relational comes closest to dissolving *both* because both cases
  and operations are clauses (data), though at the cost of static guarantees.

Recast as "which paradigm is the localizing representation for which decision class":

| Decision class | Localizing paradigm(s) |
|---|---|
| Add a case (new variant) | Logic/relational (data), FP (with enumeration) |
| Add an operation (over existing cases) | FP, Logic/relational |
| Representation: add a dimension / scalar→array | **Array/APL (dissolved)** |
| Representation: type change | FP (typed worklist) |
| Make fallible/async (propagation) | **Dataflow/reactive (dissolved)**, then effect-FP |
| Cross-cutting check over data | Logic/relational, Constraint (native); AOP (overlay) |
| Cross-cutting check over code sites | AOP, effect-FP |
| Change dispatch rule | **Logic/relational (dissolved)**, multimethod-FP |
| Find values/algorithm satisfying a spec | **Constraint/synthesis (dissolved — the algorithm itself)** |

---

## Conservation of smear — the honest counterweight

No paradigm is globally less smeary; each dissolves a class by *relocating* the smear to
another class. The relocations are systematic:

- **Reactive** dissolves async-propagation but smears **control flow / sequencing /
  imperative steps** ("do A, then ask, then B" is awkward in a pure dependency graph) and
  makes **debugging the propagation** hard (the call stack is gone; the smear moved into
  *understanding why a cell recomputed*).
- **Array/APL** dissolves iteration and rank-changes but smears **element-level branchy
  logic** (D1 above) and **readability** (the decision density per glyph is so high that a
  *reader* re-smears across mental unpacking — Frame 4's "outside the code" smear, relocated
  into the human).
- **Logic/relational** dissolves dispatch and data-invariants but smears **control over
  *how* / performance** (you don't choose the resolution/join strategy; when the engine
  picks wrong, the fix — cut, indexes, query hints — smears across the program *and the
  engine's opaque cost model*) and **ordering/state** (pure logic has no good home for "do
  this, then that").
- **Constraint/synthesis** dissolves the algorithm but smears **specification** (getting
  the constraints exactly right is itself a smeared, error-prone activity — an
  under-constrained spec admits garbage; the decision moved from code into *spec
  completeness*) and **performance predictability**.
- **AOP** dissolves cross-cutting authoring but smears **readability/locality** (action at
  a distance — the decision is localized for the writer, *delocalized for every reader*).
- **Effect-FP** dissolves coloring but smears into **handler-interaction order** and
  **type/transformer machinery**.

The pattern: **every paradigm makes some plumbing implicit (dissolving the smear that
lived in that plumbing) and in exchange surrenders explicit control over it (smearing any
decision that needs to reach into the now-hidden machinery).** Smear concentrates wherever
a paradigm forces you to *fight its grain*. Imperative makes *everything* explicit, so it
smears *uniformly and moderately* across all classes (Frame 2's "text localizes nothing");
the declarative paradigms smear *sharply* — near-zero in their wheelhouse, severe at the
boundary where you need the control they took away.

---

## Verdict: is smear paradigm-contingent?

**Yes, decisively — but with a precise qualification that strengthens rather than weakens
the thread's convergent claim.**

The convergent claim under test was: *smear is contingent on representation, not intrinsic
— it's what you get when a decision was never given a home.* This frame supplies the
strongest possible evidence: the **same** decision (D1–D5, held fixed) ranges from "badly
smeared" to "DISSOLVED" purely by changing paradigm, with nothing else varied. Async
propagation is unsmearable agony in imperative code and *does not exist as a decision* in a
signal graph. Scalar→array is loop-rewriting-everywhere imperatively and *zero edits* in
APL. Dispatch scatters across an OO hierarchy and *is just the rule set* in Prolog. A
decision class is not intrinsically smeary; **it is smeary in paradigms that gave it no
home and dissolved in paradigms whose primitives are exactly its home.** Smear is the
*mismatch between a decision's natural shape and the paradigm's offered slots* — it is
relational, not a property of the decision.

The qualification — and this is the part that keeps the claim honest:

1. **Smear is conserved, not eliminated, by paradigm choice.** No paradigm is the universal
   localizer. Each dissolves the classes matching its grain and *relocates* smear to the
   classes that fight its grain. A program is a *mix* of decision classes, so any single
   paradigm leaves a residue smeared. (This is why Frame 2's *mechanism* view and this
   *paradigm* view converge: a "localizing mechanism" is largely a way to **import one
   paradigm's primitive into another paradigm** — multimethods import logic-dispatch into
   FP/OO; effect handlers import a declarative *how* into FP; AOP imports relational
   cross-cutting into OO; reactive libraries import dataflow into imperative languages;
   SQL/ORM imports relational into everything. The mechanisms of Frame 2 are, mostly,
   *paradigm-grafts.*)

2. **The frontier of Frame 2 is partly a frontier of the imperative paradigm, not of
   computing.** Several "open/frontier" classes there (cross-cutting data invariants,
   dispatch, async propagation) are *solved* in some paradigm — they read as frontier only
   because mainstream practice is imperative-default and reaches for those paradigms rarely
   and as bolt-ons. The *genuine* frontier (the classes no paradigm dissolves, only
   relocates) is narrower: **performance/resource postures, distributed-contract evolution,
   naming/conceptual structure across artifacts, and cross-paradigm/polyglot consistency** —
   decisions that are *cross-paradigm by nature* and so cannot be homed by adopting any one
   paradigm. Those survive because they live *between* representations, not within one.

3. **Therefore smear is doubly contingent.** Contingent on *representation* (Frame 2's
   claim) and contingent on *paradigm* (this frame) — and these are the same contingency
   viewed at two scales, because a paradigm *is* a bundle of representational commitments.
   The text-smearing the whole thread indicts is the most acute case: imperative-text is the
   paradigm that makes the *most* explicit and so homes the *fewest* decision classes
   cheaply — it is not neutral ground, it is the *maximally-smearing* corner of the paradigm
   space, which is exactly why "edit the decision, not the characters" feels so far from how
   we actually program. The dissolutions above are the existence proof that it didn't have
   to be this way; the conservation law is the reason no single paradigm switch is the
   escape, and why the real target is *per-decision-class choice of representation* (edit
   each decision in the paradigm that homes it) rather than allegiance to one paradigm.

**Bottom line:** smear is not a property of decisions; it is a property of the
*decision-paradigm fit*. Change the paradigm and the *distribution* of smear across decision
classes changes radically — but its *total* is conserved, redistributed toward whatever
fights the new paradigm's grain. The dream of "edit the decision" is therefore not "pick the
right paradigm" but "let each decision be edited in the paradigm that homes it" — which is
precisely the projectional / multi-representation direction Frame 2 gestured at with Unison
and MPS, now justified from the paradigm angle.
