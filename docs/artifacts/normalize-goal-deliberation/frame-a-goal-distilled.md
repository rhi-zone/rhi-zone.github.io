# Frame A — The goal, distilled and stress-tested

> My job in this deliberation is the **goal itself**, not normalize's state (Frame B) nor
> the attack surface (Frame D). I take their findings as inputs where useful, but my
> deliverable is the cleanest possible articulation of *what the owner is actually trying
> to achieve* — at several altitudes — and an honest map of what is settled, what is open,
> and where the goal pulls against itself.
>
> I flag inference vs. explicit throughout. The shared context is explicit; anything I read
> *into* it is marked `[inferred]`.

---

## 1. The irreducible core thesis

Stripped of the code example, in three escalating compressions:

**One sentence.** *Every representation is a lossy, purpose-relative projection, so the
honest unit of work is the **decision** that the representation encodes — and the leverage
is in machinery that lets you operate on decisions directly while a faithful, verifying
substrate pays the re-translation cost between projections by machine instead of by hand.*

**One clause.** *Make the decision, not its textual shadow, the thing you edit and store —
and pay the projection toll mechanically.*

**One word.** *De-smearing.* (Take the intelligence currently spent re-deriving, by hand,
what one fixed representation throws away — and mechanize it.)

The code editor is the **worked example**, explicitly stated by the owner to be "not about
programming specifically." The thesis is about **representation and the cost of being
locked into one of them** — a claim about cognition/engineering in general, of which
source code is the cleanest, most-instrumented instance (it already has parsers, type
checkers, tests — i.e. ready-made verifiers and ready-made projections).

**The deeper "why" underneath the thesis** `[partially inferred]`: the owner's standing
interest is **non-LLM intelligence as novel-competence-per-resource** — efficient
search/compression over a decision structure. The representation thesis and the
intelligence thesis are the *same claim viewed from two sides*: a good representation is
one in which the decision structure is exposed, so search/compression over it is cheap;
"no objective representation" is precisely *why* intelligence is needed (something has to
do the re-translation work, efficiently). So the irreducible core is really a **conjunction
of two halves that imply each other**: (representation) decisions are the real unit because
representations are lossy projections; (intelligence) operating on decisions efficiently
*is* what intelligence is. The editor is where the conjunction is testable today.

---

## 2. Altitude separation — which level is "the goal"?

Three distinct altitudes are riding under one banner. They are routinely conflated, and the
conflation is the single largest source of the tensions in §5. Separating them:

| | Altitude | The claim at this level | Status |
|---|---|---|---|
| **(a)** | **Philosophical** | There is no objective representation; representations are lossy purpose-relative projections; the re-translation toll is real and is paid by hand today. | The **floor** — a *destructive/negative* result. Settled, load-bearing, and explicitly the owner's stated destination. |
| **(b)** | **Design principle** | Therefore make the **decision** the unit of editing/storage; hold projections plurally; mechanize the toll between them; staff the genuinely-new leaves by search + exact verification, LLM as proposer not decider. | The **constructive program** — a *positive* prescription. Partly settled, partly the live debate. |
| **(c)** | **Concrete artifact** | An editor-as-reconciler with five organs (locate / edit-as-decision / store-as-decision / propagate-at-fixpoint / fill-spawned-decisions), instantiated over code, candidate vehicle normalize. | One **instantiation**. Explicitly a worked example, not the destination. |

**Which one is "the goal"?** This is the crux, and getting it wrong mis-aims the whole
program.

- The goal is **(a)+(b)** — the philosophical floor *plus* the design principle it
  licenses. That is what the owner says they care about ("non-LLM intelligence / better
  representations *in general*").
- The reconciler **(c)** is **not the goal**; it is the *first worked example chosen to
  test (b)*. It is instrumental. If the reconciler were abandoned and a different artifact
  better exhibited (b), the goal would be unharmed.
- **Critical subtlety the owner should hold explicitly** `[inferred but high-confidence]`:
  the move from (a) to (b) is *not entailment*. (a) is destructive — "no representation is
  privileged." (b) quietly re-privileges one representation (the decision-tree / decision-
  store) as the place you edit. **A destructive result does not license a single canonical
  constructive object.** This is the latent self-contradiction Frame D's Attack 2 lands on,
  and at the goal-altitude it shows up as: *the philosophical floor and the design principle
  are at different altitudes and the bridge between them is assumed, not built.* The honest
  bridge from (a) is **plural projection with a mechanized toll** — many representations,
  none canonical, the toll made cheap-and-visible but never zero — which is a *weaker and
  different* (b) than "edit the decision."

So the cleanest altitude statement is:

> **Goal (a+b):** mechanize the re-translation toll that the no-objective-representation
> floor imposes — let humans operate at the level of decisions/intent and let an efficient,
> verifying substrate carry the projection cost. **Artifact (c):** a code reconciler is the
> first instrument built to find out whether (b) is real and where it pays. The reconciler
> is a *probe of the goal*, not the goal.

---

## 3. Settled vs. genuinely open

### Settled (load-bearing firm commitments)

1. **The floor is real and is the destination.** "No objective representation." Explicit,
   repeatedly affirmed, and the negative result the whole program stands on. Not in dispute.
2. **The toll is paid by hand today, and that's the waste worth attacking.** The lived
   consequence — "forced into one fixed representation, pay re-translation by hand" — is the
   concrete grievance the program exists to fix. Explicit.
3. **The seam is the architecture: fuzzy proposer at the leaves, exact verifier in the
   control loop.** Determinism is a hard invariant; the LLM is an oracle at the leaves,
   never the control loop. This survived the adversarial frame intact (Frame D, Attack 3b
   *fails* — the seam is the currently-winning frontier, not GOFAI). Settled and defensible.
4. **Code is a worked example, not the subject.** Explicit. The subject is representation /
   intelligence in general.
5. **The five-organ decomposition is a useful map.** As a *diagnostic* carving of what an
   editor-of-decisions would have to do, it's coherent and was validated across 18 frames.
   Settled *as a map*; what's open is whether organ 5 has anything to fill (below).

### Genuinely open (the real underspecification)

1. **What "non-LLM intelligence" actually buys — and whether the label is even right.**
   Two sub-questions, both open:
   - *Is the contribution the absence of the LLM, or the presence of the verifier+search
     structure?* Frame D Attack 3a lands: the proposer is load-bearing *for tractability*
     even when the verifier is load-bearing *for correctness*. The defensible thing to own
     is **"strong proposer + exact verifier,"** and the contribution is the verifier and the
     search structure — not the LLM's absence. The "non-LLM" framing is, at least partly,
     posture. **Open question for the owner: is the goal genuinely anti-LLM, or is it
     "intelligence located in the exact substrate, with the LLM demoted to proposer"?** These
     are different bets; only the second survives scrutiny. `[the owner's true intent here is
     the single most important thing to pin down — I infer the second, but it's not explicit]`
   - *Novel-competence-per-resource against what baseline?* If the baseline is "scaled LLM +
     tools + tests," the marginal claim of a bespoke substrate is unproven (Frame D Attack 5).
     The intelligence-as-efficiency framing is a real position, but *where it beats the
     scaling baseline* is unspecified.

2. **Tool vs. theory vs. substrate — which deliverable?** Three incompatible shapes hide
   under "the goal," and the owner has not chosen:
   - **Theory/research-instrument:** the deliverable is *knowledge* — does the spawned-
     decision middle cell exist? The cheapest falsifying experiment (Frame D Attack 5's
     survivor) is the deliverable. Epistemic value, niche product value.
   - **Tool:** a better refactoring/editing tool that *prunes* the human's decision load via
     verifier-gated proposal. Real, modest, trajectory-aligned, immediate beneficiaries.
   - **Substrate:** the structure-authoritative, decision-canonical store that *abolishes*
     the toll. The Unison-class bet. Highest ambition, longest timeline, contradicts the
     floor in its singular form (§5).
   These need different commitments, timelines, and success criteria. **Open and unchosen.**

3. **Is "decision" crisply definable across domains — or even within one?** The floor
   itself says *no objective decomposition into decisions exists* (decisions are observer/
   purpose-relative). So "the decision is the unit" needs a non-circular answer to "*whose*
   decomposition, picked *how*?" Every candidate (the user's / most-compositional / learned-
   from-history) re-imports a problem (re-keying toll / circularity / a learned carving in
   the determinism-critical control loop). **This is open and it is foundational** — it is
   the question of whether (b) is even well-posed. `[Frame D Attack 2; I judge it the
   deepest open question, ahead of organ-5-emptiness, because it precedes it.]`

4. **Does organ 5 have a non-empty middle cell?** The class of decisions that are
   *simultaneously* genuinely-spawned (S>0, no derivation), cheaply-exactly-verifiable, and
   not-already-handled-by-an-IDE-refactoring. Asserted across 18 frames, never exhibited with
   one worked example. **This is the empirical open question the whole "more than a better
   tool" claim rests on** (Frame D's single biggest risk).

---

## 4. The strongest version (steelman)

The most compelling coherent form of the goal — the version I would actually defend:

> **The re-translation toll is a massive, invisible, hand-paid tax on all engineering and
> cognition, and it is invisible precisely because there's no objective representation to
> measure it against. The leverage is to (i) hold representations plurally rather than
> committing to one, (ii) mechanize the projection between them so the toll is paid by
> machine and made *visible* (you can see what each projection costs), and (iii) at the
> leaves where a genuinely new decision must be made, narrow the human's choice by
> verifier-pruned search — never claiming to decide for them, but collapsing "type N
> completions by hand" into "approve K survivors." The seam (fuzzy proposer, exact verifier)
> is how (iii) works and it is the architecture currently winning at every serious frontier.
> Code is the first instrument because it is the most-instrumented domain — it ships with its
> own verifiers (compilers, type checkers, tests) and its own plural projections (syntaxes,
> ASTs, IRs). Prove the loop there, on one owned language, against the existing build as
> verifier, and you've exhibited a transferable principle.**

**Who benefits and why now:**
- **Near-term, real:** anyone doing large semantic edits across a codebase, *in the niche
  agents structurally cannot serve* — where "the tests passed" (a sample) is not good enough
  and a verifier-backed, auditable **proof token** is worth real money (compilers, financial,
  safety-critical, formal-methods shops). Agents+tests are eating the *sampled-correctness*
  use case from the top down; the *proved-correctness* sliver is durable and uncontested.
  (Frame D Attack 5's survivor.)
- **Why now (the honest version):** *not* "the LLM finally unblocks organ 5" — that "why
  now" evaporated when the LLM was retracted from decider to proposer. The real "why now" is
  that **the seam is now demonstrably the winning architecture** (Lean-gated AlphaProof,
  test-gated coding agents), which means a strong-enough proposer finally exists to make
  verifier-pruned search *tractable* at the leaves — the thing that was computationally
  hopeless when the projectional-editor graveyard tried it. That is a genuine, defensible
  "now," and it is about the *proposer's tractability*, not the LLM being the decider.

What makes it **matter** rather than be merely clever: it reframes a universal hidden cost
(re-translation) as an *addressable* one, and it does so with the one architecture that has
empirically beaten the alternatives at the frontier. The steelman's load is entirely on
exhibiting the middle cell once — cheaply — on real code.

---

## 5. Tensions inside the goal (where it pulls against itself)

These are not external attacks; they are places where the goal, as stated, contradicts
*itself*. Each is a fork the owner must resolve, not a flaw to paper over.

1. **Representation-plurality vs. a canonical decision-store.** *The* central tension. The
   floor (a) says no representation is privileged; the artifact (c) makes the decision-store
   authoritative — i.e. privileges one. You cannot have both. The resolution is altitude
   discipline: the floor licenses **plural projections with a mechanized, visible toll**, and
   "store-the-decision-as-canonical" is a *narrower, optional engineering choice* that you
   may take for a single owned language but may NOT claim as the general consequence of the
   floor. **Pulling hardest:** the program will otherwise spend effort hunting for "the
   canonical decision-store," which the floor says doesn't exist — wasted search after a
   contradiction.

2. **Non-LLM-intelligence vs. LLM-as-proposer.** The identity is "non-LLM"; the architecture
   *needs* a strong proposer and the strongest one available is the LLM. "Non-load-bearing
   prior" is true for *correctness*, false for *tractability* — and tractability is the
   whole game at astronomical search spaces. The honest architecture is **LLM proposer +
   exact verifier**, where the *intelligence credited to the project* lives in the verifier
   and the search structure, not in the LLM's absence. **Pulling hardest:** the anti-LLM
   purism picks a fight the project doesn't need and can't win, and obscures that the
   defensible, winning bet (the seam) is *LLM-compatible*.

3. **General-purpose vs. code-specific.** The goal is "representation in general"; the only
   tractable instrument is code, *because* code uniquely ships with verifiers and plural
   projections. The generality is exactly what makes the toll invisible (no measuring stick);
   the code-specificity is exactly what makes it measurable. So the program is structurally
   forced to *demonstrate* in the one domain where the general claim is hardest to
   generalize *from*. **Pulling hardest:** success on code may not transfer, because code's
   ready-made verifiers are the unusual case, not the general one — the very feature that
   makes the demo possible is the feature most domains lack.

4. **Abolish-the-toll vs. make-the-toll-cheap-and-visible.** The ambitious framing (store-
   the-decision) promises to *abolish* re-translation; the floor-consistent framing only
   *mechanizes and exposes* it (never zero). These imply different success criteria — "no
   toll" vs. "cheap, visible toll" — and the goal slides between them. **Pulling hardest:**
   "abolish" is the graveyard's promise; "make cheap+visible" is the achievable one. Conflating
   them lets a project aim at the achievable target while measuring itself against the
   impossible one (and so always feeling like it's failing).

5. **Decision-as-unit vs. decision-is-observer-relative.** The floor says the decomposition
   into decisions is purpose-relative and provisional (today's one decision is tomorrow's
   two). The program needs *a* decomposition to have a unit to edit and store. So the unit of
   the entire system is, by the system's own theory, non-objective and time-varying. **Pulling
   hardest:** any store keyed on a decomposition must be re-keyed as the decomposition shifts —
   the smear relocated into the editor itself, not removed (conservation of smear applies to
   the tool). This is tension #1 viewed from the unit side, and it is why **plural** (hold
   several decompositions, mechanize translation among them) is the only floor-consistent
   resolution.

**The throughline of all five:** they are one tension seen five ways — *the constructive
program (b)/(c) keeps re-privileging a single representation that the destructive floor (a)
forbids.* Resolving it once, at the goal-altitude, dissolves all five: **adopt the plural,
toll-mechanizing framing as the goal; treat any single canonical store as a local, optional
engineering tactic for one owned language, never as the thesis.**

---

## Digest (for the dispatcher)

- **Core thesis:** Every representation is a lossy purpose-relative projection (no objective
  representation — the floor), so the honest unit of work is the *decision*, and the leverage
  is machinery that lets humans operate on decisions/intent while an efficient *verifying*
  substrate pays the projection toll by machine instead of by hand. Code is the worked
  example, not the subject; the subject is representation/intelligence in general.
- **Altitude separation:** (a) philosophical floor [destructive, settled, = the destination]
  → (b) design principle "edit the decision, mechanize the toll, seam at the leaves" [the live
  program] → (c) the code reconciler / normalize [one instrument, a *probe* of (b), explicitly
  not the goal]. **The goal is (a)+(b); the reconciler is instrumental.** Key trap: the
  (a)→(b) step is *not entailment* — a destructive floor does NOT license a single canonical
  constructive object; the floor-honest (b) is *plural projection with a mechanized toll*, not
  "the canonical decision-store."
- **Settled:** the floor; the hand-paid toll as the waste; the seam (fuzzy proposer / exact
  verifier in the loop) as architecture; code-as-example; the five-organ map *as a map*.
- **Open:** (1) what "non-LLM intelligence" buys — and whether the goal is truly anti-LLM or
  really "intelligence in the exact substrate, LLM demoted to proposer" [the most important
  thing to pin down]; (2) tool vs. theory/experiment vs. substrate — unchosen, different
  deliverables; (3) is "decision" crisply/non-circularly definable given the floor — the
  deepest, most foundational open question; (4) does organ 5's middle cell (spawned ∧
  cheaply-verifiable ∧ not-IDE-solved) exist — asserted, never exhibited.
- **Key internal tensions (all one tension, five faces):** representation-plurality vs.
  canonical store; non-LLM-intelligence vs. needed-LLM-proposer; general-purpose vs.
  code-specific-instrument; abolish-the-toll vs. make-it-cheap-and-visible; decision-as-unit
  vs. decision-is-observer-relative. Throughline: **the constructive program keeps
  re-privileging one representation that the floor forbids.** Resolve once by adopting the
  *plural, toll-mechanizing* framing as the goal and demoting any single canonical store to a
  local engineering tactic.
