# Frame 9 — The Algebra of Edits and Collaboration Semantics

> Context (shared with frames 1–4): a program is a structure of *decisions*;
> text smears one decision across many edits; the right unit of editing is the
> *decision*. Prior frames mapped the decision space by structural axis (1), by
> what localizes a decision (2), by mechanical-shrapnel-vs-spawned-decision
> propagation (3), and by what edits empirically occur (4).
>
> This frame treats decision-edits as **operations on program-space** and asks
> what algebraic structure they have, then uses that structure to predict
> **collaboration/merge behavior**. The payoff claim under test: *the algebraic
> signature of a decision-edit predicts its merge behavior, and decision-granular
> version control dissolves the false-conflict / false-merge problem that line-based
> merge produces.*

I am going to be deliberately strict about the algebra. The temptation is to
wave the words "group" and "lattice" around because edits *feel* invertible or
ordered. Most of the interesting structure is **weaker than a group** (partial,
non-total, state-dependent), and saying so precisely is the whole contribution.

---

## 0. Setup: what is the carrier set, what are the operations?

To talk about algebra at all we need to fix (a) the set the operations act on and
(b) how operations compose. There are two defensible choices, and conflating them
is the most common error, so I separate them up front.

**Carrier choice A — programs as points.** Let `P` be the set of well-formed
programs (or, better, *decision-structures*: the AST-of-decisions, not the text).
An edit is a **partial function** `e : P ⇀ P`. It is partial because most edits
have a **precondition**: "rename `foo`→`bar`" is only defined on programs that
contain a binding named `foo` and no conflicting `bar`. Composition is function
composition `e₂ ∘ e₁`, defined only where the intermediate program satisfies
`e₂`'s precondition. This is the **state-transformer** view.

**Carrier choice B — edits as the elements.** Forget programs; ask whether the
*edits themselves* form an algebra under composition, independent of which program
they hit. This is what you need for VCS: a commit is an edit you want to replay
onto a program it wasn't authored against. This is the **operation-algebra** view,
and it is where operational transform (OT) and CRDTs live.

The key early observation: **almost nothing is total in view A, and view B only
has clean structure for the edits that are total (or near-total) in view A.** The
algebra is real but *partial*. Pretending it is total is exactly the move that
makes naive `git revert` / `git cherry-pick` silently corrupt state.

I will use view A to *derive* properties (preconditions are visible there) and
view B to *state merge consequences*.

Four algebraic properties, defined sharply for partial state-transformers:

- **Invertible** (on its domain): `e` is injective on `dom(e)` and there exists a
  partial `e⁻¹` with `e⁻¹ ∘ e = id` on `dom(e)`. NOTE: this is invertibility of the
  *map*, which is weaker than "you can recover the pre-state by knowing only the
  edit." The latter needs `e⁻¹` to be *expressible as an edit of the same kind*,
  which is a strictly stronger and rarer condition (see §1).
- **Idempotent**: `e ∘ e = e` on `dom(e ∘ e)`. (Standard.)
- **Commuting** (two edits `e, f`): `e ∘ f = f ∘ e` as partial functions —
  *including domain agreement*: both orders defined on the same states and equal
  there. Domain disagreement is itself a form of non-commutation and is the source
  of one whole class of false merges (§5).
- **Monotone**: there is a partial order `⊑` on `P` (more on which order below) and
  `p ⊑ e(p)` — the edit only moves *up*. "Add a case" is the paradigm. The order
  that makes this meaningful is **behavioral extension / observational refinement**:
  `p ⊑ q` iff `q` agrees with `p` on every input `p` was defined on, and is defined
  on at least as many. Monotone edits are exactly the ones that *cannot break an
  existing caller* — which, note, is precisely the property a type-checker's
  "this change is backward-compatible" wants to certify.

---

## A. Algebraic signatures by decision class

I take the decision classes from Frame 1 (A–N) and the M/S split from Frame 3 and
assign each an algebraic signature. The signature is `⟨invertible?, idempotent?,
commutes-with-disjoint?, monotone?⟩`, with the honest qualifier attached. The
single most important corrective up front:

> **Invertibility of the *map* and recoverability-by-the-*edit* come apart, and
> the gap is where data is lost.** A migration `email: String → email: Option<String>`
> that defaults old rows is an injective map *if you keep the old data somewhere*,
> but as an *edit operation that replays forward*, its inverse is not an edit of the
> same form — going back requires the dropped non-null witness. So it is
> "invertible as a relation on a fattened state-space" yet **irreversible as a VCS
> operation**. VCS cares only about the latter. I score the VCS-relevant notion.

### A.1 Rename / move / re-export (Frame 1 §C; Frame 3 §2.1–2.2; "pure wiring")

- **Invertible: YES, cleanly.** `rename(a→b)` has inverse `rename(b→a)`, an edit of
  the same kind. This is the closest thing to a genuine **group** in the whole space:
  the set of renamings of a fixed name-set, under composition, *is* a group —
  isomorphic to a subgroup of the symmetric group on identifiers (permutations of
  names). Moves between modules likewise form a groupoid (partial because the target
  module must exist). I am comfortable claiming **group structure here** and nowhere
  else without heavy qualification.
- **Idempotent: NO** (renaming twice is not renaming once) — except the *degenerate*
  `rename(a→a) = id`.
- **Commutes: YES with disjoint name-sets; NO when names alias.** `rename(a→b)` and
  `rename(c→d)` commute. `rename(a→b)` and `rename(b→c)` do **not** (one composes to
  `a→c`, the other leaves `a` alone) — they share the *decision locus* `b`.
- **Monotone: N/A** — pure renames are behavior-preserving *isomorphisms*; they sit
  at the identity of the refinement order (an automorphism of behavior), neither up
  nor down.

This class is **100% mechanical shrapnel (Frame 3)** and **algebraically a group**.
That coincidence is not accidental and is the load-bearing result of this frame
(see §4).

### A.2 Extract / inline / reorder declarations (Frame 1 §C/§J; Frame 3 §2.2)

Same family as rename: behavior-preserving structural rearrangements.
- **Invertible: YES** (extract⁻¹ = inline). Together with rename these generate a
  group of *refactorings* — the behavior-preserving automorphisms of program-space.
  This is essentially the claim that "refactorings form a group acting on programs,
  with orbits = behavioral-equivalence classes." I believe this is *true and the
  cleanest algebraic statement available*, with the caveat that real languages leak
  (reflection, ordering-sensitive initialization) so the action is only *almost*
  by isomorphism.
- **Idempotent: NO.**
- **Commutes: mostly YES** for disjoint code regions; **NO** when one extraction's
  body contains another's locus (nesting). Order-dependence is *structural
  containment*, not text adjacency — already a sharper conflict predicate than diff's.
- **Monotone: N/A** (behavior-preserving).

### A.3 Set a flag / config value / constant (Frame 1 §A; Frame 4 §A point-fixes)

- **Invertible: YES** as a map (set it back), but **lossy as forward-replay if you
  overwrite**: `set(x, v)` discards the old value. Inverse `set(x, v_old)` exists
  *only if you recorded `v_old`*. So invertible iff the operation is recorded as
  `set(x, old→new)` (a *typed* assignment carrying its precondition) rather than
  `set(x, new)`. **This distinction is the entire OT/CRDT design space in miniature.**
- **Idempotent: YES.** `set(x, v) ∘ set(x, v) = set(x, v)`. The flagship idempotent
  edit. A "register" in CRDT terms.
- **Commutes: NO** for the *same* key (last-writer-wins is the conflict); **YES** for
  distinct keys. Two writes to the same flag is the canonical **genuine conflict** —
  one decision, two deciders. This is the conflict that *should* surface, and the one
  line-merge sometimes *hides* if the two values live on different lines (false merge).
- **Monotone: NO** in general; **YES** for accumulating flags (`enable_X = true` only
  ever turned on) — those become a **grow-only** structure (see CRDT, §6).

### A.4 Add an enum case / add a struct field / add a function (Frame 1 §D/§E/§B; Frame 3 §2.4–2.5 — the headline mixed case)

This is the most important class because it is where monotonicity and conflict both
live, and where Frame 3's M+S mixing has an algebraic shadow.

- **Invertible: PARTIALLY.** Removing the case you just added is a clean inverse *iff
  nothing downstream came to depend on it*. But "add enum case" in Frame 3 *spawns*
  exhaustiveness decisions: once a `match` arm is written for the new case, the
  inverse "remove case" must also remove (or it strands) that arm. So the edit is
  invertible **only up to the spawned shrapnel it triggered** — the inverse is the
  inverse of the *whole transaction*, not of the headline op. **Flag: this is where
  "decision-granular revert" gets subtle** — you must revert the decision *and its
  determined consequences as one unit*, which is exactly what line-revert cannot do
  and decision-revert can, *if* the consequences were recorded as derived-from.
- **Idempotent: YES, structurally.** "Add field `f`" applied twice = added once
  (adding an already-present field is a no-op / error, not a second field). Add-case,
  add-method: same. This is a **grow-only set (G-Set)** at the structural level — and
  G-Sets are the simplest CRDT. **This is the first real bridge to auto-merge: the
  add-only structural edits are literally CRDT-shaped.**
- **Commutes: YES for distinct additions.** "Alice adds case `Banana`, Bob adds case
  `Cherry`" → both present, order-independent, no conflict. **This is the single
  biggest win of decision-merge over line-merge**: in text these two edits hit
  adjacent lines of the same `enum {}` block and produce a *false conflict*; as
  G-Set inserts they auto-merge. Verified against the failure mode line-merge
  exhibits daily (every "two people added an import / a match arm / a struct field"
  conflict).
- **Monotone: YES** — by construction these only *extend*. Adding a case widens the
  type's domain; adding a field widens the record; adding a function widens the
  module's surface. They move strictly *up* the refinement order. **Monotone +
  idempotent + commuting = a join-semilattice**, and that is precisely a state-based
  CRDT (CvRDT). I am confident in this for the *pure add* skeleton; I am **not**
  confident it survives the spawned exhaustiveness work (the `match` arms), because
  those are *not* monotone — see §4.

### A.5 Widen / narrow a type; split a type (Frame 1 §D; Frame 3 §2.6)

This is the class where a **lattice** is genuinely present and worth claiming —
carefully.
- Types under subtyping/assignability form a (partial) lattice in many systems:
  `join = least common supertype`, `meet = greatest common subtype`. **Widening a
  parameter type is a join; narrowing a return type is a meet.** So far so clean.
- **But the edit's monotonicity flips with variance.** Widening a *parameter* type is
  monotone-safe (accepts more, breaks no caller) → moves *up* the behavioral order.
  Widening a *return* type is **anti-monotone** (callers now handle values they
  didn't) → moves *down*, breaks callers. So "widen a type" has **no single
  algebraic sign**; its signature is *position-dependent* (co/contravariant).
  **Flag:** this is a place where "the decision class" is too coarse — the algebra
  forces you to split it by variance position, which Frame 1's axis didn't.
- **Invertible:** widen⁻¹ = narrow *as a type-lattice op*, but **lossy at the value
  level** (narrowing drops the witnesses of the wider type). Invertible on types,
  irreversible on data. Same map-vs-replay gap as A.3/A.7.
- **Idempotent: NO** (widen to `int|string` then to `int|string|bool` ≠ once), except
  re-widening to the same supertype.
- **Commutes: as lattice joins, YES** — `join` is commutative and associative, so two
  independent widenings of the same type to different supertypes merge to *their*
  join automatically. **This is a second clean CRDT: a type that is the running join
  of all widenings is a join-semilattice CRDT.** Genuinely auto-mergeable. I'm
  confident here for the lattice skeleton.

### A.6 Change control flow / reorder effects / make async (Frame 1 §F/§I; Frame 3 §2.7)

- **Invertible: NO in general.** Sequencing changes drop information about the
  original order; "make this async" is not undone by a syntactic transform (you must
  re-derive the synchronous assumptions callers were relying on — spawned, not
  mechanical).
- **Idempotent: NO.**
- **Commutes: NO** — these edits change the *very order structure* that commutation is
  defined over; two concurrent control-flow edits to the same region are the
  archetypal **genuine semantic conflict** and *must not* auto-merge even if textually
  disjoint. (This is the false-*merge* direction: two people independently reorder the
  same pipeline, each diff applies cleanly, result is incoherent.)
- **Monotone: NO.** These are *destructive rewrites* of structure.

This class is **S-dominant (Frame 3)** and **algebraically structureless** (no
inverse, no idempotence, no commutation). That pairing — *S-dominant ⇒
algebraically poor* — is the second load-bearing result (§4).

### A.7 Data-dropping migration / change representation (Frame 1 §E; Frame 3 §2.6 tail)

- **Invertible: NO — the defining irreversible class.** `f(x) = x mod 10` as an edit
  to a stored representation destroys the quotient. No `f⁻¹` exists *as a function*,
  let alone as an edit. This is the bottom of the algebra: a **non-injective** map.
- **Idempotent: SOMETIMES** (a normalization/canonicalization migration is often
  idempotent — `normalize ∘ normalize = normalize` — which is *why* normalizers are
  safe to re-run; this is a real and useful fact, e.g. the ecosystem's `normalize`).
- **Commutes: rarely**, and dangerously: two migrations of the same column almost
  never commute and line-merge will happily interleave their DDL.
- **Monotone: NO** (destructive by definition).

### A.8 Add/strengthen an invariant or contract (Frame 1 §L)

- **Monotone: NO — it is *anti*-monotone.** Strengthening a precondition *shrinks* the
  domain → moves *down* the refinement order (rejects inputs previously accepted).
  Weakening a contract moves up. So contracts have the **opposite** monotonicity sign
  from "add a case," which is a clean, slightly surprising result: *adding a case to a
  type widens (up); adding a clause to a contract narrows (down).* The lattice
  direction depends on whether the artifact is a *producer* (types: more cases = more
  values = up) or a *guard* (contracts: more clauses = fewer admitted = down).
- **Invertible:** weaken⁻¹ = strengthen, lossless at the spec level; the group is the
  free structure on "add clause / drop clause" *if* clauses are independent —
  realistically they interact, so it's a partial order of specs, not a group.
- **Commutes: YES for independent clauses** (conjunction is commutative) — **and this
  is a third auto-merge class**: a contract that is the *conjunction* of all
  independently-added clauses is a meet-semilattice; two people adding different
  preconditions merge to the conjunction. Auto-mergeable, confidently.

---

## A.9 Summary table

| Decision class | Invertible (as VCS replay) | Idempotent | Commutes (disjoint loci) | Monotone (behavioral order) | Frame-3 M/S | Algebraic verdict |
|---|---|---|---|---|---|---|
| Rename / move (A.1) | **Yes** (own inverse) | No | Yes (disjoint names) | N/A (iso) | M=100% | **Group** |
| Extract / inline / reorder (A.2) | **Yes** | No | Mostly (non-nested) | N/A (iso) | M=100% | **Group(oid)** of refactorings |
| Set flag / const (A.3) | Yes *iff* records old | **Yes** | No (same key) | Sometimes (accumulators) | M (point-fix) | LWW-register |
| Add case / field / fn (A.4) | Partial (up to spawned) | **Yes** | **Yes** (distinct adds) | **Yes** (pure add) | M+S | **Join-semilattice / G-Set CRDT** (pure-add skeleton) |
| Widen/narrow type (A.5) | Lossy (type ok, data no) | No | **Yes** (as join) | Variance-dependent | S-leaning | **Join-semilattice** (per type) |
| Control flow / async (A.6) | No | No | No | No | S=~100% | **Structureless** |
| Data-drop migration (A.7) | **No** (non-injective) | Sometimes (normalizers) | No | No | S + irreversible M | **Below the algebra** |
| Add/strengthen contract (A.8) | Yes (spec-level) | Yes (re-add = noop) | **Yes** (independent clauses) | **Anti**-monotone | M+S | **Meet-semilattice** |

---

## 1. The two invertibilities, made precise (the load-bearing distinction)

The table's "Invertible" column hides a fork that deserves its own statement because
it is the thing practitioners get wrong with `git revert`:

1. **Map-invertible**: `e : P ⇀ P` is injective on its domain. Whether the inverse is
   *cheap to find* or *expressible as an edit* is a separate question.
2. **Operation-invertible (VCS-relevant)**: `e⁻¹` exists *and is itself an edit of a
   kind the system can author and replay*, recoverable **from the recorded edit
   alone**, without consulting the pre-state.

Rename is operation-invertible (the inverse is `rename(b→a)`, recoverable from the
op). `set(x, new)` is only operation-invertible if recorded as `set(x, old→new)`.
Data-dropping migration is *neither*. The practical rule:

> **An edit is cleanly revertible in a decision-VCS iff it is operation-invertible.
> The system should record each edit with enough of its precondition (the "old"
> side) to make as many edits operation-invertible as possible** — i.e. record edits
> as *typed deltas carrying their preconditions*, not as new-state snapshots. Text
> diff already does a weak version of this (`-old / +new`), which is *why* `git
> revert` works at all; it fails exactly when the textual inverse is not a semantic
> inverse (A.4's stranded match arm, A.7's lost data).

---

## 2. Commutation is the merge primitive — and it's about *decision loci*, not text

Two edits **auto-merge soundly iff they commute** (Lamport / OT folklore, but it
holds here for the partial-function definition too, *including domain agreement*).
The entire merge story reduces to: *characterize which pairs of decision-edits
commute.*

The sharp result, contrasting with line-merge:

- **Line-merge's conflict predicate is `overlapping-or-adjacent text ranges`.** This
  is neither sound nor complete w.r.t. commutation:
  - **False conflicts** (predicate fires, edits commute): two `enum` cases added to
    one block; two imports; two struct fields; two independent functions in one file.
    Frame-1 class A.4 — *provably commuting* (G-Set), yet textually adjacent.
    Line-merge halts the human for nothing.
  - **False merges** (predicate stays silent, edits *don't* commute): two people
    change the *same decision* expressed on *different lines* — e.g. one edits the
    default in the declaration, another edits an overriding call site; one reorders a
    pipeline, another inserts a step mid-pipeline. Textually clean, semantically
    contradictory. Line-merge ships a broken program.

- **Decision-merge's conflict predicate is `share a decision locus AND do not
  commute`.** Soundness/completeness depends on having a correct commutation oracle
  per decision class — which §A's table is the start of. Where the class is a CRDT
  (A.1, A.4-pure, A.5, A.8), commutation is *decidable and the merge is canonical*.
  Where the class is structureless (A.6, A.7), non-commutation is *detected* and
  escalated to a human — which is the *correct* behavior, not a failure.

So decision-VCS does not promise "no conflicts." It promises **the conflicts it
raises are real and the merges it performs are sound** — it fixes both the false
positives and the false negatives. That is a stronger and more honest claim than
"fewer conflicts."

---

## 3. Do decisions admit a CRDT? — yes for a characterized sublattice, no in general

A CRDT requires the merge to be a **join in a semilattice**: commutative,
associative, idempotent. Map §A onto that requirement:

**Admits a CRDT (state-based / CvRDT), confidently:**
- **A.4 pure additions** → G-Set (grow-only set of cases/fields/functions). Merge =
  union. This is the canonical example and it is *exactly* the everyday false-conflict
  source, so the win is concrete and large.
- **A.5 type widening** → per-type join-semilattice (running least-upper-bound of all
  widenings). Merge = type-join.
- **A.8 independent contract clauses** → meet-semilattice (conjunction). Merge = AND.
- **A.1/A.2 renames/refactors** → not a *lattice* but a **group**, which is even
  better for merge in one sense (full invertibility) and worse in another: group
  composition is **non-commutative**, so renames do NOT freely auto-merge — two
  renames of the *same* symbol genuinely conflict, and a rename composed with an
  add must be *transformed* (OT-style: re-express Bob's add against Alice's rename).
  **So refactors are an OT story, not a CRDT story** — they need transformation
  functions, not joins. This is a real and useful split: *additive structure → CRDT;
  bijective structure → OT.*

**Does NOT admit a CRDT, and shouldn't pretend to:**
- **A.3 flag writes** → only LWW-register (a CRDT *technically*, but it resolves
  same-key conflicts by *discarding* one decision via a timestamp — which for a
  semantic decision is "silently pick a winner," i.e. a false merge dressed as a CRDT.
  **A flag conflict is a real conflict and should escalate, not LWW-resolve.** This is
  where blindly importing CRDTs from collaborative-text would *reintroduce* the false
  merge. Flag this loudly.)
- **A.6 control-flow / async / effect reordering** — non-commutative, non-monotone,
  no join. Must escalate.
- **A.7 data-dropping migration** — non-injective, below the algebra. Must escalate
  and additionally is *not even replayable* without the data.

**The honest synthesis:** decisions admit a CRDT **iff the decision class is monotone
+ idempotent + commuting**, which is exactly the *additive / grow-only* classes
(A.4-pure, A.5, A.8). These are also — not coincidentally — the **M-dominant,
behavior-extending** classes from Frame 3. The **S-dominant, behavior-replacing**
classes (A.6, A.7) are precisely the ones with no algebra and no CRDT, and they
*should* require human merge. Refactors (A.1/A.2) are a third regime: full group
structure but non-commutative, so **OT, not CRDT**.

---

## 4. The unifying result: algebraic signature ≈ Frame-3 M/S profile ≈ merge regime

The strongest claim this frame supports, stated as a conjecture with its evidence:

> **Conjecture.** A decision-edit's *mechanical-shrapnel fraction* (Frame 3), its
> *algebraic signature* (this frame), and its *merge regime* are three views of one
> underlying quantity: **how much of the edit's outcome is forced by the existing
> program vs. how much new information it injects.**
>
> - **M=100%, no new info** → behavior-preserving → **group** (invertible
>   bijections) → **OT-mergeable** (transform around). [A.1, A.2]
> - **M-dominant, info only *extends*** → **monotone + idempotent + commuting** →
>   **join/meet-semilattice** → **CRDT-mergeable** (auto). [A.4-pure, A.5, A.8]
> - **S-dominant, info *replaces*** → **no inverse, non-commuting** →
>   **structureless** → **must escalate to a human**. [A.6, A.7]

The middle and edges line up because they are all measuring the *information* the
edit carries relative to the program — Frame 3's "surprise given the decision," the
algebra's "does the op preserve/extend/replace structure," and merge's "can two such
ops be reconciled without a new decision." If the conjecture holds, **a decision-VCS
can classify an incoming edit's merge regime from its algebraic signature alone**,
which it can read off the edit's *kind* — no diff-text heuristics.

**Where I am NOT confident (flags):**
- The clean A.4 G-Set result **degrades when the add spawns non-monotone shrapnel**
  (the exhaustiveness `match` arms of Frame 3 §2.4). The *add-the-case* sub-edit is a
  CRDT; the *fill-the-arms* sub-edits are A.3/A.6-flavored and are NOT. So a real
  "add enum case" transaction is a **mixed-signature bundle**, and its merge regime is
  the *meet* of its parts' regimes (the least-mergeable component dominates). The
  decision-VCS must therefore record the bundle's internal derived-from edges (which
  arm came from which case) to merge the CRDT part and escalate only the non-CRDT
  part. I believe this is right but have not formalized "regime of a bundle = meet of
  component regimes"; it's a conjecture-within-a-conjecture.
- "Refactors form a group acting on programs by behavioral isomorphism" leaks in real
  languages (reflection, init order, `unsafe`). The group is over the *idealized*
  semantics; the action is only *almost* by automorphism. Don't oversell it.
- The behavioral-refinement order `⊑` that makes "monotone" meaningful is itself only
  a *pre*order in the presence of nontermination/effects (you need a domain theory to
  make it a real partial order). The lattice claims (A.4/A.5/A.8) are clean at the
  *syntactic* structure level (sets of cases, types under subtyping, conjunctions of
  clauses); promoting them to *behavioral* lattices requires the domain-theory
  scaffolding and I'm only claiming the syntactic level firmly.

---

## 5. What branching / review / conflict become under decision-granularity

Concretely, recasting the VCS primitives:

- **Branch** = a divergent *set* of decision-edits over a shared base decision-structure.
- **Merge** = fold the two edit-sets by per-pair commutation: CRDT classes join
  automatically; OT classes (refactors) transform-and-apply; structureless classes
  raise a *semantic* conflict.
- **Conflict** = a detected non-commuting pair sharing a decision locus. It is
  presented as *"you both changed decision D"* (e.g. "you both set the retry policy"),
  not *"both touched line 42"*. The diff is over the decision, so the review unit
  matches the thinking unit (this is the Frame-3 throughline: review the decision, not
  its smear).
- **Review** = inspecting the *spawned-decision* (S) components, since the mechanical
  (M) components are by definition forced and need no review — the system can render
  "these 40 call-site edits are the determined shrapnel of decision D; only D and its
  3 spawned sub-decisions need your eyes." This is the editing-time payoff of the
  whole reasoning thread: **review collapses to the decision-content, which is what
  code review was always *trying* to be and text smears.**
- **Cherry-pick** = replay a single decision-edit onto another branch — sound iff the
  edit commutes with the intervening edits (decidable for CRDT/OT classes; needs
  human for structureless), and *operation-invertible* edits (§1) cherry-pick and
  revert cleanly while data-dropping ones cannot.

The net: **decision-granular VCS dissolves the false-conflict / false-merge problem
for exactly the additive (CRDT) and bijective (OT) classes — which empirically (Frame
4) are the *majority* of everyday edits — and correctly *refuses* to auto-resolve the
structureless classes, where today's line-merge produces its most dangerous false
merges.** It does not make merge trivial; it makes merge *honest*: every auto-merge is
sound, every raised conflict is real, and the residue that needs a human is exactly
the residue that always needed one.

---

## 6. Honesty ledger

- **Group claims:** made *only* for renames/refactors (A.1/A.2), and even there
  flagged as "over idealized semantics; real languages leak." Not claimed loosely.
- **Lattice/CRDT claims:** made for A.4-pure / A.5 / A.8 at the *syntactic-structure*
  level (confident); promotion to behavioral lattices flagged as needing domain
  theory (not claimed).
- **The LWW trap:** explicitly called out — A.3 flags are *technically* a CRDT but
  resolving them by LWW reintroduces the false merge; they should escalate. Importing
  CRDTs naively from collaborative *text* is a foot-gun here.
- **Mixed bundles:** the headline "add enum case" is a *mixed-signature bundle*, not a
  clean CRDT; "regime of bundle = meet of components" is a conjecture I did not prove.
- **The unifying conjecture (§4)** that M/S-fraction ≈ algebraic signature ≈ merge
  regime is the frame's central bet. It is well-evidenced by the per-class alignment
  but is a *conjecture*, not a theorem; the alignment could have counterexamples in
  classes I split too coarsely (A.5's variance flip is one warning that "decision
  class" sometimes needs sub-splitting before the algebra is single-signed).
