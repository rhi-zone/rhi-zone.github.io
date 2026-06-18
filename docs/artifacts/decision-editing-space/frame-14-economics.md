# Frame 14 — The Economics of Localization (When NOT to Localize)

> Context (shared with frames 1–10): a program is a structure of *decisions*; text
> smears one decision across many edits; the right editing unit is the *decision*;
> localizing a decision = giving it a single home in a representation that propagates
> the shrapnel. Frames 1–10 mapped the space of single-decision behavior changes.
> **Frame 10's adversarial pass flagged that the whole map inherited an uncritical
> "localize everything" bias and never priced localization** (its B7, the cost axis it
> declined to run). This frame runs it.
>
> Thesis under test: *localization is not a free good. Every localizer carries a cost;
> the redundancy it removes is sometimes load-bearing; and for a definable class of
> apparent duplication, factoring it out is an **error**. The correct move is an
> economic one — localize iff expected benefit exceeds total cost — and the map's
> default bias has the sign wrong often enough to matter.*

I will be strict about one thing: this is not "sometimes abstraction is bad, use
judgment." That is a truism and useless. The contribution is a **cost taxonomy** with
named, separable cost terms; a **decision model** that says which term dominates when;
and a **discriminator** (incidental vs essential duplication) that is sharp enough to
classify a real case before you've paid to find out you were wrong. Where the model is
soft I flag it; the softness is mostly in *measuring* the terms, not in *naming* them.

---

## 0. The inversion the map needs

The reasoning thread's load-bearing equation is *structure = reducible redundancy;
abstraction removes it*. Every localizing representation in Frame 2 is an instance:
the type localizes the enum so the 14 match arms are *derived*, not *repeated*. The
redundancy across the 14 sites was reducible — it was one decision smeared — so
factoring it is pure win.

This frame is the **inverse statement**, and it is not symmetric:

> Not all redundancy is reducible. Some apparent redundancy is **irreducible**: N sites
> that look alike because N *independent* decisions happened to land on the same value
> today. Factoring that is not compression — it is **fabricating a coupling that the
> domain does not have.** And even when redundancy *is* reducible, the localizer that
> reduces it is itself a constructed artifact with its own cost of existence,
> comprehension, and maintenance — so reducibility is *necessary but not sufficient*
> for localization to pay.

So the localize-decision has two independent gates, and the map collapses both:

1. **Is the redundancy reducible at all?** (incidental vs essential — §3) If essential,
   stop: localizing is an error regardless of cost. This is the gate Frame 9's A6
   ("load-bearing redundancy: the distribution *is* the decision") named but did not
   build into a discriminator.
2. **If reducible, does the localizer pay for itself?** (cost-benefit — §1, §2) Even
   pure-win-in-principle factorings lose money when the abstraction is wrong, premature,
   or comprehension-expensive relative to how often the decision actually changes.

The map's "localize everything" bias fails at *both* gates: it factors essential
duplication (gate 1 error — false coupling) and it factors reducible-but-not-worth-it
duplication (gate 2 error — premature/wrong abstraction). These are different failures
with different fixes, and conflating them is the first thing to fix.

---

## 1. The cost taxonomy of a localizer

Every localizer — an abstraction, a function, a DSL, a type-level encoding, a macro, an
aspect, a code generator, a config schema, a propagation rule — incurs costs across the
artifact's whole life. I separate them into terms because they have different *units*,
peak at different *times*, and are paid by different *people*. A model that lumps them
("abstraction has overhead") cannot tell you which one is killing you.

### C1 — Construction cost (one-time, paid by the author, up front)

The cost to *build* the localizer the first time: design the abstraction, find the right
seam, write the generator/macro/type, set up the build step that runs it. This is the
term everyone notices because it is salient and immediate. It is also usually the
*smallest* term over the life of the artifact, which is exactly why optimizing for it
(by *not* abstracting to save the up-front cost) is the wrong default and DRY zealots are
right to discount it. **C1 alone never justifies skipping a localizer** — it is the term
the "localize everything" bias correctly ignores. The trap is to *stop the cost analysis
at C1*, conclude "abstraction is cheap to build relative to the smear it saves," and miss
C2–C5.

### C2 — Maintenance cost of the localizer itself (recurring, paid by every future editor)

The localizer is *a new thing that must be edited.* Frame 2's own closing admission: a
rule/generator/macro "moves the locality, you don't eliminate the need for it." The
shrapnel didn't vanish — it moved *into the body of the abstraction*, and now that body
is the high-traffic edit site. A code generator must be edited when the target language
changes; a macro must be edited when its expansion needs a new case; a DSL must grow a
feature every time the domain does, and DSL evolution is *harder* than library evolution
because the DSL has users who wrote against its current shape. This is the **re-smearing**
cost: the localizer concentrates the decision, but a decision-about-*how-to-localize* is
now smeared across every consumer of the localizer. You traded N call-site edits for 1
abstraction-body edit **plus** the standing obligation to keep the abstraction's contract
stable for its N consumers. That trade is good when the body changes rarely and the
contract is stable; it is *negative* when the abstraction is still churning (which a
*premature* one is, by definition — see §2).

### C3 — Comprehension / indirection tax (recurring, paid by every reader, including non-editors)

This is the largest under-counted term and the one Frame 2 named structurally as **"the
read-site lies."** A localizer makes the read-site *not contain the behavior* — the
behavior is assembled elsewhere (the macro expansion, the aspect's pointcut, the
generic's instantiation, the type-class instance the compiler selected, the config the
runtime merged). The reader must *traverse indirection* to reconstruct what actually
happens, and crucially **must traverse it even when they are not editing anything** —
comprehension is paid on *every read*, which is the most frequent operation on code.
Three sub-flavors, increasingly toxic:

- **Indirection** (a function call, a layer): cheap, local, the reader follows one hop.
  This is the *good* kind and the comprehension tax is near-zero; ordinary functions are
  localizers whose C3 is negligible, which is why "extract a function" is almost always
  free and the rule-of-three barely applies to it.
- **Action-at-a-distance** (AOP advice, an overridden default three layers up, a
  monkey-patch, an implicit conversion): the read-site gives *no syntactic signal* that
  behavior is being injected. The reader cannot follow a hop because *there is no hop
  visible at the read-site* — the localizer made the call-site lie by omission. This is
  Frame 2's "dual of the type system": the type system pushes information *to* the
  read-site (you see the type); action-at-a-distance pushes behavior *away from* it (you
  don't see the advice). AOP's logging/transaction aspects are the canonical case — the
  method body is *literally false* about what executes.
- **Conceptual load of a wrong/leaky abstraction** (a generic that almost-fits, a DSL
  whose escape hatches you must understand alongside the DSL): the reader must hold *both*
  the abstraction's model *and* the ways it leaks. This is strictly worse than
  duplication, because duplication has zero conceptual load — `n` copies of obvious code
  are each individually readable; one clever wrong abstraction is globally unreadable.

C3 is recurring, compounds with team size and reader count, and is **invisible in the
diff** — you cannot see it in the PR that introduced the abstraction; you pay it forever
after in every onboarding and every "wait, where does this behavior come from."

### C4 — False-coupling cost (latent, paid catastrophically at the moment of divergence)

This is the cost of gate-1 failure and it is *qualitatively* different from C1–C3: those
are *taxes* (continuous, bounded, you pay a known rate). C4 is a *latent liability* —
zero cost right up until the two things you coupled need to diverge, then a cliff. You
localized two sites that were equal *by coincidence* into one home. The day one must
change without the other, you face: (a) re-splitting the abstraction (un-factoring, often
harder than never factoring because consumers now depend on the shared shape), or (b) the
**parameter-creep** failure — bolting a flag/conditional onto the shared abstraction for
every divergence, until the abstraction is a pile of `if mode == A` branches that is
*both* the union of all the duplications you "removed" *and* an indirection tax on top.
Sandi Metz's "the wrong abstraction" essay is precisely this trajectory: the abstraction
accretes parameters as callers' needs diverge, and "the code is harder to understand than
duplication would have been." The honest cost accounting: **false coupling converts a
cheap future independent change into an expensive coordinated one, and the bill arrives
at the worst time — when requirements are already forcing a change.** This is why "a
little copying is better than a little dependency" (Rob Pike / Go proverbs): the copy's
cost is bounded and local; the dependency's cost is unbounded and arrives later under
duress.

### C5 — Lock-in / late-binding-foreclosure cost (one-time-but-irreversible)

Building the localizer *early* commits you to a *shape* for the decision before you know
the decision's true shape. Frame 9's A6 in reverse: the localizer encodes "these vary
together" as a structural fact, and structural facts are sticky. If you guessed the
abstraction's axis wrong (you factored on the dimension that turned out to be the one
that varies, instead of the one that's stable), un-guessing requires demolishing the
abstraction and everything built on it. This is distinct from C4 (which is about coupling
*independent* things); C5 is about **committing to the wrong factoring axis** of a thing
that genuinely *should* be factored. The defense is *late binding of abstraction* — wait
for the shape to reveal itself (§2, rule-of-three), because the cost of waiting (a little
duplication) is bounded and the cost of guessing wrong (C5) is not.

### Cost summary

| Term | When paid | By whom | Visible in diff? | Bounded? |
|---|---|---|---|---|
| C1 construction | once, up front | author | **yes** | yes (small) |
| C2 localizer maintenance | recurring | future editors | partly | yes, but ∝ churn |
| C3 comprehension/indirection | every read | all readers | **no** | grows w/ readers |
| C4 false coupling | at divergence | whoever needs to diverge | **no** | **no (cliff)** |
| C5 wrong-axis lock-in | at re-factor | whole downstream | no | **no** |

The decisive observation: **the only cheap-and-visible term is C1, and it is the one the
pro-localization bias correctly tells you to ignore.** Every term that should actually
gate the decision (C3, C4, C5) is invisible in the diff and either unbounded or
proportional to things (reader count, churn, divergence likelihood) you must *estimate*,
not measure. This is *why* the bias toward localizing is so durable: its cost is
front-loaded and visible (so DRY-discounting it feels rigorous), while the cost of
*over*-localizing is back-loaded and invisible (so it never shows up in the PR that
caused it). The bias is a *salience artifact*, not a reasoned position.

---

## 2. The localize-or-not decision model

Given the taxonomy, the decision is an expected-value comparison. State it as the
inequality, then make each factor operational.

> **Localize iff:**
> &nbsp;&nbsp; `P(change) · Smear · Rightness` &nbsp; **>** &nbsp; `C1 + Σ_life(C2 + C3) + P(divergence)·C4 + P(wrong-axis)·C5`
>
> where the left side is the *benefit* of having a single home (you pay the smear once at
> authoring instead of `Smear` edits every time the decision changes, weighted by how
> often it changes and discounted by whether the abstraction is the *right* one).

Operationalizing the four benefit/gating factors:

- **`P(change)` — how often does this decision actually change?** A decision that has
  changed zero times and has no roadmap reason to change has `P(change) ≈ 0`, and *no
  smear width justifies localizing it* — you'd pay C1–C5 to optimize an edit you never
  make. This is the single most common over-localization error: factoring code that is
  *repeated* but *stable* (it looks like smear, but a smear you never re-edit is just
  free-standing duplication, and duplication of stable code is cheap — see C3's "n copies
  of obvious code are each readable"). **Repetition is not the trigger; expected
  re-editing is.** This is the precise content of "DRY is about *knowledge* not *text*":
  knowledge that won't change is not worth a single home.

- **`Smear` — how wide is the shrapnel?** Frame 1/4's blast radius. Two sites: barely
  worth a function. Forty sites across twelve files with exhaustiveness obligations: the
  type pays for itself on the first change. Smear is the term the map measures well; it
  is *necessary* for benefit but, multiplied by a near-zero `P(change)`, irrelevant.

- **`Rightness` — is this the correct, stable abstraction?** ∈ [0,1], and it *gates the
  whole left side* (it's a multiplier, not an addend): a wrong abstraction has negative
  benefit no matter how wide the smear or how often it changes, because every change now
  fights the abstraction (C4 parameter-creep). **You cannot assess `Rightness` up front
  for a novel decision** — this is the epistemic core of the whole frame. The right
  abstraction is *discovered*, not designed, because rightness = "factored on the axis
  that actually varies," and which axis varies is *revealed by changes you haven't seen
  yet*. Hence rule-of-three: **wait until you have three instances**, because three points
  is the minimum to distinguish "these vary together" (real axis) from "these coincided
  twice" (luck), and to see *which dimension* the variation lives on. Before three, your
  `Rightness` estimate is a guess and `P(wrong-axis)·C5` dominates.

- **`P(divergence)` and `P(wrong-axis)`** — the gate-1 and gate-5 risk weights. These are
  the *domain* questions: do these sites encode the *same* knowledge (low divergence,
  safe to couple) or *independent* knowledge that coincides (high divergence, C4 cliff
  ahead)? §3 is the discriminator for this term specifically.

**The model's three regimes** (the actionable output):

1. **Localize now.** `P(change)` high, `Smear` wide, `Rightness` high-confidence (you've
   seen the variation, the axis is obvious, the abstraction is a known pattern — e.g. an
   enum with exhaustive matching, a config key, a capability handle). The map's examples
   live here and the map is *correct* here. This is the band where the "localize
   everything" bias is right by accident.

2. **Wait (late-bind the abstraction).** `Smear` wide but `Rightness` unknown — you have
   one or two instances and cannot yet see the varying axis. **Duplicate deliberately**,
   tolerate the smear, and let the third instance reveal the shape. The cost of waiting is
   `(instances−1) · one extra edit` (bounded, small, visible); the cost of guessing is
   `C5` (unbounded). AHA ("Avoid Hasty Abstractions", Sandi Metz / Kent C. Dodds) names
   exactly this regime: *prefer duplication over the wrong abstraction; optimize for
   change later, not for DRY now.*

3. **Never localize (essential duplication).** `P(divergence)` high — the sites are
   independent decisions that look alike (§3). No amount of `Smear` or `P(change)` moves
   this; coupling them is a category error, not a cost trade-off. The redundancy is
   *load-bearing*: it *is* the decision "these may vary independently" (Frame 9 A6).

The map only has a vocabulary for regime 1. Regimes 2 and 3 are the contribution, and
**they are different**: regime 2 is "right abstraction, wrong time" (wait); regime 3 is
"no abstraction is ever right" (never). Collapsing them — treating all hesitation as "not
yet" — is itself an error, because it implies regime 3's essential duplication will
*eventually* be worth factoring, and it won't.

---

## 3. The incidental-vs-essential discriminator (gate 1)

This is the sharp tool. Two sites are textually/structurally identical today. Should they
share a home? The question is **not** "are they the same now" (they are, by assumption) —
it is **"are they the same *decision*, or two decisions that coincide?"** The
discriminator, stated as a test you can apply before the divergence that would otherwise
teach you the answer the expensive way:

> **The change-reason test (a refinement of "DRY is about knowledge").** Ask: *is there a
> single conceivable change to the domain that should alter one site and not the other?*
> - If **no** such change exists — any reason to change one is necessarily a reason to
>   change the other, because they encode *one* piece of knowledge — the duplication is
>   **incidental** (reducible). The redundancy is the smear of one decision. **Localize**
>   (subject to gate 2: the cost model). This is one fact wearing two hats.
> - If **yes** — there exists a domain change that should move them independently — the
>   duplication is **essential** (irreducible). They are two decisions that *currently*
>   agree. **Do not localize**, regardless of how identical they look. Coupling them
>   manufactures a constraint the domain does not impose, and you will pay C4 the day the
>   domain exercises the independence you denied.

This is the same test as "do these change *for the same reason*" (the Single
Responsibility Principle's reason-to-change, applied to duplication rather than to
modules) and as "do they encode the same *knowledge*" (DRY's actual definition, as Hunt &
Thomas stated it — *not* "the same text"). The reframing that makes it operational:
**duplication is a question about the future, not the present.** Identical-today is the
present; "could they need to diverge" is the future; and the discriminator is entirely
about the future, which is why repetition-counting (a present-tense measurement) is the
wrong instrument and is responsible for most false coupling.

**Worked discriminations (to show the test cuts cleanly, not vacuously):**

- Two validation rules that both happen to be `length <= 32` — one for usernames, one for
  a hostname label. *Change-reason test:* a future RFC could change hostname labels to 63;
  usernames are a product decision. **Independent reasons exist → essential → do not
  share** the `32`. They coincide; coupling them via a shared `MAX_LEN` constant is the
  classic false-coupling bug (the day hostnames go to 63, you either break usernames or
  add a parameter and the "constant" was never a constant).

- Forty `match` arms that all dispatch on the same enum. *Change-reason test:* adding a
  variant changes *all* arms' completeness obligation simultaneously; there is no domain
  change that adds a variant to one arm's worldview and not the others' — they share one
  fact (the set of variants). **No independent reason → incidental → localize** (the enum
  type is the home; arms are derived shrapnel). This is the map's regime-1 win, *and the
  discriminator confirms it for the right reason* — not "they look alike" but "they have
  no independent reason to change."

- Three services that each retry with `backoff=200ms`. *Change-reason test:* could one
  service's SLA force a different backoff while the others stay? **Almost certainly yes →
  essential → do not share** a global `BACKOFF`. The fact that they coincide at 200ms
  today is luck; they are three independent latency decisions. (Contrast: if the 200ms is
  *mandated by a single upstream contract* all three must honor, then it's one fact and
  *is* reducible — note how the test flips on the domain, not the text. Same number, same
  three sites, opposite verdict, decided purely by "is there one reason or three.")

The discriminator's edge — and where it's *hard*: **you often cannot know `P(divergence)`
with certainty up front.** The test asks about *conceivable* future divergence, and
conceivability is a judgment. The honest fallback when genuinely uncertain is **regime 2
(wait)**: do not couple speculatively, because un-coupling (C4) is harder than
coupling-later (just a `P(change)` edit). The asymmetry of error costs settles ties:
*failing to localize incidental duplication* costs you a bounded number of extra edits
later (you DRY it up when the third instance confirms it's one fact); *falsely localizing
essential duplication* costs you the C4 cliff plus the demolition. **When unsure, under-
localize** — the errors are not symmetric, and the cheap-to-reverse direction is leaving
duplication in place.

---

## 4. Connection to the reasoning thread (the inverse claim, made precise)

The thread's compression frame says: *abstraction removes reducible redundancy; structure
is the redundancy that a representation can factor.* This frame's precise inverse, and the
correction it makes to the thread:

> **"Reducible redundancy" is a property of the *decision structure*, not of the *text*.
> Two sites are reducible iff they realize *one* decision (one reason-to-change); they are
> irreducible iff they realize *independent* decisions that happen to coincide in their
> current realization. Factoring irreducible redundancy is not compression — it is
> introducing a *false equation* into the program's decision-algebra, asserting `D₁ = D₂`
> for two decisions that are merely equal-valued today.** The compression is *lossy in the
> wrong direction*: it discards the information "these are independent," which Frame 9
> identified as load-bearing.

This sharpens the thread in three ways:

1. **Redundancy ≠ reducibility.** The thread's "structure = redundancy" elides that
   *only reducible* redundancy is structure-you-can-factor; irreducible redundancy is
   *also* structure (it carries the decision "independent"), but factoring it *destroys*
   that structure. So "minimize redundancy" is wrong as stated; the correct objective is
   "factor reducible redundancy, *preserve* irreducible redundancy" — and the two are
   indistinguishable by inspecting the text, distinguishable only by the change-reason
   test (§3). **Redundancy that encodes independence is information, not waste** — exactly
   the error-correcting-code analogy Frame 10 B7 predicted (some redundancy is there *so
   that* the parts can vary; removing it removes the variation-freedom).

2. **Localization has a Kolmogorov-style catch the thread misses.** Even for *genuinely*
   reducible redundancy, the localizer (the "shorter program" that generates the N sites)
   has its own description length — and if the generator is more complex to comprehend
   than the redundancy it removes (C3), you have "compressed" the program into a form that
   is *longer in the metric that matters* (human comprehension), even though it is shorter
   in source bytes. The map measured smear (bytes saved) and never measured the
   generator's comprehension length (C3). A wrong abstraction is a *negative-compression
   localizer*: it adds description length while claiming to remove it.

3. **Late binding is the thread's "wait for the structure to reveal itself."** The thread
   assumes the decision structure is *known* (we're factoring a decision we can see). In
   practice the structure is *latent* and revealed only by the trajectory of changes —
   so the *correct* compression is not always available *yet*, and forcing it early (C5)
   compresses against a *guessed* structure. Rule-of-three is the thread's discipline
   applied honestly: **don't compress against a structure you've only sampled once.**

---

## 5. Honesty ledger

- **The cost *taxonomy* (C1–C5) I'm confident in** — the terms are real, separable, and
  each maps to a named engineering failure (premature abstraction = C5; wrong abstraction
  = C4; action-at-a-distance = C3; re-smearing = C2). What I *cannot* give is a
  *measurement* procedure: C3, C4, C5 are estimated, not computed, and the decision model
  (§2) is therefore a *structuring* of the judgment, not a formula that removes it. The
  contribution is making the judgment's *terms* explicit so you argue about the right
  ones; it does not make the judgment mechanical.

- **The change-reason discriminator (§3) is sharp in principle, soft in application.** "Is
  there a conceivable independent reason to change" is a clean *criterion* but requires
  domain foresight to *apply*, and foresight is fallible. I lean on the **error-asymmetry
  argument** (under-localize when unsure) to make it actionable despite the softness — and
  I'm confident in *that* asymmetry (un-factoring is harder than factoring-later) more
  than in any individual divergence prediction. The asymmetry, not the prediction, is the
  load-bearing claim.

- **The decision inequality (§2) is a model, not a theorem.** The factors are right; the
  combination (multiplicative gating by `Rightness`, additive costs) is a *defensible*
  structure, not a proven one. In particular "`Rightness` gates multiplicatively"
  (a wrong abstraction has *negative*, not just *reduced*, benefit) is the strongest
  claim and the one most worth attacking — it's why I'd reject "partially-right
  abstraction, ship it and fix later," but I haven't proven the negativity, only argued it
  from the parameter-creep trajectory (C4).

- **Where this frame *agrees* the map is right:** regime 1 (frequent change × wide smear ×
  known-right abstraction) is real and large, and the map's worked examples (enum/type,
  config, capability) genuinely live there. This frame is not "don't localize" — it is
  "localization is a *priced* good, the price has five invisible terms, and two whole
  regimes (wait, never) exist that the unpriced map cannot see." The map over-claims by
  *omission of the cost side*, exactly as Frame 10 B7 charged; it is not *wrong* about its
  examples, it is *silent* about the band where its bias inverts.

- **Scope honesty:** this frame prices the *general-purpose localizers* (abstractions,
  DSLs, macros, types, aspects, generators). It does *not* re-derive the cost of the
  cheapest localizer, the plain function — whose C3 is near-zero, so the cost model
  collapses to "just do it" and rule-of-three barely applies. The economics *bite* exactly
  as the localizer gets *cleverer* (macro > generic > DSL > aspect), because cleverness is
  C3. The cost is roughly monotone in the localizer's distance from "a function you can
  step into," and that distance is the single best proxy for "how carefully do I need to
  run §2 before reaching for this."

---

## Digest (for the dispatcher)

**Cost taxonomy of localizing (C1–C5):** C1 construction (one-time, visible, *the only
cheap-and-visible term — correctly ignored, which is why the bias is durable*); C2
localizer-maintenance / re-smearing (the shrapnel moves into the abstraction's body +
contract-stability obligation to its consumers); C3 comprehension/indirection tax (paid on
every *read*, invisible in diffs — three flavors: cheap indirection < toxic
action-at-a-distance < worst-of-all conceptual load of a leaky abstraction; this is Frame
2's "read-site lies / dual of the type system"); C4 false-coupling (latent liability, not
a tax — zero until divergence, then a cliff: re-split or parameter-creep, = Sandi Metz's
"wrong abstraction"); C5 wrong-axis lock-in (committing to a factoring axis before the
varying axis is revealed). **Decisive structural fact: every term that should gate the
decision (C3/C4/C5) is invisible in the diff and unbounded; the bias is a salience
artifact.**

**Localize-or-not model:** `P(change)·Smear·Rightness > C1 + Σ(C2+C3) +
P(divergence)·C4 + P(wrong-axis)·C5`. `Rightness` gates *multiplicatively* (wrong
abstraction = negative benefit). Three regimes: **(1) localize now** (frequent × wide ×
known-right — the map's only regime, correct there); **(2) wait / late-bind** (wide smear
but `Rightness` unknown — rule-of-three / AHA: duplicate until the third instance reveals
the axis; cost of waiting is bounded, cost of guessing is C5); **(3) never** (essential
duplication — no cost trade moves it). Map sees only regime 1; regimes 2 (right
abstraction wrong time) and 3 (no abstraction ever right) are distinct and must not be
collapsed.

**Incidental-vs-essential discriminator (gate 1):** the **change-reason test** — *is there
a single conceivable domain change that should alter one site and not the other?* No →
incidental/reducible → one fact wearing two hats → localize (subject to cost). Yes →
essential/irreducible → two decisions that coincide → **never** localize; the redundancy
*is* the decision "these may vary independently" (Frame 9 A6, load-bearing redundancy).
This is "DRY is about *knowledge* not *text*" made operational; duplication is a question
about the *future* (divergence) not the *present* (identical-today), so repetition-counting
is the wrong instrument. **Error asymmetry settles ties: under-localize when unsure** —
un-factoring (C4 cliff + demolition) is strictly harder than factoring-later (one
`P(change)` edit). **Connection to the thread:** the inverse of "abstraction removes
reducible redundancy" — only *reducible* (single-decision) redundancy is factorable;
*irreducible* (independent-decisions-coinciding) redundancy carries information
(independence), and factoring it is a *false equation* `D₁=D₂` in the decision-algebra,
i.e. negative-compression. "Minimize redundancy" is wrong; "factor reducible, *preserve*
irreducible" is right, and the two are indistinguishable in the text — only the
change-reason test separates them.
