# Synthesis — The Space of Single-Decision Behavior Changes

> A unified map of the *editing* side of a long reasoning/representation thread. The
> thread's destination, finally named by the user: **there is no objective
> representation**; we are forced into a single fixed one and pay the re-translation cost
> by hand. On the editing axis this becomes: **the unit of editing should be the
> *decision*, not the line.** Eighteen decorrelated frames mapped that space; this
> document integrates them into one picture you can read without the frames. It cites
> frame numbers (F1–F18) throughout so it is also a map *into* the artifacts. It is a
> research artifact, not a pitch: where the frames flagged uncertainty or disagreed, the
> uncertainty is preserved.

---

## 1. The premise

A program is not fundamentally text; it is a **structure of decisions**. Text is a
**lossy, redundant linearization** of that structure — and crucially, one decision
("store money as cents", "this payment method is now supported", "make this call
fallible") is *smeared* across many character/line edits, often across files and even
across repositories and substrates (F1, F4). The human carries the entire burden of
*finding and coordinating* the N scattered edits that one decision determines.

The discriminator that runs through every frame: **one intent, one decision in the head
— but the text projection scatters it across many edits.** Behavior-*changing* edits are
in scope; behavior-preserving refactors (rename, reformat) are the boundary case where
the smear is purely mechanical (F1).

This is the *editing-side* resolution of the thread. The thread had already established
(per the handoff): meaning is structured; structure is redundancy; redundancy serialized
into a line is necessarily uneven in density; the disease is **flat compute over non-flat
structure** — the same forward pass for a forced `)` as for the token that picks the
algorithm; and entropy is **representation-relative** — the representation *creates* the
distribution. The user's final framing closed it: there is no objective representation,
so we are *forced into a single fixed one* (text/the imperative line) and *pay the
re-translation cost by hand* every time we edit. The unit of editing should be the
decision; text bills you for the smear (F3, F7).

The user's interest is **non-LLM intelligence and better representations generally** —
code is the worked example, not the subject. "Edit the decision, not the line" is one
concrete instance of "stop paying the re-translation toll of a single fixed
representation."

---

## 2. The central axis (the spine), confirmed five independent ways

Every frame, from its own starting frame, rediscovers **one** axis. A change to a program
partitions into two kinds of content:

- **Mechanical / forced-by-program** — consequences fully determined by the decision plus
  the existing program. Given the decision, there is exactly one correct edit; a
  derivation procedure produces it; **no new information enters**. (F3's "mechanical
  shrapnel".)
- **Spawned / new-info-from-oracle** — sites the change *forces to exist* but cannot
  *fill*; they admit multiple program-consistent completions with no basis in the program
  to choose. **Information must enter from outside the program** — a candidate is proposed
  (by search/synthesis, by a human, or by a learned proposer) and *decided* by an exact
  verifier at the leaf; where no such verifier exists, the only safe source is a human.
  (F3's "spawned decisions"; the oracle *proposes*, it never *decides* — see §7/§9.)

This is exactly the thread's **reducible-redundancy vs irreducible-decision-content**
line, seen at editing time. Five frames confirm the *same* axis from genuinely different
starting frames:

1. **Mechanical vs spawned** (F3) — the propagation profile of an edit: derive the
   forced, isolate and oracle-fill the new.
2. **Decision-entropy / bits** (F7) — zero-bit (forced) vs >0-bit (irreducible), graded
   into bands (1-bit toggle → choice-among-N → parametric → structural → open-ended),
   with a **phase transition at "open-ended"**: bands with a *known finite support*
   (Shannon applies, machine can enumerate the options) vs an *open object space* (only
   Kolmogorov applies, unbounded — the machine cannot even frame the question).
3. **Algebra of edits** (F9) — M=100% behavior-preserving edits form a *group*;
   monotone+idempotent+commuting *additive* edits form a *join-semilattice* (a CRDT); the
   S-dominant behavior-replacing edits are *structureless* (no inverse, no commutation).
   The algebraic signature ≈ the M/S profile.
4. **Derivable vs observable propagation** (F12) — symbolic substrates have *derivable*
   shrapnel (the spine holds); statistical substrates have *observable-only* propagation
   (the spine fails — see §5).
5. **Proof-stationary vs empirical** (F11) — a forced edit's verification can be
   *stationary* (the type checker IS the proof); a spawned edit's correctness ranges to
   *empirical-only*.

The cross-disciplinary frame (F5) proves the spine *by exhaustion*: spreadsheets,
parametric CAD, relational databases, build systems, IaC, and constraint solvers are each
**near-pure-M engines that work precisely because they engineered S ≈ 0 inside their
domain** (via four tricks: purity/totality, data-not-behavior, closed algebra,
derived-is-read-only). The thing all six avoided is the thing general code cannot avoid:
**irreducible S — intended behavior that exists only in the author's head, expressible by
no constraint the machine holds, because the program is the very place that behavior gets
written down.**

---

## 3. The master localizability discriminator: compositionality (F10), with verification as ground truth (F11)

The adversarial frame (F10) found the map's hidden over-claim and supplied the missing
precondition. "Smear is contingent on representation" is **true for compositional,
decidable, structural decisions and false for a second kind the map conflated with it**:

- **Authoring smear** — one decision requires N coordinated edits. *Contingent*: give it
  a home (a name, a type, a handler, a schema) and N collapses to 1 + derived shrapnel.
- **Realization smear** — the decision's *effect* is irreducibly distributed because the
  content *is* a property of the joint behavior. *Intrinsic*: no single home, even in
  principle.

The discriminator that separates them is **compositionality**:

> **A decision is localizable ⟹ its defining property decomposes into per-site contracts
> a determinate (decidable) procedure can check/derive.**

Non-compositional global ∀-properties — numerical stability, fairness, deadlock-freedom,
linearizability, statistical/distributional invariants — have *no local contract to
localize into*. The whole localizer machinery (types, effects, exhaustiveness) is
silently a theory of *compositional* decisions; it over-claims over the non-compositional
ones. (F10 also corrects the map's *pessimism* in places: known-algorithm performance is
*contingent* — query planners and Halide localize it — and unknown-algorithm performance
isn't smear at all, it's discovery. And it flags that F3's determinacy test is itself
undecidable for semantic-equivalence/termination properties, so the framework runs a
*decidable approximation* of its own test.)

**Verification is the un-fakeable ground truth (F11).** Run the lens backward: once a
decision is realized, what artifact establishes it is correct, and does *that* smear?
F11's central result is that **verification-smear tracks compositionality more tightly
than implementation-smear**, because implementation has an escape that verification does
not:

- The only way to localize the *implementation* of a global property is to make it **true
  by construction** (a session-typed protocol, a verified library) — and that move *is*
  making the verification stationary. They are the same act seen forward and backward.
- So "true by construction" = "verification stationary". An implementation can present N
  scattered edits that *look* like they handle a global property and pass a test suite
  that doesn't exercise the global interleaving (the Jepsen graveyard); only the attempt
  to *verify* forces the honest question "does any local artifact witness this?"

This yields the **codemod test for pseudo-localizers**: take any proposed localizer and
ask "does it make the *verification* one unit too?" If the edit collapses to one gesture
but confidence still must be earned per-site, it is a *pseudo-localizer* that merely
relocated the smear from your fingers to your eyes.

And the operational rule (F11 §6): **an oracle-at-a-leaf is safe only where a cheap, total
verifier sits at that same leaf** — a typed hole, a contract, a property test that
mechanically rejects a wrong fill. The verifier-at-leaf is *what keeps the oracle at the
leaf rather than in the control loop*. The 1→∅ classes (no local verifier — emergent
invariants, ML weights) are **exactly where you must NOT delegate to an oracle**, because
no deterministic catch exists for a wrong bit. The verifier must be cheap-total, *never
another oracle* (infinite regress). (F11 honestly flags the P-vs-NP caveat: verification
is monotone-worse than implementation *for establishing completeness of a distributed
change*, but for *a single proposed answer* it can be strictly cheaper — which is exactly
why the oracle-at-leaf + cheap-verifier architecture works at all.)

---

## 4. "Localizable" ≠ "should be localized": the economics correction (F14)

The map inherited an uncritical *localize-everything* bias. F14 prices it and inverts it
in a way that is not symmetric to the compression story:

**Not all redundancy is reducible.** Some apparent duplication is **essential** — N
*independent* decisions that happen to land on the same value today. Factoring it is not
compression; it **fabricates a coupling the domain does not have**, asserting `D₁ = D₂`
for two decisions merely equal-valued now. This is *load-bearing redundancy*: the
distribution *is* the decision "these may vary independently" (F9 A6, F10 A6).

The discriminator is the **change-reason test**: *is there a single conceivable domain
change that should alter one site and not the other?* No → incidental/reducible → localize
(subject to cost). Yes → essential/irreducible → **never** localize. Duplication is a
question about the *future* (divergence), not the *present* (identical-today), so
repetition-counting is the wrong instrument.

Even *reducible* redundancy doesn't always pay. F14's cost taxonomy (C1 construction, C2
localizer maintenance, C3 comprehension/indirection tax, C4 false-coupling cliff, C5
wrong-axis lock-in) shows that **the only cheap-and-visible term is C1 — the one the
pro-localization bias correctly ignores — while every term that should gate the decision
(C3/C4/C5) is invisible in the diff and unbounded.** The bias is a *salience artifact*.
Three regimes: **(1) localize now** (frequent × wide × known-right — the map's only
regime), **(2) wait/late-bind** (rule-of-three: duplicate until the third instance reveals
the varying axis), **(3) never** (essential duplication). Error asymmetry settles ties:
**under-localize when unsure** — un-factoring is strictly harder than factoring-later.

So the corrected objective is not "minimize redundancy" but **"factor reducible, preserve
irreducible"** — and the two are indistinguishable in the text, separable only by the
change-reason test.

---

## 5. Three distinct sources of unlocalizability (plus a substrate modulation)

The frames isolate three *kinds* of wall, which fail for different reasons and yield to
different fixes:

**(a) Representational** (F2, F6). The decision is smeared because we lack a notation in
which it is positionally local. Often *contingent*: F2 inventories the localizers (DRY,
static types as exhaustive-failure-worklists, richer types, effect systems, AOP,
macros/codegen, config, schema+migrations) each of which makes one band of decisions
single-edit. F6 shows much of F2's "frontier" is **a frontier of the imperative paradigm
specifically**: async-coloring is *dissolved* by dataflow/reactive, scalar→array by APL's
rank-polymorphism, dispatch by logic programming, cross-cutting-over-data by
logic/constraint paradigms. But there is a **conservation of smear**: no paradigm is
globally less smeary; each dissolves the classes matching its grain and *relocates* smear
to the classes that fight it. The dream is therefore not "pick the right paradigm" but
"let each decision be edited in the paradigm that homes it" — which is the
multi-representation / projectional direction.

**(b) Intrinsic / logical** (F10, F11, F13). Non-compositional global ∀-properties have no
local home *even in principle* (§3) — you can only verify them empirically. F13 adds the
**polarity asymmetry**: *addition is a local existential act* (∃ a site where I add a
thing — the machine enumerates the forced worklist, complete by type soundness);
*deletion is a global universal claim* (∀ sites, nothing depends on the thing — a backward
closure over a frontier that includes dynamic/at-rest/external/adversarial dependents the
program graph does not contain, completable only with empirical evidence; and it
*destroys the rationale* that would let you safely reverse it — Chesterton's Fence
formalized).

**(c) Social / authority** (F15). The decision's sites sit under *different
write-authorities*; no notation grants you write access. This is a **genuinely distinct**
unlocalizability — the read/write-symmetry test separates it cleanly: give the agent a
perfect localizing representation and ask if the smear vanishes. For representational
smear, yes (that's the definition). For social smear, *no* — the node is now perfectly
local and you *still can't apply it*, because applying it is N write-acts under N
authorities. **Representation is about *knowing*; authority is about *acting*; a perfect
map of a territory you may not enter is still a wall.** The fix is scale-dependent:
*tooling* fixes reach (within ownership; converts reach-smear into authority-smear);
*decoupling* (versioning + deprecation windows) is the only thing that works across
company boundaries; *org design + ADRs* fix authority and rationale. Beyond the company
boundary, unlocalizability is permanent.

**The substrate modulation** (F12). Where does behavior *live*? Symbolic substrates
(grammars/schemas/DSLs, data/config) have **derivable** propagation — the spine holds, and
for data-as-behavior authoring smear → ~0 (the strongest vindication of "prefer data over
code"). Statistical substrates (ML **weights**, trained policies) have **observable-only**
propagation: no exhaustiveness checker, no worklist, "propagate the decision" is replaced
by "retrain and *measure*", and measurement is a *sample* of an infinite surface — a
**statistic where the spine had a proof**. **Prompts are the dangerous hybrid**: a
*symbolic* edit (localized, diffable, versioned authoring) feeding a *statistical*
realizer (unbounded, underivable, un-checkable realization). The clean `git diff` of a
prompt masquerades as realization-localization while telling you *nothing* about the
behavior delta. This is the substrate *this very ecosystem* runs on (CLAUDE.md, hooks,
skills). And **editing the oracle bifurcates along the framework's own seam** (F12 §7,
F10 §D): the *invocation surface* (prompt/tools/RAG/harness) is symbolic and in-framework
— where all practical leverage lives; the *weights* are the statistical substrate, outside
the symbolic framework, with only the weaker statistical analogue. **The framework is not
closed under self-application on the weight axis** — which is exactly *why* the
architecture confines the oracle to the leaves and keeps the control loop symbolic.

---

## 6. Modulating dimensions

Three dimensions cut across the spine and modulate every decision:

- **Time** (F8). A decision is not a state but a **trajectory**. Some decisions are
  *intrinsically temporal*: expand→migrate→contract, canary rollouts, deprecation cycles,
  credential rotation — the old and new behaviors *must coexist* because the population is
  not all updated at one instant. This smear is **not collapsible by any representation**;
  it is mandated by overlap. The discriminator: *if the intermediate state must run in
  production*, the decision is intrinsically temporal (sequence it); *if it need only
  exist in the working tree*, it is a collapsible spatial smear. The **run-in-production
  discriminator** is the temporal twin of F11's empirical-verification finding. Most
  decisions die uncompleted (dead flags, immortal shims, un-sunset `/v1`).

- **Direction** (F5). The whole map is *forward* (change a decision, consequences flow
  downstream) — except IaC, which inverts it: **declare the desired state, let a
  reconciler derive the transition (the shrapnel) by diffing against where you are.** This
  is *desired-state editing* — make the *goal* the unit. F11's verification is the
  *backward* dual of the same inversion.

- **Polarity** (F13). Addition (∃-act, monotone, machine-completable forward tree) vs
  deletion (∀-claim, anti-monotone, backward closure over an open frontier,
  non-invertible). The universal practical move is to **convert the negative into a
  positive**: a chokepoint deny-check for revocation, a failing assertion/lint for "stop
  doing X", a richer type for forbidding a state (unrepresentability discharges the ∀ *by
  construction, forever*), a `#[deprecated]` marker that *borrows the type system's
  worklist* to enumerate the dependent frontier — addition in service of subtraction.

---

## 7. The constructive synthesis: editor-as-reconciler

The fusion of IaC's inversion + the constraint-solver's fixpoint engine + CDCL's
learn-from-conflict (F5) names the destination: **the editor of the future is a
reconciler.** You edit a *decision / desired-state*; a fixpoint engine derives every
consequence it can (the M shrapnel), surfaces the *forced-but-undetermined* sites (the S
holes) as a worklist, each hole is filled by a *verified* candidate (search/synthesis
proposes, an exact verifier at the leaf decides; no verifier → escalate to a human), each
accepted fill re-enters and re-triggers
propagation, and derived artifacts are **read-only projections** maintained by continuous
reconciliation. Every piece already exists, battle-tested, in some discipline; none is
assembled.

The state-of-the-art survey (F16) sharpens this into **five organs**:

1. **Locate** decision sites semantically — *solved, production-grade* (CodeQL, Glean,
   Semgrep, name-resolution).
2. **Edit-as-decision** — *solved for the M-only / behavior-preserving subset*
   (OpenRewrite recipes, codemods, IDE refactorings).
3. **Store** code so the decision *is* the unit — *freshly alive* (Unison reached 1.0 in
   Nov 2025; MPS niche; OpenRewrite's LST round-trips to byte-identical text).
4. **Propagate** by fixpoint — *solved, production-grade* (Salsa powers rust-analyzer;
   differential dataflow; CDCL in every SMT solver).
5. **Fill / refuse spawned decisions** — **the historical missing organ.** Hazel built the
   *socket* (typed holes = forced spawned decisions made first-class) and pre-LLM **nobody
   had an automated way to staff it**.

**Four organs already ship at scale; organ 5 is the gap — and what newly fills it is
search + synthesis over the decision structure, *decided by exact verification*** (the
non-LLM intelligence this whole thread was about). The decision-content organ 5 must
produce is the *spawned* decision: the irreducible, high-entropy bit. That is **exactly the
reasoning the thread established LLMs only imitate and degrade on**, so the LLM must *not*
be the thing that makes these decisions. The competence comes from **search over the space
of program-consistent candidates + a cheap-total verifier that decides accept/reject** —
the verifier is the decision-maker; correctness rests entirely on it. A learned proposer
(an LLM, or any heuristic) is at most a **branching prior that narrows the search, and is
load-bearing for nothing** — strip it and the verifier still decides correctly, just over a
wider frontier. This is the literal reading of "oracle at the leaves, never the control
loop" (cf. AlphaZero: the policy/value net *proposes and prunes*; MCTS-search + the exact
rules of the game *decide*; the net is replaceable, the rules are not).

> **Correction (recorded, not retconned).** An earlier framing of this synthesis named
> "the LLM" as organ-5's filler and decider — "the first entity that can supply
> undetermined-but-forced behavioral content at a leaf." That was wrong and self-contradictory:
> it put the imitator that *degrades on exactly the irreducible decisions* into the role of
> *making* those decisions, collapsing "oracle proposes" into "oracle decides" — the
> control-loop role the ecosystem principle (and F11) forbid. It also contradicted the thread's
> own thrust, which is **non-LLM intelligence**. Organ 5 is staffed by search + verification;
> a learned proposer is an optional, non-load-bearing prior; and where no cheap-total verifier
> exists, organ 5 cannot be safely automated at all and escalates to a human (per F11).

This is *why prior whole-vision attempts failed structurally and why
"now" may differ* (F16 Part B/C): strip the contingent blockers (text/diff/merge interop,
ecosystem bootstrap, editing friction — each individually hard, each historically sank a
company) and *every* corpse — Intentional Software, MPS outside DSL niches, Hazel,
Smalltalk — died on **the same defect: editing one decision was cheap, the mechanical
shrapnel was free, but nothing could *automatically* staff the spawned decisions, so on every
behavior-*changing* edit the system collapsed back into "a fancier way for the human to
type the new behavior" and lost to text on friction.** IDE refactorings are the lone
whole-success precisely because they *definitionally restrict themselves to S = 0*. What
removes that one structural blocker now is **search + verification at the leaf** — **decided
by F11's verifier-at-leaf and bounded by F10's compositionality** (candidates are searched
or synthesized — a learned proposer may narrow that search — and the verifier accepts or
rejects; where no cheap-total verifier exists, organ 5 is *not* automated, it routes to the
human — strictly the pre-LLM behavior, no regression). The new risk a *generative* proposer
would introduce, and the reason it cannot be the decider: **confident-wrong spawned
content** that no verifier gates — most dangerous at exactly the unverifiable leaves, which
is precisely where it must escalate to a human instead.

**The cognitive fit** (F17). The editor is a bet about cognition, and it is *substantially
right in a bounded way*: the human's intent is **decision-shaped but not
decision-complete.** The *figure* (the irreducible bit) is genuinely held, compositional,
and the unit people communicate and chunk in (commit messages, PR titles, names are all
decision-granular — naming is the human-side analog of localization, straining against
working-memory limits). But the *ground* is **co-constructed and discovered**: M-shrapnel
is foreseen in kind, not extent; spawned S-decisions are *discovered reactively, often by
the compiler* ("JPY has no minor units, so the rounding assumption is now wrong" did not
exist in the intent at formation). The compiler error is *the oracle's work-queue*. So the
editor must be built as an **iterative dialogue that surfaces the spawned worklist**, not a
form demanding a complete spec up front — and quality/structural intents ("make it faster",
"this is really two things") have *no pre-existing decision at all* (the decision is the
*output* of exploration), so for those the editor is at best a downstream recorder.

**The interaction resolution** (F18). The reconciler is a *plan/apply loop* (IaC-shaped),
not direct manipulation. The visible-vs-invisible-shrapnel trust tension (show all N edits
→ drown in the burden you fled; hide them → action-at-a-distance dread) **dissolves by
changing the object of review**: you do not review the shrapnel — you review **the decision
and its proof token**; the shrapnel is reviewed by *its verifier*. Invisible propagation is
*earned* exactly where a cheap-total verifier backs a green badge (you trust it the way you
trust a compiler), and **refused — honestly, visibly — where no such verifier exists** (the
token goes red/empirical; you're escalated to architecture-review or staged-rollout
evidence). The token's strength = the verifier's grade = the compositionality grade. Commit
shows a **behavior diff, not a source diff**. (F18's honest open list: backward-ambiguous
edit-through-lossy-projection (the view-update problem, decades-unsolved); no good UI for
evaluating an *empirical* proof token; proof-token literacy / anti-habituation;
selective/DAG undo; temporal-trajectory editing as one object; refusal UX; and a
*decision-level merge-conflict UI* for non-commuting concurrent edits, for which there is no
precedent — git's text-conflict UI is the shrapnel-tool this project replaces.)

---

## 8. The honest boundary — where the whole program cannot reach

The surviving core is **narrower and sharper** than the strong claim: smear is contingent
*exactly when* the decision's property is compositional and its correctness decidable. The
program cannot reach:

- **Non-compositional global ∀-properties** (numerical stability, fairness,
  deadlock-freedom, linearizability, statistical invariants) — verifiable only
  empirically; the unit of change is *the substrate*, not a node (F10, F11).
- **The oracle's own weights** — the framework is not closed under self-application on the
  weight axis; you edit the oracle's behavior only through the symbolic things *around* the
  weights (F12, F10 §D).
- **Cross-org authority** — permanent beyond the company boundary; the fix is decoupling,
  not tooling (F15).
- **Essential duplication** — load-bearing redundancy that must be preserved, not factored
  (F14, F9 A6).
- **Intrinsically-temporal change** — the overlap window must run in production; not
  collapsible by any representation (F8).
- **Exploratory / holistic / fixpoint decisions** — quality/structural intents whose
  decision is the *output* of exploration (F17); consistency/gestalt decisions that are a
  relation among *all* sites with no separable node (F10 C2); mutually-recursive /
  cyclic decision graphs that are a strongly-connected component, not a tree (F10 C1).

These are the **unstated preconditions of the "one node" editing unit** that F10 forced
into the open: the unit is a node of a *tree* only when the decision graph is
**compositional / acyclic / decidable / single-owner / reversible**; otherwise the editor
must *escalate to the human*. The earlier frames present the special case as the general
one; the honest map states the precondition.

---

## 9. The loop closed

The thread opened with "LLMs suck at reasoning / at code." It resolves to: **organ 5 — the
filling of spawned decisions — is staffed by search + synthesis over the decision structure,
*decided by exact verification at the leaf*, bounded by compositionality; a learned proposer
(an LLM, if any) is at most a non-load-bearing branching prior, and where no cheap-total
verifier exists the leaf escalates to a human.** The competence is non-LLM intelligence —
search and verification — which is what the thread was about all along; the LLM is never the
decision-maker (and is *most* dangerous exactly where no verifier can gate it). That is the
ecosystem's own standing principle ("the LLM is an oracle at the leaves, never the control
loop; determinism is a hard invariant") read literally — oracle *proposes*, the exact
substrate *decides* — arrived at independently from the editing side.

The two arguments are **one argument**. The representation argument (the thread): meaning
is structured, structure is redundancy, the disease is flat compute over non-flat
structure, representation is the primary lever because it *creates* the entropy
distribution, the game is a representation where each unit ≈ one irreducible decision. The
editing argument (these frames): a program is a structure of decisions, text smears one
decision across many edits, the disease is flat *labor* over non-flat decision structure,
the editor-as-reconciler derives the reducible and isolates the irreducible. The **M/S
spine is the thread's reducible/irreducible line** — counted three ways (F7): by *origin*
(mechanical vs spawned), by *representation* (localizable vs not), by *information* (0 bits
vs >0 bits). Bit-conservation under representation change is the conjectured invariant
(F7): representation moves bits between artifacts and drives the *smear* N→0, but cannot
reduce total irreducible content below the world's actual demand.

And the user's actual interest stands above the worked example: **there is no objective
representation.** Code is where we watched the toll get paid by hand. The reconciler is one
machine for paying it automatically *wherever the representation stays faithful* — and
refusing to pretend, wherever it doesn't.

---

## 10. Frame index

| Frame | Contribution (one line) |
|---|---|
| **F1** — program axes | Derives the 14 structural axes (values, types, control flow, effects, concurrency, …) a program can change along, and the three smear mechanisms (replication / contract / cross-cutting). |
| **F2** — localizing representations | Inventories the localizers (DRY, types-as-worklist, richer types, effects, AOP, macros/codegen, config, schema+migrations) and charts the frontier where none exists. |
| **F3** — mechanical vs spawned | Names the spine: forced shrapnel (machine-derivable, 0 new bits) vs spawned decisions (oracle-only); the boundary is itself machine-locatable; the edit is a *tree*, the unit is one node. |
| **F4** — empirical edits | Grounds it in real diffs: smear is bimodal (point-fix vs fan-out/cross-cutting), the decision often lives *outside the code* (ticket/contract/changelog), derived artifacts carry zero decision-content. |
| **F5** — cross-disciplinary | Six mature one-edit-propagates engines (spreadsheet/CAD/DB/build/IaC/solver) prove S≈0 is *engineered*, name the four tricks, and synthesize the **editor-as-reconciler** (desired-state + fixpoint + CDCL). |
| **F6** — paradigm relativity | Same decision, varied paradigm: many "frontier" smears are *dissolved* by some paradigm — but smear is *conserved*, relocated to whatever fights the new grain. |
| **F7** — decision entropy | The information lens: decision-bits = conditional, engine-relative surprise; bands with a phase transition at open-ended; smear N ⟂ bits-per-decision. |
| **F8** — temporal lifecycle | A decision is a *trajectory*; intrinsically-temporal smears (expand/contract) are uncollapsible because old+new must coexist in production; reversibility is spent monotonically. |
| **F9** — algebra & merge | Edits' algebraic signature (group / semilattice / structureless) ≈ M/S profile ≈ merge regime; additive=CRDT, refactor=OT, S-dominant=must-escalate; dissolves false-conflict/false-merge. |
| **F10** — adversarial | The master fix: **compositionality** is the localizability discriminator; separates authoring-smear (contingent) from realization-smear (intrinsic); surfaces the unit's unstated preconditions. |
| **F11** — verification dual | Verification is the decision's backward half; smear tracks compositionality *more tightly* (un-fakeable ground truth); oracle-at-leaf needs cheap-total verifier-at-leaf; codemod = pseudo-localizer. |
| **F12** — behavior-is-substrate | Symbolic (derivable propagation, spine holds) vs statistical (observable-only, spine fails → statistic-not-proof); prompts the dangerous hybrid; editing the oracle bifurcates along the seam. |
| **F13** — deletion / negative | Addition = ∃-act (local, machine-completable tree); deletion = ∀-claim (global, backward closure over an open frontier, non-invertible, destroys rationale); convert negative→positive. |
| **F14** — economics | Localizable ≠ should-localize: cost taxonomy (C1–C5, only C1 cheap-and-visible); change-reason test for essential vs incidental duplication; factor reducible, *preserve* irreducible; under-localize when unsure. |
| **F15** — social / ownership | Authority-structural unlocalizability ≠ representational; representation is knowing, authority is acting; cross-org → decoupling, not tooling; the read/write-symmetry test. |
| **F16** — state of the art + graveyard | Five organs; 1–4 ship at scale, organ 5 (fill spawned) is the historical gap; prior projectional/intentional editors died for want of an *automated* filler; what fills it now is search + verification (verifier decides; learned proposer optional, non-load-bearing; escalate where no verifier). |
| **F17** — cognitive / intent | Intent is decision-*shaped* but not decision-*complete*: figure held, ground discovered; compiler-as-work-queue; build as iterative dialogue, not an up-front form. |
| **F18** — interaction design | Plan/apply loop; trust tension dissolves by reviewing the *decision + proof token*, not the shrapnel; verifier-at-leaf earns invisible trust; behavior-diff not source-diff; honest open problems. |
