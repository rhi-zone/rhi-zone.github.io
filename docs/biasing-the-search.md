# Biasing the Search

**See also:** [Oracles for Logic Bugs in Existing Code](/logic-bug-oracles) (the oracle-half companion — how to judge a run once you have it), [Finding Bugs in Existing Code](/finding-bugs-in-existing-code) (the predecessor arc — eliminations that cleared the ground for this question), [Deterministic Simulation Testing](/deterministic-simulation-testing), [The Decision Stream](/decision-stream).

The oracle essay covered the online half of the bug-finding problem: given that a run has executed, what relation-checks catch logic bugs cheaply and without a full spec? This essay covers the other half: **which runs do you generate?** A program's path space is exponential in its branch count, and unbounded once loops enter the picture. You can only ever execute a finite subset. The search *is* the choice of which subset to sample. This essay records where that question lands — including one hard negative result — derived in a single long design conversation. The reasoning was sound enough to record, but treat every "settled" here as settled by argument, not by experiment. None of it has been validated against real bugs.

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

## Status and what remains open (open / unvalidated)

None of the above has been validated against real bugs. The proof-of-concept spike validated the *mechanism* only: the LD_PRELOAD fault-injection seam loads correctly against rsync 3.2.7, the conservation-plus-exit-code oracle fires correctly on a deliberately corrupted control, and the naive search found zero violations in roughly 4,000 blind trials. The naive search failing is a result: it tells you the path space is not so bug-dense that uniform sampling suffices.

The open problems, in rough dependency order:

**(a) Path tracing infrastructure.** Computing path-novelty requires branch-level tracing — the actual sequence of branch decisions taken per run. LD_PRELOAD gives syscall interposition, not branch traces. Compile-time instrumentation (SanitizerCoverage, custom LLVM passes) or hardware trace (Intel PT via `perf record -e intel_pt`) would provide this, but both are heavier than the current seam and require either source access or platform-specific tooling.

**(b) Loop-granularity knob.** How to represent looping paths is unresolved. The tradeoffs are clear — collapsing loses iteration-count sensitivity; keeping counts explodes the space — but the right default is not settled.

**(c) The explore/exploit search itself.** Path-novelty base plus bounded user-tunable value portfolio is a design hypothesis, not a built system.

**(d) Does it find anything?** The honest terminal question. The oracle mechanism is validated. The search is not built. Whether the combination finds bugs in rsync — or in anything — is entirely unknown.

The honest status of this essay: a design hypothesis derived from reasoning, recorded because the reasoning was coherent enough to be worth preserving, but with zero empirical grounding. Treat the "settled" tags as "settled by argument" throughout. The only path from here to "settled by evidence" goes through building and running the search.

---

*Provenance note:* The conclusions above were derived in a single long design conversation. The reasoning was sound enough to record, but the session was also error-prone and over-confident in places. Read "settled" throughout as "settled by argument, not by experiment." The companion oracle essay ([Oracles for Logic Bugs in Existing Code](/logic-bug-oracles)) applies the same epistemic discipline to the oracle half and should be read alongside this one.
