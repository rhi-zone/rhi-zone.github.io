# Frame 17 — Cognitive / Intent: the human side of the seam

**Method.** Every prior frame is about the *program* — its axes (F1), its localizing
representations (F2), the mechanical-vs-spawned split (F3), the empirical edit taxonomy (F4),
cross-disciplinary propagation engines (F5), the temporal smear (F8), economics (F14). This
frame rotates the question onto the **programmer**. The unified findings give us a clean
machine-side picture: a decision is forced-by-program (M, mechanical shrapnel, zero new bits,
derivable) or new-info-from-oracle (S, spawned decision, irreducible bit); compositionality is
the master discriminator; the vision is an "editor as reconciler" that derives M and enumerates
S as a worklist. All of that describes what the *artifact* needs. This frame asks the question
those frames cannot answer: **does any of this match how the human actually forms and executes a
change?** Specifically —

> A decision-granular editor is a bet about cognition: that there is, in the programmer's head,
> a clean object ("the decision") that text currently forces them to lossily encode across N
> edits, and that surfacing it as the unit will *fit* how they already think. This frame tests
> that bet. The headline finding, stated up front so the rest reads against it:

> **The intent is decision-*shaped* but not decision-*complete*.** What the programmer holds at
> formation is real, compositional, and genuinely the unit they think in — F1–F16's "decision"
> is not a machine fiction, it is the cognitive object. But it is a **goal, not a specification**:
> it fixes the *figure* (the irreducible bit they want to inject) and leaves the *ground* (the
> shrapnel and most of the spawned sub-decisions) un-derived. The human does not hold the closure
> of the decision; they hold its seed. Crucially, the two halves of that gap are not symmetric:
> the **M-shrapnel the human re-derives is pure translation overhead** (the human doing the
> machine's job, and doing it worse), but the **S-decisions are discovered, not retrieved** — the
> intent is *literally incomplete at formation* and gets completed reactively, often by the
> compiler. This splits the editor's value proposition cleanly in two, and tells us exactly where
> the editor *fits* cognition and where it *fights* it.

I cite real HCI / PL-cognition / program-comprehension work where the claim rests on it, and
flag explicitly where I am reasoning past the evidence.

---

## Part I — How a change-intent is actually formed, and the shapes it takes

### I.1 The intent arrives as a *goal*, in domain/behavioral vocabulary

Take the four canonical intents from the prompt and look at the vocabulary they are *born* in:

- "I want X to also handle Y" — additive
- "make this faster" — non-functional/quality
- "never allow Z" — restrictive/invariant
- "this should be configurable" — parametric/structural

None of these are stated in the program's coordinate system. They are stated in the
**problem domain** ("handle Y", "allow Z") or in **quality space** ("faster"). This is the first
and most important cognitive fact: *the intent is formed in a different language than the edit is
executed in.* The programmer thinks "payments should also accept JPY"; the edit is `+1` enum
variant, a match arm, a validation branch, a currency-table row, a rounding-rules entry. The
intent names a behavior; the edit names text positions. The translation between those two
languages is the entire job — and Part II argues most of it is overhead.

This maps directly onto Norman's **gulf of execution** (cited below): the gulf is the distance
between a goal stated in the user's terms and the actions the system makes available. Programming
has an unusually *wide* gulf of execution because the action vocabulary (text edits at scattered
sites) is maximally far from the goal vocabulary (a behavioral delta).

### I.2 The shapes of change-intent — and whether they mirror the structural axes

F1 mapped the *program's* structural axes. Do intents come in matching shapes, or cut across?
My read: **intents have their own taxonomy, and it is offset from — not aligned with — the
structural axes.** A small set of recurring intent-shapes:

| Intent shape | Canonical phrasing | What the human holds | Where the smear lands |
|---|---|---|---|
| **Additive** | "also handle Y" | one new case + the *promise* that all dispatch sites cover it | every dispatch/match/enum site (M-heavy if exhaustiveness-checked; S-heavy otherwise) |
| **Restrictive** | "never allow Z" | one invariant | every site that could produce Z (a *negative* concern — F13's deletion frame) |
| **Parametric** | "make this configurable" | one value → one knob | def site + all read sites + plumbing path (mostly M, classic delocalized plan) |
| **Quality / non-functional** | "make this faster" | a *property*, no concrete edit at all | unknown until profiled — the intent has **no site** at formation |
| **Structural / re-conceptual** | "this is really two things" | a new decomposition | pervasive; the edit *is* the re-chunking |
| **Cross-cutting** | "log every external call" | one aspect | every join point (the aspect-orientation motivating case) |

Two things stand out. First, **intent shape and structural axis are different projections of the
same change.** "Make configurable" is parametric *as an intent* but, structurally, can land as a
point-edit, a delocalized plumbing smear, or a whole config subsystem depending on the
representation — the intent shape does not determine the structural shape; the *representation*
does (consistent with F2's thesis that localization is a property of representation, not of the
decision). Second, **two intent shapes have no localizable site at formation at all**: quality
intents ("faster") and structural intents ("this is really two things"). These are not decisions
that have been *smeared*; they are decisions that *do not yet have an extension in the program*.
That is a different cognitive animal and Part III returns to it — it is the strongest case where
"the decision" is co-constructed with the edit rather than pre-existing.

### I.3 Intent forms by *recognition*, top-down, against schemas

How does the goal become even a partial plan? The program-comprehension literature is clear and
old: experts work by **recognizing plans/schemas**, not by reading text linearly. Soloway &
Ehrlich's plan theory and the schema-based accounts (see Détienne; Brooks' top-down model) hold
that programmers carry a library of stereotyped solution fragments ("plans" — a running-total
loop, a guarded-lookup, a validate-then-commit) and that both *comprehension* and *generation*
proceed by matching code to these schemas. The practical consequence for intent formation: when a
programmer forms "also handle Y", they are not enumerating sites — they are **retrieving a plan**
("this is an add-a-variant-to-a-sum-type situation") and the plan *comes with an expectation of
its own shrapnel*. An expert's intent is richer than a novice's *precisely because the schema
predicts more of the M-shrapnel up front.* This is a key, citable hinge: the degree to which
intent is "decision-complete" at formation is a function of **expertise = schema coverage**.
Novices form intents that are almost pure seed (figure only); experts form intents that already
carry much of the ground. Neither holds the *full* closure — see Part III on S.

---

## Part II — The gulf of execution: how much of editing is pure translation overhead

### II.1 Norman's gulfs, applied

Norman (*The Psychology / Design of Everyday Things*) splits the human–system distance into the
**gulf of execution** (turning a goal into actions the system accepts) and the **gulf of
evaluation** (turning system state back into a judgment about the goal). Programming under text
editing pays both, heavily, and the decision-editor vision is precisely a proposal to *narrow the
gulf of execution by changing the action vocabulary* — let the human act on the object they
already hold (the decision) instead of on its text projection.

The sharp question this frame can answer: **of the cognitive work between "I want X" and a
committed edit, how much is essential (specifying the irreducible bit) versus overhead (re-deriving
what the machine could derive)?** Decompose the work:

1. **Locate the smear** — find every site the decision currently touches. (feature/concern location)
2. **Re-derive the M-shrapnel** — work out, by hand, the consequences the decision *forces*.
3. **Specify the S-bits** — supply the genuinely new information at each spawned site.
4. **Verify** — confirm the edit realizes the intent (gulf of evaluation; F11's verification dual).

Of these, **(1) and (2) are pure translation overhead** under the unified model: they are exactly
the M-derivation and worklist-enumeration the "editor as reconciler" promises to do mechanically.
Only **(3) is irreducible human work** — it is the oracle filling irreducible bits. (4) is partly
reducible (the machine can check compositional consequences) and partly irreducible (does the new
behavior match the *intent*, which lives only in the human's head — see II.4).

### II.2 How big is the overhead? — the empirical anchors

This is where I lean on measured numbers rather than reason.

- **Locating the smear is a large, measured fraction of developer time.** Field/lab studies put
  developers at roughly **~35% of time navigating** code (Ko et al.'s instrumented study and
  follow-ups), and "understanding unfamiliar code / finding where to change" dominates maintenance
  effort across the comprehension literature. In Ko, Myers, Coblenz & Aung's *70-minute
  enhancement/debugging study*, developers **searched on limited and often misrepresentative cues,
  hit failed searches, then followed incoming/outgoing dependencies — with navigation tooling
  itself imposing significant overhead.** That last clause matters: even the *act of traversing*
  the smear is costly, on top of finding it. (Source below.)
- **The smear is real and named.** Letovsky & Soloway (1986), *Delocalized Plans and Program
  Comprehension*: a single conceptual plan whose pieces are **scattered across non-contiguous
  regions** so that local reading misleads — "a maintainer's understanding can go awry when it is
  based on purely local clues." This is the program-comprehension field's own name for *the smear*,
  established 40 years ago. The decision-editor is, in these terms, a tool to **re-localize a
  delocalized plan at edit time.** (Source below.)
- **Cognitive Dimensions name the cost as a property of the notation.** Green & Petre's framework
  gives us two dimensions that *are* the smear-tax: **Viscosity** ("resistance to local change" —
  one conceptual change requiring many coordinated edits) and **Hidden Dependencies** (a dependency
  not overtly indicated in both directions, so the human must *hold the dependency graph in their
  head* to know what their edit breaks). Text source code is high-viscosity and rife with hidden
  dependencies by construction. A decision-editor is an explicit attack on both: it lowers viscosity
  (one gesture) by *making the dependency overt and bidirectional* so the machine can walk it.
  (Source below.)

Putting these together: a substantial fraction of the human's per-change cost is steps (1)+(2),
and the comprehension literature has independently identified both the phenomenon (delocalized
plans / hidden dependencies) and its expense (navigation time). **I am confident the overhead is
large; I am not able to cite a clean decomposition that isolates "M-re-derivation" specifically**
— the studies measure navigation and comprehension in aggregate, not "time spent computing forced
consequences" vs "time spent supplying new bits." That precise split is, to my knowledge,
unmeasured. Flagging this as reasoning, not citation.

### II.3 Re-deriving M by hand is *strictly worse* than the machine doing it

A subtle point the human-side frame adds: when the programmer re-derives mechanical shrapnel
manually, they are not merely doing redundant work — they are doing it **less reliably than the
machine would**, because the derivation runs through a lossy human dependency-model. Hidden
dependencies (Green & Petre) mean the human's mental model of "what this touches" is *incomplete*;
missed M-sites are exactly the "forgot to update the other place" class of bug. So the M half of
the gulf is not just overhead — it is **error-injecting overhead**. This strengthens the editor's
case on its strongest ground: M-derivation is the part where the machine is unambiguously better,
and the part the human currently does worst.

### II.4 The gulf of evaluation is *not* fully reducible — and this bounds the editor

Symmetry check, because the unified model is M/S on the *execution* side. On the *evaluation* side
there is an analogous split: the machine can verify **compositional** consequences (types check,
exhaustiveness holds, tests pass — F11), but it **cannot verify that the realized behavior matches
the intent**, because the intent lives only in the human's head and was never fully externalized.
"Make this faster" — the machine can measure speed, but only the human holds the threshold that
counts as "fast enough." This is the residue: even a perfect reconciler leaves the human owning the
gulf of evaluation for the *non-compositional, intent-relative* part of the judgment. The editor
narrows execution far more than it narrows evaluation.

---

## Part III — Is intent decision-shaped-and-complete, or fuzzy-and-co-constructed?

This is the frame's central question and it has a *split* answer, which is the most important
contribution of the cognitive view.

### III.1 The figure is pre-existing and decision-shaped (the editor fits)

The irreducible bit the human wants to inject — the *figure* — is genuinely held, genuinely
compositional, genuinely the unit they think in. "Also handle JPY", "never allow negative balance",
"make the timeout configurable": each is a single, nameable, pre-formed decision. The evidence that
this object is real and pre-linguistic-to-the-code:

- **Programmers narrate changes at decision granularity, not edit granularity.** Commit messages,
  PR titles, code-review summaries, and stand-up reports are *overwhelmingly* one-decision-per-unit
  ("add JPY support", "fix the off-by-one", "make timeout configurable"). The human spontaneously
  re-collapses the smear back to its decision *when communicating*. The diff is the encoding; the
  message is the decision. (This is observation of universal practice, offered as evidence the
  cognitive unit is the decision; not a controlled study.)
- **Code review operates on diffs but reviewers reconstruct the decision.** The reviewer's first
  act is to *recover the intent* from the scattered hunks — "what is this change trying to do?" —
  then check each hunk against that reconstructed intent. Review is **decode-then-judge**: the diff
  format forces the reviewer to re-run the human's lossy encode in reverse before they can evaluate.
  That the wrong unit (diff) is universally used while the right unit (decision) is universally
  reconstructed is strong evidence the decision is the cognitively real object and the diff is mere
  transport. (Reasoning from how review demonstrably works; I'm not citing a specific study that
  measured "reviewers reconstruct intent," though the program-comprehension literature on top-down
  recognition supports it.)
- **Naming and chunking ARE the human's localization mechanism.** How does a human compress a
  program enough to hold it? By **chunking** — Miller's classic capacity limit forces grouping, and
  the comprehension literature (Soloway's plans, Détienne's schemas) shows experts chunk code into
  named plans. A good **name** is a handle on a decision: it lets the human refer to the whole
  decision by one token instead of holding its smear. Naming is the human-side analog of F2's
  localization — *the human already tries to localize decisions, using names, because their working
  memory cannot hold the smear.* The decision-editor formalizes a move humans make under cognitive
  duress anyway. This is the single strongest "the editor fits how people think" argument:
  **decision-as-unit is what naming/chunking is already straining toward.**

### III.2 The ground is co-constructed and discovered (the editor must *support* this, not assume it away)

The shrapnel and — critically — most of the **spawned S-decisions** are *not* held at formation.

- **M-shrapnel: foreseen in kind, not in extent.** An expert with a good schema knows "adding a
  variant will touch the match sites"; they rarely hold *which* sites or *how many*. They know the
  *shape* of the ground, not its *coordinates*. So M is "predicted abstractly, located concretely" —
  exactly the work the editor should take over.
- **S-decisions: genuinely discovered, often reactively, often by the compiler.** This is the
  decisive finding. Take "also handle JPY": the human's seed does *not* contain "JPY has no minor
  units, so the rounding code's assumption of 2 decimal places is now wrong." That spawned decision
  *did not exist in the intent at formation.* It is **discovered mid-edit** — frequently when the
  type checker, an exhaustiveness warning, or a failing test surfaces the forced-but-unfilled slot.
  The programmer then *forms a new sub-intent reactively* ("oh — how should JPY round?") and the
  oracle (the human) supplies the bit. **Intent is incomplete at formation and completed by a
  feedback loop with the artifact.** This is consistent with the comprehension literature's
  *opportunistic* model (Soloway: programmers exploit bottom-up and top-down cues as they arrive) —
  understanding, and therefore intent, is assembled *as cues arrive*, not specified up front. The
  compiler complaint is not a failure of foresight; it is the **designed mechanism by which the
  spawned worklist is delivered to a human who could not have enumerated it.**

This reframes "the compiler complains and I fix it" from an annoyance into a *cognitive
necessity*: it is how the S-worklist reaches the only agent that can fill it. Which is exactly
F3/F5's machine-side picture (S needs an oracle) seen from the human side: **the human is the
oracle, and the compiler error is the oracle's work-queue.** The unified vision's "enumerates
spawned decisions as a worklist" is, cognitively, *formalizing and front-loading the feedback that
today arrives as a scatter of compiler errors discovered one at a time.*

### III.3 The quality/structural intents: the decision genuinely does not pre-exist

The hardest case for "intent is decision-shaped." "Make this faster" has **no decision in it at
all** at formation — it is a goal with an empty extension. The actual decision ("cache the result of
F", "switch to a hash index") is *constructed* during investigation (profile → hypothesize →
choose). Same for "this is really two things": the new decomposition is the *output* of the edit
session, not its input. For these intents, the decision is fully co-constructed — there is nothing
to "edit at decision granularity" because the decision does not yet exist. **The editor's
decision-unit assumes the figure pre-exists; for quality/structural intents it does not, and forcing
them into a decision-node would be premature commitment** (Green & Petre's dimension: being forced to
decide something before you have the information to). The honest scope: a decision-granular editor is
a great fit for additive/restrictive/parametric intents (figure pre-exists, ground is derivable+
discoverable) and a *poor* fit — or at best a downstream recorder — for quality/structural intents
where the decision is the *result* of exploration.

---

## Part IV — Implications: does a decision-granular editor match how people think?

**Where it fits (act on this):**

1. **It matches the unit humans communicate and chunk in.** Decision-as-unit is what commit
   messages, PR titles, review summaries, and naming/chunking are already straining toward under
   working-memory pressure. The editor gives a first-class home to an object the mind already holds.
2. **It eliminates the worst, most error-prone overhead.** Steps (1) locate-the-smear and (2)
   re-derive-M are large fractions of measured developer time (navigation ~35%; delocalized-plan
   comprehension cost) AND the part the human does *least reliably* (hidden dependencies → missed
   sites → bugs). This is the machine's strongest ground and the human's weakest — the cleanest
   possible division of labor.
3. **The S-worklist matches the opportunistic reality — if delivered right.** Front-loading the
   spawned decisions as an explicit worklist *improves on* today's reactive trickle of compiler
   errors, because it gives the human the full set at once instead of one-at-a-time discovery that
   forces repeated context reload (F16/the re-read-context failure mode, in cognitive terms).

**Where it fights cognition (design around this, don't assume it away):**

4. **Intent is incomplete at formation — the editor must be a *dialogue*, not a *form*.** If the UI
   demands the human specify the decision completely before deriving, it fights the deepest finding:
   humans don't hold the closure, they hold the seed and *discover* S reactively. The editor must
   let the human commit the figure, then *surface the spawned worklist as prompts the human answers
   iteratively* — the compiler-as-work-queue, made explicit and ordered. A decision-node that must
   be filled atomically up front would impose premature commitment and would be *less* usable than
   text, not more.
5. **Quality and structural intents have no pre-existing decision.** For these the editor is at best
   a recorder of a decision reached by other means (profiling, exploration). Don't model them as
   editable decision-nodes; model the *outcome* as one once it exists.
6. **The gulf of evaluation survives.** Intent-relative correctness ("is this actually what I
   wanted / fast enough?") lives only in the human's head and was never fully externalized. The
   editor narrows execution far more than evaluation; the human keeps owning the final
   does-this-match-intent judgment, and the editor should make *that* check cheap (good evaluation
   feedback) rather than pretend to automate it.

**Net.** The decision-editor's bet is *substantially* right but in a specific, bounded way: the
human's intent is **decision-shaped (figure pre-exists, compositional, the real cognitive unit) but
not decision-complete (ground is derived + discovered, not held)**. So text is *not* a pure lossy
encode/decode of a clean mental object — that is true only of the figure. The ground is genuinely
co-constructed with the edit. The editor wins decisively on the figure-plus-M-shrapnel (act on the
held decision; let the machine derive consequences the human re-derives badly) and must be built as
an *iterative dialogue that delivers the S-worklist* rather than a form that demands a complete
specification up front. Build it to match how intent actually forms — seed first, closure
reactively — and it fits the mind. Build it assuming the human holds the closure, and it fights the
mind harder than text does.

---

## Sources

- Letovsky, S. & Soloway, E. (1986). *Delocalized Plans and Program Comprehension.* IEEE Software 3(3):41–49. [PDF](https://www.cs.kent.edu/~jmaletic/cs63902/Papers/ProgramComprehension/letovsky-1986-software.pdf) · [ACM/IEEE](https://dl.acm.org/doi/10.1109/MS.1986.233414)
- Ko, A.J., Myers, B., Coblenz, M., Aung, H. — field/lab studies of how developers seek, relate, and collect information; ~35% navigation time; failed-search + dependency-following + tool overhead. [A field study of how developers locate features in source code (PDF)](https://damevski.github.io/files/cst-field-study.pdf) · [Empirical Software Engineering](https://dl.acm.org/doi/abs/10.1007/s10664-015-9373-9)
- Green, T.R.G. & Petre, M. — *Cognitive Dimensions of Notations* (viscosity = resistance to local change; hidden dependencies; premature commitment). [Usability Analysis of Visual Programming Environments (PDF)](https://web.engr.oregonstate.edu/~burnett/CS589and584/CS589-papers/CogDimsPaper.pdf) · [CDs chapter, Blackwell & Green (PDF)](https://www.cl.cam.ac.uk/~afb21/publications/BlackwellGreen-CDsChapter.pdf) · [Wikipedia overview](https://en.wikipedia.org/wiki/Cognitive_dimensions_of_notations)
- Soloway & Ehrlich; Brooks; Détienne — plan/schema theories of program comprehension; top-down recognition; opportunistic processing. [Cognitive processes in program comprehension (PDF)](https://www.academia.edu/27587163/Cognitive_processes_in_program_comprehension) · [Expert Programming Knowledge: A Schema-Based Approach (PDF)](https://arxiv.org/pdf/cs/0702003)
- Norman, D. — *The Design of Everyday Things* (gulfs of execution and evaluation). (Standard reference; not web-verified in this session — flagged.)
- Code Compass / unfamiliar-codebase navigation challenges. [arXiv PDF](https://arxiv.org/pdf/2405.06271)
