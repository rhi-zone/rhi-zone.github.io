# Biasing the Search

**See also:** [Oracles for Logic Bugs in Existing Code](/logic-bug-oracles) (the oracle-half companion — how to judge a run once you have it), [Finding Bugs in Existing Code](/finding-bugs-in-existing-code) (the predecessor arc — eliminations that cleared the ground for this question), [Deterministic Simulation Testing](/deterministic-simulation-testing), [The Decision Stream](/decision-stream).

The oracle essay covered the online half of the bug-finding problem: given that a run has executed, what relation-checks catch logic bugs cheaply and without a full spec? This essay covers the other half: **which runs do you generate?** A program's path space is exponential in its branch count, and unbounded once loops enter the picture. You can only ever execute a finite subset. The search *is* the choice of which subset to sample. This essay records where that question lands — including one hard negative result — derived in a single long design conversation. The reasoning was sound enough to record, but treat every "settled" here as settled by argument, not by experiment — **except where the empirical-result section below explicitly upgrades a claim to settled-by-evidence.** One follow-up experiment has now run (the two-phase resume experiment, recorded at the end); it validates the region/shape part of the search hypothesis and, more importantly, relocates the open problem onto the oracle.

The concrete backdrop: a proof-of-concept (`~/git/pterror/rsync-blind-fault-oracle-spike`) ran the naive search — uniform random inputs, one injected fault per trial, zero feedback from prior runs — against rsync 3.2.7 across roughly 4,000 trials. It found zero violations. The oracle mechanism was validated (the seam fires correctly, the conservation and exit-code oracle work); the naive search strategy found nothing. So the search needs a non-uniform bias. The whole question is: **biased by what?**

## Redundancy has a near-objective measure: path-uniqueness (settled, with one caveat)

Two runs are redundant if and only if they take the same control-flow path — the same sequence of branch decisions, hash-comparable as a sequence. This is not a heuristic; it is the *exact* thing that edge-coverage is a lossy, order-dependent approximation of. Edge coverage is the flawed proxy; the path is the real object. The prior essay on finding bugs in existing code established why edge coverage fails: whether a given input contributes "new coverage" depends on the history of inputs before it, not on any intrinsic property of the input itself. Path-uniqueness does not have this defect. Two paths are either the same sequence or they are not.

Path-uniqueness is close to objective because it is self-referential: the question "is this run redundant with a prior run?" references only the runs themselves, through the program's own control-flow decisions, with no external goal and no chosen projection. The program's branching structure *is* the projection — not a guess imposed from outside. The measure is coarser than full execution state (many distinct inputs map to the same control-flow path, so the measure correctly collapses them as genuinely redundant), and it reaches gradient-free needles by *exploration* — by walking an untaken branch — rather than by gradient ascent toward a scalar score.

**(open / caveat)** The one residual knob is loop granularity: how do you represent a path through a loop? Collapsing back-edges to a single "loop taken" token is objective — loops are a CFG feature, not a guess — but it is blind to iteration-count bugs: a 2³¹-iteration overflow path and a 1-iteration path both map to "loop taken," and the oracle cannot distinguish them. Keeping full iteration counts catches those bugs but explodes the space and reintroduces a parameter choice — how many iterations to bound at. This is the one place a residual prior hides in the redundancy measure, and it is genuinely open.

## Value has no single objective measure — this is the key negative result (settled)

This is the night's hard-won conclusion, and it belongs to the user, not the assistant.

A scalar "value" for a run is a projection of that run toward the goal of finding bugs. "Toward what" is inherently a *choice*. Every candidate value measure that came up in the conversation — oracle-proximity (how close did this run come to tripping the oracle?), fragility or sensitivity (how much does a small input perturbation change the path?), compression or algorithmic information (how surprising is this path, relative to a model?), structural priors (does this path exercise known-risky code patterns?) — had a residual knob that did not die: a smoothing prior, a quotient, a threshold, a reference model. The knob is not an implementation detail. **The knob IS the irreducible subjectivity.** A scalar measure is a choice of what counts as valuable, and "objective" and "single" cannot coexist for value — it is a category error to demand both at once.

The corollary is direct: bug-value specifically cannot be computed *prospectively*. It would have to predict the location of the very thing you are searching for. The only *objective* value is *retrospective* — the oracle fired, which is to say the bug was found — and that signal is sparse, terminal, and useless for steering a search before it fires. Stop hunting for the one true value measure. There is not one, and there cannot be one.

## The bias is therefore a plural, openly-chosen portfolio, owned by the user (settled by reasoning)

Irreducible subjectivity has to live somewhere. The honest home is the user's explicit hand. Baking it into a tool-internal "objective measure" is the actual poisoning: it launders a choice into fake objectivity and hides the prior from the person whose domain knowledge should be informing it. User-tuning of the value portfolio is not a violation of "don't bias the search" — it is its *fulfillment*. The choice is made openly, by the domain expert, revisably, with full awareness that it is a choice.

This directly mirrors the Antithesis division of labor recorded in the oracle essay: the tool owns the objective plumbing (the fault-injection seam, the relation-checker, the path-tracer); the human writes the subjective guidance (which relations to assert, which regions to weight). The same boundary applies to search: the tool owns the objective novelty base; the human owns the subjective up-weights.

## User guidance must be a bounded up-weight, never exclusive (settled — the synthesis)

Human guidance skews toward obvious areas. Bugs hide in the non-obvious. If user steering becomes the search, it reintroduces exactly the "chosen target" problem that the earlier eliminations (in the finding-bugs essay) discarded: you are sampling from the failure modes you already imagined, going blind to the rest. The whole point of the search was to reach what you did not already know to look for.

The synthesis has two components, both necessary:

**Explore:** an objective, full-support, bug-agnostic novelty base built on path-novelty. Its job is coverage insurance: it pushes independently into regions a human would never name, without any goal other than "I have not been here before." This component has full support over the path space — every region remains reachable — and its steering signal is entirely intrinsic.

**Exploit:** the user's subjective portfolio, applied as a bounded up-weight over the explore distribution. The user can tilt the distribution toward regions of interest — code that handles retries, code that touches symlinks, code that runs under fault injection — but may never zero any region out. The never-zero rule is the hinge that makes human bias *safe* rather than poisonous. A region that has zero probability assigned can never be reached regardless of how many trials run. Keeping full support means the finite trial budget can still, in principle, reach the non-obvious.

One implementation note: a *fixed* mixing coefficient between explore and exploit is itself a smuggled constant, a prior in disguise. The real constraint is not a particular ratio but a structural one: keep enough mass on the novelty base that the finite budget still reaches regions the user did not name. What that ratio should be is itself a residual knob — one the user arguably owns, tuned to their confidence in their own domain knowledge.

## Empirical update: the two-phase resume experiment (settled by evidence)

This section is the first piece of this essay backed by an experiment rather than by argument. It was cheap by design — no branch tracing, no path-novelty machinery — built only to test one hypothesis: that the naive search found zero because it searched the wrong *region*, not because rsync is bug-free under fault.

**The hypothesis.** rsync's default temp-file-then-rename atomicity makes a single injected fault either abort cleanly (non-zero exit) or complete correctly — so the single-fault search across ~4,000 trials necessarily found zero. The interesting behaviors live on the **non-atomic** paths (`--inplace` / `--partial` / `--append` / `-u`/`--update`), which a single fault on the atomic path cannot reach. Crucially, those paths are reachable **without branch tracing** — by a two-phase harness and a class-level flag bias alone.

**The harness.** Phase 1 interrupts a transfer mid-write with one fault (via the existing LD_PRELOAD seam, aimed strictly inside a write window; `eio`/`enospc`/`eintr`/`shortwrite`; `exit`/`_exit` deliberately excluded because a hard kill orphans a temp file that no realistic interruption produces). Phase 2 re-runs rsync with the same flags and **no fault** — the clean resume a user would do. The oracle conditions on the phase-2 exit code against `Dref`, an uninterrupted clean run with the same flags. Flags are biased toward the resume/in-place/update *class* (base `-a`/`-rt`/`-rlptD` plus 1–4 from a resume pool). A greedy reducer minimizes each tripping trial.

**Trust check (the harness is not blind).** A hand-staged control (case D) builds a truncated destination with mtime newer than source, runs a real `-a -u --inplace --partial` resume, and confirms the oracle **fires** `SILENT_CORRUPTION_OR_OMISSION`. It fires correctly; the earlier controls still pass. So a null result here would have been trustworthy — and a positive result is too.

**Result.** 165 violations across 3,000 trials (3 seeds × 1,000: 54 / 60 / 51), all `SILENT_CORRUPTION_OR_OMISSION`, ~97% deterministically reproducible. Greedy reduction collapses nearly every violation to a flag-set that **requires `-u`/`--update`** (seed1 52/52, seed3 50/50, seed2 55/57 retain the update flag). The discrepancy reproduces with no fault library at all — pure rsync plus a real SIGINT.

**What this validates, and what it does NOT.** Two findings, kept separate:

1. **The region/shape hypothesis is validated (settled by evidence).** Aiming the search at the non-atomic paths immediately and repeatedly surfaced reproducible silent data-omission, against zero for the blind single-fault search. The blind reduce-pipeline independently isolated the load-bearing flag. The naive search's zero was a *region* miss, exactly as hypothesized — and the right region was reached by a cheap class-level bias, **without** any path-novelty or branch-tracing infrastructure.

2. **The oracle conflates a defect with a documented footgun (the real new finding).** The discrepancies are NOT a hidden rsync logic defect. They are the documented `--update` footgun: an interrupted transfer leaves a partial whose mtime is newer than the older source; a same-flags `-u` resume then correctly applies "skip files newer on the receiver," exits 0, and silently leaves the file truncated. rsync does exactly what `--update` specifies. So the clean-run-reference oracle **conflates true defects with documented-semantics footguns** — it cannot tell "lost data due to a logic bug" from "lost data because `-u` did what it says." This is the concrete, empirical instance of the oracle essay's ceiling — a clean-run relation that is *too weak*, blind to behaviors semantically consistent with the contract but wrong-for-the-user ([Oracles for Logic Bugs](/logic-bug-oracles), the "relation too weak" caveat; note that essay's own §3 lists this `-u --inplace --partial` resume scenario as a candidate bug — this experiment shows the clean-run oracle alone cannot earn that label). **Nothing here is a confirmed rsync bug**, and none of it should be reported as one.

**Where this relocates the bottleneck.** Because the search demonstrably reaches the logic, the next cheap step is **oracle refinement** — a second oracle gate that classifies `-u`/`--update`-driven skips as expected behavior, so that any *remaining* violation is a genuine candidate defect. It is emphatically **not** the heavy branch-level path-tracing infrastructure (Intel PT, compile-time instrumentation) — that work remains unbuilt and is now *further deprioritized*, because a cheap class-level bias already reached the region path-novelty was meant to find.

## Status and what remains open (mixed: one item now settled-by-evidence)

The two-phase experiment above upgrades the region/shape hypothesis to settled-by-evidence and demotes the path-tracing line of work. The rest of this essay remains settled-by-argument only. The proof-of-concept spike validated the *mechanism* (the LD_PRELOAD seam loads against rsync 3.2.7; the conservation-plus-exit-code oracle fires on a deliberately corrupted control) and produced the naive search's zero violations across ~4,000 blind trials — telling you the atomic-path space is not so bug-dense that uniform single-fault sampling suffices.

The open problems, in rough dependency order:

**(a) Path tracing infrastructure (now further deprioritized).** Computing path-novelty requires branch-level tracing — the actual sequence of branch decisions taken per run. LD_PRELOAD gives syscall interposition, not branch traces. Compile-time instrumentation (SanitizerCoverage, custom LLVM passes) or hardware trace (Intel PT via `perf record -e intel_pt`) would provide this, but both are heavier than the current seam and require either source access or platform-specific tooling. The two-phase result is direct evidence *against* prioritizing this: a cheap class-level flag bias reached the non-atomic logic region with no path tracing at all. This stays unbuilt and unjustified by current evidence.

**(b) Loop-granularity knob.** How to represent looping paths is unresolved. The tradeoffs are clear — collapsing loses iteration-count sensitivity; keeping counts explodes the space — but the right default is not settled.

**(c) The explore/exploit search itself.** Path-novelty base plus bounded user-tunable value portfolio is a design hypothesis, not a built system.

**(d) Does it find anything? (partially answered).** The naive single-fault search found nothing; the cheap class-biased two-phase search found reproducible discrepancies in the non-atomic region. So the search *can* be steered to surface silent-omission behavior. But what it surfaced is a documented footgun, not a defect — so the honest terminal question is now sharper: **can the oracle, once gated against documented footguns, still surface a true logic defect?** That depends on the new top open problem:

**(e) The footgun-vs-defect oracle gate (new top priority).** A second oracle gate that distinguishes documented-semantics footguns (e.g. `-u`-driven resume skips) from true silent-corruption defects, so a violation can be reported as a candidate rsync bug. This is the cheap next step and the current bottleneck — ahead of (a)–(c).

The honest status of this essay: a design hypothesis derived from reasoning, with one part now grounded by experiment (the region/shape hypothesis) and the rest still settled-by-argument. The cheap two-phase experiment moved the frontier from "build the search" to "refine the oracle"; the path from the remaining "settled-by-argument" claims to "settled-by-evidence" still goes through building and running.

---

*Provenance note:* The conclusions above were derived in a single long design conversation. The reasoning was sound enough to record, but the session was also error-prone and over-confident in places. Read "settled" throughout as "settled by argument, not by experiment." The companion oracle essay ([Oracles for Logic Bugs in Existing Code](/logic-bug-oracles)) applies the same epistemic discipline to the oracle half and should be read alongside this one.
