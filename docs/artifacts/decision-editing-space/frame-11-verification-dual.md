# Frame 11 — The Verification / Attestation Dual

> Context: a program is a structure of *decisions*; text smears one decision across many
> edits; the right editing unit is the *decision*. The first ten frames are all **forward**:
> decision → mechanical shrapnel + spawned decisions → behavior. This frame runs the lens
> **backward**: once a decision is made and realized, what artifact *establishes that it is
> correct*, and does that artifact **smear** the same way, differently, or not at all?
>
> Frame 10 (adversarial) nominated this as the single highest-value missing lens, on three
> grounds: (i) every prior frame is forward-only; (ii) verification is exactly where the
> undecidability hole (Frame 10 §A5) lives; (iii) it connects to a CLAUDE.md principle the
> frames never invoked — *"trust comes from verifiable evidence, not authority."* This frame
> tests whether that nomination pays off.

The claim I will defend: **verification is not separate from the decision — it is the
decision's other half.** A decision-content is "the information the oracle injects that the
program-so-far does not force" (Frame 3/7). But an injected bit is worthless until someone can
*tell whether it was the right bit*. The forward frames count the bit; this frame asks what it
costs to **attest** the bit. And the central finding is that **attestation-smear tracks
compositionality even more tightly than implementation-smear does** — because a verification
artifact, unlike an implementation, cannot be "given a home" by a representation that merely
*relocates* the smear: a test that doesn't actually exercise the distributed behavior is not a
relocated verification, it is a *false* one. Implementation-smear can be hidden inside an
abstraction; verification-smear cannot be hidden without becoming a lie.

---

## 0. The dual quantity, stated sharp

The established spine has one quantity: **outcome-forced-by-program (mechanical, 0 decision-bits)
vs new-info-from-oracle (spawned, all the decision-bits)**, counted by Frames 3/7/9.

The backward dual is a second quantity, orthogonal to the first:

> **Attestation cost** — the information a *verifier* must inject to establish that the
> realized behavior matches the intended decision, *measured relative to a given checking
> engine.*

This is precisely the forward quantity with the arrow reversed. Forward: oracle injects bits
the program doesn't force. Backward: verifier extracts evidence that the injected bits were
correct. And the two are **not symmetric** — this asymmetry is the whole content of the frame:

- A **mechanical** edit (0 forward decision-bits) is *not* 0 attestation-bits. Its derivation
  procedure must itself be trusted. If the procedure is a type checker, attestation is ~free
  (the derivation *is* the proof — see §3 below). If the procedure is "a codemod the model
  wrote," the attestation cost is *the full cost of checking the codemod was sound* — which can
  exceed the cost of the original decision. **Mechanical-forward does not imply mechanical-backward.**
- A **spawned** decision (high forward decision-bits) has attestation cost ranging from near-zero
  (a discretionary choice with no correctness criterion — "name this `cache` vs `store`": one
  decision-bit, zero attestation-bits because there is nothing to be *wrong* about) to unbounded
  (an emergent global invariant — full decision-bit, full attestation-bit, and the attestation
  doesn't decompose).

So the (mechanical, spawned) partition of Frame 3 acquires a **third axis**, exactly as Frame
10 §B6 predicted: every edit has a forward profile *and* a backward profile, and the backward
profile is what Frame 4 §E dismissed as "non-decision scaffolding."

---

## 1. The decision → verification-artifact map

For each decision class on the established map, what artifact establishes correctness, and how
does that artifact smear relative to the implementation? `1→1` means one verification unit per
decision (verification-stationary). `1→N` means the verification shrapnel mirrors the code
shrapnel. `1→∅` means *no local artifact can establish it* — verification is intrinsically
non-local.

| Decision class (from prior frames) | Verification artifact | Impl smear | Verification smear | Tracks compositionality? |
|---|---|---|---|---|
| Point fix (off-by-one, inverted cond) | one unit test / one assertion | ~nil (1→1) | ~nil (1→1) | trivially yes |
| Rename | the type checker / compiler (rename is mechanical) | 1→N call sites | **1→1** — derivation *is* the proof; if it compiles, it's correct | yes — rename is compositional, verification collapses |
| Enum-case add | exhaustiveness checker | 1→N arms | **1→1** for *reachability* (compiler finds all arms); **1→N** for *what each arm does* (each new arm's behavior needs its own test) | yes — the compositional part (coverage) is 1→1, the non-compositional part (semantics) is 1→N |
| Signature change | type checker + per-call-site behavior tests | 1→N | 1→1 (shape) + 1→N (semantics at sites that now pass new arg) | yes |
| Schema / data-model change | migration test + serializer roundtrip + every consumer's null-handling test | 1→N across substrates | **1→N across the same substrates** — verification *re-smears in lockstep* with the impl | yes |
| Cross-cutting predicate (security check everywhere) | "no unguarded site" — a **completeness** property over the whole codebase | 1→N | **1→∅** — no local test proves "I got *all* sites"; needs a global proof (taint analysis, choke-point architecture, or exhaustive enumeration) | **yes, and this is the sharpest case** — the property is non-compositional (∀-over-sites), so no local artifact attests it |
| House-style / consistency | reviewer judgment / linter (if mechanizable) | maximal | **1→∅** for semantic style — consistency is a *relation among sites*, not a property of any site; no local test | yes — non-compositional, no local verifier |
| Numerical stability (Frame 10 A1) | property test over input range + comparison to high-precision oracle | intrinsic (1→∅) | **1→∅** — correctness is a ∀-over-inputs bound; no site-local assertion captures it; you verify the *ensemble* | yes — non-compositional global property, attestation is global by construction |
| Emergent invariant: deadlock-freedom, linearizability, fairness (Frame 10 A2) | model checker / formal proof / Jepsen-style adversarial trace exploration | intrinsic (1→∅) | **1→∅ AND the verifier is its own research artifact** | yes — the purest case |
| Performance (known algorithm) | benchmark + regression guard | contingent (1→1 via planner) | **1→1** — one benchmark attests the asymptotic decision | yes |
| ML weights / prompt (Frame 10 B2) | eval suite / canary / staged rollout / red-team | intrinsic (1→∅) | **1→∅, empirical only** — no static artifact; you can *only* attest by running in production and measuring the distribution | yes — non-compositional, behavior-IS-substrate |
| Online migration (Frame 10 B5) | canary + dual-read consistency check across the deploy sequence | intrinsic, temporal | **temporal: 1→sequence** — attestation is itself spread over time (must verify old+new coexist correctly at each phase) | tracks *temporal* non-compositionality |
| Removal / negative decision (Frame 10 B1) | "nothing depends on this anymore" — a closure over *all* dependents incl. data-at-rest, external clients | intrinsic, asymmetric | **1→∅, and partly unverifiable** — you cannot test the absence of a dependent you don't know exists | yes — completeness-over-an-open-frontier, the verification-dual of B1 |

Reading the table top to bottom: **the verification-smear column is a near-perfect copy of an
implementation-smear column that has been pushed one notch *more pessimistic*.** Where the impl
is 1→1, verification is 1→1 (point fix) *or* the impl is 1→N but a checker makes verification
1→1 (rename, performance). Where the impl is 1→N, verification is 1→N (schema) *or worse*, 1→∅
(security: the impl is N edits but the *verification* — completeness — is non-local). Where the
impl is 1→∅, verification is *always* 1→∅. **There is no cell where verification is more
localizable than implementation.** That monotonicity is the frame's first hard claim.

---

## 2. Does verification-smear track compositionality more tightly than implementation-smear?

**Yes, and the mechanism is precise.** Frame 10 established compositionality as the master
localizability discriminator: a decision is implementation-localizable iff its defining property
decomposes into per-site contracts a determinate procedure can check/derive. The verification
dual sharpens this because **implementation has an escape that verification does not.**

The implementation escape (Frame 10 §A2, "where my attack partially fails"): a non-compositional
global property *can* be given a local home by adopting a construction that makes it **true by
construction** rather than checked — a session-typed protocol, a deterministic-scheduler DSL, a
verified-arithmetic library. This relocates the implementation smear into the substrate.

But notice what "true by construction" *is*: it is **moving the verification into the type
system / the construction's proof**. The escape does not eliminate verification-smear — it
*converts* it. The deadlock-freedom that was 1→∅ to test becomes 1→1 to verify *because the
session-type discipline carries the proof*. So:

> **The implementation "escape" from non-compositional smear is identically the move that makes
> verification stationary.** They are the same act seen from two directions. You cannot localize
> the implementation of a global property without also localizing its verification, because the
> only way to localize the implementation *is* to make the property structural — i.e.,
> machine-checkable at one locus.

This is why verification-smear tracks compositionality *more* tightly: implementation-smear has
two states for a non-compositional property (smeared-and-checked, or structural-and-proven), but
verification-smear has only one degree of freedom — it is 1→∅ **unless and until** the property
is made structural, at which point both collapse together. The verification column is the
*ground truth* of the compositionality classification; the implementation column can lie about
it (you can write N scattered edits that *look* like they handle a global property and pass a
test suite that doesn't actually exercise the global interleaving — the Jepsen literature is a
graveyard of exactly this). **Verification-smear cannot be faked by a leaky abstraction. That is
its diagnostic value.**

Concretely, the falsifier that distinguishes the two columns: take any "localizing
representation" proposed by Frame 2 and ask *"does it make the verification one unit too?"* If
yes, it is a real localizer (rename: yes — the compiler proves it; DI container: yes — wiring is
type-checked). If no — if the representation collapses the *edit* to one gesture but the
*confidence* still has to be earned per-site — it is a **pseudo-localizer** that relocated the
edit-smear into verification-smear. A codemod is the canonical pseudo-localizer: it makes the
edit one command, but you must now review N output sites to trust it, because the codemod's
soundness is not itself proven (it is text-pattern, not type-derived). **The codemod moved the
smear from your fingers to your eyes.** This is a genuinely new discriminator the forward frames
could not produce, because it requires looking at the backward obligation.

---

## 3. The verification-stationary representations (and the one that is a gradient, not a unit)

A representation is **verification-stationary** for a decision class iff establishing the
decision's correctness is itself *one unit* — one artifact, checked once, that derives the
confidence the way a mechanical shrapnel-deriver derives the edits. These exist, and they are
exactly the cases where the forward escape (§2) is available. Grounded inventory:

1. **Types-as-proofs (Curry–Howard, the strongest case).** A type *is* a proposition; a
   well-typed program *is* its proof; the type checker *is* the verifier, run once, total. For
   any decision expressible as a typing obligation — rename, signature, exhaustiveness, "this
   value is non-null here," "this resource is used linearly," "this state transition is legal"
   (typestate / session types) — verification is 1→1 and *mechanical*: the same derivation that
   produces the shrapnel produces the proof. This is the verification dual of Frame 3's "the
   boundary is machine-locatable for decidable contracts." Types are decidable-by-construction,
   so the type checker is the cheapest verifier in existence: attestation cost ≈ 0. **This is
   why the ecosystem's "library-first; projection-from-one-definition" principle is also a
   verification principle: a projection from one typed definition inherits the definition's proof
   — you verify the source once, not each projected surface.**

2. **Property-based testing (the verification dual of "decompose the input space, not the
   sites").** A property `∀x. P(impl(x))` is *one artifact* that attests behavior over an entire
   input distribution. This is verification-stationary along the **input axis** even when the
   implementation is smeared along the *site* axis — which is exactly the right shape for the
   non-compositional-over-inputs classes (numerical stability, statistical invariants, "the
   parser roundtrips"). One property + a shrinking generator replaces N hand-picked example
   tests. Crucially, property-based testing **does not localize site-smear** (it still runs the
   whole distributed machine) — it localizes the *specification of correctness* into one
   quantified statement. So it is verification-stationary for the *spec*, not for the
   *execution*. This is the honest limit: PBT gives you a one-unit *statement* of correctness; it
   does not give you a one-unit *establishment* of it (you still pay runtime over the ensemble,
   and ∀ is sampled, not proven — Frame 10 §A5's "decidable approximation").

3. **Contracts / design-by-contract (the runtime dual of types).** A precondition/postcondition/
   invariant attached at the decision's locus is one artifact that attests the decision *every
   time it runs*. Contracts are verification-stationary for *local* invariants (1→1) and degrade
   exactly as compositionality degrades: a class invariant is 1→1; a *cross-object* protocol
   invariant ("these two aggregates stay consistent") is 1→N or 1→∅ — the contract has nowhere to
   live, mirroring §1's schema/consistency rows. Contracts make the temporal-smear case (Frame
   8) cheaper too: an invariant is checked across the *trajectory*, not at one edit-time.

4. **Formal methods / model checking (the only verification-stationary representation for
   emergent invariants).** For deadlock-freedom, linearizability, fairness — the 1→∅ classes —
   the *only* thing that makes verification one unit is a model checker or a machine-checked proof
   over the global state space (TLA+, Alloy, a separation-logic proof, a Jepsen suite as an
   empirical approximation). This is verification-stationary in the sense that there is *one*
   artifact (the spec + the checker) — but it is the most expensive unit in the inventory, and
   for the genuinely-undecidable members it is an *approximation* (bounded model checking,
   sampled traces), never total. This is the dual of Frame 10's "redesign the substrate" escape:
   the unit of *verification* for an emergent invariant is the *whole-system model*, not a node —
   exactly as the unit of *change* for it was the substrate, not a node.

5. **THE NON-STATIONARY CASE — ML weights / prompts (Frame 10 B2).** There is **no
   verification-stationary representation** for "make the model more cautious." The decision is a
   gradient field over a parameter space; its verification is an *eval distribution* over inputs,
   established only empirically, only in aggregate, and never totally (the input space is
   unbounded and adversarial). This is the verification dual of "behavior-IS-the-substrate": just
   as the *implementation* is unlocalizable (it's weights), the *verification* is unlocalizable
   (it's an eval/canary/red-team over the distribution). The attestation cost is irreducibly
   empirical and irreducibly continuous — there is no "if it compiles, it's correct," only "the
   eval moved in the right direction, on the inputs we thought to measure." **This is the case
   where the verification dual most decisively refutes any hope of a universal
   verification-stationary representation.**

So: verification-stationary representations exist for the compositional/decidable band (types,
contracts) and for the *spec* of well-quantified properties (PBT, formal specs), and they are
**the same representations Frame 2 named as implementation-localizers** — confirming §2's claim
that localizing the edit and localizing the proof are one act. They *do not* exist for
non-compositional emergent invariants (only an expensive whole-system model, often approximate)
or for behavior-IS-substrate media (only empirical eval). The gradient between them is the
compositionality gradient, read backward.

---

## 4. Reclassifying Frame 4 §E: scaffolding is load-bearing verification, not noise

Frame 4 §E filed tests, feature flags, canaries, snapshots, and CHANGELOG entries as "edits that
aren't decisions at all (and pollute the signal)." The verification dual **partially overturns
this**, and the correction is sharp enough to matter:

- **Tests are not noise — they are the attestation half of the decision, and they carry their
  own decision-bits.** Frame 4's own normalize/enum examples make the point against Frame 4:
  a test for a 14-arm enum must cover 14 arms — *the verification shrapnel mirrors the code
  shrapnel exactly* (§1, enum row). The test suite is not pollution; it is the 1→N backward
  projection of the same decision. Moreover, **choosing what to test is itself a spawned
  decision** with real decision-bits: "which inputs are the boundary cases" is information the
  oracle injects that the program does not force. A test is forward-mechanical only when the
  property is type-expressible (then you'd use a type instead); otherwise it is spawned.
- **Feature flags / canaries / staged rollout are the verification artifact for the
  unverifiable-statically classes.** For ML weights, online migrations, and emergent invariants —
  precisely the 1→∅ classes — the *only* available attestation is "ship it to a fraction of
  traffic and measure." The canary is not scaffolding around the decision; **it is the only
  instrument that can establish the decision at all.** Frame 4 §E called the flag a
  representational accident; the verification dual says the flag is the *runtime verifier* for a
  decision whose correctness is intrinsically empirical (Frame 8's "run-in-production
  discriminator" is exactly this seen from the temporal frame — and the two frames agree:
  intrinsically-temporal smear forces intrinsically-temporal *verification*).
- **What stays noise:** Frame 4 was right about *genuinely derived* artifacts — lockfiles,
  compiled output, formatter output, mechanical cross-repo propagation. These carry neither
  decision-bits nor attestation-bits: they are projections, and they are verified by *re-deriving
  them* (the lockfile is "correct" iff `bun install` reproduces it; the propagation is correct iff
  re-running the propagator is a no-op — which is exactly what `sync-skills.sh --check` *is*: a
  verification-stationary drift check, one unit, over 37 repos). The propagator's `--check` mode
  is a beautiful in-ecosystem instance: the *implementation* smear (one CLAUDE.md → 37 repos) and
  the *verification* smear collapse to the *same* one unit, because the propagation is a pure
  determinate projection. Mechanical-forward → mechanical-backward, the §0 best case.

The corrected partition: Frame 4 §E conflated **derived artifacts** (truly no content — exclude)
with **attestation artifacts** (load-bearing verification content — *include as the backward half
of the decision*). The discriminator is the §0 one: does re-deriving it require any oracle
judgment? Lockfile — no, exclude. Test boundary-case selection — yes, it is spawned verification.

---

## 5. Non-compositional decisions cannot be locally verified — the tightened theorem

Frame 10's master result: non-compositional global property ⟹ no local implementation contract
to localize into. The verification dual strengthens this to a statement about *evidence*:

> **A non-compositional decision cannot be locally attested.** If the decision's defining
> property does not decompose into per-site predicates, then no per-site artifact (assertion,
> unit test, local contract, local type) can be evidence for it — because the property is false
> at no single site and true at no single site; it is a predicate over the *joint* behavior.
> Local verification of a global property is not merely hard, it is *category-incorrect*: a
> green per-site test suite is **not weak evidence** for a global invariant, it is **no
> evidence**, and reporting it as evidence is the confabulation the ecosystem's CLAUDE.md names
> as the root failure ("asserting past your evidence").

This is why verification-smear is the *more faithful* compositionality signal (§2): an
implementation can present N local edits that *appear* to address a global property; only the
attempt to *verify* it forces the question "does any local artifact actually witness this?" —
and for a non-compositional property the answer is structurally no. The verification dual thus
operationalizes the ecosystem principle directly:

> **"Trust comes from verifiable evidence, not authority"** — restated through this frame:
> the trustworthiness of a decision is bounded by the *localizability of its verification
> artifact*. For compositional decisions, evidence is local, cheap, and total (types) — trust is
> warranted. For non-compositional decisions, the only honest evidence is global and often
> approximate (model checking, canaries, eval distributions) — and any local "evidence" offered
> in its place is authority-dressed-as-evidence. The principle is not a slogan; it is the
> verification-smear classification: **the evidence that warrants trust smears exactly as the
> decision's compositionality dictates, and substituting local evidence for a global property is
> precisely substituting authority for evidence.**

---

## 6. Does the oracle-at-leaves need a verifier-at-leaves?

The ecosystem principle: *"the LLM is an oracle at the leaves, never the control loop;
determinism is a hard invariant."* The forward frames cite this to justify a model-as-oracle
filling spawned-decision slots. The verification dual asks the sharp question Frame 10 §D2
forced: **if an oracle injects a decision-bit at a leaf, what attests the bit was right?**

The answer is structural and, I think, the most important consequence of running this frame:

> **An oracle-at-a-leaf is only trustworthy to the degree its output lands in a
> verification-stationary representation.** The oracle is safe at exactly the leaves where a
> *cheap total verifier* catches a wrong bit — i.e., where the oracle proposes into a typed hole
> (the type checker rejects a wrong fill), a contract'd slot (the contract fails fast), or a
> property-tested unit (the property falsifies a wrong implementation). At those leaves the
> oracle can be *wrong* without being *dangerous*, because the determinism on the verification
> side is preserved: a wrong bit is mechanically rejected. **The verifier-at-the-leaf is what
> keeps the oracle "at the leaf" rather than "in the control loop"** — without it, an unverified
> oracle bit silently propagates, which *is* the oracle entering the control loop.

So the answer is **yes, and it is load-bearing**: the oracle-at-leaves architecture is only
sound when paired with a **verifier-at-leaves**, and the verifier must be of the cheap-total kind
(type, contract, property) — *not* itself another oracle, or you get Frame 10 §D2's infinite
regress (an oracle checking an oracle never bottoms out). The determinism invariant the
ecosystem demands lives on the *verification* side: the oracle may be stochastic, but its output
must fall into a deterministically-checked frame. This is the precise sense in which
oracle-at-leaves and verifier-at-leaves are *the same architectural commitment seen forward and
backward*. Where no cheap-total verifier exists — the 1→∅ classes (emergent invariants, ML
weights) — the oracle is **not** safe at the leaf, because there is no deterministic catch for a
wrong bit; there, the verification is empirical and delayed (canary), which is exactly why those
decisions must run in production before they can be trusted (agreement with Frame 8). **The
absence of a leaf-verifier is the precise signal that a decision is not safe to delegate to an
oracle** — a directly actionable criterion for where the model may and may not be the leaf.

---

## 7. What this frame adds to the spine (and where it stays uncertain)

**Added to the spine:**

1. A **second quantity** dual to outcome-forced-vs-new-info: **attestation cost** (the
   verifier-injected bits to establish the decision), and the asymmetry that mechanical-forward
   does *not* imply mechanical-backward (§0).
2. **Verification-smear tracks compositionality more tightly than implementation-smear** (§2),
   because implementation has the make-it-structural escape and verification *is* that escape
   seen backward — so the verification column is the un-fakeable ground truth of the
   compositionality classification, and a **codemod-class pseudo-localizer** is detected exactly
   by verification-smear surviving when edit-smear collapses.
3. **Verification-stationary representations exist iff the decision is compositional/decidable**
   (types, contracts) **or well-quantified** (PBT/formal specs for the *spec*), are the *same*
   representations Frame 2 named as localizers, and **do not exist** for emergent invariants
   (only expensive, often-approximate whole-system models) or behavior-IS-substrate media (only
   empirical eval) — §3.
4. **Reclassification of Frame 4 §E**: tests, flags, canaries are load-bearing *attestation*, not
   noise; only truly-derived artifacts (lockfiles, propagation output) are excludable, and they
   are excludable because their verification is itself stationary (`--check` is a no-op re-derive)
   — §4.
5. **Oracle-at-leaves requires verifier-at-leaves**, and the verifier must be cheap-total (type/
   contract/property), never another oracle (regress); the *absence* of such a verifier is the
   criterion for where an oracle must **not** be the leaf — §6.

**Uncertainties I will not paper over:**

- The claim that verification-smear is *strictly* monotone-worse than implementation-smear (§1,
  "no cell where verification is more localizable") is strong. I believe it because verification
  inherits the impl's site-structure *plus* a completeness obligation, but I have not proven there
  is no decision class where a *cheaper* verifier exists than the implementation warrants (a
  decision hard to write but trivial to check — the P-vs-NP-flavored "easy to verify, hard to
  produce" asymmetry). **That asymmetry is real in complexity theory and I may be wrong about
  its absence here:** "find the bug-fix" can be hard while "check the test passes" is easy. The
  honest restatement: verification-smear is monotone-worse *for establishing completeness of a
  distributed change*; for establishing *a single proposed answer*, verification can be strictly
  cheaper (this is exactly why the oracle-at-leaves + cheap-verifier architecture works). I am
  fairly confident in the per-decision-completeness claim and explicitly unsure about the
  general case. Flagging rather than resolving.
- "Property-based testing is verification-stationary for the *spec* but not the *establishment*"
  (§3.2) rests on ∀ being sampled not proven — solid for PBT, but dependent-type/refinement-type
  systems *do* prove some ∀s totally, which would move those cases into the fully-stationary
  column. The boundary between "PBT-sampled" and "type-proven" is the decidability frontier
  (Frame 10 §A5), and I have located the cases relative to it rather than re-deriving where it
  sits.

**The one-line digest:** verification is the decision's backward half; its smear is the
implementation's smear pushed one notch more pessimistic and made un-fakeable, it tracks
compositionality more tightly than implementation-smear (because localizing the proof *is* the
only way to localize a global property's implementation), verification-stationary representations
exist exactly in the compositional/decidable band and nowhere else, and an oracle is safe at a
leaf only where a cheap-total verifier sits at the same leaf.
