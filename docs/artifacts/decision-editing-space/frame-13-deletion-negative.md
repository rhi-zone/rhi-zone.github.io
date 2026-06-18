# Frame 13 — Deletion / Negative / Subtractive Decisions

> Shared context: a program is a structure of *decisions*; text smears one decision
> across many edits; the right editing unit is the *decision*. Ten frames mapped the
> space; Frame 10 (adversarial) flagged that nearly every frame is biased toward
> **additive** decisions and treats deletion as a trivial mirror of addition (B1, B4,
> B9). It is not. This frame maps the subtractive half and proves the asymmetry.
>
> Anchored on Frame 9's algebra (monotone / anti-monotone / semilattice /
> invertibility-as-replay vs as-map) and Frame 3's mechanical-shrapnel-vs-spawned
> split. I use Frame 9's terms deliberately so the two frames compose.

The thesis in one line: **addition is a local existential act (∃ a site where I add a
thing); deletion is a global universal claim (∀ sites, nothing depends on the thing).**
That single quantifier flip — ∃ vs ∀ — is the root of every asymmetry below: the
verification cost, the algebraic signature, the irreversibility, the security stakes,
and the shape of the spawned-decision structure. Everything in this frame is a corollary
of the quantifier flip.

---

## 0. The master asymmetry: ∃-act vs ∀-claim

State the two operations as *what you must establish to know you are done*.

- **Addition** — "add case `C` / field `f` / function `g` / parameter `p`." To complete
  it soundly you must do **one local thing** (write the new construct) and discharge a
  *bounded, machine-enumerable* set of spawned obligations (Frame 3: the exhaustiveness
  arms a type-checker hands you). The completeness witness is **local and positive**:
  *the thing now exists here.* You can point at it. The compiler agrees by construction.

- **Deletion** — "remove case `C` / stop calling API `A` / revoke capability `K`." To
  complete it soundly you must establish **a universal negative**: *nothing, anywhere,
  still depends on the thing.* The completeness witness is the **non-existence of a
  dependent** — and non-existence is not a thing you can point at. You discharge it by
  *quantifying over the whole dependency frontier* and showing each site is clear. Miss
  one site and the claim is false; and unlike a missed addition (which leaves a gap you
  notice later), a missed deletion's failure mode depends on the kind (§4).

This is the same shape as the difference between **proving ∃x.P(x)** (exhibit one
witness — local, cheap, certain once exhibited) and **proving ∀x.¬Q(x)** (rule out every
x — global, and only as complete as your enumeration of the domain). Deletion is
intrinsically the second kind. *That is why it is harder, and the rest of this frame is
just unfolding the consequences.*

> **The unstated dual of Frame 3.** Frame 3's headline result — "the machine enumerates
> the shrapnel of an addition (incomplete `match` arms)" — relies on the type system
> being able to *show you the gap a new thing creates*. Deletion has no dual gap. When
> you remove a case, the type system does *sometimes* show you the now-dead arms (a
> match on a removed variant fails to typecheck) — but **only for dependents the type
> system can see**. The completeness of the addition worklist is guaranteed by the type
> system's soundness; the completeness of the deletion worklist is guaranteed by
> *nothing*, because it is a claim about the *absence* of dependents across a frontier
> that includes things the type system does not model (§3).

---

## 1. The taxonomy of negative decisions

Subtraction is not one operation. Map it by *what is removed* and *what "done" requires*.

### 1.1 Remove a feature / case / field / parameter — the structural delete

The clean dual of Frame 9 A.4 (add case/field/fn). Frame 9 scored "remove the case you
just added" as a clean inverse *iff nothing downstream came to depend on it* — and
buried the entire difficulty in that *iff*. This frame makes the *iff* the subject.

- **What "done" requires:** prove every read of the field, every construction of the
  variant, every pass of the parameter is gone. For a closed program with full type
  information and no reflection, this is **decidable and machine-enumerable** — the
  compiler's "unused"/"no longer matched" errors *are* the worklist, and here deletion
  is genuinely close to a mirror of addition. This is the band where Frame 10's "trivial
  mirror" framing is *correct*. I concede it cleanly: **for closed, fully-typed,
  reflection-free programs, structural deletion is decidable and nearly symmetric to
  addition.** The asymmetry below is about everything outside that band.
- **Why it leaves the band immediately in practice:** the dependent set includes
  serialized data at rest encoding the variant, external clients sending the field,
  config files setting the parameter, log-parsers matching the old shape, and reflective
  / string-keyed access (`getattr`, JSON dispatch, `match` on a stringly-typed tag). The
  type system sees none of these. So the *real* completeness claim ranges over a frontier
  strictly larger than the type-checked program (§3).

### 1.2 "Stop doing X everywhere" — the negative cross-cutting decision

Remove all uses of a deprecated API; strip a behavior (e.g. "stop emitting this log
line," "stop double-encoding," "no component reaches into global state"). This is the
dual of Frame 1/Frame 4's *positive* cross-cutting predicate ("add a check everywhere").

The positive and negative cross-cutting decisions look symmetric — "touch every site" —
but they are not, on the verification axis:

- **Positive cross-cutting ("add a check everywhere"):** the failure of incompleteness
  is *a site that lacks the new check* — and you can often *make it positive* by routing
  all sites through one chokepoint (a decorator, a middleware, a wrapper) so the check
  exists *by construction* and the cross-cut collapses to a single locus. This is the
  "localize it into a chokepoint" escape.
- **Negative cross-cutting ("stop doing X everywhere"):** you cannot route *absence*
  through a chokepoint. There is no object whose existence guarantees the *non*-existence
  of X at N sites. The only way to know X happens nowhere is to **inspect everywhere X
  could happen** — i.e. discharge the ∀ directly. The chokepoint escape, which is the
  positive case's main weapon, **is not available to the negative case.** (You can
  sometimes approximate it: make X *unrepresentable* so future X cannot be written —
  §1.4 — but that does not remove *existing* X, it only closes the door behind you.)

### 1.3 Deleting code safely — dead-code elimination and its halting-flavored core

"Delete this code because nothing reaches it." When is *dead-code* decidable?

- **Syntactically unreachable** (no edge in the call/control-flow graph reaches it; a
  private function with zero callers; a branch under `if (false)`): **decidable**, and
  this is what tree-shaking / DCE / linkers do soundly. The compiler computes a
  reachability closure and removes the complement. This is the *only* fully sound
  automatic deletion, and it is sound precisely because it is *conservative*: it deletes
  only what it can *prove* unreachable, and keeps anything it is unsure about. Note the
  asymmetry even here: DCE errs toward *keeping* (a false-live is safe, a false-dead is a
  bug) — the tool itself is built around the ∀-claim being expensive to get wrong.
- **Semantically dead but syntactically reachable** ("this branch is reachable in the
  CFG but the guard is never true at runtime"): **undecidable in general** — it reduces
  to "does this predicate ever hold," which is the halting/satisfiability flavor. `if
  (complicated_condition_that_is_always_false) { ... }` cannot be proven dead without
  deciding the condition. Tools approximate (constant propagation, range analysis, SMT)
  and stay conservative; they *under-delete* rather than risk removing live code.
- **Dead across a dynamic boundary** (reflection, `eval`, plugin-loaded, called only by
  external clients, invoked by name from config/data): **not decidable from the program
  text at all** — the caller is outside the analyzed artifact. This is where "is this
  dead?" stops being a program-analysis question and becomes an *empirical* one
  (telemetry: "has this endpoint been hit in 90 days?"), which is a probabilistic, not a
  proof-carrying, answer.

**The general structure:** the soundness of *any* deletion is exactly the soundness of
its underlying ∀-non-dependence claim, and that claim is decidable only to the extent the
dependency graph is *statically complete and closed*. Every dynamic / external / at-rest
edge that the graph omits is a place where "decidable dead-code" silently degrades into
"empirically-probably-dead."

### 1.4 Tightening / forbidding — making illegal states unrepresentable is a *negative* decision

This is the subtlest and most important entry, because it is usually celebrated as a
*design win* and not recognized as a *deletion*. "Make illegal states unrepresentable"
(Yaron Minsky's slogan; sum types over flag-soup; non-empty-list types; `parse, don't
validate') — **removes possibilities from the type's inhabitant set.** It is subtraction
in the space of *representable values*, even when it is addition in the space of *type
declarations* (you often add a richer type to subtract its bad inhabitants).

- **Algebraic sign:** this is Frame 9 A.8's *anti-monotone* class. Strengthening a
  type/contract **shrinks the domain** of admitted values → moves *down* the behavioral
  refinement order → **can break existing callers** (the ones relying on now-rejected
  inputs). Addition of a case *widens* (up, monotone, breaks nobody — Frame 9 A.4);
  forbidding a state *narrows* (down, anti-monotone, breaks producers of the forbidden
  state). **Same surface verb ("change the type"), opposite algebraic sign, opposite
  blast pattern.** This is the cleanest formal statement of the addition/deletion
  asymmetry available, and it is *already in Frame 9* — this frame just names it as the
  defining signature of the negative class.
- **Why it is a ∀-claim:** to tighten a type safely you must establish that *every*
  current producer of values already satisfies the new, stricter invariant (or be
  willing to break the ones that don't). "No value of this type is ever the illegal
  state" is, again, a universal negative over all construction sites.
- **The payoff that justifies the cost:** once tightened, the *future* ∀-claim is
  discharged *by construction* — the illegal state can no longer be written, so all
  future code is clean for free. This is the one place subtraction *buys* you something
  the additive world cannot: a removed possibility stays removed without per-site vigilance
  (a structural guarantee, not a checked one). The cost is paid once (the migration that
  discharges the ∀ over *existing* sites); the benefit accrues forever. This is exactly
  the "redesign the substrate so the property is structural" escape Frame 10 §A2
  identified — and it is *the* reason to prefer make-illegal-states-unrepresentable over
  a runtime check: the check is a standing positive ∀-obligation; the unrepresentability
  discharges the ∀ permanently.

### 1.5 Revocation — security-critical removal

"Revoke this capability / permission / token / trust anchor everywhere." The dual of
Frame 4/Frame 10-B4's *grant*. This is the negative class where incompleteness is not a
latent bug but an **active vulnerability**, and it inverts the entire risk model.

- For ordinary deletion, a missed site = *the old thing still works somewhere* = a bug
  you find later, usually benignly (a dead code path, a stale field still read).
- For revocation, **a missed site = the revoked authority still works** = the thing you
  were trying to forbid is still permitted, and an adversary, not a test suite, finds it.
  "Revoke the leaked key" that misses one validator means the leaked key still
  authenticates *there*. "Drop the legacy auth path" that misses one endpoint means the
  legacy auth still admits attackers *at that endpoint*.
- **The correctness criterion is completeness over an *adversarially-chosen* frontier.**
  The relevant dependents are exactly the ones static analysis misses (untrusted input
  paths, deserialization sinks, the forgotten admin endpoint, the cached token, the
  replica that didn't get the revocation list). The ∀ ranges not over "sites my compiler
  knows" but over "sites an attacker will probe." This is the worst case of the ∀-claim:
  the domain of quantification is *defined by the adversary*, not by your program graph.
- **Operational consequence:** revocation is almost never done by deletion alone; it is
  done by **adding a positive deny-check at a chokepoint** (a revocation list, a kill
  switch, a deny-by-default gate) — i.e. you *convert the negative ∀-claim into a
  positive ∃-act* by funneling all authority checks through one point where you can add
  "deny K." This is the single most important practical pattern in the whole frame:
  **when the negative ∀ is too dangerous to discharge by enumeration, you re-architect so
  that a positive addition at a chokepoint *enforces* the negative.** Capability security
  (allow-list over deny-list, the ecosystem's own principle) is exactly this move done
  *ahead of time*: if all authority flows through granted handles, revocation = drop the
  handle at one place, and there is no frontier to quantify over because there was never
  ambient authority to miss.

### 1.6 Narrowing a contract — the anti-monotone interface change

Frame 9 A.8: weakening a contract is monotone (up, safe), strengthening is anti-monotone
(down, breaks callers). Narrowing an interface — remove a parameter, drop a return field,
tighten a precondition, reduce the accepted input set — is the **anti-monotone** half and
is governed by the same ∀-claim: "no consumer relies on the part I'm removing." Across an
ownership boundary (Frame 10 B8) the ∀ ranges over *other people's code you cannot see*,
which is why public-API narrowing is the canonical multi-deploy, multi-owner, deprecation-
windowed operation (§5) — the ∀ is literally undischargeable from inside your repo.

---

## 2. Why the algebraic signature of removal is worse

Mapping the negative classes onto Frame 9's four properties. The verdict: **removal is
systematically worse on every axis, and the badness is not incidental — it is forced by
the ∀-claim.**

| Property | Addition (Frame 9 A.4) | Deletion (this frame) | Why the asymmetry |
|---|---|---|---|
| **Monotone** | YES — extends the domain, breaks no caller, moves *up* | **NO — anti-monotone.** Shrinks the domain, *can* break callers, moves *down* (§1.4, §1.6; Frame 9 A.8) | A removal *withdraws* behavior others may rely on; that is the definition of moving down the refinement order |
| **Idempotent** | YES — adding a present thing is a no-op | **YES, weakly** — removing an absent thing is a no-op | This one *does* mirror — but see the invertibility row for why it is cold comfort |
| **Commutes (disjoint loci)** | YES — two distinct adds merge (G-Set / union) | **Partially** — two distinct removals commute *as set-difference*, BUT a removal and an *addition that depends on the removed thing* do **not** commute, and worse, do not even have agreeing *domains* | Order matters: "Bob adds a use of X" then "Alice removes X" ≠ "Alice removes X" then "Bob adds a use of X" — the second strands Bob's add on a missing referent. Frame 9's domain-disagreement = false-merge source, in its sharpest form |
| **Invertible (as VCS replay)** | Partial — un-add by removing, *up to spawned shrapnel* | **NO — the deep one. Often non-invertible even as a map.** | §2.1 below |

### 2.1 The non-invertibility of deletion — you cannot un-delete the *knowledge*

Frame 9 distinguished **map-invertible** (the function is injective) from
**operation-invertible** (the inverse is itself a replayable edit recoverable from the
recorded op alone). Deletion fails *both*, and for a reason addition never faces:

- **As a map on program text**, deletion *looks* invertible: re-add the deleted lines.
  Frame 9 A.4 scores it this way. But this is the shallow view, and it is the trap.
- **The deleted artifact carried justifying context that the deletion destroys.** When
  you remove a case, a guard, a workaround, a defensive check, you remove not just the
  code but *the encoded reason it existed* — the bug it fixed, the edge case it handled,
  the client it served. The text can be restored from git; **the knowledge of *why* it
  was load-bearing cannot be reconstructed from the deletion itself.** This is the
  asymmetry's sharpest edge: addition *creates* information (and the artifact carries its
  own rationale forward); deletion *destroys* information (and the deletion op records
  only *that* something went, not the web of assumptions that depended on it). You can
  `git revert` the diff; you cannot `git revert` the lost understanding of which of the
  300 things that broke after the deletion broke *because* of it.
- **Chesterton's Fence is the folk theorem of exactly this.** "Do not remove a fence
  until you know why it was put there." Formally: deletion's precondition is *knowledge
  of the deleted thing's full set of dependents and justifications*, and that knowledge
  is precisely what is *not* recorded in the artifact being deleted (if it were recorded
  locally, the thing would be self-justifying and deletion would be safe). The ∀-claim
  ("nothing depends on this") requires the very global knowledge that the local artifact
  lacks. **This is why removal is intrinsically a non-local, non-compositional act: the
  evidence for its safety lives everywhere *except* at the deletion site.**

### 2.2 Removal is non-compositional in the precise sense Frame 10 named

Frame 10's master discriminator: *localizable ⟹ the decision's property decomposes into
per-site contracts a determinate procedure can check.* Deletion's defining property —
"nothing depends on X" — is a **conjunction over all sites of a negative local fact**
(¬depends-on-X-here). That *is* compositional in form (it decomposes per-site), but with
two stings that addition avoids:

1. **The conjunction is over a frontier the program graph does not fully contain** (§3),
   so the "determinate procedure" cannot enumerate the conjuncts — the ∀ has no complete
   index set. Addition's spawned obligations *do* have a complete index set (the type
   system's soundness guarantees it found every gap). Deletion's do not.
2. **Each conjunct is a negative ("nothing here"), and negatives are not witnessed by
   inspection of the site alone** — to confirm "this site does not depend on X" you must
   understand the site well enough to rule out a *hidden* dependence (a reflective call,
   a behavioral coupling, a timing assumption). Addition's per-site obligation is
   positive and self-evidencing (the new arm is *there*, typed, and the compiler agrees).

So removal sits *one rung lower* than addition on Frame 10's compositionality ladder: not
fully non-compositional like a global emergent property (it does decompose per-site), but
**non-enumerable and negatively-witnessed**, which is enough to deny it addition's clean
machine-worklist guarantee.

---

## 3. The spawned-decision structure of a deletion: "everywhere that assumed it existed"

The dispatch asks directly: *is "the spawned decisions of a deletion" = "everywhere that
assumed the thing existed"?* **Yes — and this is exactly why the tree model of Frame 3
fits addition and strains on deletion.**

- **Addition spawns a *worklist* (a forward fan-out, a tree).** Add a case → the machine
  hands you N exhaustiveness holes → you fill each → each fill may spawn its own children.
  It is a tree rooted at the decision, descended top-down, *complete by the type system's
  soundness*. Frame 3's model is exactly right here.
- **Deletion spawns a *closure* (a backward reachability set over dependents).** Remove X
  → the obligation is "find every site that assumed X existed and decide what it does
  without X." This is not a forward worklist generated *from* the decision; it is a
  *search backward over the dependency graph* for everything pointing *at* the deleted
  thing. The shape is a **dependent-set closure**, not a spawned subtree, and crucially it
  is the *transitive* closure: removing X may make Y dead (Y only existed to serve X),
  which spawns "remove Y," which has its own dependent closure — DCE's fixpoint iteration
  is exactly this closure computation.
- **The two shapes differ in completeness guarantee, not just direction.** The forward
  worklist is complete because the type checker generated it. The backward closure is
  complete *only over the edges the graph records* — and the deletion's whole difficulty
  is the edges it doesn't (dynamic, external, at-rest, temporal, social — §1.1, §5). So:

> **"The spawned decisions of a deletion = everywhere that assumed the thing existed" is
> correct, with the critical caveat that "everywhere" is not enumerable from the program
> alone.** Addition's spawned set is machine-complete; deletion's spawned set is
> machine-complete *only within the closed static graph* and is otherwise an open frontier
> requiring empirical evidence (telemetry, client surveys, deprecation-period silence) to
> close. This is the operational form of "∀-claims need global evidence."

---

## 4. The blast-pattern of a missed site, by negative class

Addition's miss = a gap you'll notice (the feature isn't there). Deletion's miss varies by
class, and the variation is itself diagnostic of why deletion needs more care:

| Negative decision | A missed site means… | Detected by | Severity |
|---|---|---|---|
| Remove field/case (§1.1) | a dangling reference / the old shape still constructed | compiler (if static) / runtime error (if dynamic) | usually loud — fails fast |
| Stop doing X (§1.2) | X still happens somewhere | nothing automatic — needs an assertion *that X never happens* | quiet — the bug is "still works" |
| Dead-code delete (§1.3) | you deleted something *live* | runtime crash / missing behavior | loud but already-shipped |
| Tighten/forbid (§1.4) | a producer of the now-illegal state breaks | compiler (if encoded in types) / runtime (if checked) | loud if typed, quiet if not |
| **Revoke (§1.5)** | **the authority still works** | **the attacker** | **silent until exploited — worst case** |
| Narrow contract (§1.6) | a consumer breaks | their build / their runtime, possibly in another org | loud but *not your build* (Frame 10 B8) |

The pattern: **the negative decisions whose miss is *silent* (1.2, 1.5, untyped 1.4) are
exactly the ones that cannot be converted to a loud positive.** This motivates the
universal practical move — *turn the negative into a positive assertion*: rather than
"stop doing X and hope," add a *guard that fails if X happens* (a lint rule, an
architecture test, a runtime assert, a `#[deny]`), converting the silent ∀-claim into a
loud, enforced, *future-proof* one. You can't witness an absence, but you *can* witness
"the alarm never fired" — which is the closest a negative gets to a positive certificate.

---

## 5. How real systems handle it — the deprecation→removal cycle as a ∀-discharge protocol

Real systems do not delete by fiat; they run a **multi-phase protocol whose entire
purpose is to discharge the ∀-claim incrementally and gather the global evidence the
deletion-site lacks.** The phases map exactly onto the analysis above:

1. **Mark deprecated (`#[deprecated]`, `@Deprecated`, `DeprecationWarning`).** This adds a
   *positive* signal at the definition site that propagates to every use — the compiler/
   linter now *enumerates the dependents for you* by warning at each call. This is the
   single cleverest move in the whole practice: **it converts the un-enumerable negative
   frontier into an enumerable positive worklist** by making the type system emit a
   warning at each dependent — i.e. it borrows addition's machine-worklist guarantee to
   serve a deletion. The deprecation marker is *addition in service of subtraction*.
2. **Deprecation window / telemetry.** For dynamic and external dependents the compiler
   can't see, you wait and *measure*: log every use of the deprecated thing, watch the
   rate fall to zero, survey clients. This is the *empirical* discharge of the part of the
   ∀ that is not statically decidable (§3) — you cannot prove non-dependence, so you
   gather evidence that approximates it (90 days of zero hits ⇒ probably-dead).
3. **Expand/contract (parallel-change) for online systems.** Frame 10 B5's intrinsically-
   temporal class: old and new must coexist *by requirement* during the change. The
   removal is *necessarily* smeared across time/deploys — you add the new path, migrate
   readers, drain the old, *then* delete. The deletion is the *last* phase and is only
   safe because the earlier phases discharged the ∀ over live traffic.
4. **Remove + tombstone.** Finally delete, often leaving a *tombstone* (a reserved field
   number in protobuf, a `410 Gone`, a removed-in-version note) — an artifact that
   *records the absence* so the now-missing thing isn't re-added with conflicting meaning
   and so at-rest data referencing it is handled. The tombstone is the system's admission
   that **deletion cannot fully erase: it leaves a negative-space marker because pure
   absence is unsafe.**

**Tree-shaking / DCE / linker GC** are the *automatic* end of the same protocol, applicable
*only* in the decidable band (§1.3): closed static graph ⇒ compute reachability closure ⇒
remove complement, conservatively. They are sound because they refuse to leave the
decidable band — they keep anything they can't prove dead. **`#[deprecated]` + telemetry +
expand/contract is what you do precisely when you are *outside* the band DCE can handle** —
they are the manual ∀-discharge for the dependents the static graph omits.

---

## 6. Synthesis — the asymmetry, formalized

- **Quantifier:** addition is **∃-shaped** (exhibit one witness; local; complete-by-
  construction). Deletion is **∀-shaped** (rule out every dependent; global; complete only
  as far as your enumeration of the frontier reaches). *Every* downstream asymmetry is a
  corollary of this.
- **Algebra (Frame 9):** addition is **monotone** (up the refinement order, breaks no
  caller, join-semilattice / G-Set, CRDT-mergeable). Deletion is **anti-monotone** (down
  the order, can break callers, set-difference doesn't commute with dependent-adds, and is
  **non-invertible** — not just lossy-as-replay like a data migration, but *destroying the
  rationale* that no `git revert` restores). The negative classes are the **meet/erase**
  side of the lattice, and they are *not* CRDT-mergeable as removals (a remove vs a
  concurrent dependent-add is a genuine domain-disagreement conflict that *must* escalate
  — auto-merging it is Frame 9's false-merge).
- **Verification:** addition's completeness is **machine-guaranteed** (type soundness
  generates the full worklist). Deletion's completeness is **machine-guaranteed only inside
  the closed static graph**, and otherwise requires **empirical global evidence**
  (telemetry, deprecation-window silence, client survey) because the ∀ ranges over a
  frontier — dynamic, at-rest, external, temporal, adversarial — that the program graph
  does not contain. Removal is *intrinsically closer to a non-compositional ∀-claim*: it
  decomposes per-site (so not maximally non-compositional) but is **non-enumerable and
  negatively-witnessed**, denying it addition's clean worklist.
- **The spawned structure:** addition spawns a **forward tree** (worklist, complete).
  Deletion spawns a **backward transitive closure over dependents** ("everywhere that
  assumed it existed"), complete only over recorded edges.
- **The universal practical inversion:** because you cannot witness an absence, real
  practice **converts the negative into a positive** wherever possible — a chokepoint
  deny-check for revocation, a failing assertion/lint for "stop doing X," a richer type for
  forbidding a state (unrepresentability discharges the ∀ *by construction* and forever), a
  `#[deprecated]` marker that borrows the type system's worklist to enumerate the
  dependent frontier. **The negative ∀-claim is made tractable by re-expressing it as a
  positive ∃-act at a single enforced locus** — which is exactly capability security's
  allow-list-over-deny-list done ahead of time. Where that conversion is impossible, the
  deprecation→telemetry→expand/contract→tombstone cycle discharges the ∀ incrementally over
  time, and that temporal smear is *irreducible* (Frame 10 B5), not a representational
  accident.

**One-sentence frame:** *Addition is a local existential you can witness and the machine
can complete; deletion is a global universal-negative you cannot witness, the machine can
complete only within the closed static graph, whose evidence lives everywhere except the
deletion site, and which destroys the rationale that would let you safely reverse it —
which is why every mature system treats removal not as the inverse of addition but as its
own multi-phase, evidence-gathering, positive-assertion-backed protocol.*

---

## 7. Honesty ledger / flags

- **The decidable band is real and I conceded it (§1.1, §1.3):** for closed, fully-typed,
  reflection-free programs, structural deletion *is* nearly the symmetric mirror Frame 10
  said the frames assumed. The asymmetry is a claim about everything outside that band —
  which is most real systems, but the band is not empty and pretending it is would be the
  inverse over-claim.
- **"Non-compositional" is used carefully:** deletion's property *does* decompose per-site
  (a conjunction of local negatives), so it is **not** non-compositional in Frame 10's
  strongest sense (emergent global properties like fairness). Its trouble is
  **non-enumerability of the index set + negative witnessing**, which is a *weaker* but
  still real departure from addition. I am not claiming deletion is as intrinsically smeared
  as a numerical-stability posture; I am claiming it is strictly worse than addition on
  enumerability and invertibility, and I've tried to say exactly how much worse.
- **The "destroys the rationale" claim (§2.1) is the one I'd most want challenged.** It is
  not an algebraic fact; it's an empirical/epistemic one (the artifact rarely records why it
  was load-bearing). It is well-supported by Chesterton's Fence as folk practice and by the
  universal use of deprecation comments / tombstones (systems *try* to record the rationale
  precisely because deletion otherwise loses it), but it is a claim about how code is
  written, not a theorem. Flagged as such.
- **Revocation-as-positive-chokepoint (§1.5) assumes you *can* re-architect to a chokepoint.**
  In a system with ambient authority already spread everywhere, you can't — and then
  revocation really is the dangerous adversarial ∀ with no escape, which is the whole
  argument *for* capability security being designed in up front. The escape exists only if
  the architecture admits it; I've stated it as a target, not a guarantee.
- **Overlap with Frame 9 is deliberate, not duplicative:** Frame 9 derived the anti-monotone
  signature of contracts (A.8) and the invertibility fork; this frame takes those as given
  and asks *why removal as a class* inherits them and what the verification/spawned-structure
  consequences are. The new content is the ∃/∀ root cause, the spawned-closure-vs-tree shape,
  the missed-site blast-pattern table, the deprecation-cycle-as-∀-discharge reading, and the
  negative→positive conversion as the unifying practical move.
