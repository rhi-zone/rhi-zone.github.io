# Frame 12 — Behavior-IS-the-Substrate (non-code behavior-bearing artifacts)

> Mandate: every prior frame assumes behavior lives in **code** — symbolic, parseable,
> type-checkable, with a derivable propagation worklist. Frame 10 flagged this as its
> missing category **B2** and confirmed via self-reference (D1) that the framework's *own*
> oracle is built from the one material the map never charted. This frame charts it: map
> single-decision behavior changes where the behavior is encoded in **ML weights**,
> **prompts / system messages**, **grammars / schemas / DSLs**, **data / lookup tables /
> config-as-behavior**, and **trained policies**. For each: what is the editing unit, how
> badly does one decision smear, is there a localizing representation, and — the load-bearing
> question — **does the mechanical/spawned spine (Frame 3) even apply when the substrate is
> statistical/non-symbolic** (no exhaustiveness checker, no type-error worklist, propagation
> knowable only empirically-via-eval, not derivable)? Then: editing the oracle itself.

I inherit Frame 10's two sharp tools and use them throughout:

- **Authoring smear vs realization smear.** Authoring smear = one decision needs N
  coordinated edits, contingent on representation, collapses to 1 + machine-derived shrapnel.
  Realization smear = the decision's *effect* is irreducibly distributed; no single locus can
  carry it even with a perfect representation, because the content *is* a property of the
  distribution. Frame 10's central result: the map conflated these, and realization smear is
  *intrinsic*, not contingent.
- **The localization-faithfulness test.** A representation localizes a decision iff there is
  a single editable object O such that (i) editing O changes behavior as intended, (ii) the
  rest is *derivable from O by a determinate procedure*, and (iii) O *faithfully* names the
  decision — O is not a leaky wrapper that merely relocated the smear into its own
  unreadable body.

The thesis of this frame, stated up front so the body can be checked against it:

> **These substrates split into two families on exactly one axis — whether the propagation
> from edit to behavior is *derivable* (a determinate procedure exists) or only *observable*
> (you must run an eval to find out).** Grammars/schemas/DSLs and data-as-behavior are
> **symbolic**: Frame 3's spine survives essentially intact — there *is* a worklist, an
> exhaustiveness question, a derivable shrapnel set. Weights and trained policies are
> **statistical**: the spine does *not* survive — there is no exhaustiveness checker, no type
> worklist, and propagation is **empirical-via-eval**, which is a fundamentally weaker
> guarantee (a sample, not a proof). Prompts are the **hybrid and the most interesting case**:
> a prompt edit is a *symbolic* edit (one localized object) feeding a *statistical* realizer,
> so it has localized authoring with **non-derivable, un-checkable propagation** — high
> apparent leverage, no propagation guarantee. This is the dominant substrate of *this very
> ecosystem* and deserves the most care.

I flag uncertainty heavily; this is the least-formalized region of the whole map and several
claims below are my best reading of how these substrates behave, not settled results.

---

## 1. The substrate spectrum, ordered by derivability of propagation

```
SYMBOLIC                                              HYBRID                 STATISTICAL
(propagation derivable;                              (symbolic edit,        (propagation only
 Frame 3 spine survives)                              statistical realize)   observable; spine fails)
|---------------------|---------------------|---------------------|---------------------|---------------------|
grammar / schema /    data / lookup table /  config-as-behavior    prompts / system       trained policies /
DSL                   decision table         (feature flags,        messages               RL agents
                                              rule rows)            (CLAUDE.md, hooks,
                                                                     skills)               ML weights
                                                                                           (fine-tune / edit)
editing unit:         editing unit:          editing unit:         editing unit:          editing unit:
a production /        a ROW                  a row / flag value    a span of text          a dataset + a
a schema field        (or a cell)                                  (an instruction)        training run
                                                                                           (or a weight-edit)

smear: AUTHORING      smear: ~NONE           smear: AUTHORING      smear: REALIZATION,    smear: REALIZATION,
(downstream consumers (the row IS the        (consumers of the     UNBOUNDED &            TOTAL & non-
recompute)            home; near-zero)       flag)                 UNDERIVABLE            localizable
```

The ordering principle is exactly the question the mandate poses: **is propagation
derivable?** Reading left to right, the answer degrades from "yes, by a determinate
procedure" through "the edit and its effect are the same object" to "you can only find out
by running it, and what you find out is a sample." The mechanical/spawned spine is a
**property of the left half** and is *absent by construction* on the right.

---

## 2. Grammars / schemas / DSLs — symbolic; the spine survives, and *strengthens*

**Editing unit:** a single grammar production, a schema field/constraint, one DSL rule.

**The behavior:** in a grammar the behavior IS the grammar — parsing, validation, the shape
of every accepted input. One production edit ("identifiers may now contain `-`") reshapes
everything downstream: the lexer, every rule that references identifiers, the AST shape, every
consumer of the AST.

**Does it smear?** **Authoring smear, and it is contingent** — exactly the Frame 3 case. This
is the *best-behaved* substrate in this entire frame, and the reason is precise: a grammar/
schema is *already* the localizing representation Frame 2 was hunting for. The decision has a
faithful single home (the production), and the downstream effects are **derivable by a
determinate procedure** — that procedure is *parser generation / schema compilation itself*.
You edit the BNF; the parser generator (yacc, tree-sitter, a schema compiler) *recomputes*
the recognizer. The shrapnel is machine-derived, by construction, by a tool that already
exists.

**Does the mechanical/spawned spine apply?** **Yes — fully, and it is the cleanest instance
in the map.** A grammar edit has:
- **Mechanical shrapnel:** the regenerated parser tables, the re-derived FIRST/FOLLOW sets,
  reported conflicts (shift/reduce). These are *exactly* Frame 3's worklist — and a grammar
  tool *literally emits them*. A shift/reduce conflict is the grammar analogue of a type
  error: a machine-located spawned-decision flag ("you must decide precedence here").
- **Spawned decisions:** what the new AST node *means* downstream (the semantic action,
  the consumer's handling of the new shape) — genuinely new, oracle-filled.
- **Exhaustiveness:** schemas have it directly (a closed enum / required-field set is
  checkable); grammars have it as parser conflict detection and "unreachable production"
  warnings.

So for the symbolic substrates the answer to the mandate's hard question is **the spine not
only survives, it is *sharper* here than in general code**, because the propagation tool
(parser/schema generator) is more complete than a general type checker — grammar conflicts
are decidable where general program properties are not.

**Caveat (where it leaks):** a grammar edit's effect on a *downstream LLM or human* that
consumes the language is statistical/social, not derivable — but that's the consumer's
substrate, not the grammar's. Within the grammar, the spine holds.

---

## 3. Data / lookup tables / config-as-behavior — symbolic; smear → ~0 (the ideal case)

**Editing unit:** a **row** (or a cell). The decision IS the row.

This is the substrate the original reasoning thread's ecosystem principle *recommends* —
"prefer data over code at a seam where a faithful serialization is viable." It is the
**limit case of localization**: the decision-to-edit map is the identity. A decision table
("if region=EU and amount>10k → manual review") encodes one decision per row; changing the
policy = editing/adding/deleting a row. Frame 10's missing category **B1 (deletion)** is
*trivially clean here* — deleting a behavior = deleting a row, with no shrapnel.

**Does it smear?** **Near-zero authoring smear**, *provided* consumers treat the table as
data and recompute over it (one interpreter loop reads all rows). The smear collapses to zero
because there is no "spreading across edits" — the row is the home, and the interpreter is the
single propagation site. This is the strongest vindication in the map of "prefer data over
code": **data-as-behavior is the representation that makes authoring smear identically zero.**

**Does the spine apply?** **Yes, degenerately.** Mechanical shrapnel ≈ ∅ (the interpreter
already generalizes over rows; no per-row code to regenerate). Spawned decision = the *content
of the new row* (what the policy should be — oracle-filled). Exhaustiveness = "are all input
combinations covered by some row?" which is *checkable* for a finite decision table (this is
literally what decision-table coverage tooling does). So the spine holds, but is almost
content-free because M≈0.

**The catch (faithfulness test bites here):** config-as-behavior degrades toward prompts when
the "data" is actually a leaky wrapper. A feature flag whose value is `true`/`false` is clean
data; a config string that is *actually a mini-DSL* or *actually free-text injected into a
prompt* has relocated the smear into the consumer, failing faithfulness test (iii). The
boundary: **data-as-behavior is clean exactly when the interpreter over it is symbolic and
total.** The moment the interpreter is an LLM, you have left this section and entered §5.

---

## 4. Prompts / system messages — the HYBRID, and the most important case for this ecosystem

This is the substrate the mandate flags as most accessible and most demanding of care,
because **this ecosystem runs on it**: CLAUDE.md, hooks, skills, system messages ARE
behavior-bearing text. A behavior change here is a prompt edit. The question the mandate
poses directly: *is a prompt a high-leverage localized decision-representation, or an
un-checkable smear with no propagation guarantees?*

**Answer: it is uniquely both, and the two halves live on opposite sides of the realizer.**

- **Authoring side — localized, high-leverage.** A prompt edit is a *symbolic* edit to a
  *single, small, diffable, version-controllable object* (one span of text). On the authoring
  axis it is the *most* localized representation in the entire map after data-as-behavior:
  one instruction, one place, `git diff`-able. CLAUDE.md's whole design — "control surface
  stays self-contained and versioned… behavioral rules live in-repo, diffable, propagatable"
  — is a bet that prompts ARE high-leverage localized decision-representations. On the
  authoring axis, that bet is correct: you change behavior across the ecosystem by editing
  text and running `sync-skills.sh`. The *authoring* smear is low and contingent (and the
  propagator mechanizes even the cross-repo fan-out — the ecosystem built a propagation tool
  for prompt-shrapnel).

- **Realization side — unbounded, underivable, un-checkable.** The prompt feeds a
  **statistical realizer** (the model). The map from "edited instruction" to "changed
  behavior over all inputs" is **not derivable by any determinate procedure** — there is no
  prompt-compiler that emits the behavior the way a parser generator emits a recognizer. The
  effect is **realization smear in Frame 10's exact sense**: distributed across the model's
  response distribution over all possible inputs, and knowable only by sampling (eval). And it
  is worse than ordinary realization smear in three specific ways:
  1. **No exhaustiveness.** You cannot enumerate the inputs over which the instruction now
     fires. "Be more concise" has no input-set you can check it against.
  2. **Non-local interactions.** A new instruction interacts with every other instruction
     non-compositionally (instruction A can override, dilute, or be diluted by B; ordering and
     salience matter; long context degrades adherence). Adding rule N+1 can silently weaken
     rule K — a realization-smear interaction with **no static checker**. (CLAUDE.md's own
     "fewer, sharper rules" instinct and the repeated worry about rule bloat are the
     ecosystem feeling this.)
  3. **No propagation guarantee at all.** Editing the instruction does *not* guarantee the
     behavior changed — the model may ignore it, partially follow it, or follow it only on
     inputs you didn't test. This is the defining hazard: **a prompt edit can be a no-op or a
     catastrophe and the diff looks identical either way.**

**Does the spine apply?** **Partially, and the split is the key finding.** Frame 3's spine
*does* survive on the **authoring** half — a CLAUDE.md edit has mechanical shrapnel (propagate
to 37 repos via `sync-skills.sh` — a real, derivable worklist) and spawned decisions (what the
new rule should *say* — oracle-filled). But the spine **fails on the realization half**:
there is no mechanical shrapnel that is "the set of behaviors that must change," because that
set is not derivable. **The exhaustiveness checker, the type-error worklist, the
"propagation fully determined once the decision is made" — none of these exist on the far side
of the realizer.** Propagation is empirical-via-eval: you change the prompt, you run an eval
suite, you observe a *sample* of the new behavior distribution. That is a fundamentally weaker
object than Frame 3's derivation — it is a finite sample of an infinite, non-stationary
behavior surface, with no completeness claim. (Connects to Frame 10's B6, the verification
dual: here verification is *forced to the center*, because eval is the *only* propagation
oracle available, and it is incomplete by nature.)

**Verdict on the mandate's question:** a prompt is **a high-leverage localized
decision-representation on the authoring axis AND an un-checkable smear with no propagation
guarantees on the realization axis — simultaneously, and the gap between the two is the
defining risk of prompt-as-behavior.** The danger is that the *authoring* localization
(clean diff, one place, versioned) *masquerades* as realization localization. It looks like
you made one small precise change. You made one small precise *cause* with an unbounded,
unverified *effect*. The ecosystem's CLAUDE.md is right to version and diff prompts (authoring
discipline) but a `git diff` of CLAUDE.md tells you **nothing** about the behavior delta — for
that you'd need eval, which the ecosystem mostly does not have for its own harness behavior.
(Uncertainty flag: this is my read; I have not measured prompt-edit behavioral deltas in this
repo, and the strength of "no propagation guarantee" is qualitative — instruction-following is
strong-but-not-total in current models, so it's "weak guarantee," not "zero," but it is *not a
derivable* guarantee, which is the load-bearing point.)

---

## 5. ML weights — statistical; the spine does **not** apply; total non-localizable smear

This is the maximally-unlocalizable substrate, and — per Frame 10 D1 — the substrate of the
**oracle this whole framework leans on**.

**What is the editing unit?** There is no clean one. The candidates, in order of
localization:
- **Fine-tuning (incl. LoRA):** unit = *a dataset + a training run* (+ hyperparameters). The
  "decision" is "behave more like these examples." This is the honest default unit and it is
  enormous and indirect: you do not edit behavior, you edit *data about behavior* and run an
  optimizer that distributes the change across millions/billions of parameters by an
  empirical procedure.
- **RAG / retrieval augmentation:** unit = *a document in the retrieval corpus*. This is the
  one genuinely localizing move — it pulls the "decision" *out* of the weights and back into
  **data-as-behavior (§3)** at inference time. Adding a fact = adding a row/doc. This is why
  RAG is the standard answer to "I need to change a specific behavior without retraining":
  **it re-localizes by escaping the substrate** rather than by editing within it. (Crucial:
  RAG doesn't make weights localizable; it *avoids editing weights* by overlaying a symbolic
  substrate. The localization is real but it's §3's, not §5's.)
- **Targeted weight editing (ROME / MEMIT and kin):** unit = *a single factual association*
  ("the Eiffel Tower is in Rome"), edited by a rank-one or batched update to specific MLP
  layers. This is the closest thing to a "localized decision representation *inside the
  weights*" that exists, and it is an active research area, not a reliable engineering tool.
  (Uncertainty flag, important: my understanding is these methods edit *factual recall* with
  measurable success but have documented failure modes — *ripple effects* where related facts
  don't update consistently, *bleed* into unrelated behavior, and degradation under many
  sequential edits. So even the most localized weight-edit technique exhibits exactly Frame
  10's faithfulness-test failure: it *relocates* the smear into hard-to-predict ripples rather
  than eliminating it. I am fairly confident of the direction of this claim and less confident
  of specifics; treat it as a research-frontier characterization.)

**How badly does one decision smear?** **Maximally — realization smear is total.** A single
behavioral decision ("refuse this category of request," "prefer this coding style") is
realized as a diffuse change across the parameter field with *no* identifiable locus.
Fine-tuning to instill behavior B routinely perturbs unrelated behaviors (**catastrophic
forgetting / alignment tax / capability regressions**) — the textbook signature of
realization smear that *cannot* be localized: the decision's content is a property of the
whole function the network computes, not of any weight.

**Is there a localizing representation?** **No native one; only escapes.** The localizing
moves all work by *leaving* the substrate: RAG (→ §3 data), system prompts (→ §4), tool-use /
scaffolding (→ §2/§3 symbolic). Within the weights, ROME/MEMIT *gesture* at localization but
fail the faithfulness test (relocated-into-ripples). **This is the deepest confirmation of
Frame 10's thesis that realization smear is intrinsic, not contingent: here the substrate is
*nothing but* realization smear — there was never an authoring locus to begin with.**

**Does the mechanical/spawned spine apply?** **No. The spine fails completely, and the way it
fails is diagnostic.** Walk Frame 3's apparatus item by item:
- **Determinacy test** ("given the decision, exactly one correct edit at this site?"):
  inapplicable — there are no *sites*, there is a parameter field, and "the correct weight
  delta" is the *output of an optimizer*, not a derivable value. You cannot ask "what is the
  correct value here" of an individual weight.
- **Mechanical shrapnel** ("propagation fully determined once the decision is made, machine-
  derivable for free"): **does not exist**. Propagation is performed by gradient descent
  *empirically*, and its result is not *derivable* in advance — it is *discovered* by running
  the training and then *measured* by eval. There is no worklist; there is a loss curve.
- **Exhaustiveness checker** (the engine that *locates* spawned decisions): **does not
  exist**. Nothing tells you which behaviors your fine-tune broke. You find regressions by
  *evaluating*, and only on the inputs your eval set happens to cover. The set of "behaviors
  that changed" is not enumerable.
- **Spawned decisions:** in a sense *everything* is spawned and nothing is — the concept
  doesn't transfer, because there is no symbolic structure within which a "new slot" appears.

So the answer to the mandate's central question is **sharp and negative for weights: the
mechanical/spawned spine is a property of *symbolic* substrates with derivable propagation,
and it does not survive the transition to a statistical substrate.** What *replaces* it is a
**statistical analogue that is strictly weaker**:

| Frame 3 (symbolic spine) | Statistical analogue (weights) | Why weaker |
|---|---|---|
| Derivable shrapnel | Gradient descent | result discovered, not derived; non-deterministic-ish |
| Exhaustiveness checker | **Eval suite** | a *sample*, never complete; only covers chosen inputs |
| Type error worklist | **Regression set / red-team** | finds *some* breakage, proves no absence |
| "Exactly one correct edit" | Loss minimum + hyperparameter search | a basin, not a point; underdetermined |
| Static, before-run guarantee | Empirical, after-run measurement | a proof vs. a statistic |

The single sentence: **on statistical substrates, "propagate the decision" is replaced by
"retrain and *measure*," and measurement is a sample of an infinite surface, so every
guarantee the symbolic spine gave (completeness, determinism, before-the-fact) is downgraded
to a statistic.**

---

## 6. Trained policies / learned components — same as §5, plus non-stationarity

RL policies, learned rankers, learned heuristics inside otherwise-symbolic systems. Editing
unit = *reward function + environment + training run* (or *the dataset* for imitation
learning). Everything in §5 applies, **plus one strictly-harder property**: the behavior is a
function of an *environment / data distribution that drifts*, so a "single decision" (a reward
shaping term) realizes differently as the world changes — Frame 10's online-change axis (B5)
and realization-over-time, fused with statistical realization smear. **Reward hacking** is the
canonical signature: you edit one reward term (apparently localized authoring decision) and
the policy realizes an unintended global behavior because the decision's true content was a
property of the *whole optimization landscape*, not the term you edited. Spine: does not
apply, same as §5, and even the eval substitute is shakier because the eval distribution
itself is non-stationary. (Uncertainty flag: I am characterizing this from general RL
behavior, not a specific measured system here.)

---

## 7. Editing the oracle itself — is it outside the framework?

The mandate's pointed question, sharpened by Frame 10 D1/D2: the original thread's whole
construction is "the LLM is an oracle *at the leaves*, never the control loop." The oracle's
own behavior lives in **weights (§5)**. So: is editing the oracle outside the entire
framework, or does it have its own (statistical) version of the spine?

**Finding — it splits exactly along the seam Frame 10 found self-application splits on (D3),
and the split is clean:**

1. **Editing *how the oracle is invoked* is INSIDE the framework, on the symbolic side.** The
   prompt (§4), the tool definitions (§2 symbolic), the retrieval corpus (§3 data), the
   scaffolding/harness (ordinary code) — all of these shape the oracle's *effective* behavior
   and all of them are symbolic substrates where the spine survives (fully for §2/§3,
   authoring-only for §4). **This is the entire surface the ecosystem actually edits.**
   CLAUDE.md, hooks, skills, sync-skills.sh — every lever this repo pulls on "the oracle's
   behavior" is on the *invocation* side, which is in-framework. The ecosystem has, in effect,
   *already chosen* to edit the oracle only through the symbolic substrates — pushing the
   decision out of the weights and into versioned text/data/code — which is precisely the
   "re-localize by escaping the statistical substrate" move from §5. **That is not an
   accident; it is the only side of the oracle where editing has propagation discipline at
   all.**

2. **Editing *the oracle's own judgment* — its weights — is OUTSIDE the symbolic framework
   and only has the statistical analogue (§5).** "Make the oracle more conservative about
   discretionary fills" as a *weight* change (fine-tune the base model) is a §5 operation:
   total realization smear, no spine, eval-only propagation. Frame 10 D1 is exactly right —
   **the framework is not closed under self-application on this axis**: the control component
   is built from the one material the framework cannot localize, so you cannot use the
   clean (symbolic) decision-editor to cleanly edit the oracle's judgment. D2 sharpens it: the
   determinacy test applied to the oracle's *own* outputs ("is this proposed fill correct?")
   is the alignment/verification problem — undecidable — so the oracle cannot mechanically
   classify its own outputs as mechanical-vs-spawned; it must invoke an oracle to check the
   oracle, which doesn't bottom out.

**So: editing the oracle itself is *not* monolithically outside the framework — it bifurcates.**
The invocation surface is in-framework and symbolic (and is where all the practical leverage
lives); the weight surface is the §5 statistical substrate with only the weaker statistical
analogue of the spine. The honest one-liner: **you edit the oracle's behavior in practice by
editing the symbolic things *around* the weights (prompt/tools/data/harness), because that's
the only side with propagation discipline; editing the weights themselves is the
maximally-smeared §5 operation and is exactly the territory the framework's seam excludes.**

This is also *why* the original principle says oracle-at-the-leaves, **never the control
loop**: the control loop must be on the symbolic side (derivable propagation, replay,
determinism — the ecosystem's hard invariants), precisely because the leaf-oracle's substrate
has no propagation guarantee. The architecture is the framework *defending its own seam*: keep
the un-localizable statistical substrate confined to the leaves, keep the control loop in the
substrates where the spine survives.

---

## 8. Synthesis — what this frame adds to the map

1. **The map's hidden universal precondition, named for this region:** every prior frame's
   spine (derivable shrapnel, exhaustiveness checker, "exactly one correct edit") presupposes
   a **symbolic substrate with derivable propagation**. This frame shows the substrates split
   on exactly that property, and the spine is *coextensive with the symbolic half*. This is
   the per-substrate face of Frame 10's compositionality/decidability precondition: **the
   spine requires not just compositionality but *symbolic-with-a-derivation-procedure*.**

2. **Two re-localization escapes, not in-substrate fixes.** You cannot localize a decision
   *inside* weights (ROME/MEMIT relocate smear, failing faithfulness). You localize by
   *escaping the substrate*: push the decision into **RAG/data (§3)** or **prompt/tools (§2,
   §4)**. "Prefer data over code at a seam" (the ecosystem principle) is, at the ML layer,
   literally "prefer RAG/config over fine-tuning" — and for the same reason: the symbolic
   substrate is the one with a localizing home and a derivable propagation.

3. **Prompts are the dangerous middle:** localized authoring + underivable, un-checkable
   realization. The ecosystem's versioned-CLAUDE.md discipline is correct for the authoring
   half and *silent* on the realization half — a `git diff` of behavior-bearing prompt text
   gives a perfect authoring record and **zero** propagation guarantee. The missing piece
   (Frame 10's B6 verification dual) is **forced to the center here**: eval is the only
   propagation oracle, and it is incomplete by construction.

4. **Editing the oracle bifurcates along the framework's own seam:** invocation surface
   (symbolic, in-framework, all the practical leverage) vs. weights (statistical, §5, the
   excluded territory). The framework is not closed under self-application on the weight axis;
   it *is* closed on the invocation axis — which is exactly why the architecture confines the
   oracle to the leaves and keeps the control loop symbolic.

5. **The statistical analogue of the spine, stated as the frame's takeaway:** where the spine
   fails (weights, policies, the realization half of prompts), it is replaced by
   **retrain/edit-then-*measure***, where measure = eval = a finite sample of an infinite,
   possibly non-stationary behavior surface. Every property the symbolic spine guaranteed —
   completeness, determinism, before-the-fact derivability — is downgraded to a statistic.
   That downgrade *is* the frame's headline: **non-symbolic substrates don't have a weaker
   spine; they have a *statistic where the spine had a proof*.**

---

### Uncertainty ledger (this is the least-formalized region)

- Weight-editing specifics (ROME/MEMIT ripple/bleed/sequential-edit degradation): direction
  confident, specifics are a research-frontier characterization, not measured here.
- "Prompt edit has no propagation guarantee": load-bearing claim is *not-derivable*; the
  strength is "weak guarantee, not zero" since instruction-following is strong-but-not-total in
  current models. I have not measured prompt-edit behavioral deltas in this repo.
- RL/policy non-stationarity and reward hacking: characterized from general RL behavior, not a
  specific system in this ecosystem.
- The clean symbolic/statistical dichotomy is a *modeling* claim; real systems are layered
  (a symbolic harness around a statistical leaf), and the layering is where most engineering
  judgment actually lives — that interaction is under-explored here and is the natural seam to
  the verification frame (B6/Frame 11).
