# Hypothesis register — falsifiability first

> **PRE-REGISTRATION — CONTEXT FENCE.** This file is a PRE-REGISTRATION (committed
> a633f8e, 2026-07-03). It must **NEVER** be included in the context of any extraction,
> skim, pre-filter, or induction agent — hypotheses handed to miners prime the theory
> into the findings (confirmation harvesting). It is read only by (a) the post-hoc
> matching stage operating on the verified ledger, and (b) the human arbiter.

Each hypothesis states: the claim, what evidence would support it, its prediction in the
record (what the verified evidence ledger should look like if true), and an explicit
COUNTEREXAMPLE HUNT — what would refute it. The post-hoc matching stage must hunt
counterexamples with the same energy as support; a hypothesis nobody tried to break is
not evidence-grounded. `hypothesis_id` in mapping-table records (see schema.md)
references the H-numbers here.

## H1 — Delegability is a property of decisions, not projects

**Statement.** Agent-built projects succeed in derivational/oracle-rich regions and fail
at taste-laden semantic kernels *within the same codebase*; "can the agent build project
X" is the wrong granularity.

**Supporting evidence.** Records showing, inside one project, clean delegated success on
derivational work alongside failure/relitigating at the semantic kernel.

**Prediction in the record.** Failure records cluster by decision type, not by project:
the same projects appear in both success and failure inventories, split along the
derivational/taste axis.

**COUNTEREXAMPLE HUNT.** Whole-project failures in oracle-rich domains; smooth delegated
success at taste-laden decisions.

## H2 — Wrong-peak prior

**Statement.** Where a bespoke design sits adjacent to a strong training-data convention,
agent drift is systematic toward the convention, not random.

**Supporting evidence.** Repeated same-direction corrections: the same deviation toward
the same conventional form, corrected multiple times across sessions.

**Prediction in the record.** Correction events for convention-adjacent designs share a
direction (toward the convention); a direction histogram is skewed, not uniform.

**COUNTEREXAMPLE HUNT.** Random-direction drift on convention-adjacent designs;
convention-adjacent domains showing no drift at all.

## H3 — Oracle distance

**Statement.** Failure severity and monkeypatching correlate with the distance/granularity
of the correctness check; distant or aggregate oracles (e.g. end-to-end error counts)
produce proxy hill-climbing.

**Supporting evidence.** Records pairing an aggregate/distant oracle with churn,
proxy-metric chasing, or monkeypatch accumulation; records pairing tight local oracles
with clean convergence.

**Prediction in the record.** Severity and patch-churn metrics (stage 4) correlate with
an oracle-distance classification of each incident's correctness check.

**COUNTEREXAMPLE HUNT.** Tight-oracle projects that still oscillated; distant-oracle
projects that converged cleanly.

## H4 — Enforcement medium

**Statement.** Prose contracts (docs, instructions) fail to hold against a wrong-peak
prior; contracts embedded in names, implementing-language types, and failing tests hold.
**Priming corollary:** a name holds its contract only if its dominant reading under LOCAL
context priming is the intended one — e.g. an identifier that reads correctly in
application code but flips meaning inside an inference engine.

**Supporting evidence.** The same invariant violated while documented as prose, then
holding after being encoded in a name/type/test; violations of correctly-named
identifiers specifically in contexts that re-prime the name's reading.

**Prediction in the record.** Violation records for a given invariant thin out or stop
after its encoding medium hardens (prose → name/type/test); residual name-encoded
violations concentrate where local context flips the name's dominant reading.

**COUNTEREXAMPLE HUNT.** Written invariants that held for long periods as prose;
renames/type-encodings that failed to stop drift.

## H5 — Unsettled kernels have a detectable pre-disaster signature

**Statement.** Before a design disaster, the record shows a signature: the same semantic
point relitigated/overridden across sessions, oscillation between two designs,
error-count-driven churn.

**Supporting evidence.** Disasters whose preceding sessions contain relitigating,
oscillation, or count-driven churn on the point that later failed.

**Prediction in the record.** Timeline aggregation (stage 4) shows signature events
preceding disaster events on the same semantic point; signature density predicts
incident severity.

**COUNTEREXAMPLE HUNT.** Disasters with no such preceding signature; signatures that
never led to trouble.

## H6 — Coordination failures are a distinct class from design failures

**Statement.** Orchestrator drift over decomposed shared mutable state is its own failure
class and would occur even with settled design.

**Supporting evidence.** Coordination failures in episodes where the design was settled
and uncontested; design failures in single-agent, no-decomposition episodes.

**Prediction in the record.** The two classes separate cleanly when records are tagged
for design-settledness and decomposition: coordination failures appear across the
settledness axis, design failures across the decomposition axis.

**COUNTEREXAMPLE HUNT.** Cases where an apparent coordination failure was actually caused
by unsettled design, or an apparent design failure by coordination.
