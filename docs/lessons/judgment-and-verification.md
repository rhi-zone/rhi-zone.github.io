# Judgment and verification

Distilled from hardening and audit work where the cost of a wrong belief was high and most claims were non-obvious. The lessons below are the durable, reusable parts.

---

## Calibrate skepticism to stakes × uncertainty

A uniform high suspicion dial is not rigor — it is a cost. Spend verification budget where a wrong belief is *both* costly *and* the claim is non-obvious. "Is this NULL-deref actually reachable?" earns careful end-to-end confirmation. "Is the cloned repo the one we're working on?" is answered by one operationally-obvious check; demanding cryptographic proof of a settled fact burns time without changing any conclusion.

Over-hedging facts that are already established is a defect of the same family as accepting an unverified claim — both misallocate attention. Verify hard where it matters; stop verifying once the question is actually answered.

And a conclusion is as dangerous as a fact. A glib "lesson" or summary is a claim too, and an over-skeptical (or over-confident) bias leaks straight into the conclusions you draw from the work. Review your conclusions with the same skepticism you applied to the findings.

## Pick the right reference point for "is this true *now*?"

"Was this always here?" and "Does this exist today?" are different questions with different reference points. Comparing a current-state question against a stale snapshot or last release gives the wrong verdict. To decide whether something is a *current* problem, compare against current state / HEAD, not the last tag. Choosing the reference point is part of getting the question right.

## Carry confidence levels through delegation

A delegated agent's (or any source's) interpretation of evidence is a hypothesis, not the evidence itself. Do not relay a mechanistic claim ("this field was spoofed", "this path is unreachable") as established fact just because a source asserted it. Forward the underlying evidence and attach your own assessment. Distinguish *verified* from *asserted* every time a claim crosses a boundary.

## Durable apparatus ≠ single-change bloat

A net that catches a whole *class* of faults and runs locally is real, lasting value — it keeps paying out long after the change that motivated it. Padding a single change with tests and scaffolding to *look* thorough is not; it is bloat. The discriminant is class-catching reusability, not volume.

Tooling never substitutes for getting the core fix or check correct. A check built on the wrong discriminant fails even when it is well-engineered. Get the core right first; the apparatus is the bonus, not the alibi.

## Metadata isn't merit

The existence or status of an artifact proves nothing about its quality. "A PR exists / closes the issue / is merged / has this author" carries no weight in a low-trust context — especially one where the surrounding source itself can't be trusted. The remedy is not to distrust everything; it is to judge the artifact directly: read the change in context, trace the callers, record the verdict with concrete reasons.

## Confirm the target before writing into a structured system

Before writing into a structured system whose conventions you don't fully understand — a config, a registry, a navigation tree, a schema — confirm where the new content actually belongs. A plausible-looking slot is not a confirmed-correct one. Match the existing pattern exactly rather than inventing a parallel one.

## The honest negative is a real result

Under an "assume X is broken" prior, the pull is to manufacture findings to justify the effort. Resisting that pull is itself rigor. A deep review that comes back mostly clean is a result: document the coverage and the clean verdicts plainly. Validating that your own apparatus catches a fault you deliberately introduced is a legitimate positive on its own terms — you don't need a pile of marginal findings to show the work was worth doing.

## Orchestration: cross-repo parallel work needs explicit per-repo isolation

A generic "isolate the workspace" feature isolates the session's own repo, not the other repositories you're operating on. For parallel work that touches a separate repository, create explicit per-repo isolation (e.g. a dedicated git worktree per branch) rather than assuming the generic mechanism covered it. Background fan-out works well *with* explicit per-repo worktrees in place.
