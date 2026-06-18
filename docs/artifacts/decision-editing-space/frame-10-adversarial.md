# Frame 10 — Adversarial completeness-critic / red-team

> Mandate: **break the map.** Find single-decision behavior changes that are *intrinsically*
> smeared (no representation could localize them even in principle); find whole categories
> and framing-axes the nine frames miss; attack the "one node of a decision-tree" unit
> definition; test self-reference. Be hostile and rigorous. Flag where the attack fails and
> the claim survives. No padding.

What I read first (so this critique attacks the real text, not the summary): frames 1–4 as
written (`frame-1-program-axes.md`, `frame-2-localizing-representations.md`,
`frame-3-mechanical-vs-spawned.md`, `frame-4-empirical-edits.md`) plus the nine-frame
digest from the dispatch. Frames 5–9 exist only as summary; I attack their *stated*
content and flag where I'm inferring.

The central claim under fire, stated as the frames state it (Frame 4 §6, Frame 2 closing):

> "Smear is contingent on representation, not intrinsic — it's what you get when a decision
> was never given a home." The mechanical/spawned split mirrors reducible-redundancy /
> irreducible-decision. The editing unit is "one node of the decision-cascade tree with
> shrapnel pre-derived and spawned decisions enumerated."

I will show: (a) the contingency claim is **true for positional/structural smear and false
for a second, distinct kind of smear the frames conflate it with** — there is a class that
is irreducibly distributed and the frames' own frontier list half-sees it without drawing
the line; (b) at least **three whole framing-axes are missing**, one of which (the
*observer/verification* axis) I think is worth running as a real frame; (c) the tree-unit
model **breaks on a definable class of relational/holistic decisions** and the frames admit
this only as a footnote when it deserves to be load-bearing; (d) the framework is **not
self-applicable** in a way that matters.

---

## 0. The move the whole map makes, and the equivocation hiding in it

Every frame leans on one inference: *the type system can enumerate the shrapnel of an
enum-case addition → therefore smear is a representational accident → therefore for any
decision there exists (or could exist) a representation that localizes it.* Frame 2 hedges
this ("no single representation localizes all of them") but its closing thesis and Frame 4's
synthesis #6 state the strong form: smear is "contingent on the representation, not
fundamental."

The equivocation is on the word **smear**. The frames use it for two different things:

1. **Authoring smear** — the *one human-authored decision* requires N coordinated edits.
   This is what rename, enum-add, signature-change exhibit. It is genuinely contingent:
   give the decision a home (a name, a type, a handler, a schema) and the N collapses to 1
   + machine-derived shrapnel. The frames prove this convincingly.

2. **Realization smear** — the decision's *effect on observable behavior* is irreducibly
   distributed across the program's runtime structure, such that **no single locus can
   carry the decision's content even with a perfect representation**, because the content
   *is a property of the distribution itself.*

The frames collapse (2) into (1) and declare victory. The red-team claim is: **(2) is real,
(2) is not contingent, and the existence of an enumerator for (1) tells you nothing about
(2).** Below, the falsifiers — each tested against the discriminator "could a representation
give this decision a single home *even in principle*?"

---

## (a) Falsifying "smear is contingent" — irreducibly-distributed decisions

For each candidate I apply one test the frames don't: **the localization-faithfulness
test.** A representation localizes a decision iff there exists a single editable object O
such that (i) editing O changes the behavior in the intended way, (ii) the rest of the
behavior is *derivable* from O by a determinate procedure, and (iii) O *faithfully* names
the decision — O is not a leaky wrapper that has merely *relocated* the smear into its own
unreadable body. Frame 2 already flagged (iii) implicitly ("the rule itself is hard to
write… you've moved the locality, not eliminated the need for it") — I make it the
discriminator and push it hard.

### A1. Global numerical-stability / accuracy postures — **IN-PRINCIPLE UNLOCALIZABLE.**

Frame 1 lists "change associativity of an accumulation (numerical stability)" under axis B
as if it were a local operator swap. It is not, and this is the cleanest falsifier I found.

Consider the decision: *"this pipeline must be numerically stable to 1e-12 relative error
across the operating range."* This is one decision in the head. Its realization is: a
particular *choice at every arithmetic site* of summation order, of when to rescale, of
Kahan-vs-naive accumulation, of where to factor a near-singular matrix differently — and
the correct choice at each site **depends on the choices at the others** (catastrophic
cancellation is a property of the *sequence*, not of any one op). There is no object O you
can edit such that the per-site choices are *derived* from it, because deriving them is the
unsolved problem of numerical analysis — each is a research result (Kahan summation,
pairwise summation, the specific pivoting strategy). A representation that "localized" this
would have to *be* a numerical-analysis oracle. The decision is not under-determined by a
missing name; it is under-determined by mathematics.

**Verdict: in-principle-unlocalizable, not contingent-but-hard.** The reason is precise: the
decision's content is a *predicate over the joint behavior of all sites* (a global accuracy
bound), and the map from that predicate to per-site choices is not a determinate procedure
— it is itself an open problem. Frame 2's frontier #4 ("performance/complexity") gestures at
this but mis-diagnoses it as a *cost* problem ("no representation makes O(n²)→O(n) one
unit"). The deeper issue is that **a decision phrased as a global property over the joint
output has no faithful single home, because localizing it would require solving the
inverse problem "what local choices realize this global property," which is not mechanical.**
This generalizes well beyond numerics (next).

### A2. Decisions phrased as a global property of the joint behavior — the general class.

A1 is an instance of a class the frames never name. Call it **emergent-property decisions**:
the decision is a constraint on a *global, emergent* property of the running program, and
the property is not a sum of local properties.

Members:
- Numerical accuracy (A1).
- **"This system must be fair"** (no thread/tenant starves) — fairness is a property of the
  *schedule*, an emergent trace property; you cannot point at one lock and say "fairness
  lives here." Frame 1 axis I lists "fair vs priority scheduling" as a local primitive swap;
  it is not, when the *requirement* is end-to-end fairness across a pipeline of queues.
- **"This must not deadlock"** — deadlock-freedom is a property of the global lock-acquisition
  graph; the decision "be deadlock-free" cannot live in any single lock site; it is realized
  as a *global ordering discipline* that every site must respect, and whose correctness is a
  cycle-freedom property of the whole graph. (Lock ordering is the closest thing to a
  "home," but it's a *convention every site obeys*, not an editable object that derives the
  sites.)
- **"This distributed protocol is linearizable / this is eventually consistent"** — a global
  trace property. Frame 1 axis L calls "strong → eventual" a single decision with "huge
  smear"; correct, but it then files it under contingent smear. It is not contingent:
  linearizability is *defined* over the set of all possible interleavings of all operations;
  no single object derives the per-operation choices that make the global property hold,
  because that derivation is the (undecidable in general) protocol-design problem.
- **Statistical / distributional invariants:** "this sampler is unbiased," "this load
  balancer's output is uniform," "this anonymization gives k-anonymity." The decision is a
  property of the *distribution of outputs over all runs* — it cannot be checked or derived
  at any single site, only over the ensemble.

**Verdict on the class: in-principle-unlocalizable.** The unifying structure: the decision is
∀-quantified over *executions/inputs/sites jointly* and the property is non-compositional
(not a conjunction of local properties). The frames' localizers all assume the property
*decomposes* into a per-site contract the compiler can check site-by-site (types, effects,
exhaustiveness are all *local* checks aggregated). Non-compositional global properties have
**no local contract to localize into.** This is the single strongest hole in the map: the
whole localizer machinery is implicitly a theory of *compositional* decisions, and it never
says so, so it silently over-claims over the non-compositional ones.

*Where my attack partially fails:* you *can* sometimes give such a decision a home by
adopting a representation that makes the global property *true by construction* rather than
checked — e.g., a deterministic-scheduler DSL where fairness is structural, a session-typed
protocol where a class of deadlocks is unrepresentable, a verified-arithmetic library where
the stability is pre-proven inside the abstraction. So the honest verdict is: **the decision
"satisfy this global property" is unlocalizable, but the decision "adopt this construction
that guarantees the property" can be localizable.** That is a real escape — but note what it
costs: it is no longer "edit one node and the behavior follows," it is "redesign the whole
substrate so the property is structural," which is exactly the thing the editing-unit model
says it has *abstracted away*. The escape concedes the point: for these decisions the unit
of change is *the substrate*, not *a node*. (More in (c).)

### A3. Pareto postures — the frames already flag these; I sharpen to a *proof*.

Frame 2 frontier #8 says postures are "possibly not localizable in principle, because a
posture is by definition the coherence of many decisions, not one." I agree with the
conclusion and supply the argument the frame omits, because the argument also tells you
*which* postures are unlocalizable and which aren't:

A posture ("favor latency over throughput") is a *tie-breaking rule applied at every local
decision where the two objectives conflict.* It is localizable iff the tie-break can be
expressed as a single parameter that every site *reads* and that *determinately* selects the
local choice. Sometimes it can: a single `LATENCY_WEIGHT` knob that a cost model consumes at
every site (some query planners, some schedulers do exactly this). When it can, the posture
is *contingent-smear*, not intrinsic — Frame 2 over-concedes here.

But it is unlocalizable when the local choices are **not parameterizable by a shared
scalar** — when "favor latency" means *qualitatively different code* at each site (here a
cache, there a different data structure, elsewhere a precomputation), and no shared parameter
derives those qualitatively-different realizations. Then it is A2 again: a global property
with no compositional local contract.

**Verdict: split.** Pareto postures are *contingent* exactly when a shared parameter + a
per-site cost model can derive the local choices, and *intrinsic* otherwise. The frames
treat them as uniformly intrinsic; that's a smaller error than A1/A2 but it's an error, and
the discriminator (shared-parameter-derivability) is itself a useful addition to the map.

### A4. Performance/complexity rewrites — Frame 2 says "open and probably hard-open"; I say **mostly contingent, occasionally intrinsic, and the frame mis-locates the boundary.**

Frame 2 frontier #4 claims algorithmic-complexity decisions are unlocalizable because
"O(n)→O(n²) is inherently a restructuring of the whole computation." This conflates two
things:

- **"Use a better algorithm here"** where the algorithm is *named and known* (use a hash
  index instead of linear scan). This is *contingent*: a sufficiently high-level
  representation (a relational query + a planner, a Halide-style schedule separated from the
  algorithm, a `@memoize` boundary) *does* localize it — the decision is "materialize this
  relation as a hash index" and the planner derives the rest. Databases solved this decades
  ago: the SQL is the *what*, the plan is derived, and the index decision is one `CREATE
  INDEX`. Halide's algorithm/schedule split is the same move for array compute. So the frame
  is *wrong* that there is "no representation in which a complexity decision is one unit" —
  there are several, and they're load-bearing in production. The frame under-credits its own
  thesis here.

- **"Make this fast" where the faster algorithm is not yet known** — the decision is to
  *invent* an algorithm with better asymptotics. This is genuinely unlocalizable, but for a
  reason the frame should name precisely: it's not smear, it's that **the decision's content
  doesn't exist yet** — it's a research/discovery act, not an edit. This belongs with §2.7's
  "intent decomposition" / the pure-generative end, not in the smear taxonomy at all. It is a
  *category error to call algorithm-discovery a "smeared decision"* — there's no decision to
  smear until the algorithm is found.

**Verdict: Frame 2 mis-files this.** Known-algorithm performance is contingent (and already
localized in real systems the frame ignores: query planners, Halide, JIT directives).
Unknown-algorithm performance isn't a smear problem at all; it's a discovery problem
masquerading as one. Either way "performance is intrinsically smeared" is *false as stated*.

### A5. Decisions whose correctness is *undecidable* — a distinct hole.

None of the nine frames addresses decisions where you **cannot in principle verify the
shrapnel is correct.** Examples: "this loop now terminates for all inputs" (halting),
"these two implementations are now observably equivalent" (program equivalence, undecidable),
"this refactor preserves behavior" (the *behavior-preserving* refactors the frames
*excluded* in their first paragraph — but excluding them assumes you can *decide* they're
behavior-preserving, which in general you can't).

Why this matters to the central claim: the entire mechanical/spawned split (Frame 3) rests
on a **determinacy test** — "given the decision and program, is there exactly one correct
edit?" For an undecidable property *there is no procedure to answer the test itself.* The
machine cannot classify the site as mechanical-or-spawned, because deciding which one it is
is undecidable. Frame 3's boundary is "machine-locatable" only for decidable contracts
(types, exhaustiveness — all decidable by construction). **For semantic equivalence /
termination / general invariants, the M/S boundary is not machine-locatable, and Frame 3
silently assumes decidability of its own discriminator.** This isn't contingent-vs-intrinsic
about *smear*; it's a deeper hole: the framework's central operational test is not always
computable. That deserves a flag the frames don't give it.

*Where it fails to fully bite:* in *practice* you sidestep undecidability with conservative
approximation (the type checker rejects some safe programs to stay decidable; tests sample
inputs instead of proving ∀). So the framework survives operationally — but only by
admitting it answers a *decidable approximation* of its own test, never the test itself.
The frames should state this; they present the determinacy test as if it were total.

### A6. The "incidental duplication" trap, run in reverse — a falsifier the frames half-own.

Frame 2 §1 notes that DRY can *falsely couple* two decisions that happen to be equal today.
Push this into a falsifier: there exist decision-pairs that are **observationally identical
now but must be able to diverge later**, and the *decision to keep them separable* is
itself a single decision with **no positive locus** — it is realized as the *absence* of a
shared abstraction across N sites. You cannot localize "these N sites are independent" into
one object, because the moment you make one object you've made them dependent. This is a
decision whose faithful representation is *distribution itself* — the redundancy is the
content. The reasoning thread's equation "structure = redundancy, redundancy is reducible"
**fails here**: this is *irreducible* redundancy that carries the decision "these may
diverge." Frame 3's table ("reducible redundancy ↔ mechanical shrapnel") has no cell for
*load-bearing redundancy*. That's a genuine gap in the core analogy.

### Summary of (a)

| candidate | frames' position | red-team verdict | reason |
|---|---|---|---|
| numerical stability (A1) | local op-swap (F1-B) | **intrinsic** | global non-compositional property; inverse problem not mechanical |
| emergent global properties — fairness, deadlock-freedom, linearizability, statistical invariants (A2) | scattered as local primitives / "huge smear" | **intrinsic (the core class)** | ∀-over-executions, non-compositional; no local contract to localize into |
| Pareto postures (A3) | "possibly not localizable" | **split** — contingent iff shared-parameter-derivable | tie-break parameterizable or not |
| performance/complexity (A4) | "open, probably hard-open, no representation exists" | **mis-filed** — mostly contingent (planners/Halide exist), unknown-algo is discovery not smear | conflates known vs unknown algorithm |
| undecidable-correctness decisions (A5) | unaddressed | **breaks the M/S test itself** | determinacy test not computable; framework uses a decidable approximation silently |
| load-bearing redundancy (A6) | half-owned as "incidental duplication trap" | **intrinsic** | the distribution *is* the decision content; redundancy not reducible |

The defensible reduced claim, after the attack: **authoring smear of compositional,
decidable, structural decisions is contingent on representation (the frames prove this).
Realization smear of non-compositional global properties, and the classification of
undecidable decisions, are not — they are intrinsic, and the map currently over-claims by
filing them as merely "frontier / hard."** The fix is not to abandon the thesis but to add
the **compositionality axis** as a hard precondition: *localizable ⟹ the decision's property
decomposes into per-site contracts a determinate procedure can check/derive.* Everything
non-compositional is out of the localizable band by construction, not by current limitation.

---

## (b) Missing categories / lenses — entire classes the nine frames don't cover

I'll separate (i) missing *decision categories* (kinds of edit) from (ii) missing
*framing-axes* (whole new frames worth running).

### (i) Missing decision categories

**B1. Deletion / removal / negative decisions — "stop doing X everywhere."** The frames are
almost entirely *additive*. Frame 1 mentions "remove a variant" and "remove a parameter" as
duals of adds; Frame 4 mentions feature-flag *death* and shim removal. But the general class
— **"this behavior should no longer happen, anywhere it currently does"** — is structurally
*different* from addition and is under-treated. Why different: an addition's shrapnel is
*type-enumerable* (the compiler shows you incomplete matches). A *removal*'s shrapnel is the
set of sites that *currently depend on the thing*, which includes **silent dynamic
dependents the type system cannot see** — reflection, serialized data at rest encoding the
removed variant, external clients, log-parsers, *cached* values. "Stop accepting the legacy
auth token" is one decision whose blast radius is *outside the program entirely* and partly
*in the past* (data already written). Removal is the asymmetric, harder dual and the frames
treat it as a footnote-dual of addition. **Negative decisions also break the spawned-decision
tree model:** there's no "what does the new arm do?" slot — there's a *search for everything
that must stop*, which is a different shape (a closure over dependents, not a worklist of
fills).

**B2. Decisions in non-code substrates that ARE the behavior.** Frame 4 §D touches "decision
lives outside the code" but means *tickets/specs/contracts* — artifacts that *describe* the
decision. It misses the harder case: substrates where **the artifact is not a description of
the behavior, it is the behavior**:
- **ML model weights.** "Make the model less likely to do X" is a single decision realized
  as a diffuse change across millions of parameters via fine-tuning/RLHF. There is *no*
  localization even in principle — the decision is realized as a gradient field over the
  whole parameter space. This is A2 (non-compositional) in its purest form, and it's also
  the substrate the *editor itself* (an LLM) is made of (see (d)).
- **Prompts.** "The agent should be more cautious" — one decision, realized as scattered
  edits across a prompt whose effects are non-local and non-compositional (changing one
  clause shifts behavior on unrelated inputs). This is a *first-class decision substrate in
  this very ecosystem* (CLAUDE.md, skills) and the frames — written about this ecosystem —
  never name it.
- **Grammars / DSL definitions / parser rules.** One grammar edit changes the accepted
  language non-locally (a new production can make a previously-unambiguous grammar
  ambiguous everywhere).
- **Training data / corpora.** "The model should know about Y" = add data; the behavior
  change is emergent and unlocalizable.
- **Configuration *that is a program*** (Nix expressions, Terraform, this repo's
  `settings.json` hooks) — the frames treat config as a localizer (Frame 2 §7), but config
  *as behavior-defining substrate* is itself subject to all the same smear, recursively.

This is a whole missing *column* in Frame 4's substrate analysis: the frames assume the
behavior lives in *code* and other substrates are *descriptions/projections* of it. For ML
weights, prompts, grammars, and data, the substrate **is** the behavior and is precisely the
unlocalizable case.

**B3. Meta-level decisions — changing the build / language / tooling itself.** "Switch build
systems," "adopt a new language edition," "change the lint ruleset," "migrate the test
framework." These change behavior *of the development system*, and their shrapnel is the
*entire repo re-expressed under new rules.* The frames live one level down (decisions about
the program); they never consider decisions about the *substrate that runs the program.*
This is exactly the self-reference problem (d) in disguise, and it's a real category:
ecosystem-wide refactors (this repo's whole job per CLAUDE.md) are *meta-level* decisions
whose unit is "the propagator," and the frames' tree model has no node type for "a decision
that changes what counts as a decision."

**B4. Security / capability decisions as a distinct category.** Frame 4 §C lists "add a check
everywhere" under cross-cutting predicates and Frame 2 §9 mentions capability grants as a
localizer. But security decisions have a property no other category has: **partial
application is not just incomplete, it is a vulnerability — the *unedited* site is the
exploit.** This inverts the whole risk model. For a normal smear, missing a site = a bug you
find later. For a security smear, missing a site = the attacker finds it first. This means
the *verification* obligation (did I get *all* sites?) is categorically stronger, and the
"machine enumerates the worklist" guarantee (Frame 3's comfort) is only as trustworthy as the
machine's model is *complete* — and for security the relevant dependents are exactly the ones
type systems miss (untrusted input paths, deserialization, injection sinks). Security
decisions also have a *dual*: "**revoke** this authority everywhere" (a negative decision,
B1) where missing a site means the authority leaks. This deserves its own treatment because
its correctness criterion (*completeness over an adversarially-chosen frontier*) is unique.

**B5. Decisions about *time/migration choreography* as first-class.** Frame 2 §8 notes
schema migrations are "temporally smeared across multiple deploys" and Frame 4 §C/§D touches
shims. But the general decision **"change X in a live system without downtime"** is its own
category: it is *intrinsically* realized as a *sequence over time* (expand → migrate →
contract), and the decision cannot be a single edit *even in principle* because old and new
must coexist *by requirement*. This is a second flavor of intrinsic-non-contingency the
frames half-see: not "smeared across space" but "smeared across *time*, irreducibly, because
the requirement is continuity during change." You cannot localize "do this online" into one
edit because the *online-ness* is the property that forbids atomicity. (Frame 8 — temporal
lifecycle — may cover this; flagging since I only have its summary. If Frame 8 treats
lifecycle as "the same entity emits different edits over its life" (Frame 4 §3 does), it's
*describing* the phenomenon but not identifying *online-change* as an intrinsically-multi-step
decision class.)

### (ii) Missing framing-axes — whole new frames worth running

**B6. THE OBSERVER / VERIFICATION AXIS — the biggest missing frame, worth running.**

Every one of the nine frames maps the decision and its *forward* propagation (decision →
shrapnel → behavior). **None maps the *backward/verification* obligation: how do you know the
change is right, and complete?** This is not a minor add — it's a dual frame of equal size,
and it changes conclusions:

- The mechanical/spawned split (Frame 3) implicitly assumes "mechanical = done, no
  verification needed." False: mechanically-derived shrapnel still needs *the derivation
  procedure itself* to be trusted, and for the high-value cases (in-process→RPC, ML weights)
  there *is no* trusted derivation — you verify empirically (tests, canaries, staged
  rollout). The reason Frame 4's real diffs include CHANGELOG entries, tests, and feature
  flags is that **a huge fraction of a real edit is verification scaffolding**, which the
  forward-only frames classify as "not a decision" (Frame 4 §E) or ignore. But the decision
  *"how will I know this is correct"* is a real, often-dominant decision, and it has its own
  smear: a test for an enum-add must cover all 14 arms (the verification shrapnel mirrors the
  code shrapnel).
- A verification frame would add a third partition to Frame 3's (mechanical, spawned):
  **(mechanical, spawned, *attestation*)** — the work of producing *evidence* the decision was
  realized correctly. This maps directly onto the ecosystem's own principle "trust comes from
  verifiable evidence, not authority" — which the frames invoke nowhere despite it being in
  the CLAUDE.md they live under.
- It also subsumes A5 (undecidable correctness): the verification axis is exactly where
  undecidability lives, because verification *is* the deciding.

**This is the one new frame I'd actually run.** Provisional name for the dispatch: *"the
verification/attestation dual — for each decision class, what is the obligation to *prove* it
landed, and does *that* smear?"* I expect it to show that verification smear is often
*worse* than authoring smear and *less* contingent (you can localize the edit but the
*confidence* still has to be earned per-site), which would be a genuinely new load-bearing
claim.

**B7. The cost/economics axis — who pays, and is the localization worth it.** The frames
treat localization as an unalloyed good. Missing: **every localizer has a cost** (the
abstraction tax, the build step, the macro you now must maintain, the indirection a reader
must traverse — Frame 2 lists these per-mechanism but never aggregates them into an axis).
The *decision to localize* is itself a decision with smear, and frequently the right answer
is *don't* (Sandi Metz, which Frame 2 cites once and drops). A frame that maps "for a
decision of frequency f and shrapnel-size N, when does a localizer pay for itself" would
discipline the whole map's implicit "localize everything" bias. The reasoning-thread analogy
even predicts this: not all redundancy should be removed (some is error-correcting / aids
the reader) — the frames inherited the "redundancy = waste" framing uncritically.

**B8. The social/ownership axis — decisions that span multiple deciders.** All nine frames
model a single decider editing a single (if distributed) artifact. Missing: decisions whose
smear crosses **ownership boundaries** — a change that requires *another team* to edit *their*
code (Conway's law as a smear mechanism), a deprecation that N downstream consumers must each
act on, an API change that is "one decision" for you and "N forced decisions" for your users.
Frame 1 axis N (interface/versioning) sees the *technical* blast radius but not the *social*
one: the decision "break this API" spawns a *negotiation*, a deprecation window, a migration
guide — none of which is a code edit, all of which is the real cost. This is distinct from
B6 and is arguably where the largest real-world smears live (the frames' own ecosystem-wide
refactor protocol exists precisely because cross-repo, cross-owner smear needed special
machinery).

**B9. The *reversibility / blast-radius asymmetry* axis.** The frames treat all decisions as
symmetric (you can edit them back). Missing: decisions that are **one-way doors** —
irreversible because they've leaked into state-at-rest, into other parties' systems, into
caches, into the past (you sent the email; you migrated and dropped the old column; you
trained on the data). Frame 2 §8 notes migrations aren't truly bidirectional; this
generalizes to a whole axis: *the localizability of a decision and the reversibility of its
realization are independent properties*, and the dangerous quadrant (easy to make, impossible
to unmake) is unmapped. `git revert` (Frame 4's existence proof of decision-granular editing)
*only* works in the reversible quadrant — the frames generalize from the easy case.

### Summary of (b)

Missing categories: **deletion/negative (B1)**, **behavior-IS-the-substrate: weights/prompts/
grammars/data (B2)**, **meta-level/tooling (B3)**, **security/capability completeness (B4)**,
**online-change-over-time (B5)**. Missing axes/frames: **verification/attestation dual (B6 —
run this one)**, **localization economics (B7)**, **social/ownership/Conway (B8)**,
**reversibility/blast-radius (B9)**.

The single highest-value addition is **B6 (verification dual)** because it's a structural
gap (every frame is forward-only), it interacts with the deepest hole (A5 undecidability),
and it connects to a CLAUDE.md principle the frames inexplicably ignore.

---

## (c) Attacking the unit definition — where "one node of a decision tree" breaks

The frames' settled unit (Frame 3 §3, restated in the dispatch): *one node of the
spawned-decision tree, with shrapnel pre-derived and the next layer of spawned decisions
enumerated.* This is a **tree** model: single-rooted, children are spawned sub-decisions,
leaves are oracle-fills. Attacks:

**C1. Mutually-recursive / fixpoint decisions — no root, no tree.** Some decision sets are
*mutually constraining with no acyclic order*. Classic: the **expression problem** itself
(which Frame 1 names as an axis but doesn't notice refutes the tree model) — deciding "open vs
closed dispatch" is not a node with children; it's a decision about *which dimension of a
2-D matrix is cheap to extend*, and it co-determines decisions on *both* axes simultaneously.
More starkly: **type inference with mutually-recursive definitions**, **a set of database
tables with circular foreign keys**, **a protocol where client and server decisions
constrain each other** (you can't fix the client's retry policy without the server's
idempotency guarantee and vice versa). These form a *constraint graph with cycles*, not a
tree. The right unit is a *strongly-connected component you must solve as a fixpoint*, not a
node you fill then descend from. Frame 3's tree picture has *no representation for a cycle*,
and §4's "compound single decision" footnote ("may already be a small tree") under-states it:
it's sometimes a small *cyclic graph*, which is categorically harder — you can't isolate one
node because the nodes are not separable.

**C2. Holistic / gestalt decisions — the unit is the whole, not any part.** Some single
decisions are *irreducibly about a configuration* and decompose into parts only by losing
their content. "Make this API *feel* RESTful / idiomatic," "make this codebase *consistent*,"
"make this UI *coherent*." The decision is a predicate over the *relationships among all
sites* (consistency is literally a relation, not a property of any site). You cannot present
"one node at a time" because *every node's correct value depends on every other node's value*
— it's A2 (non-compositional) viewed from the unit angle. Frame 4's house-style example
(`normalize` wave 2) is exactly this and the frame admits "no localizing representation" —
but doesn't notice this also means **no tree-structured editing unit**, because consistency
has no root and no separable nodes.

**C3. The unit assumes the decision *precedes* its realization — but exploratory/derived
decisions invert this.** The tree model has the human (oracle) *decide*, then the machine
*derives*. But a large class of real decisions are *discovered by realizing them*: you don't
know "what should the Crypto arm do" until you *prototype* several and *see*. Here the
"oracle fills the slot" picture is backwards — the slot-fill is the *output* of an
exploratory loop (write, run, observe, revise), not an input the oracle has on hand. Frame
3's model treats the oracle as *possessing* the decision; for exploratory decisions the
oracle *manufactures* it through interaction with the running program, which is a feedback
loop the tree (a one-pass top-down structure) can't express. This connects to B6: you
*verify to decide*, not decide-then-verify.

**C4. The boundary between "spawned decision" and "new root" is undefined and load-bearing.**
Frame 3 §2.7 admits the generative end is "not one decision at all — an intent." So when does
a spawned decision become "actually a new root intent that should restart the whole process"?
The frame has no criterion. This matters because the *unit* is defined relative to "the
decision-tree of one intent," and if intents nest arbitrarily, the unit is not well-defined —
"one node" could be a whole sub-project. The frames need a *stopping criterion* (a decision is
a leaf-unit iff its shrapnel is fully mechanical and it spawns no further forced decisions)
and they gesture at it but never state it as the unit's defining boundary. Without it, "one
node of the decision tree" is not a definite quantity.

**Where the unit model survives:** for the *compositional, decidable, additive, single-owner*
core — exactly the band where smear is contingent (the (a) conclusion) — the tree model is
*correct and useful*, and Frame 3's enum-case worked example genuinely demonstrates it. The
attack is not "the unit model is wrong" but "the unit model is **the special case** of a more
general structure (a constraint graph with cycles, feedback, and indefinite nesting), and the
frames present the special case as the general one." The honest statement: **the editing unit
is a node of a tree *when the decision graph is a tree* — i.e. acyclic, separable,
forward-determined — and the frames never state that precondition.** Same shape of error as
(a): a compositional special case generalized silently.

---

## (d) Self-reference — does the framework apply to editing the decision-editor?

The framework claims to be about *any* program's decisions. The decision-editor is a program
(or, more pointedly in this ecosystem, an *LLM + harness*). Apply the framework to it:

**D1. The editor's own decisions are in the unlocalizable substrate.** The proposed editor
uses "a model-as-oracle at the leaves" (Frame 3 §4 cites the ecosystem principle). The
oracle is an LLM — i.e. **weights (B2)**. So a decision to *change how the editor decides*
("make the oracle more conservative about proposing discretionary fills") is a decision in
the maximally-unlocalizable substrate the frames never named. **The framework's own control
component is built from the one material the framework cannot localize.** This isn't a
gotcha; it's a real consequence: you cannot use the decision-editor to cleanly edit the
decision-editor's judgment, because that judgment isn't a node, it's a weight field. The
framework is **not closed under self-application.**

**D2. The framework's central test is not self-applicable.** Frame 3's determinacy test
("exactly one correct edit?") applied to the editor's *own* heuristics is undecidable (A5):
"is the model's proposed fill correct?" is the alignment/verification problem. So the editor
cannot mechanically classify its *own* outputs as mechanical-vs-spawned. It must — recursively
— invoke an oracle to check the oracle, which doesn't bottom out. The forward-only frames
have no answer because the answer is the missing verification frame (B6): self-reference
forces verification to the center, confirming B6 isn't optional.

**D3. Where self-application *works* — and it's instructive.** The *deterministic* half (the
propagation/worklist engine — binding graph, type graph, exhaustiveness) **is** cleanly
self-applicable: a decision to change the propagation engine *is* a normal compositional
code decision and the framework handles it fine. So self-reference cleanly *splits the
framework along its own seam*: the deterministic-derivation half is self-applicable (it's
ordinary code); the oracle half is not (it's weights/judgment, the unlocalizable substrate).
This is actually the framework's *own* mechanical/spawned split applied to *itself* — and it
holds, which is a point *for* the frames: the seam they drew is real enough to survive
self-application. The catch is only that **the oracle side of their own seam lands in the
category they forgot to map (B2).** The map is correct about where its own boundary is; it
just didn't draw the territory on the far side of that boundary.

---

## Where my attacks failed (the claim survives)

Stated plainly so this isn't all demolition:

1. **The contingency claim survives, fully, for its proper domain:** compositional,
   decidable, structural, additive, single-owner decisions. The frames *prove* this and I
   could not falsify a single instance in that band. Rename, enum-add, signature-change,
   schema-migration-to-typed-models, async-coloring — all genuinely contingent. The thesis
   is *true and important* there.

2. **The mechanical/spawned split is real** and Frame 3's claim that the *boundary* is
   machine-locatable holds **for decidable contracts** — which is most of day-to-day typed
   editing. My A5 attack restricts but doesn't destroy it.

3. **Self-application along the deterministic seam works (D3)** — the framework's own
   structure survives being turned on itself, on the half that's ordinary code.

4. **Performance is *not* the slam-dunk unlocalizable case the frames feared (A4)** — this is
   an attack on the frames' *pessimism*; query planners and Halide are existence proofs that
   the thesis reaches *further* than Frame 2 conceded. So one "falsifier" actually
   *strengthens* the central claim.

The surviving core is narrower and sharper than stated: **smear is contingent exactly when
the decision's property is compositional and its correctness decidable; it is intrinsic when
the property is a non-compositional global/emergent invariant, or when realization is
irreducibly spread across *time* (online change) or *other parties* (social), or lives in a
behavior-IS-the-substrate medium (weights/prompts/data).** The map's error is not falsity but
**unstated preconditions** (compositionality, decidability, acyclicity, single-ownership,
reversibility) that quietly bound every strong claim it makes.

---

## The two structural fixes the map needs

1. **Add the compositionality precondition as the master discriminator.** Rewrite the
   localizability claim as: *a decision is localizable ⟹ its defining property decomposes
   into per-site contracts checkable/derivable by a determinate (decidable) procedure.* This
   single addition correctly ejects A1/A2/A6 from the localizable band by construction, splits
   A3 on the right criterion, and re-files A4. It also subsumes Frame 2's frontier list under
   one principle instead of eight ad-hoc entries.

2. **Run the verification/attestation dual as Frame 11 (or 10b).** Every existing frame is
   forward-only (decision → shrapnel → behavior). The backward obligation (how is correctness
   *established*, and does *that* smear / localize?) is a frame-sized gap that (a) interacts
   with the undecidability hole, (b) reclassifies Frame 4's "non-decision" scaffolding (tests,
   flags, canaries) as load-bearing decision content, (c) is forced to the center by
   self-reference (d), and (d) connects to the ecosystem's own "trust from verifiable
   evidence" principle the frames never used.
