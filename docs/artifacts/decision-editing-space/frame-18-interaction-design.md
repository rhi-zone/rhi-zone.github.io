# Frame 18 — Interaction Design (driving a decision-granular reconciler editor)

> Context: a program is a structure of *decisions*; text smears one decision across many
> edits; the right editing unit is the *decision*. The unified spine: ONE central axis —
> outcome-forced-by-program (mechanical shrapnel, machine-derivable) vs new-info-from-oracle
> (spawned decisions, oracle-only); MASTER discriminator = compositionality; verification is
> ground truth (Frame 11); oracle-at-leaf needs verifier-at-leaf (Frame 11 §6). VISION: you
> edit a decision-node/desired-state → machine runs fixpoint propagation, derives all
> mechanical shrapnel, enumerates FORCED spawned decisions as a worklist, PROPOSES
> discretionary ones, refuses to invent irreducible bits; derived artifacts are read-only;
> commuting decisions auto-merge (Frame 9); a decision is edited as a trajectory not a state
> (Frame 8); preconditions for the "one node" unit = compositional/acyclic/decidable/
> single-owner/reversible, else escalate to human.
>
> THIS FRAME owns the **interaction**, not the cognition (a separate frame covers programmer
> psychology/intent). The question: *how do you actually drive this thing*, and what HCI
> problems does the vision create that prior frames assumed away.

The central design claim I will defend:

> **The reconciler editor is a plan/apply loop (IaC-shaped), not a direct-manipulation
> editor (text/CAD-shaped) — and the visible-vs-invisible-shrapnel trust tension dissolves
> the moment you stop reviewing the *shrapnel* and start reviewing the *decision + its
> proof*. The shrapnel is reviewed by its verifier, not by your eyes. Frame 11's
> verifier-at-leaf is not just a soundness condition; it is the literal interaction primitive
> that earns invisible propagation. Where the verifier is cheap-total (type/contract/
> property), the shrapnel collapses to a green checkmark you trust the way you trust a
> compiler. Where it is 1→∅ (emergent invariant, ML weights), no checkmark exists, the
> tension does NOT dissolve, and the interaction must degrade — honestly and visibly — to
> empirical/staged review. The grade of the interaction is the grade of the verifier.**

Everything below is the elaboration of that claim into a concrete loop, grounded in real
paradigms (direct manipulation, structure/typed-hole editing, refactoring-preview UIs, diff/
review UX, spreadsheet recalc, IaC plan/apply). Uncertainty flagged inline.

---

## 0. The loop, end to end

The interaction is five phases. I name them as the user experiences them, then map each to
the spine and to a real paradigm it borrows from.

```
  EXPRESS  →  PROPAGATE  →  REVIEW (decision + proof)  →  RESOLVE worklist  →  COMMIT
     ↑                                                                            │
     └────────────────────────── (edit is a trajectory, undo at decision grain) ─┘
```

| Phase | What the user does | Spine | Paradigm borrowed |
|---|---|---|---|
| **Express** | Names/edits ONE decision: state a desired-state, manipulate a node, or pick a transform | the decision-bit injection | direct manipulation + IaC desired-state + refactoring palette |
| **Propagate** | (machine) fixpoint: derive mechanical shrapnel, enumerate forced spawns, propose discretionary, refuse to invent | mechanical vs spawned split | spreadsheet recalc + compiler + `terraform plan` |
| **Review** | Reads the DECISION and its PROOF — not the shrapnel; expands shrapnel only on demand | Frame 11: review the proof | IaC plan summary + refactoring preview "what will change" |
| **Resolve** | Fills the forced-spawn worklist (typed holes); approves/rejects/edits oracle proposals for discretionary spawns | oracle-at-leaf + human-as-verifier | structure editing / typed holes + LLM-autocomplete-with-accept |
| **Commit** | Applies; sees projected behavior diff become real; gets a decision-grained undo entry | reconciler apply | `terraform apply` + git commit + undo stack |

The phases are not always distinct in time — for a fully-mechanical compositional edit
(rename) Express→Commit can be one gesture with the middle three collapsed to a flash of a
green proof. For a 1→∅ edit they blow up into a multi-day staged-rollout interaction. **The
loop is the same shape; its phases dilate with the compositionality grade.** That dilation,
made visible, is itself the honesty mechanism (§5).

---

## 1. EXPRESS — what the user does to inject a decision

The vision lists four candidate input modalities. They are not alternatives to choose
between; they are **four faces of the same act, each ergonomic for a different decision
class.** The design decision is *which face to surface for which class*, and the discriminator
is — again — compositionality + the shape of the decision-bit.

1. **Desired-state declaration** (IaC `*.tf` / Kubernetes manifest / spreadsheet cell
   formula). You write *what should be true*, not the steps to make it true. Ergonomic for
   decisions whose content is a *value or a relation*: "tax rate is 8.25%", "this field is now
   non-null", "these two aggregates stay consistent", "the cache evicts LRU". The machine
   computes the delta from current state to declared state. This is the **default face**,
   because it is the one that most directly *is* the decision (the decision-bit literally is
   the declared value) and it is the one that makes the reconciler a reconciler.

2. **Direct manipulation of a node** (drag, type-into, structure edit). You grab the
   AST/decision-graph node and change it in place. Ergonomic for *point* decisions with an
   obvious locus: invert a condition, change a literal, reorder two independent statements.
   This is the cheap path for the cheap cases — it must exist so the trivial edit stays
   trivial (the failure mode of structure editors is making `2 → 3` require a wizard).

3. **Select-and-transform / generalized refactoring palette** (Extract Method, Inline,
   Change Signature — but as first-class *decisions* rather than IDE commands). You select a
   region/node and pick a named transform. Ergonomic for *structural* decisions that are
   behavior-preserving or behavior-shaped-by-a-known-template: "make this parameter a field",
   "split this type", "thread this effect". The palette is the curated set of transforms whose
   *propagation is known-mechanical* — i.e., the transforms for which the machine can derive
   all shrapnel because the transform is a compositional rewrite rule. **This is the band
   where invisible propagation is most trustworthy**, because the transform's soundness is
   pre-proven once (the refactoring's correctness theorem) rather than per-application.

4. **Constraint / property assertion** (a contract, an invariant, a property-based test as
   *input*). You state `∀x. P(impl(x))` and the machine treats it as a decision to be made
   true. Ergonomic for the non-compositional-over-inputs band (Frame 11 §3.2): you cannot
   point at a locus, but you *can* point at the property. The machine then either derives an
   implementation (rare), enumerates the obligation as a worklist, or — honestly — tells you
   it cannot and hands you a hole.

**Design ruling:** the editor offers a *single unified surface* whose default is (1)
desired-state, with (2)/(3)/(4) as affordances reachable from any node. Crucially, **the
modality is a projection of the decision, not a property of it** — the same rename decision is
expressible as "edit the name node" (2) or "declare the new name" (1); the editor picks the
ergonomic default per class but never makes the decision *only* reachable one way. This is
Frame 2's multi-representation principle applied to *input*, not just *view*.

The open ergonomic risk (flagged, §8): desired-state declaration has a notorious gulf-of-
execution problem — users find it *harder* to say "what should be true" than "what to do"
(the documented learning curve of IaC, SQL, constraint solvers, and spreadsheet formulas
versus imperative scripting). Mitigation is the palette (3) as training wheels: every
direct-manipulation gesture is *recorded as the desired-state declaration it implies* and
shown, so the user learns the declarative form by seeing their imperative gesture transcribed
into it. (This is the spreadsheet move: you click a cell, it shows you the formula.)

---

## 2. PROPAGATE — the machine's turn (no user action; sets up Review)

This phase is the reconciler computing the fixpoint. The user does nothing; but *what it
produces* determines the entire Review interaction, so it belongs here. It produces a
**typed plan** with four strata, each interacting differently:

| Stratum | What it is | Default visibility | Why |
|---|---|---|---|
| **Mechanical shrapnel** | edits forced by the decision, machine-derived, verifier-backed | **collapsed** → shown as a count + one proof token | this is the shrapnel you were trying to escape; showing it re-imposes the burden (§4) |
| **Forced spawned** | decisions the change *creates* and that MUST be answered (new enum arm's behavior, new null-handling) | **expanded as a worklist** | these are genuine decision-bits the machine cannot invent; they are the to-do list |
| **Discretionary spawned** | decisions created but with a default the oracle can propose | **collapsed proposals** → "3 suggestions, review?" | human-as-curator; opt-in, not forced (§3) |
| **Refusals / escalations** | bits the machine will NOT invent (irreducible, or precondition violated: cyclic/non-decidable/multi-owner/irreversible) | **surfaced as blockers** | the vision's "refuses to invent"; an honest dead-end, not a guess |

This four-stratum plan is the direct analog of `terraform plan`'s `+/~/-/known-after-apply`,
but typed by the spine's mechanical/spawned axis rather than by create/update/destroy. **The
plan is the artifact the trust tension is fought over** — and the resolution (§4) is entirely
about which strata are visible by default and what stands in for the invisible ones.

---

## 3. The role of the LLM-oracle in the loop — human as verifier/curator

The oracle appears in exactly two strata, and the interaction discipline is sharply different
from "the model edits your code":

- **Forced-spawned worklist:** the oracle may *propose a fill* for each hole, but the hole
  stays a hole — typed, red, blocking — until a human (or a cheap-total verifier) accepts. The
  oracle's proposal is rendered like an autocomplete ghost: present, dismissible, never
  applied silently. This is the gulf-of-evaluation problem head-on: the human must be able to
  *evaluate* the proposal cheaply, which is only possible when the hole has a verifier (the
  type checker rejects a mistyped fill; the contract fails; the property falsifies). **The
  oracle is allowed to propose exactly and only into holes that have a leaf-verifier (Frame 11
  §6).** Where a hole has no verifier, the oracle may still propose, but the proposal is marked
  *unverifiable* and acceptance is logged as a human assumption of risk — the interaction
  refuses to let an unverified oracle bit masquerade as a checked one.

- **Discretionary-spawned proposals:** here the oracle is a *curator's assistant*. It
  proposes the discretionary default (naming, ordering of independent effects, which of two
  equivalent structures); the human curates by accept/reject/edit. Because these are
  decision-bits with ~0 attestation cost (Frame 11 §0 — "nothing to be wrong about"), the gulf
  of evaluation is shallow and batch-acceptance is safe ("accept all suggested names").

**The hard interaction rule, stated once:** *the oracle never closes a hole; it only fills the
ghost.* Closing is a human act (or a verifier's automatic act when the fill type-checks and the
human has pre-authorized auto-close for verified fills). This keeps the oracle at the leaf and
out of the control loop — and it does so *as an interaction property*, not just an
architectural one: the control loop is the human walking the worklist; the oracle is a
leaf-decoration on that walk.

---

## 4. The visible-vs-invisible-shrapnel trust tension — the resolution

This is the frame's load-bearing problem, so I treat it directly.

**The dilemma, sharp:** the entire point was to stop forcing the human to hand-process
shrapnel. But:
- **Invisible propagation** (the machine applies the N−1 derived edits silently) =
  action-at-a-distance dread. The human knows a fallible (LLM-assisted) engine touched code
  they cannot see; they have traded N edits for a leap of faith. This is the documented terror
  of "magic" refactorings and of `terraform apply` on a plan you didn't read.
- **Visible propagation** (the machine shows all N derived edits for approval) = you are
  drowning in exactly the shrapnel you were escaping. A rename across 400 sites shown as a
  400-hunk diff has re-imposed the original burden; the human rubber-stamps it (review
  fatigue), which is *worse* than invisible because it launders blind trust as review.

Neither pole works. The resolution is **not** a slider between them. It is a **change of the
object under review**:

> **You do not review the shrapnel. You review the DECISION and its PROOF. The shrapnel is
> reviewed by its verifier.**

Concretely, the Review phase shows, per decision, a **proof token** whose strength is the
compositionality grade of the decision (Frame 11 is the whole basis here):

| Decision grade | Proof token shown | What the human reviews | Shrapnel visibility |
|---|---|---|---|
| Compositional + decidable (rename, signature, exhaustiveness) | **"derivation is the proof"** — a green badge: *"42 sites rewritten; type-checked; rewrite rule R is sound"* | the *decision* ("did I mean to rename this?") + that the badge is green | invisible by default; expandable to the 42 hunks if you insist, but you don't need to |
| Compositional + needs spawned behavior (enum arm + its semantics) | **coverage proof** (all arms reached) + **worklist** (each arm's behavior) | the coverage badge (machine) + each arm's intended behavior (you, in the worklist) | the *reachability* shrapnel is invisible-trusted; the *semantic* shrapnel is the worklist you fill |
| Schema / cross-substrate (1→N verification) | **re-derive check** + per-consumer contract status | the contract dashboard (which consumers are green/red) | shrapnel grouped by consumer, collapsed per-consumer, expand on red |
| Non-compositional global (security ∀-sites, consistency) | **completeness proof or its absence** — taint/choke-point analysis result, or a RED "no local proof exists" | whether a *global* witness exists; if not, you review the *architecture* not the edits | N/A — there is no per-site shrapnel that witnesses this; showing per-site diffs would be the lie Frame 11 §5 names |
| Behavior-IS-substrate (ML weights, prompt) | **eval delta + canary plan** — empirical only | the eval movement on measured inputs + the staged-rollout plan | no shrapnel; no static proof; the "diff" is a distribution shift over time |

**Why this resolves the tension:** the dread of invisible propagation is *fear of an
unverified engine*. A cheap-total verifier (Frame 11) converts the engine's output from
"trust me" into "here is a deterministic proof a wrong edit would have been rejected." You
trust the invisible 42-site rename for exactly the reason you trust an invisible compiler
optimization: **not because you read the output, but because a sound checker stands between the
fallible producer and you.** The proof token *is* the verifier-at-leaf surfaced as UI. So:

- Invisible propagation is earned *precisely where a cheap-total verifier exists* — and there,
  invisibility is not blind trust, it is the same warranted trust you give `rustc`.
- Where no such verifier exists (the bottom two rows), **the tension is NOT resolved, and the
  honest interaction is to say so**: the proof token goes red/empirical, invisibility is
  *refused*, and the human is escalated to review the architecture (global case) or the
  staged-rollout evidence (empirical case). The editor never offers a green badge it cannot
  back — that would be authority-dressed-as-evidence (Frame 11 §5).

This is the IaC plan/apply discipline corrected by Frame 11: `terraform plan` shows you the
*resources*, which is still shrapnel and still suffers review fatigue. The reconciler editor
shows you the *decision and a soundness proof*, and only drops to resource-level when the proof
is weak. The codemod (Frame 11 §2 pseudo-localizer) is the cautionary case: it makes the *edit*
one gesture but its output is unproven text-pattern, so it *cannot* offer a green token and
*must* show all sites — the editor would render a codemod-class transform with full shrapnel
visibility and an explicit "unproven, review every site" banner, distinguishing it from a
type-derived rename that shows a badge. **The proof token's color is the user's signal for
whether they are escaping shrapnel or merely relocating it to their eyes.**

---

## 5. PREVIEW & COMMIT — projected behavior diff, then reconcile

Before commit, the user sees a **behavior diff**, not (primarily) a source diff. This is the
direct realization of the reconciler vision: you edited a decision, you want to see *what the
program will now do differently*, not *which characters changed*.

- **For decidable cases:** the behavior diff is a set of input→output pairs that changed
  (computed by running the old and new program on a representative/property-generated input
  set, or by symbolic diff where tractable). "These 3 of 200 test inputs now return a
  different value; here they are." This is far more reviewable than a source diff and is the
  thing the human actually has an opinion about.
- **For the empirical band:** the "preview" is a *plan for how the behavior diff will be
  measured* (canary %, eval suite, rollback trigger) — because the diff cannot be known before
  running. Commit here means *begin the staged rollout*, and the loop stays open across time
  (§6).

**Commit** is `apply`: derived artifacts become real and **read-only** (the vision's
constraint — you cannot hand-edit generated shrapnel; editing it means re-opening the decision
that generated it). The behavior-diff-before-apply / apply-reconciles structure is the literal
plan/apply loop, with the diff upgraded from resource-level to behavior-level.

---

## 6. Viewing & editing through projections (Frame 2, applied to the live editor)

The program is never shown as "the source." It is shown through **task-specific projections**,
and *every projection is editable* (edit-through-projection), with edits resolving back to the
single decision-graph and re-propagating. Concrete projections the editor offers:

- **Decision-graph view** — nodes are decisions, edges are forces-relations; the primary
  navigational surface. Editing a node = Express (§1).
- **Behavior/IO view** — input→output table (spreadsheet-shaped); edit an output cell ⇒ the
  editor asks "which decision should change to make this output true?" and routes you to the
  node (or proposes one). This is the "programming by example / live spreadsheet" projection.
- **Source-text projection** — for humans who think in text; it is a *rendering* of the
  decision-graph, edits are parsed back to decision deltas. Critically this means text editing
  still works, but a text edit that touches derived (read-only) shrapnel is rejected with
  "this is derived from decision D; edit D."
- **Worklist projection** — the forced-spawn holes as a checklist / structured interview
  (§7).
- **Verification projection** — the proof tokens and their status (the §4 table, live).

The hard part (flagged §8): **edit-through-projection requires a sound bidirectional mapping**
(lens) between each projection and the decision-graph, and bidirectional transformations are a
known-hard, often-leaky research area (the view-update problem in databases; Boomerang/lenses;
the general impossibility of a total clean inverse for lossy projections). Some projections
(the behavior/IO view) are *necessarily* lossy backward — many decision-changes produce the
same output change — so editing through them is *ambiguous* and must escalate to "which
decision did you mean?" rather than guess. I do not claim this is solved; I claim the editor
must treat backward-ambiguity as a first-class escalation, not paper over it.

---

## 7. The spawned-decision worklist — surfacing & navigation

The forced-spawned stratum (§2) is the genuinely-new work the human must do, and its UI is the
make-or-break of the whole interaction (it is where the burden that *isn't* shrapnel lives).
Three real paradigms compose into the answer:

1. **Typed holes (structure-editing / Hazel / Agda / Idris).** Each forced spawn is a typed
   hole in the program: it has a known type/contract (so the oracle can propose and the
   verifier can check a fill), it is navigable ("jump to next hole"), and the program is
   *runnable with holes* (Hazel's key property) — you can preview behavior with some holes
   still open, seeing `?` propagate into the behavior diff. This is strictly better than a
   flat checklist because the hole carries its verifier with it.

2. **Compiler-errors-as-worklist (Frame 2 §2, propagation-by-failure).** The worklist is
   exactly the set of non-exhaustive-match-style obligations, but presented as a *to-do* with
   progress (`7 of 14 arms decided`) rather than as errors to be silenced.

3. **The editor as a structured interview.** For a decision that spawns many forced
   sub-decisions, the editor walks you through them one at a time with context — "you added
   case `Refunded`; what should `computeTotal` do for it? (here's the type it must return, here
   are the sibling arms for reference)". This is the wizard/structured-interview paradigm, and
   it is the right shape when spawns have dependencies (answer A constrains the type of hole
   B).

**Navigation ruling:** holes form a (partial) order by dependency; the worklist is traversed
in topological order, with independent holes batchable and dependent holes gated. A hole is
*closed* only when filled-and-verified; the commit is blocked while forced holes remain open
(you cannot ship a program with an undecided forced spawn — that is the editor enforcing the
"refuses to invent" rule at the interaction layer).

---

## 8. Undo/redo and temporal/trajectory edits (Frames 8, 9)

**Undo at decision granularity.** The undo stack is a stack of *decisions*, not keystrokes or
even source-diffs. Undoing a decision re-runs the reconciler to un-propagate its shrapnel and
re-open its spawns. Because commuting decisions auto-merge (Frame 9), the undo stack is really
a *DAG*, and selective undo ("undo decision D but keep the three decisions made after it that
don't depend on D") is possible exactly when D commutes with them — the editor offers
selective undo precisely over the commuting set and refuses (escalates) over the
non-commuting set. This is a genuine advance over linear undo and a direct payoff of the
algebra frame; it is also a known-hard UI (selective/regional undo has a thin track record —
flagged).

**Trajectory/temporal edits (Frame 8) — the hardest display problem.** When the decision is a
*migration over time* (online schema change, gradual rollout, dual-read/dual-write window),
you are not editing a state; you are editing a *trajectory* — a sequence of intermediate states
that must each be valid and the transitions safe. The interaction cannot be a single diff. The
design I propose, flagged as the least-certain part of this frame:

- The decision is authored as a **trajectory declaration** — a sequence of desired-states with
  invariants that must hold *at every step and across every transition* (e.g., "at all times,
  old and new readers see consistent data"). This is the IaC-migration / saga / workflow-engine
  shape.
- It is *viewed* as a **timeline projection** — a horizontal sequence of phases, each a
  desired-state, with the cross-phase invariants drawn as bands spanning the phases they
  constrain. Editing the trajectory = editing this timeline (insert a phase, change a phase's
  state, tighten an invariant).
- Its **proof token is temporal** (Frame 11 §1, "1→sequence"): the verifier must attest each
  phase *and* each transition, and the behavior diff is per-phase. The canary/dual-read check
  is the runtime verifier, surfaced as a live per-phase status on the timeline.
- **Commit is staged**: applying a trajectory means scheduling its phases; the editor stays
  open across the rollout, the timeline lights up phase-by-phase, and a failed invariant at
  phase k triggers the (declared) rollback of phases ≥k. This is where the loop is most dilated
  in time and where the editor most resembles a workflow/orchestration console rather than a
  text editor.

I am least confident here: I have not seen a deployed editor that treats a temporal migration
as a single editable object with cross-phase invariant proofs; the nearest real things
(workflow engines, deployment pipelines, DB online-migration tools like gh-ost) author the
trajectory *imperatively/operationally* and do not give it a decision-granular reconciler
treatment. So this section is design-by-analogy, explicitly speculative.

---

## 9. The hardest unsolved interaction problems (honest list)

These are the problems the vision *creates* and that I cannot claim are solved. They are the
frame's main contribution to "what's hard," and they should drive any prototype.

1. **Backward-ambiguous edit-through-projection (§6).** Lossy projections (behavior/IO view,
   any abstraction) have no clean inverse; editing through them is fundamentally ambiguous and
   must escalate, not guess. The view-update problem is decades-old and unsolved in general.
   This caps how "live"/manipulable the high-level projections can be.

2. **The proof-token gulf-of-evaluation (§4) for the empirical band.** Where the proof token
   is empirical (ML weights, canaries), the human must evaluate a *distribution shift* — a far
   harder perceptual/cognitive task than reading a green badge, and the failure mode is exactly
   the confident-wrong acceptance the ecosystem most fears. We have *no* good UI for "is this
   eval delta good enough to trust?" that isn't itself an expert judgment call. The tension
   does not dissolve here; it relocates into "how do you make an empirical proof token
   reviewable," which is open.

3. **Trust calibration / proof-token literacy.** The whole resolution (§4) rests on the user
   *correctly reading the proof token's strength* — trusting the green badge and *not* trusting
   the red/empirical one. But humans habituate: after 200 green rename badges, they will
   rubber-stamp the one schema change that wasn't actually fully verified. Designing a token
   system that resists habituation (so that a *weaker* proof visibly *feels* weaker, every time)
   is an unsolved affective/perceptual-design problem. Get this wrong and you have rebuilt
   review-fatigue one level up.

4. **Selective/DAG undo over the commuting set (§8).** Right in principle (Frame 9), but
   regional/selective undo has a poor usability track record; presenting a non-linear undo
   history navigably is hard, and the commute-test that gates it is itself only as good as the
   compositionality analysis (which is undecidable in general — Frame 10).

5. **Temporal/trajectory editing as a single object (§8).** No precedent treats a migration-
   over-time as one decision-granular editable artifact with cross-phase invariant proofs. The
   timeline projection is plausible; that it can be *driven* without collapsing back into
   operational scripting is unverified.

6. **Refusal UX — the productive dead-end.** The vision's "refuses to invent irreducible bits"
   and "escalate to human when preconditions fail (cyclic/non-decidable/multi-owner/
   irreversible)" is *correct* but is, interactionally, the editor saying *no*. Designing a
   refusal that is read as "this genuinely needs you" rather than "the tool is broken/limited"
   — and that hands the human the *right* next move rather than dumping them back into raw text
   — is unsolved and easy to get demoralizing. The escalation must arrive with the *reason* (the
   violated precondition) and the *minimal manual frontier*, or users route around the whole
   editor.

7. **The single-owner precondition vs. real multi-author edits (Frame 15).** The "one node /
   single-owner" precondition collides with collaborative editing: two people editing
   neighboring decisions, where commute-merge (Frame 9) handles the easy case but
   non-commuting concurrent decisions need a *decision-level merge-conflict UI* that has no
   precedent (git's text-conflict UI is exactly the shrapnel-level tool this whole project is
   trying to replace). What does a *decision*-level conflict even look like to two humans? Open.

---

## 10. Digest

- **Loop:** EXPRESS (desired-state declaration default; direct-manipulation / refactoring-
  palette / property-assertion as per-class faces; input modality is a projection, not a
  property) → PROPAGATE (machine emits a four-stratum typed plan: mechanical-shrapnel,
  forced-spawned, discretionary-spawned, refusals) → REVIEW the **decision + its proof token**,
  not the shrapnel → RESOLVE the forced-spawn worklist as runnable **typed holes** with the
  oracle filling *ghosts* it never closes (closing is human/verifier) → COMMIT via a
  **behavior diff** (input→output deltas, not source diff) that reconciles, derived artifacts
  read-only. Phases dilate with compositionality grade; for a rename they collapse to a flash,
  for a migration they spread across a staged rollout.

- **Trust tension resolved by changing the object of review:** you never review the shrapnel
  (visible = drowning, the burden you fled) and never blind-trust it (invisible = action-at-a-
  distance dread). **You review the decision and a proof token; the shrapnel is reviewed by its
  verifier-at-leaf (Frame 11).** Invisible propagation is *earned* exactly where a cheap-total
  verifier (type/contract/property) backs a green token — there it is warranted trust, same as
  trusting a compiler. Where no such verifier exists (non-compositional global properties; ML
  weights / behavior-IS-substrate), the token goes red/empirical, invisibility is **refused**,
  and the user is honestly escalated to architecture-review or staged-rollout evidence. The
  token's strength = the verifier's grade = the compositionality grade. A codemod is the
  cautionary inverse: one gesture, no proof, so it *must* show all sites with an "unproven"
  banner — distinguishing real localization from smear merely relocated to the eyes.

- **Hardest unsolved problems:** (1) backward-ambiguous edit-through-lossy-projection (view-
  update problem, decades-unsolved) caps live manipulability of high-level views; (2) no good
  UI for evaluating an *empirical* proof token (eval/canary distribution shift) — the gulf of
  evaluation survives in the 1→∅ band; (3) proof-token-literacy / anti-habituation so a weaker
  proof reliably *feels* weaker and review-fatigue isn't rebuilt one level up; (4)
  selective/DAG undo over the commuting set (thin usability precedent); (5) temporal/trajectory
  editing as a single decision-granular object with cross-phase invariant proofs (no
  precedent); (6) refusal UX that reads as "this needs you" + hands over the minimal manual
  frontier, not "tool broke"; (7) decision-level merge-conflict UI for non-commuting concurrent
  edits — git's text-conflict UI is exactly the shrapnel-tool this project replaces, and there
  is no decision-level analog.
