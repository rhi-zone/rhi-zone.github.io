# Frame 3 — The Propagation Axis: Mechanical Shrapnel vs Spawned Decisions

> Context: a program is a structure of *decisions*; text smears one decision
> across many edits. This frame maps the space of single-decision behavior
> changes by their **mechanical-vs-spawned profile**. The thesis being tested:
> a "single-decision behavior change" is almost never atomic — it decomposes
> into (1) **mechanical shrapnel**, propagation fully determined once the
> decision is made, which a machine should derive for free; and (2) **spawned
> decisions**, genuinely new sub-decisions the change creates, which only an
> oracle (human or model-as-oracle) can fill. The right editing unit isolates
> (2) and automates (1).

This connects to the settled terrain from the reasoning thread: *flat compute
over non-flat structure*. Text editing is flat *labor* over a non-flat
decision structure — you grind the same keystroke effort over the shrapnel
(zero decision-content) as over the spawned decisions (all the
decision-content). The propagation axis is the editing-time face of the
density argument.

---

## 0. Definitions, made sharp

A **decision** is a choice not forced by anything already in the program: it
adds information that was not derivable from the existing structure. (Mirrors
"irreducible decision-content" from the reasoning thread — conditional
surprise relative to the program-so-far.)

A change to a program is initiated by an **intent** (the human's actual goal:
"rename this", "support a third payment method", "make this async"). From the
intent, the system must reach a new consistent program state. The work to get
there partitions into:

- **Mechanical shrapnel (M):** edits whose content is a *function of* the
  decision already made plus the existing program. Given the decision and the
  program, the edit is determined — there is exactly one correct value, and a
  derivation procedure (search, type-driven, structural) can produce it. No new
  information enters. **Surprise = 0 given the decision.**

- **Spawned decisions (S):** edits whose content is *not* determined by the
  decision plus the program. The change makes a *new* slot exist, and what goes
  in the slot is a fresh choice. **Surprise > 0** — an oracle must supply it.

The key operational test, applied per edit site:

> **Determinacy test.** Given the originating decision and the rest of the
> program, is there exactly one correct edit at this site? If yes → mechanical.
> If the site admits multiple consistent completions and the program has no
> basis to prefer one → spawned.

A crucial subtlety the test exposes: **mechanical does not mean trivial, and
spawned does not mean large.** Threading a type through 40 call sites is large
but mechanical; deciding what one new match arm returns is small but spawned.
Effort and decision-content are *orthogonal* — which is exactly why text, by
measuring effort, mismeasures the change.

---

## 1. The spectrum

Ordered by **spawned-decision fraction** (S-content / total decision-content),
from pure-mechanical (left) to pure-generative (right). Each point gets a
concrete edit and a decomposition below.

```
PURELY            MECHANICAL          MIXED                MIXED              PURELY
MECHANICAL        + GUARDED           (mechanical         (spawn-            GENERATIVE
(M only)                              shell, spawned       dominant)         (mostly S)
                                      filling)
|-----------------|-----------------|------------------|------------------|------------------|
rename            change a            add an enum case   change a data      "add a feature"
reorder params    signature          add a struct       model / split a    "support OAuth"
inline a const    (add/remove arg)   field              type               "make it
extract a var     make fn async      add an interface   widen a type's      undoable"
move a defn       narrow a type      method             domain
                  change return type
M = 100%          M ≈ 100%,          M and S both        S dominant,        S ≈ 100%,
S = 0             S = 0 but          substantial         M is the           M is downstream
                  *correctness       (the headline       cleanup tail       of the spawned
                  obligations*       case)                                  decisions
                  spawned
```

The axis is **not** a difficulty axis and **not** a size axis. It is purely:
*how much of the post-decision work is determined vs newly-chosen.*

---

## 2. Decomposed examples, left to right

### 2.1 Rename a symbol — `userId` → `accountId` (M = 100%, S = 0)

- **Decision:** one. "This concept is now called `accountId`." (The *name* is a
  decision; the user supplies it once.)
- **Mechanical shrapnel:** every reference site — declaration, all reads, all
  writes, doc comments that name it, possibly serialized keys if they track the
  identifier. Each site has exactly one correct edit, derivable by binding
  resolution (NOT text match — text match is the broken proxy that hits the
  string inside an unrelated `userId` in another scope).
- **Spawned decisions:** *none.* The behavior is identical; only the label
  changed.
- **Verdict: fully mechanizable.** A machine with a real binding graph completes
  this alone. The human supplies one token (the new name) and the decision is
  spent. This is the *purest* case: text makes you visit N sites; the decision
  count is 1.

*Boundary note:* rename is the canonical "already solved by good tooling" case
— rename-refactoring exists precisely because the shrapnel is mechanizable.
That it works is the existence proof for the whole frame: when the unit is the
*decision* ("rename") and not the *keystrokes* (N edits), the machine does the
rest. Everything to the right is "why doesn't this work for harder changes
yet."

### 2.2 Reorder / inline / extract (M = 100%, S = 0)

- Reorder parameters: decision = new order; shrapnel = rewrite every call
  site's argument order. Determined.
- Inline a constant: decision = "stop naming this"; shrapnel = substitute value
  at each use, delete the binding. Determined.
- Extract a subexpression to a variable: decision = "name this / hoist it";
  shrapnel = replace occurrences, insert binding at the right scope.
  Determined (the only subtle part — *where* to hoist — is determined by the
  occurrences' common dominator, still mechanical).

All three: classic mechanizable refactors. The decision is the *name* or the
*order* or the *position*; the rest is search + structural rewrite.

### 2.3 Change a signature: add a parameter (M ≈ 100%, but S = correctness obligations)

`fn charge(amount)` → `fn charge(amount, currency)`.

- **Decision:** "charge now needs a currency." One.
- **Mechanical shrapnel:** the signature edit, and threading the new parameter
  *if* the callers already have a currency in scope to pass. Plumbing a value
  that already exists down through a call chain is determined — this is the
  "thread a type / thread a value" shrapnel, and it can be large (every
  intermediate function on the path gains the parameter and forwards it).
- **SPAWNED at the leaves — and this is the important nuance:** at each call
  site, *does the caller have a currency to pass?* If yes for all → still pure
  mechanical. But typically **some call site has no currency in scope.** That
  site now has an *unfilled slot* — "what currency does THIS caller use?" — and
  the program has no basis to answer. That is a spawned decision, one per
  under-determined call site. The machine can *locate* every such site (that
  part is mechanical and is the high-value derivation) but cannot *fill* it.

So even a "signature change" — intuitively pure mechanical — spawns one
decision per call site that lacks the new input. **The machine's job is to
thread where it can and present a worklist of exactly the sites where it
can't.** This is the first place the boundary appears mid-change rather than at
the end.

*Sub-cases:*
- Add a parameter *with a default* → the default is a single spawned decision
  ("what's the sensible default?"), made once; then *all* call sites become
  mechanical (they take the default). One spawned decision converts the whole
  tail to mechanical. (Defaults are a decision-compression device — they're how
  languages let you make one choice instead of N.)
- Remove a parameter → shrapnel = delete the argument at each call site. The
  removed value's *computation* at each site may now be dead → mechanical dead
  code elimination, also determined. S = 0, unless removing it means a caller
  now must do something else with the value it was passing (rare; usually pure
  M).
- Change return type `T` → `Result<T, E>` → shrapnel = wrap returns. **Spawned:
  every caller must now decide how to handle `E`** (propagate? unwrap? recover?)
  — one spawned decision per caller, none determined by the change. This is a
  signature change that is *spawn-heavy* despite looking mechanical, because the
  new type widens the *obligations* at every use. (Same structure as `make
  async`: the `async` keyword is mechanical, but every caller must decide
  await-vs-spawn-vs-restructure.)

**Takeaway from §2.3:** the "signature change" bucket is not one point on the
spectrum. Adding-a-threadable-value is far left; widening the return type into
a new obligation (`Result`, `async`, `Option`) is mid-spectrum because the new
type *spawns a handling decision at every use site.* The discriminator is
whether the change adds a value callers already have (mechanical) or an
*obligation* callers must newly discharge (spawned).

### 2.4 Add an enum case — the headline mixed case (M and S both substantial)

`enum Payment { Card, Cash }` → add `Crypto`.

This is the example the frame was built around; it's the clean demonstration
that one intent splits cleanly into both halves.

- **Decision:** "Crypto is now a payment method." One.
- **Mechanical shrapnel — the variant exists for free:**
  - The variant declaration itself (trivially mechanical).
  - **Every non-exhaustive `match`/`switch` on `Payment` is now incomplete.**
    *Locating* all of them is fully mechanical and is exactly what an
    exhaustiveness checker does. The compiler/type system *derives the entire
    worklist* — "here are the 14 sites that must now handle `Crypto`." This is
    pure determined propagation: the change *itself* tells you precisely where
    the spawned decisions live.
- **Spawned decisions — what each arm DOES:**
  - At each of the 14 match sites, **what should the `Crypto` arm do?** Nothing
    in the program determines this. `Card`'s behavior doesn't tell you `Crypto`'s.
    Each arm is an independent spawned decision. 14 sites → up to 14 spawned
    decisions (fewer if several legitimately share an arm, but *that* sharing is
    itself a decision).
  - **Construction sites:** somewhere a `Crypto` value must actually get
    created (parse it from input, branch on user selection). That's a spawned
    decision too — the variant existing doesn't make anything produce it.

**The clean split:** "the variant exists" = mechanical (declaration +
exhaustiveness worklist, both derived). "What each match arm now does" + "where
it gets constructed" = N spawned decisions, each requiring the oracle.

This is the frame's load-bearing example because the type system *already*
implements the mechanical half perfectly (exhaustiveness = automated
worklist-of-spawned-decisions generation) — proving the split is real and
that the machine can find the exact boundary. What's *missing* in current tools
is that they dump you into text at each site instead of presenting them as *a
list of N isolated decisions to fill.* The decision is buried back under
keystroke-grind the moment you start editing.

### 2.5 Add a struct field (M and S, struct-shaped)

`struct User { name }` → add `email`.

- **Mechanical:** the field declaration. Locating every construction site
  (which is now incomplete — they don't supply `email`) — derived by the type
  checker, exactly like enum exhaustiveness but on the *product* side instead of
  the *sum* side. (Symmetry worth noting: sum types spawn decisions at
  *destructuring* sites — match arms; product types spawn them at *construction*
  sites — initializers. Same mechanism, dual position.)
- **Spawned:** at each construction site, *what email does this `User` get?* Not
  determined. Plus: does anything need to *read* `email` (display it, validate
  it, persist it)? Those are spawned and **discretionary** — the field's
  existence creates no obligation to use it, so these spawned decisions are not
  even *forced*; they're latent until someone decides the feature needs them.

Note the new subtlety: §2.4's spawned decisions were **forced** (the program
won't type-check until each match arm exists). §2.5's *read*-side spawned
decisions are **optional** (the program compiles with the field unread). So
spawned decisions further split into **forced** (the change won't be consistent
until they're made — the type system can *demand* them) and **discretionary**
(the change is consistent without them — the system can at most *suggest*
them). The machine can enumerate forced spawned decisions exhaustively; it can
only *propose* discretionary ones.

### 2.6 Widen a type's domain / split a type (S-dominant, M is cleanup tail)

`type Id = u64` → `type Id = Uuid`, or split `User` into `User` + `Account`.

- **Decision:** the headline decision is itself *compound* — splitting `User`
  means deciding *which fields go where*, which is already several decisions,
  not one. (This is where "single-decision change" starts to strain — see §4.)
- **Spawned, dominant:** every site that used the old type must decide how it
  maps onto the new shape. Many of these are genuine re-modelings, not
  substitutions. A function that took a `User` might now need a `User`, an
  `Account`, both, or a new joined view — a spawned decision per site, and the
  *answer differs by site* (no uniform rewrite).
- **Mechanical, the tail:** once each site's mapping is *decided*, the actual
  edit (rewrite the access path) is determined. But the determination came from
  a per-site oracle call, so the mechanical part is downstream of dense spawning.

### 2.7 "Add a feature" / "support OAuth login" / "make this undoable" (S ≈ 100%)

- **Decision:** not one decision at all — an *intent* that must first be
  *decomposed into* decisions before any of this frame applies. "Support OAuth"
  spawns: which providers? where do tokens live? how does it compose with
  existing sessions? new routes? new data model? Each is a spawned decision, and
  each spawns more (see §3).
- **Mechanical:** essentially none *at the level of the intent.* Mechanical
  shrapnel reappears only *after* the spawned decisions have been made and
  bottomed out into concrete typed changes — at which point you're back doing
  §2.1–§2.5-shaped sub-changes, each with their own M/S split.

The pure-generative end is where the propagation framing has *nothing to
automate at the top level* — there is no decision yet, only an intent. The
machine's role here is not propagation but **decomposition / elicitation**:
help turn the intent into the tree of decisions. That is a different capability
(authoring support) from propagation (shrapnel derivation), and the spectrum's
right end is precisely where the handoff from one to the other occurs.

---

## 3. How spawned decisions cascade

A spawned decision is not a leaf. **Filling a spawned decision can spawn
further decisions** — and can also generate *its own* mechanical shrapnel. The
change is therefore not a flat (M, S) split but a **tree**:

```
intent
 └─ decision D0 (the headline decision)
     ├─ mechanical shrapnel of D0   ← machine derives, done
     └─ spawned decisions S1..Sk    ← oracle fills each
          ├─ S1 filled = decision D1
          │    ├─ mechanical shrapnel of D1   ← machine derives
          │    └─ spawned decisions of D1 ...  ← oracle, recurse
          └─ ...
```

Concrete cascade — **add `Crypto` enum case** (continuing §2.4):

1. D0 = "Crypto exists." Mechanical: declaration + exhaustiveness worklist.
2. Spawned S = "what does the `process(payment)` arm do for `Crypto`?"
3. Oracle fills S: "call a `CryptoGateway`." → this is decision D1.
4. **D1 spawns its own mechanical shrapnel** (`CryptoGateway` must be
   imported/constructed/injected — determined once you say "use a gateway") AND
   **its own spawned decisions** ("which gateway? what's the retry policy? what
   happens on chain reorg?"). Each of *those* recurses again.

So a single intent fans out into a tree whose **internal nodes alternate**
between oracle-supplied content (the spawned decisions) and machine-derived
content (the shrapnel each filled decision drags along). The depth and breadth
of the tree — *not* the number of files touched — is the honest measure of the
change's decision-content.

This reframes the unit problem precisely:

> The right editing unit is **one node of the spawned-decision tree** — present
> the human exactly one under-determined slot at a time, with all of *its*
> mechanical shrapnel pre-derived and the *next* layer of spawned slots
> enumerated as a worklist. Text instead serializes the entire tree's *leaves*
> (every keystroke at every site) into one flat undifferentiated grind, with no
> marker distinguishing a spawned-decision keystroke from a shrapnel keystroke.

The cascade also explains why "single-decision behavior change" is a slightly
misleading phrase: it's *single-rooted*, not single-node. The root is one
decision; the tree it induces is the change. The aspiration is that the human
only ever touches the oracle-nodes, and the count of those — not the file
diff — is what they should experience as "the size of the change."

---

## 4. The mechanizable / needs-oracle boundary

Collecting the discriminators that appeared across the examples:

### What is FULLY mechanizable (machine completes alone, no oracle)

The change is fully mechanizable iff **S = 0** — every consequence is
determined by the decision + program. Signatures:

- **Pure relabeling / repositioning:** rename, reorder, move, inline, extract.
  The decision is a name/order/position; all sites follow by binding/structure.
- **Threading a value that already exists in scope** down a call chain (every
  intermediate forwards it; leaves already have it).
- **Propagating a default** once the default is chosen (the one spawned decision
  collapses the rest to mechanical).
- **Dead-code / consistency cleanup** that follows deterministically from a
  removal.
- **Generating the worklist itself** — even for spawn-heavy changes, *locating*
  every site that needs a spawned decision is mechanical (this is what
  exhaustiveness/type-checking already do). The machine always owns "where are
  the decisions?" even when it can't own "what are they?"

These are mechanizable because they require **no information not already
present.** Equivalently: the edit is a pure function of (decision, program). A
search/derivation procedure with a *real semantic model of the program* (binding
graph, type graph, call graph — NOT text) computes it.

### What NEEDS AN ORACLE (machine can locate, cannot fill)

A site needs the oracle iff it admits **multiple program-consistent completions
with no basis in the program to choose** — i.e. the edit adds information. Three
recurring shapes:

1. **New behavioral slots** — what a new match arm *does*, what a new construction
   site *supplies*, how a new obligation (`Result`/`async`/`Option`) is
   *discharged* at each use. The structure forces the slot to exist; nothing
   fills it.
2. **New obligations created by a widened type** — return-type widening, type
   splitting: each use site must be *re-modeled*, and the right model differs
   per site.
3. **Intent decomposition** — at the generative end, there is no decision yet to
   propagate; the oracle must *produce* the decision tree from an intent.

### The boundary is itself machine-locatable — the key asymmetry

The single most useful structural fact: **the boundary between M and S is
mechanically detectable even when S itself is not.** The type system's
exhaustiveness/initialization/typedness checks are exactly a *spawned-decision
detector*: they fire at precisely the sites where the program is now
under-determined. So the division of labor is sharp and implementable:

- **Machine:** derive all M; *enumerate* all forced S as a worklist; *propose*
  discretionary S; refuse to invent the content of any S.
- **Oracle (human, or model-as-oracle-at-the-leaves):** fill each S — and *only*
  each S. Every fill is a new decision that re-enters the machine, which derives
  *its* M and enumerates *its* spawned S, recursing until the worklist empties.

This is the editing-time instance of the ecosystem's standing principle: **the
LLM/human is an oracle at the leaves, never the control loop.** The control loop
here is the deterministic propagation/worklist engine (search + type-driven
derivation). The oracle is invoked *only* at spawned-decision nodes. A model
used to *guess shrapnel* is misused (it should be derived); a model used to
*fill spawned decisions* is used correctly (that content genuinely isn't in the
program). The boundary tells you which calls are legitimate oracle calls and
which are a deterministic step masquerading as one.

### Where the line is fuzzy (flagged, not resolved)

- **"Determined" is relative to how rich the machine's model is.** With only
  text, almost everything looks spawned (text can't tell a rename from a
  coincidental substring). With a binding+type+call graph, far more collapses to
  mechanical. With a *specification* attached, even some §2.4 match arms might be
  derivable (the spec determines the arm). So the M/S line **moves left as you
  add machine-readable intent.** The frame's claim is that the line *exists and
  is detectable at a given model richness*, not that it's fixed.
- **Convention-determined sites are a gray zone.** A new match arm whose
  behavior is "obviously" the same as a sibling by local convention is *weakly*
  determined — a model could propose it with high confidence, but the program
  doesn't strictly force it. These are exactly the *discretionary-but-suggestible*
  spawned decisions: legitimately oracle-territory, but where a model-as-oracle
  earns its keep by proposing and a human confirms. (This maps to the reasoning
  thread's "idiom/convention" residual entropy — reducible by a richer model,
  irreducible to a poorer one.)
- **Compound "single" decisions** (§2.6 type-split) reveal that what the human
  *calls* one decision may already be a small tree. The frame doesn't require the
  root to be atomic; it requires the *leaves* to be isolated. Decomposing a
  compound headline decision is itself the elicitation work of §2.7.

---

## 5. Connection back to the throughline

The propagation axis is the **editing-time projection** of the reasoning
thread's core result:

- *Reasoning thread:* meaning is structured; structure is redundancy;
  redundancy serialized into a line is unevenly dense; the crime is **flat
  compute over non-flat structure** — same forward pass for a forced `):` as
  for the token that picks the algorithm.
- *This frame:* a change is structured; the structure is the spawned-decision
  tree; serialized into a text diff it becomes an unevenly-dense pile of
  keystrokes; the crime is **flat human labor over non-flat decision
  structure** — same editing effort for mechanical shrapnel (forced, zero
  decision-content) as for a spawned decision (the choice that carries all the
  content).

And the resolution mirrors too. The reasoning thread landed on *representation
is the primary lever* — choose a representation where each unit ≈ one
irreducible decision, with adaptive compute mopping up the residual. The
editing analogue: **choose an editing unit where each interaction ≈ one spawned
decision, with deterministic propagation deriving the residual (the shrapnel).**

The two "reducible vs irreducible" partitions are the same partition seen from
two sides:

| reasoning thread | this frame |
|---|---|
| reducible redundancy (grammar/idiom/repetition) | mechanical shrapnel |
| irreducible decision-content | spawned decisions |
| abstraction removes reducible redundancy | propagation/derivation removes shrapnel from the human's plate |
| adaptive compute handles the irreducible residual | the oracle fills the spawned residual |

This is the through-line: **find the irreducible decisions, isolate them as the
unit, and let determinism own everything else.** The propagation axis is what
that looks like when the "everything else" is *edit propagation* rather than
*inference compute.*
