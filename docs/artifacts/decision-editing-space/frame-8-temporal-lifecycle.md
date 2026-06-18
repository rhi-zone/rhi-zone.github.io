# Frame 8 — Temporal / lifecycle: a decision is a *process*, not a state

**Method.** The prior four frames map the space of single-decision behavior changes
*spatially*: where a decision lives in program structure (Frame 1), what representation
would localize it (Frame 2), whether the smear is mechanical shrapnel or spawned
sub-decisions (Frame 3), and what edits empirically occur (Frame 4). All four take an
implicit snapshot: they ask "for one decision, how is it scattered across the *text*?"
This frame rotates the question onto the **time axis**: for one decision, how is it
scattered across the *history* — across commits, deploys, releases, and the running
population of the system?

Frame 4 §3 named the seed ("one conceptual entity emits different edit-kinds over its
lifecycle"; feature flag: birth = fan-out, flip = point-edit, death = dead-code-removal)
and §"Compat / version shim" / §"Revert" gestured at it, but explicitly left it for a
temporal frame to develop. This is that frame. The thesis it sharpens:

> A decision is not a point you can edit; it is a **trajectory**. The text-smear that the
> other frames fight in *space* has a sibling that no editor of a single program state
> can ever collapse: a smear in *time*, forced by the fact that the world will not let
> the old behavior and the new behavior coexist at one instant. Some of the most
> important single decisions are **intrinsically temporal** — they cannot be one atomic
> edit even in principle, because their correctness *is* a sequence.

The discriminator that earns a place in this frame: **the smear is not a deficiency of
representation that a better tool could collapse — it is mandated by the requirement that
two states of the world overlap.** That distinguishes a temporal smear from the spatial
smears of Frames 1–4. A rename smears across N call sites because no tool localized it;
fix the representation and it collapses to one gesture. An expand/contract migration
smears across ≥2 deploys because at the instant of the change there exist, simultaneously,
producers on the old schema and consumers on the new one *and you do not control when each
restarts*. No representation collapses that. The atom is a sequence.

---

## Part I — The lifecycle of a single decision, and the edit-kind each phase emits

Take one logical decision — say "messages now carry a `priority` field" — and watch it
live. It is not one edit; it is a **lifecycle** with phases, and each phase emits a
*structurally different* edit-kind. The same decision is a fan-out at one age and a
dead-code deletion at another. A static taxonomy of "what is a decision" (Frames 1, 3)
cannot see this because it photographs the decision at one age.

| Phase | The decision's content at this phase | Edit-kind emitted | Smear character | Reversible? |
|---|---|---|---|---|
| **Introduce** | "this thing now exists" | additive fan-out: new field/branch/registration + first consumer + default + test | spatial (Frame 1/4 territory) | yes — additive, `git revert` clean *if nothing depended on it yet* |
| **Evolve** | "the thing now behaves differently" | point-edits to the locus + possibly re-fan-out if the contract widened | small, unless the change is itself contract-breaking (→ Part II) | usually |
| **Stabilize / promote** | "this is now the default / the only path" | flip a default; delete the *alternative* branch | low at flip, fan-out at branch-delete | flip yes; branch-delete no (the old path is gone) |
| **Deprecate** | "this still works but you must stop using it" | *additive again* — a warning, a shim, a compat alias, a lint, a doc note | **spawns a long-lived bridge** (Part IV) — adds code rather than removes it | yes (remove the warning) |
| **Remove / sunset** | "the thing no longer exists" | dead-code/dead-branch deletion at every site + drop the column/endpoint | fan-out deletion; **crosses into irreversible** if it drops data/contract | often NO (Part V) |

Five observations the table makes that the spatial frames structurally cannot:

1. **Birth and death are mirror fan-outs, not one fan-out.** Introducing a variant forces
   edits at every match site (Frame 1.D); *removing* it forces edits at the same sites
   again. These are two separate single-decisions ("add Pending", "Pending is gone"),
   separated by the entity's whole lifetime, each a fan-out, with a *low-smear flip* in
   between. The entity's identity persists; the edit-kind it emits is a function of its
   **age**, not its structure.

2. **Deprecation is additive, removal is subtractive — and they are different decisions
   made at different times.** This is the single most under-modeled fact. "Deprecate X"
   does not remove X; it *adds* a tombstone (a `@deprecated`, a console warning, a 299
   header, a migration shim) and thereby **grows** the codebase. The shrinkage is a
   *later, separate* decision ("remove X") that may never come. A decision-editor that
   models "remove X" as one act is wrong: in practice it is `deprecate(X)` at time t₀ and
   `remove(X)` at time t₁, with a deliberate gap during which *both* the warning and the
   thing coexist (Part IV).

3. **The reversibility of a decision changes across its own lifecycle.** The *same* logical
   decision is cleanly revertible at birth (additive) and irreversible at death (it
   destroyed the alternative / the data). Reversibility is not a property of the decision;
   it is a property of the decision *at an age* (Part V).

4. **The "flip" is the only phase where decision ≈ edit.** This is exactly why feature
   flags feel powerful: they manufacture a phase where the expensive part (the fan-out of
   introducing the branch) is already paid, so the *behavior change itself* is a one-line,
   instantly-reversible edit. Flags are a technology for **relocating a decision's
   high-smear phases away from the moment of behavior change.**

5. **Most decisions die uncompleted.** The lifecycle's terminal phases (remove, sunset)
   are the ones that empirically *don't happen* — dead flags, un-removed shims, `/v1`
   endpoints alive years past `/v2`. This is the ecosystem's own "finish migrations before
   building on top; fence what you can't finish" principle observed in the wild: the
   temporal lifecycle is where migrations go to *not finish*. The residue (Part IV, V) is
   the norm, not the exception.

---

## Part II — Intrinsically temporal smears: changes that *cannot* be one atomic edit, even in principle

This is the heart of the frame and its sharpest contribution. Frames 1–4 implicitly
assume that *if* you had the perfect representation, every single-decision change could be
one gesture. This frame identifies a class where that is **false** — where atomicity is
impossible not for want of tooling but because the deployment substrate forbids it.

The defining condition: **at the moment of change, the old and new behaviors must coexist,
because the parts of the system are not all updated at the same instant.** The smear is
mandated by overlap.

### II.A — Expand/contract (a.k.a. parallel change) — the canonical intrinsic smear

The expand/contract pattern (Sato/Fowler's "parallel change") is the load-bearing
real-world example, and it is *the* proof that some decisions are processes. Take the
single logical decision: **"rename column `username` → `handle`."** In a textbook with a
stop-the-world database and a single binary, that's one atomic edit. In any system with a
live database and rolling deploys, it is **mandatorily** a sequence of ≥3 deploys:

1. **Expand.** Add `handle`; have writes go to *both* `username` and `handle`; reads still
   prefer `username`. Backfill `handle` from `username` for old rows. (Additive — safe to
   deploy while old code still runs.)
2. **Migrate readers.** Flip reads to `handle`. Now old instances (reading `username`) and
   new instances (reading `handle`) coexist during the rollout — which is *only* safe
   because step 1 made both columns valid simultaneously.
3. **Contract.** Once no code reads `username`, stop writing it, then drop it. (Subtractive
   — and the point of no return: dropping the column is irreversible, Part V.)

Why this is **intrinsic**, not a tooling failure: during step 2's rollout there exist, at
the same wall-clock instant, a process running old code and a process running new code,
both hitting the same database, and **you do not control the interleaving** — Kubernetes
decides restart order; a connection may have been opened by an old pod and serve a request
after a new pod is live. For the system to be correct *throughout* the transition, the old
and new contracts must both be satisfiable *simultaneously*. The "double-write / read-old"
state in step 1 is not redundant scaffolding a smarter editor could elide — it is the
**only** state in which the next step is safe. The decision's correctness *is* the ordered
sequence. Compress it to one deploy and you get errors during the window, guaranteed.

The same shape governs:
- **DB schema migrations** (add nullable → backfill → enforce NOT NULL → make required;
  never "add NOT NULL column" in one shot against a populated table).
- **Wire-protocol / API field changes** (add field as optional → migrate producers →
  migrate consumers → make required → remove old). Protobuf's "never reuse a field number,
  reserve removed ones" rule is this pattern frozen into the format: the *number* carries
  temporal identity precisely because old and new readers coexist on the wire.
- **Event-schema / message-queue evolution** (consumers and producers deploy
  independently; an in-flight message was serialized by yesterday's producer and is read
  by today's consumer — the queue is a *time machine* that forces forward/backward
  compatibility).
- **Cross-service contract changes** generally: any change spanning two independently
  deployed units is intrinsically temporal, because "independently deployed" *means* "no
  shared instant of change."

### II.B — The general principle: a state machine you cannot skip states in

What unifies II.A is that the change traverses a state machine of **(old-only) → (old+new
coexist) → (new-only)** where the middle state is *mandatory* because it is the only
bridge that is safe to occupy while the population is mixed. You cannot teleport from
old-only to new-only; some part of the running world is always mid-transition.

Contrast with a spatial smear (rename a function): there the intermediate state (some call
sites renamed, some not) is *unsafe* and the whole point of a codemod is to never occupy it
— the edit is atomic *in the artifact* even if applied incrementally, because you ship the
fully-renamed artifact. In an intrinsic temporal smear you are *forced to ship and run* the
intermediate state. **That is the line:** if the intermediate state must run in production,
the decision is intrinsically temporal; if the intermediate state need only exist in your
working tree, it is a (collapsible) spatial smear.

### II.C — Other intrinsically-temporal classes

- **Stateful data transforms.** Re-encoding stored data (cents→millicents, naive→UTC,
  re-keying by UUID — Frame 1.E examples) is intrinsic the moment the data is *at rest and
  large*: you cannot transform petabytes atomically, so there is a window where some rows
  are old-format and some new, and code must read both. The representation decision (Frame
  1.E, "store money as cents") has a *spatial* face (every producer/consumer converts) and
  a *temporal* face (the existing corpus must be migrated through a both-formats window).
  Frame 1 saw only the spatial face.
- **Cache / index / materialized-view introduction.** Building the index over existing data
  takes time; during the build, reads must fall back to the un-indexed path. The
  "introduce a cache" decision (Frame 4) is intrinsically a warm-up sequence.
- **Capacity / quota / rate-limit tightening** against live traffic: you ramp the limit
  down over time to avoid mass-rejecting in-flight clients — the decision is a *schedule*,
  not a value.
- **Cryptographic / credential rotation.** Both old and new keys must validate during the
  overlap window (you can't invalidate the old key the instant you mint the new one — live
  sessions hold it). Classic add-new → accept-both → issue-new-only → revoke-old.

---

## Part III — Gradual rollout, feature flags, canaries: one decision deliberately split across time *and population*

Part II's smears are forced by the substrate. This part is the *dual*: smears the engineer
**chooses** to introduce, splitting one decision across time and across the *population* of
requests/users/hosts — trading atomicity for observability and reversibility.

A canary / percentage rollout makes the decision a function of **two** extra dimensions
beyond the code: **time** (0% → 5% → 50% → 100% over hours/days) and **population** (this
user cohort, this region, this ring). The single decision "turn feature F on" becomes a
*trajectory through a (time × population) space*. Real platforms (LaunchDarkly, Unleash,
Flagsmith, Statsig; Google/Meta internal config systems) make this an explicit first-class
object — and that is the strongest evidence in the whole frame that **industry already
treats some decisions as temporal objects, just not inside the source editor** (Part VI).

Key structure:
- **The behavior change is decoupled from the deploy.** Code ships dark (flag off) — that
  ship is an *introduce* edit (Part I), high-smear, but behaviorally inert. The *decision*
  ("F on for 50%") is then a data change in the flag system, made and reversed without a
  deploy. This is the cleanest real-world realization of "edit the decision, not the text":
  the flag value *is* the decision, edited as data, projected onto behavior at runtime.
- **Reversibility is the whole purpose.** A canary exists so the decision is *instantly
  revertible* during the risky window — flip the flag, no deploy, no `git revert`. The
  temporal split *buys* reversibility that an atomic deploy lacks.
- **The flag is itself a Part-I lifecycle entity**, and its death is the notorious failure:
  the "introduce" was easy (data), but the "remove" (delete the dead branch at every
  consumption site, Frame 4 §feature-flag) is a fan-out nobody schedules. Flag debt is the
  canonical un-finished lifecycle.
- **Population-conditioning makes the decision non-Boolean over the system.** At 50% there
  is no single answer to "is F on?" — it is on *here* and off *there*, simultaneously. The
  decision's *value* is a distribution, not a state. No snapshot of one program state, and
  no snapshot of one request, captures the decision; only the (time × population) function
  does.

---

## Part IV — Deprecation cycles & compat shims: one decision that spawns a long-lived bridge

Deprecation is the lifecycle phase the spatial frames most thoroughly miss, because its
edit-kind is *counterintuitive*: to (eventually) **remove** something you first **add** to
it. The decision "stop using X" emits, in order:

1. **Mark.** Add a deprecation signal — `@Deprecated`, `Deprecation`/`Sunset` HTTP headers
   (RFC 8594), a runtime warning, a changelog entry, a lint rule that fails new uses. Pure
   addition. Reversible.
2. **Bridge.** Add a **compat shim** that lets old callers keep working against new
   internals — an alias, an adapter, a translating proxy, a back-fill. This is a *spawned
   sub-decision* (Frame 3) with its own lifetime: a small, deliberate, by-design smear (a
   second code path) whose entire reason to exist is to be deleted later.
3. **Wait.** A deliberately *empty* phase whose duration is a policy (a deprecation window:
   one minor version, two majors, a calendar quarter, "until telemetry shows zero use").
   The decision is *literally* the passage of time plus a measurement.
4. **Remove.** Delete X and the shim (Part I death — fan-out deletion).

Why this matters to the editing-unit question: the bridge is a piece of code whose *meaning
is temporal*. Read at an instant it looks like cruft (Frame 3 mechanical-shrapnel) or a
duplicated path. Its honest description is "the t₀..t₁ half of the decision `migrate X→Y`."
The ecosystem's "retire, don't deprecate" principle is precisely a stance *against*
entering this cycle when you can take the atomic path instead — but that principle is only
available when *you* own all the callers (you can do the fan-out now). The instant a caller
is outside your control (a public API, another team, a third party), the deprecation cycle
is **forced** and you are back in Part II's intrinsic-temporal regime: you cannot remove X
atomically because someone you don't control still calls it, and you don't decide when they
stop.

So the deprecation cycle is the bridge between the *chosen* smears (Part III) and the
*forced* smears (Part II): you choose to deprecate rather than break, but once a contract
crosses an ownership boundary the *length* of the bridge stops being yours to set.

---

## Part V — Reversibility: which decisions `git revert` actually undoes, and which leave residue

`git revert` undoes a **text** state. It says nothing about the **world** state the original
commit also changed. The lifecycle frame exposes a hard partition:

- **Cleanly reversible** (`git revert` is the whole undo): pure-code, pure-additive,
  no-data, no-external-effect decisions. Adding a function, a branch behind an off flag, a
  new optional field *not yet populated*. The decision touched only the artifact; reverting
  the artifact reverts the decision. (Frame 4 §revert correctly flagged this as the
  *existence proof* that decision-granular editing works — but only for this class.)
- **Reversible-with-compensation**: the code revert is necessary but not sufficient; you
  need a *compensating action* (a down-migration, a backfill-the-other-way, a refund, a
  re-publish). `git revert` undoes the code; a separate inverse operation must undo the
  world. These decisions have an *inverse that is itself a decision* (often as big as the
  original).
- **Irreversible (residue)**: the decision destroyed information or had an external,
  observed effect. **Dropping a column deletes the data** — reverting the migration code
  recreates an *empty* column, not the values. Sending an email, charging a card, publishing
  to a topic other systems consumed, deleting a backup, expiring a key — the world moved and
  will not move back. Here the decision is **one-way through time**; there is no edit, in any
  representation, that returns you to the prior state.

The lifecycle consequence (ties to Part I §3): **a decision's reversibility is monotonically
spent over its lifecycle.** It is born reversible (additive/dark) and, as it promotes →
contracts → removes, it crosses one-way gates (drop the old column, delete the shim, revoke
the key). The expand/contract sequence (Part II.A) is *engineered* exactly so that the
irreversible step (contract/drop) comes **last and alone**, after every reversible step has
de-risked it — the migration discipline is, at root, a discipline of *ordering your
irreversible step to the end.* This is "fence what you can't finish" given a temporal reading:
the fence marks the point before the one-way gate.

A decision-editing system that models edits as reversible text transforms is **lying** about
this entire class. The unit of editing for an irreversible decision must carry its own
*direction of time*.

---

## Part VI — Versioning: one decision forked across versions maintained in parallel

Semantic versioning is the ecosystem's chosen *protocol for the temporal contract* of a
public surface (Frame 1.N's "versioning/compat policy" axis, here on the time axis). The
single decision "make breaking change C" cannot, for a published artifact, be one edit,
because **consumers upgrade on their own schedule** — the same intrinsic-temporal condition
as Part II, now spanning the whole user base rather than a deploy fleet.

The forms the temporal fork takes:
- **Major-version bump + parallel maintenance.** `1.x` keeps getting security/critical fixes
  while `2.x` carries the breaking change. Now *one logical fix* ("patch CVE-Z") must be
  authored against **two** divergent code states and *backported* — a single decision
  smeared across N maintained branches. Backporting is the temporal-fork analogue of the
  spatial call-site fan-out: same fix, N places, except the N places are *N versions across
  time*, not N call sites in one tree.
- **Side-by-side versioned surfaces** (`/v1` and `/v2` endpoints; `lib2`-suffixed symbols;
  Python's `from __future__ import`; Rust *editions*, where one compiler holds multiple
  language-decisions simultaneously and a crate declares which it speaks). The decision is
  forked and *both forks run at once*.
- **Compatibility ranges** (`^1.2`, `>=1.2,<2`). Here the decision "what version do I
  depend on" is deliberately left as a *range over future time* — the resolver picks a point
  in that range later, so the dependency decision is itself temporal and only collapses to a
  concrete value in the lockfile (Frame 4's machine-derived projection).

The under-appreciated point: **a maintained version is a decision kept alive past its
author's intent.** Every backport re-asserts an old decision in a new present. The cost of a
breaking decision is not the breaking edit; it is the *integral over time* of maintaining the
fork until the old version is sunset (which, per Part I §5, often never happens). Versioning
is the accounting system for that integral.

---

## Synthesis — what treating a decision as a *process* demands of the editing unit

Pulling Parts I–VI together against the thread's thesis ("the right unit of editing is the
decision"):

1. **The editing unit must be a trajectory, not a patch.** The four prior frames argue the
   unit should be a *decision node* whose text projection is regenerated. This frame adds:
   for a large and important class, the decision node is not a *value* you set but a
   *schedule* you run — `expand → migrate → contract`, or `0% → 5% → 100%`, or `mark →
   bridge → wait → remove`. The honest object is the **whole ordered sequence with its
   intermediate states**, because those intermediate states *must run*. A unit that can only
   express "the new state" cannot express the decision at all; it can only express the
   decision's *endpoint*, and the endpoint is the one part that was never the hard part.

2. **Some smears are uncollapsible — and the unit must say so.** Frames 1–4's smears are, in
   principle, collapsible by better representation (lift the constant, type the contract,
   write the codemod). The intrinsic-temporal smears (Part II) are **not** — overlap of old
   and new is mandated by independent deployment / data-at-rest / external consumers. The
   editing unit must distinguish *"this scattered across the artifact for lack of a home"*
   (collapse it) from *"this is scattered across time because the world won't hold still"*
   (sequence it, don't collapse it). Conflating the two — trying to make an expand/contract
   atomic — is a correctness bug, not an ergonomics win.

3. **The unit must carry a direction of time (reversibility metadata).** Because
   reversibility is spent monotonically over the lifecycle (Part V), the decision object
   must know *where on its one-way path it is* and *which of its steps are gated*. "Undo"
   cannot be a uniform operation; it is `git revert` for the additive head and a
   compensating decision (or *impossible*) for the irreversible tail. An editor that offers
   a single symmetric undo is lying about the irreversible class.

4. **The unit's identity must persist across phases that emit different edit-kinds.** Part I:
   the *same* decision is a fan-out at birth, a point-edit at flip, an addition at deprecation,
   a fan-out-deletion at removal. A representation keyed on edit-shape (a diff, a codemod)
   fragments one decision into four unrelated changes. The decision-object must be the thing
   that *threads* birth → flip → death, so that "remove the priority field" is recognizably
   *the same entity* as "introduce the priority field," years apart. Git gives us this for
   the trivial inverse only (`revert <sha>` ties a removal to its addition); nothing ties a
   *deprecation cycle's four commits, across months,* into one object.

5. **Completion is a property of the decision, and most decisions are never completed.**
   (Part I §5, IV §3, VI.) The lifecycle has terminal phases that empirically don't run:
   dead flags, immortal shims, un-sunset `/v1`. The editing unit must therefore model
   *unfinished* state as first-class — a decision that is "in its bridge phase, indefinitely"
   — rather than only finished states. This is the ecosystem's "finish migrations before
   building on top; fence what you can't finish" principle re-derived from the time axis:
   the temporal lifecycle is *where* migrations fail to finish, and the fence is a marker on
   the trajectory.

### Does any system today let you edit a decision-over-time as one object?

Partially, and the partial answers map cleanly onto which parts of the problem are *data*:

- **Feature-flag platforms** (LaunchDarkly et al.) are the closest: the rollout decision is a
  first-class, edited-as-data, runtime-projected object with a (time × population) value and
  instant reversibility. But they own only the *flip* phase — they do not own the
  introduce-fan-out or, infamously, the death/cleanup; the decision-as-process leaks out of
  the platform at both ends.
- **Migration frameworks** (Rails/Django/Flyway/Liquibase, schema-migration tools) reify the
  *forward step* as an ordered, versioned object with an (often unreliable) `down`. They
  encode ordering and partial reversibility but not the *overlap window* logic — the
  expand/contract dance is still hand-authored as N separate migrations; the *pattern* is
  tribal knowledge, not an object.
- **Semver + package managers** reify the *fork-across-time* contract (ranges, majors,
  resolution) but not the backport (the parallel-maintenance smear is manual).
- **Database/branching CI tools and progressive-delivery controllers** (Argo Rollouts,
  Flagger) reify the *canary schedule* as a declarative object — arguably the most complete
  "decision as a trajectory you author once and the system executes over time."
- **Git itself** reifies exactly *one* temporal relationship: the clean inverse (`revert`).

The gap, stated as the frame's closing claim: **no system today holds the *whole* lifecycle
of a single decision — introduce, evolve, flag-rollout, deprecate, fork-across-versions,
remove, with reversibility direction and overlap-window semantics — as one editable object.**
Each existing tool owns one *phase* and treats the rest as out-of-band (a deploy, a manual
backport, a someday-cleanup ticket). The decision-as-process is real, it is what
practitioners actually manage, and it is currently *spread across a flag dashboard, a
migrations folder, a CHANGELOG, a semver policy, and a TODO that says "remove the v1 shim"* —
which is the temporal sibling of exactly the spatial smear this whole thread set out to name.

---

## Honesty flags / soft spots

- **Expand/contract / parallel-change** is well-established practice (Sato/Fowler;
  "evolutionary database design"); I'm confident in the *shape* of the pattern and its
  intrinsic-temporality argument. Specific deploy-order failure modes are reasoned from how
  rolling deploys work, not cited to a single source.
- **Protobuf field-number reservation, RFC 8594 Sunset/Deprecation headers, Rust editions,
  `from __future__`** — named from training knowledge as illustrative existence-proofs of
  "temporal identity in the format"; I did not re-verify each spec detail here. The *claim
  each supports* (formats bake in old/new coexistence) holds even if a detail is imprecise.
- **Feature-flag platform capabilities** (LaunchDarkly/Unleash/Flagsmith/Statsig, Argo
  Rollouts/Flagger) are described at the level of "what this class of tool does"; exact
  feature attributions per vendor are not load-bearing and not individually verified.
- **"Most decisions die uncompleted"** (Part I §5) is an empirical generalization from
  common experience (flag debt, immortal shims) rather than a measured statistic — flagged
  as a strong claim stated without a number.
- The **Part II.B line** ("intermediate state must *run in production*" vs "need only exist
  in the working tree") is my proposed discriminator between intrinsic-temporal and
  collapsible-spatial smears; it is a clean test but it is *my* framing, offered as the
  frame's main analytic contribution, not received wisdom.
