# Frame 7 — Decision Entropy: mapping the space by the *bits* in a change

> Context: a program is a structure of *decisions*; text smears one decision
> across many edits; the right unit of editing is the *decision*. The deeper
> thread: intelligence ≈ decision-content per resource; "flat compute over
> non-flat structure" is the disease; entropy is representation-relative;
> reducible redundancy (abstraction removes it) vs irreducible decision-content
> (only an oracle supplies it).
>
> This frame charts the space of single-decision behavior changes by the
> **information content of the decision** — how many bits the oracle must
> actually supply. Prior frames mapped *structure* (1), *localizing
> representations* (2), *mechanical-shrapnel vs spawned-decisions* (3), and
> *empirical diffs* (4). This one runs the **information lens** through all of
> them and asks what *quantity* sits under the qualitative split, and whether
> that quantity predicts mechanizability.

---

## 0. Three "bits" that must not be conflated

The whole frame rests on keeping three distinct notions of "information"
separate. Conflating them is the standard way this kind of argument goes wrong,
so I pin them first and use them precisely throughout.

1. **Shannon entropy** — `H(X) = −Σ p(x) log p(x)`. Defined over a *distribution*.
   It is the expected surprise of a draw from a known source. It needs a *model*
   `p`. It says nothing about any single object; it is a property of the ensemble
   and the model. *Representation-relative by construction* — change the code and
   you change `H`.

2. **Kolmogorov complexity** — `K(x)` = length of the shortest program (on a
   fixed universal machine) that outputs `x`. Defined over a *single object*. It
   needs no distribution. It is *uncomputable* and only defined up to an additive
   constant (the choice of machine). It is the formalization of "irreducible
   description length."

3. **Decision-bits** — the quantity *this thread actually cares about*: the
   information the oracle must inject to fix a choice that the program-so-far
   leaves open, *measured relative to a given derivation engine*. This is
   **conditional**: it is the surprise of the decision *given everything the
   machine can already derive*. Formally closest to a conditional complexity
   `K(decision | program, engine)` — the bits not already implied by the existing
   structure under the engine's deductive power.

The relationship I will defend:

> **Decision-bits = the conditional, engine-relative quantity. Shannon is its
> tractable *estimator* (you need a distribution/model to put a number on it).
> Kolmogorov is its *idealized ceiling* (the bits no engine of any power can
> derive, only because they are genuinely arbitrary).** Frame 3's "spawned
> decision content" is decision-bits > 0; Frame 3's "mechanical shrapnel" is
> decision-bits = 0.

The single most important property, inherited from the reasoning thread:
**decision-bits are relative to the engine, exactly as Shannon `H` is relative
to the model `p`.** A richer engine (binding graph → type graph → spec) derives
more, so fewer bits remain irreducible. This is the *same* relativity the
thread named for entropy ("entropy is representation-relative"), now applied to
edits. I lean on it constantly below; flagging it once here as the load-bearing
assumption.

---

## 1. The entropy bands

Ordered by **bits the oracle must supply per decision**, from a single bit to
unbounded. For each band: the bit-count, a canonical edit, and (deferred to §2)
its mechanizability profile.

```
BITS supplied by oracle (engine-relative)
│
│  1 bit ───────────── choice-among-N ───── parametric ───── structural ───── open-ended
│  (Bernoulli)         (log₂ N bits)        (a real number)   (add a case)     (Kolmogorov-
│                                                                                irreducible)
│
├─ BAND 0: zero-bit        — not a decision at all; pure shrapnel. (the M of Frame 3)
├─ BAND 1: one-bit toggle  — flip a boolean policy
├─ BAND 2: choice-among-N  — pick a strategy from a known finite set (log₂N bits)
├─ BAND 3: parametric      — supply a number / threshold (bits = precision needed)
├─ BAND 4: structural      — add a case/field/variant (bits ≈ name + a small choice)
└─ BAND 5: open-ended      — invent an algorithm / decompose an intent (unbounded K)
```

### BAND 0 — zero-bit "decisions" (the degenerate floor)

Not a decision at all. Rename propagation, threading a value already in scope,
applying a chosen default to N call sites, dead-code cleanup. **Decision-bits =
0** by definition: the edit is a *function* of (decision-already-made, program).
This is precisely Frame 3's mechanical shrapnel. It earns a band only to anchor
the zero point: the spectrum *starts* at zero, and an enormous fraction of text
edits live exactly here. (Frame 4's "dependency bump → `bun.lock`" 4 lines, the
N−1 rename sites — all band 0.)

### BAND 1 — one-bit toggles (Bernoulli decisions)

Flip a boolean policy. `verbose=false → true`. `retry_on_timeout: on/off`.
`strict_mode`. Choose `floor` vs `ceil` *when the choice is binary*. The oracle
supplies **exactly 1 bit** (≤ 1, weighted by prior — if the codebase strongly
conventions one way, the *surprise* is < 1 bit; see §3 on priors).

Canonical: any feature flag's *default*. The decision content is a single bit;
everything downstream (wiring the flag through, gating the branches) is band-0
shrapnel.

### BAND 2 — choice-among-N (log₂N bits)

Pick from a *known, enumerable* set. Choose a hash algorithm from
{sha256, blake3, …}; pick an eviction policy from {LRU, LFU, FIFO}; select which
of 4 existing payment gateways to route to. If the set has N equiprobable
members the oracle supplies **log₂N bits**. Crucially: *the set is known to the
engine*. The engine can enumerate the options (they're types/variants/registered
strategies already in the program); the oracle only supplies the *selector*.

This is the band where "the machine proposes, the human picks" is exactly
right — the machine can present the N options because they already exist; the
human contributes only the choice index.

### BAND 3 — parametric (bits = required precision)

Supply a *number*: a threshold, a timeout, a buffer size, a learning rate, a
tax rate. Real-valued, so in principle unbounded bits — but **the bits that
matter are the bits of precision the behavior is sensitive to.** A timeout
"around 30s, ±5s tolerable" carries ~3 useful bits, not 64. A cryptographic
constant carries all its bits. **Decision-bits here = the entropy of the
*behaviorally-distinguishable* values**, which is usually small and bounded by
how coarsely the system responds. This band is where "a number" hides a wide
spread of actual information content depending on sensitivity.

A sharp sub-point: a parameter chosen by *tuning against a metric* (grid search,
gradient) has its bits supplied by **the data/objective, not a human oracle** —
which means it is *mechanizable given the objective* and collapses toward band
0. The bits don't vanish; their *source* moves from oracle to measurement. (Ties
to the thread: "validate against reality" — reality supplies bits an oracle
otherwise would.)

### BAND 4 — structural (a name + a small choice)

Add an enum case, a struct field, an interface method. Frame 3's headline. The
*structural act* (the variant exists) is low-bit — it's a **name** (a few bits,
or near-zero if the name is conventionally forced like `Crypto` after `Card`,
`Cash`) plus the decision *to add it at all* (~1 bit: add / don't). But — and
this is the crux the information lens sharpens — **adding the case does not, by
itself, carry the bits of what each match arm does.** Those are *separate*
decisions in bands 1–5, *spawned* by the structural act. The structural edit is
a low-entropy act that **opens N new slots**, each of which is its own
entropy-bearing decision.

So "add a case" is genuinely small in bits *as one decision* — and Frame 3 was
right that it's the *worklist* (the N spawned arms) that carries the content,
not the declaration. The information lens says: the declaration is ~band-1, the
spawned arms are independently distributed across bands 1–5.

### BAND 5 — open-ended / Kolmogorov-irreducible (unbounded bits)

Invent a new algorithm; design a new data model; decompose an intent ("make it
undoable", "support OAuth") into a tree of decisions. **No finite known set to
pick from; the oracle is *producing structure*, not selecting it.** The bits are
bounded only by `K` of the artifact produced — genuinely unbounded, and
genuinely irreducible: no derivation engine can supply them *because there is
nothing in the program that implies them*. This is where `K(decision | program)`
≈ `K(decision)` — the program-so-far gives almost no head start. This band is
the **irreducible core of programming** (§5).

A clean discriminator separates band 4 from band 5: **band 4 selects within an
existing structure the engine knows; band 5 produces structure the engine
cannot enumerate.** "Pick LRU vs LFU" (band 2) vs "design the eviction policy
that this workload actually needs" (band 5) — the latter is open-ended because
the *space of policies* is not pre-enumerated. The boundary between "choice
among N" and "open-ended" is exactly the boundary between a **known finite
distribution** (Shannon applies, bits = log N) and an **open object space**
(only Kolmogorov applies, bits unbounded).

---

## 2. The entropy → mechanizability law

The bands above line up with mechanizability *monotonically*, and the reason is
forced by the definition of decision-bits. Stated as a law:

> **A decision is mechanizable iff its engine-relative decision-bits = 0. The
> degree to which it *needs* an oracle is exactly its decision-bit count. The
> bits an engine cannot derive are precisely the bits an oracle must supply —
> they are the *same bits*, viewed from the two sides of the M/S boundary.**

This is not an empirical correlation; it is close to definitional, which is why
it's a *law* and not a *trend*:

- **Mechanizable** ≡ the edit is a deterministic function of (decision, program)
  ≡ it adds no information given the program ≡ `K(edit | program, engine) = 0`
  ≡ **0 decision-bits.** (Band 0.)
- **Needs an oracle** ≡ multiple program-consistent completions with no basis to
  choose ≡ the edit injects information ≡ `K(edit | program, engine) > 0`
  ≡ **> 0 decision-bits.** (Bands 1–5.)

The *bit count* then grades the oracle's job within "needs an oracle":

| Band | oracle bits | can a machine *derive* it? | what the machine *can* still do |
|---|---|---|---|
| 0 zero | 0 | **Yes — fully.** | derive and apply the edit |
| 1 toggle | ~1 | No (only 1 bit, but it's a real bit) | propose default; present the flip |
| 2 choice-N | log₂N | No — but the *option set* is derivable | **enumerate the N options**; human picks |
| 3 parametric | precision-bounded | No — unless an *objective* supplies it | enumerate sensitivity; auto-tune if metric exists |
| 4 structural | name + ~1, **but spawns more** | The *act* no; the *worklist* yes | derive the slot-worklist; enumerate spawned decisions |
| 5 open-ended | unbounded (~`K`) | **No, in principle.** | decompose/elicit; cannot supply the bits |

Two consequences the law makes crisp:

**(a) The machine always owns "where", even when it can't own "what".** Across
*every* band > 0, *locating* the decision sites is a band-0 (zero-bit)
operation — exhaustiveness checking, type holes, unfilled-slot detection.
"Where are the decisions?" is mechanical even when "what are they?" is not. This
is Frame 3's key asymmetry, and the information lens explains *why*: the
*existence and location* of an unfilled slot is implied by the structure (zero
new bits), while the slot's *contents* are not (the bits themselves). Location
is derivable; content is the entropy.

**(b) Mechanizability degrades smoothly, but with a phase transition at band 5.**
Bands 1–4 are "oracle supplies bits *into a slot the engine defined*" — the
engine frames the question, the oracle answers it, and the answer re-enters the
engine which derives its band-0 consequences. Band 5 is different in *kind*: the
oracle must *produce the slots themselves* (the structure), because the option
space is open. The information signature of the transition: bands 1–4 have a
*known support* (the engine can write down the set of possible answers — a flag's
two values, N strategies, a numeric range, the finite set of well-typed slot
fillers), so **Shannon entropy is defined and finite**. Band 5 has *no known
support* — the answer is an object from an open space — so **only Kolmogorov
applies and the bit count is unbounded.** The Shannon→Kolmogorov boundary *is*
the select-vs-produce boundary *is* the propagation-vs-elicitation boundary
(Frame 3 §2.7).

This gives a falsifiable-ish prediction about tooling: **everything with a known
finite support should eventually be machine-*enumerable* (the machine presents
the options), leaving the human only the selector bits; only band 5 resists even
enumeration.** Current refactoring tools already prove the band-0 end
(rename/extract). The open frontier is bands 2–4 *enumeration* (machine presents
the worklist of options/slots) — which is *less* than synthesis and therefore
plausibly reachable — and band 5 stays oracle-only.

---

## 3. Shannon vs Kolmogorov vs decision-bits — being rigorous

I want to be careful here because it's the part most prone to hand-waving.

**Why decision-bits are conditional and engine-relative (not raw Kolmogorov).**
The thread's "entropy is representation-relative" is the anchor. Raw `K(edit)`
overcounts: the edit text includes the rename shrapnel, the boilerplate, the
forced `):`. The quantity we want strips everything the engine derives — i.e.
`K(edit | program, engine)`. As the engine gets stronger (text → AST → types →
spec → learned-convention-model), the conditioning set grows and the conditional
complexity *drops*. This is exactly Shannon's `H(X | Y)` shrinking as `Y`
explains more of `X`. **So decision-bits behave like a conditional entropy whose
conditioning context is "whatever the engine can derive."**

**Where Shannon is the right tool.** When the decision has a *known support with
a distribution* — bands 1–3 and the "select" part of 4 — decision-bits are
genuinely a Shannon quantity: `H` of the answer under the engine's prior. And the
*prior matters*: a boolean flag where the codebase conventions 95/5 carries
`H ≈ 0.29` bits, not 1. Convention reduces entropy without making the decision
mechanical — this is the "discretionary-but-suggestible" gray zone of Frame 3,
now *quantified*: a high-confidence convention is a low-entropy (but nonzero)
decision, which is exactly why a model-as-oracle can *propose* it (it's predicting
a low-`H` draw) while a human still *confirms* (the residual bits are real). The
model earns its keep precisely in the **low-but-nonzero-entropy** band.

**Where only Kolmogorov applies.** Band 5: there is no distribution because there
is no enumerable support — "invent the algorithm" draws from an open object
space. You cannot write `p(x)` over all algorithms in any way that isn't itself a
universal prior (Solomonoff), at which point you're doing Kolmogorov anyway. So
band 5's bits are `K`-flavored: a single object's irreducible description length,
uncomputable, unbounded. **This is why band 5 is categorically the hard core:
not "high Shannon entropy" (that would just mean a big known menu) but "no finite
model can even frame the question as a draw."**

**The honest caveat — none of these are operationally measured.** `K` is
uncomputable; Shannon `H` needs a `p` we rarely have for code edits; "engine"
ranges over a poset of derivation powers we haven't formalized. So decision-bits
is, today, a **conceptual ruler, not a meter.** Its *value* is in the ordering
and the predictions (the law of §2, the phase transition, the convention-as-
low-`H` claim), not in numeric measurement. I'd flag any attempt to put a precise
bit-number on a real decision as unsupported. The bands are robust; the
within-band numbers are illustrative. (One *partially* operational handle: an
LLM's token-level log-probs over a candidate edit are a concrete, if model-
relative, estimator of conditional surprise — `−log p(edit | context)` — which is
the closest thing to a measurable decision-bit proxy. It inherits the model's
priors, i.e. it measures bits *relative to that model as the engine*, exactly per
the relativity above.)

---

## 4. Smear vs bits — correlated or orthogonal? (testing Frame 3's claim)

Frame 3 asserted, qualitatively, that *effort/size and decision-content are
orthogonal*: "threading a type through 40 call sites is large but mechanical;
deciding what one match arm returns is small but spawned." The information lens
lets me **sharpen this from 'orthogonal' to a precise structural statement**, and
the sharpened version is *more* than mere orthogonality.

Define two quantities for a change:
- **Smear `N`** = number of text sites the change touches.
- **Bits `B`** = total decision-bits the oracle must supply for the change.

**Claim: `N` and `B` are not just statistically uncorrelated — they are
*generated by different mechanisms*, and the cross-product spans all four
quadrants with real inhabitants.** That is stronger than "orthogonal" (which only
denies correlation); it's a *mechanism independence*.

| | low bits `B` | high bits `B` |
|---|---|---|
| **low smear `N`** | off-by-one fix (1 site, ~0 bits) | "invent the core algorithm" in one function (1 site, ~unbounded bits) |
| **high smear `N`** | rename / thread-a-type (40 sites, 0 bits) | "split User into User+Account" (40 sites, dense per-site bits) |

All four cells are populated, which *is* the empirical demonstration of
independence. The off-diagonal cells (low-N/high-B and high-N/low-B) are the
ones that *refute correlation*: the rename is the cleanest high-smear/zero-bit
case (the entire `N` is band-0 shrapnel), and the one-function algorithm rewrite
is the cleanest low-smear/unbounded-bit case (band 5 in a single site).

**But the lens reveals a *partial* coupling that 'orthogonal' would miss, and
this is the sharpening.** Smear and bits are generated by different mechanisms,
but those mechanisms share an input:

- **`N` (smear) is generated by `(decision, representation)`** — how badly the
  current representation *scatters* the consequences of the decision. Pure
  representation pathology; **independent of the decision's bits.** A 0-bit
  decision (rename) can have `N=200` purely because the representation lacks a
  localizing binding.
- **`B` (bits) is generated by `(decision, engine)`** — how much the decision
  *adds* that the engine can't derive. Independent of how many *sites* it lands
  on.

So they are orthogonal **in their primary inputs** (representation-scatter vs
information-addition). The subtle coupling: a *band-4/5 structural decision opens
slots, and the number of slots is both a smear contributor and a bit-multiplier*
— adding `Crypto` to an enum touched by 14 matches generates `N ≥ 14` *and*
spawns up-to-14 independent bit-bearing arm-decisions. Here the *same structural
fact* (14 match sites) drives both `N` and a *bound on* the spawned `B`.

The resolution that keeps Frame 3 honest: **`N` correlates with the *number of
spawned decision-slots*, not with the *bits in each*.** The structure determines
*how many* slots (and that's also the smear); the engine-irreducible content
determines *how many bits per slot* (and that's the real `B`, orthogonal to `N`).
So:

> **Smear (`N`) ⟂ bits-per-decision; but smear `N` is *correlated* with the
> count of spawned decisions, because both are projections of the same
> branching structure.** Frame 3's "orthogonal" is correct for the quantity it
> meant (effort vs content-per-decision) and the information lens upgrades it to:
> *N measures the structure's fan-out (a representation+structure fact); B
> measures the irreducible content (an engine fact); they share the fan-out only
> insofar as more slots means more places to potentially inject bits — but each
> slot's bits remain independent of N.*

The practical upshot is the same conclusion both frames reach from different
directions: **measuring a change by `N` (what text/diff-size does) mismeasures
it, because `N` is dominated by representation-scatter and slot-count, while the
thing you care about — the oracle's actual work — is `B`, the irreducible
bits.** Text bills you for `N`; the decision costs `B`; the gap between them is
the entire waste.

---

## 5. Where the high-entropy decisions live — the irreducible core

Collecting the bands by their `B`, the genuinely high-entropy decisions —
band 5, and the high-precision tail of band 3 — are concentrated in a small,
recognizable set of acts:

1. **Algorithm/representation invention** — choosing the data structure, the
   algorithm, the encoding that *is not implied* by the requirements. (`K`-bits;
   the program-so-far gives no head start.)
2. **Intent decomposition / architecture** — turning "support OAuth", "make it
   undoable", "make it real-time" into a *tree* of decisions. The bits are in
   *which decomposition*, and the space of decompositions is open.
3. **Domain-modeling choices** — what the types *mean*, where the boundaries are,
   what's the same vs different. (Splitting `User`/`Account`: the bits are in the
   *carving*, which no engine can derive because it encodes a fact about the
   world, not the program.)
4. **The high-precision parametric tail** — cryptographic constants, numerically
   sensitive thresholds where every bit of precision is behaviorally load-bearing
   *and* not derivable from an objective.

These four are **exactly the spawned-decision content of the reasoning thread,
seen through the bit-counter**: they are the bits that *no representation
removes* (representation changes `N`, not `B`) and that *only an oracle supplies*
(human, or LLM-at-the-leaves, never the control loop). And the connection closes
cleanly:

> **A decision's irreducible bits = its spawned-decision content (Frame 3) =
> the conditional-Kolmogorov surprise relative to the engine (Frame 7) = exactly
> what abstraction cannot factor out and only an oracle provides (the reasoning
> thread).** Mechanical shrapnel = decision-bits 0 = zero-new-information
> propagation = the reducible redundancy abstraction removes. The three frames
> are one partition counted three ways: by *origin* (mechanical vs spawned), by
> *representation* (localizable vs not), and by *information* (0 bits vs > 0 bits).**

**Are the high-entropy decisions the irreducible core of programming? Yes — with
one sharpening.** The irreducible core is *not* "the hard-to-type parts" or "the
big diffs" (those are `N`, smear, the wrong ruler). It is the **band-5 / high-`B`
decisions: the bits the program-so-far doesn't imply.** Everything else — all of
band 0, the propagation in 1–4, the located worklists — is *in principle*
machinable, because it adds no information. Programming's irreducible labor is
the injection of the bits the world requires but the existing structure cannot
derive. That injection is small in count and unbounded in content; it is where
the human (or oracle) is doing the only thing that *cannot* be a deterministic
function of what's already written.

This is the editing-time restatement of the thread's deepest claim —
**intelligence ≈ decision-content per resource.** The high-`B` decisions are
maximal decision-content; the disease ("flat compute over non-flat structure")
is spending equal resource — equal compute, equal keystrokes, equal model
forward-passes — on a 0-bit `):` and an unbounded-bit algorithm choice. The
cure, in every frame, is the same: **route resource to where the bits are.** This
frame's contribution is the ruler that says *where the bits are* — and the law
that the bit-count is, definitionally, the boundary between what a machine
finishes alone and what an oracle must touch.

---

## 6. Open uncertainties (flagged, not resolved)

- **The "engine poset" is informal.** I treat "engine = text < AST < types < spec
  < learned-convention-model" as a lattice of derivation powers, but I haven't
  defined it rigorously. Decision-bits being *relative to* a point in this poset
  is the whole conditional story; formalizing the poset is open work.
- **No operational meter.** `K` uncomputable, `H` needs an unavailable `p`. The
  bands and ordering are robust; numeric bit-values are illustrative. The LLM
  log-prob estimator (§3) is the only concrete handle and it's model-relative.
- **Band 3's "behaviorally-distinguishable precision" is fuzzy.** It depends on a
  sensitivity analysis of the program that is itself often undecidable. The claim
  "bits = useful precision" is directionally right but not always computable.
- **The convention-lowers-entropy claim (§3) assumes the engine *has* a
  convention model.** Without one, a 95/5 flag is still 1 full bit to that
  engine. This is just the relativity again, but it means "low-entropy
  suggestible decision" is a statement about a *specific* engine's prior, not an
  absolute property of the decision.
- **Whether band 5 is *truly* irreducible or just irreducible-to-current-engines**
  is the deepest open question, and it's the same question as "is there a ceiling
  to how much intent a representation can capture." If a sufficiently rich spec
  could derive a band-5 decision, it would collapse to band 0 — but then *the
  spec itself* carries the bits, and writing the spec is the band-5 act. The bits
  are conserved; they move to wherever the irreducible authoring happens. I
  believe (but have not proven) that **bit-conservation under representation
  change** is the right invariant: representation moves bits between artifacts and
  drives `N`→0, but cannot reduce total `B` below the world's actual demand.
```
